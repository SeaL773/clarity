# Clarity — Technical Documentation

## Architecture

```
┌──────────────────┐         REST API          ┌──────────────────┐
│                  │  ◄──────────────────────►  │                  │
│   Flutter App    │    JSON over HTTPS         │   FastAPI Server │
│   (Android/iOS)  │                            │   (Python 3.11+) │
│                  │                            │                  │
└──────────────────┘                            └────────┬─────────┘
        │                                                │
        │ Speech-to-Text                                 │ LLM Pipeline
        │ (on-device or Whisper)                         │
        ▼                                                ▼
┌──────────────────┐                            ┌──────────────────┐
│ Google STT /     │                            │ Anthropic Claude │
│ OpenAI Whisper   │                            │ (Haiku 4.5)     │
└──────────────────┘                            └──────────────────┘
                                                         │
                                                         ▼
                                                ┌──────────────────┐
                                                │ SQLite           │
                                                │ (aiosqlite)      │
                                                └──────────────────┘
```

### Data Flow

```
User Input (voice/text)
    │
    ├─ [if voice] → STT or Whisper → raw text
    │
    ▼
POST /api/parse  ──→  LLM Step 1: Extract tasks from unstructured text
    │
    ▼
POST /api/plan   ──→  LLM Step 2: Prioritize + break down + order
    │
    ▼
Flutter renders task list ──→ User interacts throughout the day
    │
    ▼
POST /api/summarize ──→ LLM Step 3: Generate daily recap
```

## Tech Stack

### Frontend (Flutter)

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | Flutter 3.x + Dart | Cross-platform mobile UI |
| State | Provider | Reactive state management |
| Voice | speech_to_text + record | On-device STT + audio recording |
| Transcription | OpenAI Whisper (server-side) | Accurate cloud transcription |
| Calendar | table_calendar | Monthly view with task tracking |
| Notifications | flutter_local_notifications | Daily reminder system |
| Theming | Material 3 | Light/dark mode with ADHD-friendly design |

### Backend (Python)

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | FastAPI | Async REST API with auto-docs |
| LLM | Anthropic SDK | Claude Haiku 4.5 |
| Fallback | Multi-provider (Anthropic → Kiro → Bedrock → OpenAI) | Resilience |
| Database | SQLite + aiosqlite | Lightweight async persistence |
| Validation | Pydantic v2 | Request/response schemas |
| Server | uvicorn | ASGI server |

## AI Pipeline

Three distinct steps, each with a dedicated prompt:

### Step 1: Parse (`POST /api/parse`)

**Input:** Raw brain dump text
**Output:** Structured task list with sub-tasks

The prompt extracts all explicit and implicit tasks, breaks large tasks into sub-steps, and uses encouraging language. Returns valid JSON.

### Step 2: Plan (`POST /api/plan`)

**Input:** List of parsed tasks
**Output:** Prioritized, ordered task list

Uses the Eisenhower Matrix (urgent × important) for priority. Orders by workflow with quick wins first — based on behavioral activation therapy for ADHD users.

### Step 3: Summarize (`POST /api/summarize`)

**Input:** Tasks with completion status
**Output:** Encouraging daily recap + tomorrow's focus

Always leads with accomplishments. Reframes incomplete items positively. Suggests carry-over priorities.

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/health` | Health check |
| `POST` | `/api/parse` | Brain dump → structured tasks |
| `POST` | `/api/plan` | Tasks → prioritized plan |
| `POST` | `/api/summarize` | Tasks → daily recap |
| `POST` | `/api/process` | Full pipeline (parse + plan combined) |
| `POST` | `/api/transcribe` | Audio file → Whisper transcription |
| `GET` | `/api/tasks/{date}` | Get tasks for a date |
| `POST` | `/api/tasks/{date}` | Save tasks for a date |
| `DELETE` | `/api/tasks/{date}` | Delete tasks for a date |

## Data Models

```python
class Priority(str, Enum):
    urgent_important = "urgent_important"
    important_not_urgent = "important_not_urgent"
    urgent_not_important = "urgent_not_important"
    neither = "neither"

class Task(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    sub_tasks: list["Task"] = []
    priority: Optional[Priority] = None
    estimated_minutes: Optional[int] = None
    completed: bool = False
```

## Security & Reliability

- **Rate limiting** — 20 requests/minute per client
- **Input validation** — Date format, text length constraints
- **Atomic transactions** — SQLite BEGIN/COMMIT/ROLLBACK
- **Generic errors** — No internal details leaked
- **Multi-provider fallback** — Automatic LLM provider switching

## Environment Variables

```env
# Required — pick one LLM provider
ANTHROPIC_API_KEY=sk-ant-...
ANTHROPIC_MODEL=claude-haiku-4-5-20251001

# Optional
OPENAI_API_KEY=sk-...          # Whisper transcription + LLM fallback
AWS_ACCESS_KEY_ID=...          # Bedrock fallback
AWS_SECRET_ACCESS_KEY=...
```

---

*Built at the AWS Kiro × CS Careers Hackathon at Virginia Tech — March 28, 2026.*
