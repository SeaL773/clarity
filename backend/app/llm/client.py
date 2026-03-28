"""LLM client wrapper — supports AWS Bedrock (primary) and OpenAI (fallback)."""

import json
import os
from pathlib import Path

import boto3
from openai import AsyncOpenAI

PROMPTS_DIR = Path(__file__).parent.parent / "prompts"


def _load_prompt(name: str) -> str:
    return (PROMPTS_DIR / f"{name}.txt").read_text(encoding="utf-8")


# Pre-load prompts
PARSE_PROMPT = _load_prompt("parse")
PLAN_PROMPT = _load_prompt("plan")
SUMMARIZE_PROMPT = _load_prompt("summarize")


async def call_llm(system_prompt: str, user_message: str) -> dict:
    """Call LLM and return parsed JSON. Tries Bedrock first, falls back to OpenAI."""

    # Try AWS Bedrock first
    if os.getenv("AWS_ACCESS_KEY_ID"):
        try:
            return await _call_bedrock(system_prompt, user_message)
        except Exception as e:
            print(f"[LLM] Bedrock failed: {e}, trying OpenAI fallback...")

    # Fallback to OpenAI
    if os.getenv("OPENAI_API_KEY"):
        return await _call_openai(system_prompt, user_message)

    raise RuntimeError("No LLM provider configured. Set AWS or OPENAI credentials in .env")


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
