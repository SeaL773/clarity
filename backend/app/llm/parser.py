"""Step 1: Parse brain dump text into structured tasks."""

from app.llm.client import PARSE_PROMPT, call_llm
from app.models import ParseRequest, ParseResponse, Task


async def parse_brain_dump(request: ParseRequest) -> ParseResponse:
    """Take raw text input and extract structured tasks via LLM."""

    user_message = request.text
    if request.context:
        user_message = f"Context about me: {request.context}\n\nMy brain dump:\n{request.text}"

    result = await call_llm(PARSE_PROMPT, user_message)

    tasks = [Task(**t) for t in result.get("tasks", [])]

    return ParseResponse(
        tasks=tasks,
        original_text=request.text,
        insights=result.get("insights"),
    )
