"""Step 2: Prioritize and schedule tasks."""

import json

from app.llm.client import PLAN_PROMPT, call_llm
from app.models import PlanRequest, PlanResponse, Task


async def plan_tasks(request: PlanRequest) -> PlanResponse:
    """Take a list of tasks and return them prioritized with time estimates."""

    tasks_json = json.dumps(
        [t.model_dump() for t in request.tasks],
        indent=2,
    )
    user_message = (
        f"Here are my tasks for today:\n{tasks_json}\n\n"
        f"I have {request.available_hours} hours available."
    )

    result = await call_llm(PLAN_PROMPT, user_message)

    planned = [Task(**t) for t in result.get("planned_tasks", [])]

    return PlanResponse(
        planned_tasks=planned,
        total_estimated_hours=result.get("total_estimated_hours", 0),
        suggested_order=result.get("suggested_order", []),
    )
