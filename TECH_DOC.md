# Clarity — AI-Powered Smart Todo List

> "Just tell me what you need to do. I'll figure out the rest."

## 1. Project Overview

### Problem

- Traditional todo lists require you to break down tasks, prioritize, and estimate time yourself — that process alone is exhausting
- Many people aren't unwilling to act — they just face a pile of chaotic thoughts and don't know where to start
- At the end of the day, you have no idea what you actually accomplished

### Solution

Clarity is an AI-powered smart todo list. Just dump all your thoughts in (type or speak), and the AI extracts tasks, breaks them into sub-steps, prioritizes, and estimates time. At the end of the day, it automatically summarizes your accomplishments.

### Core Features

1. **Brain Dump** — Say or type anything freely, AI automatically extracts discrete tasks
2. **Smart Breakdown** — Large tasks are automatically split into actionable sub-steps
3. **Priority Planning** — AI sorts by urgency/importance and estimates required time
4. **Daily Recap** — One-tap daily summary to see how much you got done

### Social Good Angle (12 pts)

This AI todo list is especially helpful for people with ADHD and executive dysfunction:

- 366M+ people worldwide are affected by ADHD; 10% of US college students have it
- The core difficulty of executive dysfunction is "task initiation" and "task planning" — exactly what Clarity solves
- Voice input lowers the barrier to entry; encouraging tone combats feelings of failure
- Design uses low-stimulation colors, large fonts, and a clean interface — following cognitive accessibility principles
- Can partner with university counseling centers and disability services offices for adoption

---

## 2. Architecture

```
┌──────────────────┐         REST API          ┌──────────────────┐
│                  │  ◄──────────────────────►  │                  │
│   Flutter App    │    JSON over HTTPS         │   FastAPI Server │
│   (Android/iOS)  │                            │   (Python 3.11+) │
│                  │                            │                  │
└──────────────────┘                            └────────┬─────────┘
        │                                                │
        │ Speech-to-Text                                 │ LLM Pipeline
        │ (on-device or API)                             │
        ▼                                                ▼
┌──────────────────┐                            ┌──────────────────┐
│ Google STT /     │                            │ AWS Bedrock      │
│ Whisper API      │                            │ (Claude 3.5)     │
└──────────────────┘                            │ via Kiro Credits │
                                                └──────────────────┘
                                                         │
                                                         ▼
                                                ┌──────────────────┐
                                                │ SQLite / Firebase│
                                                │ (persistence)    │
                                                └──────────────────┘
```

### Data Flow

```
User Input (voice/text)
    │
    ├─ [if voice] → Speech-to-Text → raw text
    │
    ▼
POST /api/parse  ──→  LLM Step 1: Extract tasks from unstructured text
    │
    ▼
POST /api/plan   ──→  LLM Step 2: Break down + prioritize + estimate time
    │
    ▼
Flutter renders task list ──→ User checks off tasks throughout the day
    │
    ▼
POST /api/summarize ──→ LLM Step 3: Generate daily recap + suggestions
```

---

## 3. Tech Stack

### Frontend (Flutter)

| Component | Library / Tool | Purpose |
|-----------|---------------|---------|
| **Framework** | Flutter 3.x + Dart | Cross-platform mobile UI |
| **HTTP Client** | `dio` | REST API calls, interceptors, error handling |
| **State Management** | `riverpod` or `provider` | App state (task list, loading, etc.) |
| **Voice Input** | `speech_to_text` package | On-device speech recognition |
| **UI Components** | `flutter_slidable` | Swipe-to-delete/complete on tasks |
| | `google_fonts` | Typography (Inter or Poppins) |
| | `flutter_animate` | Smooth micro-animations |
| | `lottie` | Loading animations |
| **Local Storage** | `sqflite` or `hive` | Offline task cache |
| **Theming** | Material 3 (Material You) | Modern, accessible design system |

#### Key Screens

1. **Home** — Brain dump input (text field + mic button) + today's task list
2. **Task Detail** — Expanded task with sub-tasks, priority badge, time estimate
3. **Daily Recap** — Summary card with stats + AI-generated reflection
4. **History** — Past days' tasks and completion rates

#### UI Design Notes

- **Color scheme**: Calm, low-stimulation palette (soft blues/greens — ADHD-friendly, avoid harsh reds)
- **Typography**: Large, readable fonts. Inter or Poppins.
- **Cards**: Rounded corners, subtle shadows, generous padding
- **Animations**: Satisfying check-off animation (confetti or gentle pulse) — dopamine hit for ADHD users
- **Voice button**: Large, prominent, always accessible — lower barrier to input

### Backend (Python)

| Component | Library / Tool | Purpose |
|-----------|---------------|---------|
| **Framework** | FastAPI | Async REST API, auto-docs (Swagger) |
| **LLM Client** | `boto3` (AWS Bedrock) | Claude 3.5 Sonnet via Kiro Credits |
| **Fallback LLM** | `openai` SDK | If Bedrock unavailable |
| **Data Models** | Pydantic v2 | Request/response validation |
| **Database** | SQLite + `aiosqlite` | Lightweight, no server needed |
| **CORS** | `fastapi.middleware.cors` | Allow Flutter app to connect |
| **Server** | `uvicorn` | ASGI server |
| **Env Config** | `python-dotenv` | API keys management |

### AI Pipeline (the 12-point section)

This is NOT a single API call. It's a multi-step pipeline with distinct prompts:

| Step | Endpoint | LLM Prompt Strategy | Input → Output |
|------|----------|---------------------|----------------|
| **Parse** | `POST /api/parse` | System prompt: "Extract discrete tasks from stream-of-consciousness text. Identify implicit tasks. Flag ambiguities." | Raw text → `List[Task]` |
| **Plan** | `POST /api/plan` | System prompt: "Break large tasks into 15-30 min sub-tasks. Assign priority (Eisenhower matrix). Estimate duration. Consider ADHD-friendly ordering (quick wins first)." | `List[Task]` → `List[PlannedTask]` |
| **Summarize** | `POST /api/summarize` | System prompt: "Generate encouraging daily recap. Highlight accomplishments. Reframe incomplete items positively. Suggest tomorrow's focus." | `List[CompletedTask]` → `DailySummary` |

#### Why this matters for scoring

- **3 distinct prompt designs** — not one generic prompt
- **ADHD-specific prompt engineering** — "quick wins first", "encouraging tone", "reframe incomplete items"
- **Pipeline architecture** — each step feeds the next
- **Custom model selection reasoning** — Claude for nuanced language understanding

---

## 4. API Specification

### Models (Pydantic)

```python
from pydantic import BaseModel
from enum import Enum
from typing import Optional

class Priority(str, Enum):
    urgent_important = "urgent_important"      # Do first
    important_not_urgent = "important_not_urgent"  # Schedule
    urgent_not_important = "urgent_not_important"  # Delegate/quick
    neither = "neither"                        # Drop/defer

class Task(BaseModel):
    id: str
    title: str
    description: Optional[str] = None
    sub_tasks: list["Task"] = []
    priority: Optional[Priority] = None
    estimated_minutes: Optional[int] = None
    completed: bool = False

class ParseRequest(BaseModel):
    text: str                    # Raw brain dump text
    context: Optional[str] = None  # e.g. "I'm a college student"

class ParseResponse(BaseModel):
    tasks: list[Task]
    original_text: str
    insights: Optional[str] = None  # AI observations

class PlanRequest(BaseModel):
    tasks: list[Task]
    available_hours: Optional[float] = 8.0

class PlanResponse(BaseModel):
    planned_tasks: list[Task]    # Re-ordered with priorities + time
    total_estimated_hours: float
    suggested_order: list[str]   # Task IDs in recommended order

class SummarizeRequest(BaseModel):
    tasks: list[Task]            # With completion status
    date: str

class SummarizeResponse(BaseModel):
    summary: str                 # AI-generated recap
    completed_count: int
    total_count: int
    completion_rate: float
    encouragement: str           # Positive reinforcement
    tomorrow_focus: list[str]    # Suggested carry-over
```

### Endpoints

```
GET  /api/health              → { "status": "ok" }

POST /api/parse               → ParseResponse
     Body: ParseRequest

POST /api/plan                → PlanResponse
     Body: PlanRequest

POST /api/summarize           → SummarizeResponse
     Body: SummarizeRequest

GET  /api/tasks/{date}        → list[Task]
POST /api/tasks/{date}        → save/update tasks
```

---

## 5. File Structure

```
clarity/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py              # FastAPI app, CORS, routes
│   │   ├── models.py            # Pydantic schemas (above)
│   │   ├── database.py          # SQLite setup
│   │   ├── llm/
│   │   │   ├── __init__.py
│   │   │   ├── client.py        # AWS Bedrock / OpenAI client wrapper
│   │   │   ├── parser.py        # Step 1: brain dump → tasks
│   │   │   ├── planner.py       # Step 2: tasks → prioritized plan
│   │   │   └── summarizer.py    # Step 3: daily recap
│   │   └── prompts/
│   │       ├── parse.txt        # System prompt for parsing
│   │       ├── plan.txt         # System prompt for planning
│   │       └── summarize.txt    # System prompt for summarizing
│   ├── requirements.txt
│   ├── .env.example
│   └── Dockerfile
│
├── frontend/
│   └── clarity_app/             # Flutter project
│       ├── lib/
│       │   ├── main.dart
│       │   ├── models/
│       │   │   └── task.dart         # Task data model
│       │   ├── services/
│       │   │   ├── api_service.dart   # HTTP client (dio)
│       │   │   └── speech_service.dart # Voice input
│       │   ├── providers/
│       │   │   └── task_provider.dart  # State management
│       │   ├── screens/
│       │   │   ├── home_screen.dart    # Main brain dump + task list
│       │   │   ├── recap_screen.dart   # Daily summary
│       │   │   └── history_screen.dart # Past days
│       │   └── widgets/
│       │       ├── brain_dump_input.dart  # Text + voice input
│       │       ├── task_card.dart         # Single task display
│       │       └── priority_badge.dart    # Priority indicator
│       ├── pubspec.yaml
│       └── assets/
│           └── animations/        # Lottie files
│
├── README.md
├── Judging Criteria.md
└── TECH_DOC.md
```

---

## 6. Implementation Guide

### Phase 1: Skeleton (10:00 - 10:30) — ALL TOGETHER

```bash
# Person A: Backend
mkdir -p backend/app/llm backend/app/prompts
cd backend
python -m venv venv
pip install fastapi uvicorn boto3 pydantic python-dotenv aiosqlite

# Person B: Frontend
flutter create clarity_app
cd clarity_app
# Add to pubspec.yaml: dio, provider/riverpod, speech_to_text, flutter_slidable, google_fonts

# Person C: Repo setup
git init
# Create .gitignore, README.md, .env.example
```

### Phase 2: Backend Core (10:30 - 12:00) — Person A

**Priority order:**

1. `main.py` — FastAPI app with CORS, health check
2. `models.py` — All Pydantic schemas
3. `llm/client.py` — Bedrock client wrapper (or OpenAI fallback)
4. `llm/parser.py` — Parse endpoint with prompt
5. Test with curl/Postman: send raw text, get back tasks

**Key: Prompt Engineering**

`prompts/parse.txt`:

```
You are an AI assistant specialized in helping people with ADHD and executive dysfunction.

Given a stream-of-consciousness brain dump, extract ALL discrete tasks mentioned or implied.
For each task, provide:
- A clear, actionable title (start with a verb)
- A brief description if the original text has context
- Break down any task that would take >30 minutes into sub-tasks

Rules:
- Identify implicit tasks (e.g., "I need to eat healthier" → "Plan meals for the week", "Go grocery shopping")
- Keep titles short and specific
- Use encouraging, non-judgmental language
- If something is ambiguous, include it anyway with a note

Return valid JSON matching this schema:
{
  "tasks": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string or null",
      "sub_tasks": [...],
      "estimated_minutes": int or null
    }
  ],
  "insights": "Brief observation about the user's needs"
}
```

### Phase 3: Frontend Core (10:30 - 13:00) — Person B

**Priority order:**

1. Home screen layout: input area (top) + task list (bottom)
2. Brain dump text field — multi-line, with placeholder "What's on your mind?"
3. Mic button (can be non-functional placeholder first)
4. Task card widget — title, checkbox, expandable sub-tasks
5. Connect to backend `/api/parse`

### Phase 4: Integration (13:00 - 15:00) — Person C bridges

1. API service in Flutter → connect parse endpoint
2. Wire up: user types → hits "Clarity" button → shows loading → tasks appear
3. Task completion toggle → local state update
4. Voice input: `speech_to_text` package → feed text to same parse flow

### Phase 5: Plan + Summarize (15:00 - 17:00)

1. Person A: implement `/api/plan` and `/api/summarize`
2. Person B: Recap screen UI
3. Person C: History/persistence layer

### Phase 6: Polish (17:00 - 19:00)

1. UI animations (check-off confetti, loading shimmer)
2. Error handling (no network, LLM timeout)
3. README with screenshots
4. Prepare demo flow + pitch script

---

## 7. Demo Script (for pitch)

1. Open app → empty state with friendly message
2. Tap mic → speak: "I have a midterm on Thursday, haven't started studying, also need to do laundry, my room is a mess, and I promised my friend I'd help them move this weekend, oh and I need to email my professor about the extension"
3. Show AI processing animation
4. Tasks appear — already broken down:
   - 📚 Study for midterm (sub-tasks: review ch 1-3, practice problems, make flashcards)
   - 🧺 Do laundry
   - 🧹 Clean room (sub-tasks: pick up clothes, vacuum, organize desk)
   - 📦 Help friend move (Saturday)
   - 📧 Email professor about extension
5. Show priority badges — email professor is marked URGENT (deadline-sensitive)
6. Fast forward → end of day → tap "Daily Recap"
7. AI summary: "You completed 7 out of 9 tasks today! You tackled the hardest one first (emailing your professor — that takes courage). Tomorrow, finish reviewing chapter 3 and you'll be in great shape for Thursday. You're doing better than you think. 💙"

---

## 8. Social Good Pitch Points (12 pts)

- **Target population**: 366M+ people with ADHD globally; 10% of US college students
- **Real barrier**: Executive dysfunction — not laziness, but a neurological difficulty with task initiation and planning
- **Accessibility**: Voice input reduces friction; encouraging AI tone combats shame spiral
- **Equity**: Free/open-source; works offline for task display; designed for cognitive accessibility
- **Realistic adoption path**: Could integrate with university counseling centers, disability services offices
- **Evidence-based**: "Quick wins first" ordering based on behavioral activation therapy principles

---

## 9. Environment Variables

```env
# .env.example
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=us-east-1
BEDROCK_MODEL_ID=anthropic.claude-3-5-sonnet-20241022-v2:0

# Fallback
OPENAI_API_KEY=your_key_if_needed

# App
DATABASE_URL=sqlite:///./clarity.db
DEBUG=true
```

---

## 10. Checklist

### Must Have (MVP) ✅

- [ ] Brain dump text input → AI parse → task list
- [ ] Task checkbox (complete/incomplete)
- [ ] Sub-task expansion
- [ ] Priority badges
- [ ] Basic daily recap
- [ ] Clean, ADHD-friendly UI

### Nice to Have 🎯

- [ ] Voice input (speech-to-text)
- [ ] Time estimation per task
- [ ] Eisenhower matrix view
- [ ] Task reordering (drag & drop)
- [ ] History / past days
- [ ] Offline mode (cached tasks)
- [ ] Confetti animation on task complete

### For Demo Only 🎬

- [ ] Pre-loaded example for smooth demo
- [ ] Pitch script rehearsed
- [ ] README with screenshots
