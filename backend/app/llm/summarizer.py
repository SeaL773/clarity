"""Step 3: Generate daily recap and encouragement."""

import json

from app.llm.client import SUMMARIZE_PROMPT, call_llm
from app.models import SummarizeRequest, SummarizeResponse


async def summarize_day(request: SummarizeRequest) -> SummarizeResponse:
    """Generate an encouraging daily summary from task completion data."""

    tasks_json = json.dumps(
        [t.model_dump() for t in request.tasks],
        indent=2,
    )
    user_message = (
        f"Date: {request.date}\n\n"
        f"Here are my tasks and their completion status:\n{tasks_json}"
    )

    result = await call_llm(SUMMARIZE_PROMPT, user_message)

    return SummarizeResponse(
        summary=result.get("summary", ""),
        completed_count=result.get("completed_count", 0),
        total_count=result.get("total_count", 0),
        completion_rate=result.get("completion_rate", 0.0),
        encouragement=result.get("encouragement", ""),
        tomorrow_focus=result.get("tomorrow_focus", []),
    )
