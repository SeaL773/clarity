"""Audio transcription using OpenAI Whisper."""

from __future__ import annotations

import os
from pathlib import Path
from tempfile import NamedTemporaryFile

from fastapi import UploadFile
from openai import AsyncOpenAI


async def transcribe_audio(file: UploadFile) -> str:
    """Transcribe an uploaded audio file with Whisper."""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is not set.")

    if not file.filename:
        raise ValueError("Audio file is required.")

    suffix = Path(file.filename).suffix or ".m4a"
    content = await file.read()
    if not content:
        raise ValueError("Uploaded audio file is empty.")

    client = AsyncOpenAI(api_key=api_key)

    with NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
        temp_file.write(content)
        temp_path = Path(temp_file.name)

    try:
        with temp_path.open("rb") as audio_file:
            transcription = await client.audio.transcriptions.create(
                file=audio_file,
                model="whisper-1",
                language="en",
            )

        text = (transcription.text or "").strip()
        if not text:
            raise RuntimeError("Whisper returned empty text.")
        return text
    finally:
        temp_path.unlink(missing_ok=True)
