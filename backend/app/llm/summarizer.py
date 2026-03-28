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

    # Calculate real counts from actual task data, don't trust AI numbers
    completed = sum(1 for t in request.tasks if t.completed)
    total = len(request.tasks)
    rate = completed / total if total > 0 else 0.0

    return SummarizeResponse(
        summary=result.get("summary", ""),
        completed_count=completed,
        total_count=total,
        completion_rate=rate,
        encouragement=result.get("encouragement", ""),
        tomorrow_focus=result.get("tomorrow_focus", []),
    )
