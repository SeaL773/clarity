"""LLM client wrapper — supports Kiro (primary), AWS Bedrock, and OpenAI (fallback)."""

import json
import os
import uuid
from pathlib import Path

import boto3
import httpx
from openai import AsyncOpenAI

PROMPTS_DIR = Path(__file__).parent.parent / "prompts"


def _load_prompt(name: str) -> str:
    return (PROMPTS_DIR / f"{name}.txt").read_text(encoding="utf-8")


# Pre-load prompts
PARSE_PROMPT = _load_prompt("parse")
PLAN_PROMPT = _load_prompt("plan")
SUMMARIZE_PROMPT = _load_prompt("summarize")

# Kiro token path
KIRO_TOKEN_PATH = Path.home() / ".aws" / "sso" / "cache" / "kiro-auth-token.json"

# Kiro API config
KIRO_ENDPOINT = "https://codewhisperer.us-east-1.amazonaws.com/generateAssistantResponse"
KIRO_MODEL_ID = "claude-haiku-4.5"
KIRO_VERSION = "0.6.18"


def _get_kiro_token() -> str | None:
    """Read Kiro access token from cache file (re-reads every call)."""
    if not KIRO_TOKEN_PATH.exists():
        return None
    try:
        data = json.loads(KIRO_TOKEN_PATH.read_text(encoding="utf-8"))
        token = data.get("accessToken")
        if not token:
            return None
        # Warn if expired (but still return — Kiro IDE may have refreshed the file)
        expires_at = data.get("expiresAt", "")
        if expires_at:
            from datetime import datetime, timezone
            expiry = datetime.fromisoformat(expires_at.replace("Z", "+00:00"))
            now = datetime.now(timezone.utc)
            remaining = (expiry - now).total_seconds()
            if remaining < 0:
                print(f"[LLM] Warning: Kiro token looks expired. Open Kiro IDE to refresh.")
            elif remaining < 300:
                print(f"[LLM] Warning: Kiro token expires in {int(remaining)}s")
        return token
    except Exception as e:
        print(f"[LLM] Error reading Kiro token: {e}")
        return None


def _get_kiro_profile_arn() -> str | None:
    """Read Kiro profile ARN from profile.json."""
    profile_path = Path(os.environ.get("APPDATA", "")) / "Kiro" / "User" / "globalStorage" / "kiro.kiroagent" / "profile.json"
    if not profile_path.exists():
        return None
    try:
        data = json.loads(profile_path.read_text(encoding="utf-8"))
        return data.get("arn")
    except Exception:
        return None


def _build_kiro_payload(system_prompt: str, user_message: str) -> dict:
    """Build Kiro API payload in the conversationState format."""
    # Combine system prompt and user message
    combined_content = f"{system_prompt}\n\n---\n\n{user_message}\n\nReturn ONLY valid JSON. No markdown, no explanation."

    payload = {
        "conversationState": {
            "chatTriggerType": "MANUAL",
            "conversationId": str(uuid.uuid4()),
            "currentMessage": {
                "userInputMessage": {
                    "content": combined_content,
                    "modelId": KIRO_MODEL_ID,
                    "origin": "AI_EDITOR",
                }
            },
        }
    }

    profile_arn = _get_kiro_profile_arn()
    if profile_arn:
        payload["profileArn"] = profile_arn

    return payload


def _get_kiro_headers(token: str) -> dict:
    """Build Kiro API request headers."""
    return {
        "Content-Type": "application/json",
        "Accept": "*/*",
        "X-Amz-Target": "AmazonCodeWhispererStreamingService.GenerateAssistantResponse",
        "User-Agent": f"aws-sdk-js/1.0.18 ua/2.1 os/windows lang/js md/nodejs#20.16.0 api/codewhispererstreaming#1.0.18 m/E KiroIDE-{KIRO_VERSION}",
        "X-Amz-User-Agent": f"aws-sdk-js/1.0.18 KiroIDE-{KIRO_VERSION}",
        "x-amzn-kiro-agent-mode": "spec",
        "x-amzn-codewhisperer-optout": "true",
        "Amz-Sdk-Request": "attempt=1; max=3",
        "Amz-Sdk-Invocation-Id": str(uuid.uuid4()),
        "Authorization": f"Bearer {token}",
    }


def _parse_event_stream(raw_bytes: bytes) -> str:
    """Parse AWS event stream response to extract assistant text.
    
    The response is in AWS binary event stream format.
    We look for assistantResponseEvent content in the raw bytes.
    """
    text_parts = []
    raw_text = raw_bytes.decode("utf-8", errors="replace")

    # The event stream contains JSON fragments with assistantResponseEvent
    # Try to find all JSON objects in the stream
    import re
    # Look for content fields in the response
    for match in re.finditer(r'"content"\s*:\s*"((?:[^"\\]|\\.)*)"', raw_text):
        content = match.group(1)
        # Unescape JSON string
        try:
            content = json.loads(f'"{content}"')
        except Exception:
            pass
        if content and content not in ("understood", "Continue", "Hello"):
            text_parts.append(content)

    return "".join(text_parts)


async def call_llm(system_prompt: str, user_message: str) -> dict:
    """Call LLM and return parsed JSON. Tries Anthropic first, then Kiro, Bedrock, OpenAI."""

    # Try Anthropic direct API first
    if os.getenv("ANTHROPIC_API_KEY"):
        try:
            return await _call_anthropic(system_prompt, user_message)
        except Exception as e:
            print(f"[LLM] Anthropic failed: {e}, trying next provider...")

    # Try Kiro (uses Kiro Credits)
    kiro_token = _get_kiro_token()
    if kiro_token:
        try:
            return await _call_kiro(system_prompt, user_message, kiro_token)
        except Exception as e:
            print(f"[LLM] Kiro failed: {e}, trying next provider...")

    # Try AWS Bedrock
    if os.getenv("AWS_ACCESS_KEY_ID"):
        try:
            return await _call_bedrock(system_prompt, user_message)
        except Exception as e:
            print(f"[LLM] Bedrock failed: {e}, trying OpenAI fallback...")

    # Fallback to OpenAI
    if os.getenv("OPENAI_API_KEY"):
        return await _call_openai(system_prompt, user_message)

    raise RuntimeError("No LLM provider configured.")


async def _call_anthropic(system_prompt: str, user_message: str) -> dict:
    """Call Anthropic API directly (Claude Haiku)."""
    api_key = os.getenv("ANTHROPIC_API_KEY")
    model = os.getenv("ANTHROPIC_MODEL", "claude-haiku-4-20250414")

    print(f"[LLM] Calling Anthropic API (model: {model})...")

    async with httpx.AsyncClient(timeout=120.0) as client:
        response = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": api_key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": model,
                "max_tokens": 4096,
                "system": system_prompt,
                "messages": [
                    {"role": "user", "content": user_message}
                ],
            },
        )

    if response.status_code != 200:
        raise RuntimeError(f"Anthropic API error ({response.status_code}): {response.text[:200]}")

    result = response.json()
    text = result["content"][0]["text"]
    print(f"[LLM] Anthropic response length: {len(text)} chars")

    # Extract JSON
    json_start = text.find("{")
    json_end = text.rfind("}") + 1
    if json_start >= 0 and json_end > json_start:
        return json.loads(text[json_start:json_end])

    raise RuntimeError(f"Could not parse JSON from Anthropic response: {text[:200]}")


async def _call_kiro(system_prompt: str, user_message: str, token: str) -> dict:
    """Call Kiro API (CodeWhisperer) using Kiro Credits."""
    import asyncio
    import httpx

    payload = _build_kiro_payload(system_prompt, user_message)
    headers = _get_kiro_headers(token)

    print(f"[LLM] Calling Kiro API (model: {KIRO_MODEL_ID})...")

    async with httpx.AsyncClient(timeout=120.0) as client:
        response = await client.post(
            KIRO_ENDPOINT,
            headers=headers,
            json=payload,
        )

    if response.status_code == 429:
        raise RuntimeError("Kiro quota exhausted (429)")
    if response.status_code in (401, 403):
        raise RuntimeError(f"Kiro auth error ({response.status_code}): {response.text[:200]}")
    if response.status_code != 200:
        raise RuntimeError(f"Kiro API error ({response.status_code}): {response.text[:200]}")

    # Parse event stream response
    text = _parse_event_stream(response.content)

    if not text:
        raise RuntimeError("Kiro returned empty response")

    print(f"[LLM] Kiro response length: {len(text)} chars")

    # Extract JSON from response (may have extra text around it)
    # Find the first { and last } to extract JSON
    json_start = text.find("{")
    json_end = text.rfind("}") + 1
    if json_start >= 0 and json_end > json_start:
        json_str = text[json_start:json_end]
        return json.loads(json_str)

    raise RuntimeError(f"Could not parse JSON from Kiro response: {text[:200]}")


async def _call_bedrock(system_prompt: str, user_message: str) -> dict:
    """Call AWS Bedrock (Claude)."""
    client = boto3.client(
        "bedrock-runtime",
        region_name=os.getenv("AWS_REGION", "us-east-1"),
    )
    model_id = os.getenv("BEDROCK_MODEL_ID", "anthropic.claude-3-5-sonnet-20241022-v2:0")

    body = json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 4096,
        "system": system_prompt,
        "messages": [
            {"role": "user", "content": user_message}
        ],
    })

    # boto3 is sync, run in thread
    import asyncio
    loop = asyncio.get_event_loop()
    response = await loop.run_in_executor(
        None,
        lambda: client.invoke_model(
            modelId=model_id,
            body=body,
            contentType="application/json",
            accept="application/json",
        )
    )

    result = json.loads(response["body"].read())
    text = result["content"][0]["text"]
    return json.loads(text)


async def _call_openai(system_prompt: str, user_message: str) -> dict:
    """Call OpenAI (fallback)."""
    client = AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    response = await client.chat.completions.create(
        model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_message},
        ],
        response_format={"type": "json_object"},
        max_tokens=4096,
        temperature=0.3,
    )

    text = response.choices[0].message.content
    return json.loads(text)
