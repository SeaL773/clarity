"""Pydantic models for Clarity API."""

from __future__ import annotations

import uuid
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class Priority(str, Enum):
    urgent_important = "urgent_important"
    important_not_urgent = "important_not_urgent"
    urgent_not_important = "urgent_not_important"
    neither = "neither"


class Task(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4())[:8])
    title: str
    description: Optional[str] = None
    sub_tasks: list[Task] = []
    priority: Optional[Priority] = None
    estimated_minutes: Optional[int] = None
    completed: bool = False


# --- Parse ---

class ParseRequest(BaseModel):
    text: str
    context: Optional[str] = None  # e.g. "I'm a college student"


class ParseResponse(BaseModel):
    tasks: list[Task]
    original_text: str
    insights: Optional[str] = None


# --- Plan ---

class PlanRequest(BaseModel):
    tasks: list[Task]
    available_hours: Optional[float] = 8.0


class PlanResponse(BaseModel):
    planned_tasks: list[Task]
    total_estimated_hours: float
    suggested_order: list[str]  # task IDs in recommended order


# --- Summarize ---

class SummarizeRequest(BaseModel):
    tasks: list[Task]
    date: str  # YYYY-MM-DD


class SummarizeResponse(BaseModel):
    summary: str
    completed_count: int
    total_count: int
    completion_rate: float
    encouragement: str
    tomorrow_focus: list[str]
