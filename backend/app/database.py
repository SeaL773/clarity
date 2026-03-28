"""SQLite database for task persistence."""

from __future__ import annotations

import json
from typing import List

import aiosqlite

DB_PATH = "clarity.db"


async def init_db():
    """Create tables if they don't exist."""
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY,
                date TEXT NOT NULL,
                data TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        await db.execute("""
            CREATE INDEX IF NOT EXISTS idx_tasks_date ON tasks(date)
        """)
        await db.commit()


async def save_tasks(date: str, tasks: List[dict]):
    """Save tasks for a given date (upsert)."""
    async with aiosqlite.connect(DB_PATH) as db:
        # Delete ALL tasks for this date, then insert fresh
        await db.execute("DELETE FROM tasks WHERE date = ?", (date,))
        for task in tasks:
            await db.execute(
                "INSERT OR REPLACE INTO tasks (id, date, data) VALUES (?, ?, ?)",
                (task["id"], date, json.dumps(task)),
            )
        await db.commit()


async def get_tasks(date: str) -> List[dict]:
    """Get all tasks for a given date."""
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute(
            "SELECT data FROM tasks WHERE date = ? ORDER BY created_at",
            (date,),
        )
        rows = await cursor.fetchall()
        return [json.loads(row["data"]) for row in rows]


async def update_task(task_id: str, data: dict):
    """Update a single task."""
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            "UPDATE tasks SET data = ? WHERE id = ?",
            (json.dumps(data), task_id),
        )
        await db.commit()
