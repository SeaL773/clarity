"""Clarity API — AI-Powered Smart Todo List."""

from __future__ import annotations

import time
from contextlib import asynccontextmanager
from datetime import date, datetime
from typing import List

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware

from app.database import get_tasks, init_db, save_tasks, update_task
from app.llm.parser import parse_brain_dump
from app.llm.planner import plan_tasks
from app.llm.summarizer import summarize_day
from app.models import (
    ParseRequest,
    ParseResponse,
    PlanRequest,
    PlanResponse,
    SummarizeRequest,
    SummarizeResponse,
    Task,
)

load_dotenv()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize DB on startup."""
    await init_db()
    yield


app = FastAPI(
    title="Clarity API",
    description="AI-Powered Smart Todo List — turn brain dumps into actionable plans",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS — allow Flutter app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ──────────────────────────────────────────
# Rate Limiting (simple in-memory)
# ──────────────────────────────────────────

_rate_limit: dict[str, list[float]] = {}
RATE_LIMIT_MAX = 20  # requests per window
RATE_LIMIT_WINDOW = 60  # seconds


@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    if request.url.path.startswith("/api/") and request.method == "POST":
        client_ip = request.client.host if request.client else "unknown"
        now = time.time()
        timestamps = _rate_limit.get(client_ip, [])
        timestamps = [t for t in timestamps if now - t < RATE_LIMIT_WINDOW]
        if len(timestamps) >= RATE_LIMIT_MAX:
            raise HTTPException(status_code=429, detail="Too many requests. Please slow down.")
        timestamps.append(now)
        _rate_limit[client_ip] = timestamps
    return await call_next(request)


def _validate_date(task_date: str) -> str:
    """Validate date string is YYYY-MM-DD format."""
    try:
        datetime.strptime(task_date, "%Y-%m-%d")
        return task_date
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")


# ──────────────────────────────────────────
# Health Check
# ──────────────────────────────────────────

@app.get("/api/health")
async def health():
    return {"status": "ok", "service": "clarity"}


# ──────────────────────────────────────────
# AI Pipeline Endpoints
# ──────────────────────────────────────────

@app.post("/api/parse", response_model=ParseResponse)
async def api_parse(request: ParseRequest):
    """Step 1: Parse brain dump text into structured tasks."""
    try:
        return await parse_brain_dump(request)
    except Exception as e:
        print(f"[API] Parse error: {e}")
        raise HTTPException(status_code=500, detail="Failed to process your input. Please try again.")


@app.post("/api/plan", response_model=PlanResponse)
async def api_plan(request: PlanRequest):
    """Step 2: Prioritize tasks and create a schedule."""
    try:
        return await plan_tasks(request)
    except Exception as e:
        print(f"[API] Plan error: {e}")
        raise HTTPException(status_code=500, detail="Failed to prioritize tasks. Please try again.")


@app.post("/api/summarize", response_model=SummarizeResponse)
async def api_summarize(request: SummarizeRequest):
    """Step 3: Generate daily recap with encouragement."""
    try:
        return await summarize_day(request)
    except Exception as e:
        print(f"[API] Summarize error: {e}")
        raise HTTPException(status_code=500, detail="Failed to generate recap. Please try again.")


# ──────────────────────────────────────────
# Task CRUD Endpoints
# ──────────────────────────────────────────

@app.get("/api/tasks/{task_date}")
async def api_get_tasks(task_date: str):
    """Get all tasks for a date (YYYY-MM-DD)."""
    _validate_date(task_date)
    tasks = await get_tasks(task_date)
    return {"date": task_date, "tasks": tasks}


@app.post("/api/tasks/{task_date}")
async def api_save_tasks(task_date: str, tasks: List[Task]):
    """Save/update tasks for a date."""
    _validate_date(task_date)
    await save_tasks(task_date, [t.model_dump() for t in tasks])
    return {"status": "saved", "date": task_date, "count": len(tasks)}


@app.delete("/api/tasks/{task_date}")
async def api_delete_tasks(task_date: str):
    """Delete all tasks for a date."""
    _validate_date(task_date)
    await save_tasks(task_date, [])
    return {"status": "deleted", "date": task_date}


@app.patch("/api/tasks/{task_id}")
async def api_update_task(task_id: str, task: Task):
    """Update a single task (e.g., mark as completed)."""
    await update_task(task_id, task.model_dump())
    return {"status": "updated", "id": task_id}


# ──────────────────────────────────────────
# Convenience: Parse + Plan in one call
# ──────────────────────────────────────────

@app.post("/api/process")
async def api_process(request: ParseRequest):
    """Full pipeline: parse brain dump → plan tasks → return organized list."""
    # Step 1: Parse
    parsed = await parse_brain_dump(request)

    # Step 2: Plan
    plan_req = PlanRequest(tasks=parsed.tasks)
    planned = await plan_tasks(plan_req)

    # Step 3: Save to DB
    today = date.today().isoformat()
    await save_tasks(today, [t.model_dump() for t in planned.planned_tasks])

    return {
        "date": today,
        "tasks": [t.model_dump() for t in planned.planned_tasks],
        "suggested_order": planned.suggested_order,
        "total_estimated_hours": planned.total_estimated_hours,
        "insights": parsed.insights,
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
