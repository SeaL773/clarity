<div align="center">

# ✨ Clarity

**AI-powered smart todo list for people who think faster than they organize.**

*Just tell me what you need to do. I'll figure out the rest.*

[![Built with Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter)](https://flutter.dev)
[![Powered by FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![AI by Claude](https://img.shields.io/badge/AI-Claude_Haiku_4.5-D97757?logo=anthropic)](https://anthropic.com)
[![Virginia-Tech CS](https://img.shields.io/badge/Virginia_Tech-CS-861F41)](https://github.com/Jerry-NotesHub/Virginia-Tech-Shields)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## The Problem

Traditional todo apps require you to already have clarity. You need to break down vague goals into specific tasks, decide what to do first, and track your own progress. That planning overhead is a barrier for everyone — and especially challenging for the **366M+ people worldwide** affected by ADHD and executive dysfunction.

## The Solution

Clarity removes the planning friction entirely:

1. **Brain Dump** → Type or speak everything on your mind
2. **AI Parse** → Extracts discrete, actionable tasks automatically
3. **Smart Plan** → Prioritizes using the Eisenhower Matrix, orders by workflow
4. **Daily Recap** → Encouraging summary of what you accomplished

No time pressure. No guilt. Just clarity.

## Architecture

```
┌──────────────┐      REST API       ┌──────────────┐      ┌─────────────┐
│              │  ◄────────────────►  │              │ ───► │  Anthropic  │
│  Flutter App │   JSON over HTTP    │   FastAPI     │      │  Claude API │
│  (Mobile)    │                     │   (Python)    │      │  (Haiku 4.5)│
│              │                     │              │      └─────────────┘
└──────────────┘                     └──────┬───────┘
                                            │
                                     ┌──────┴───────┐
                                     │   SQLite     │
                                     │  (Persistence)│
                                     └──────────────┘
```

### AI Pipeline — 3-Step, Not a Single API Call

| Step | Endpoint | What it does |
|------|----------|-------------|
| **Parse** | `POST /api/parse` | Extract tasks from unstructured text, identify implicit tasks |
| **Plan** | `POST /api/plan` | Assign priority (Eisenhower Matrix), order by workflow & quick wins |
| **Summarize** | `POST /api/summarize` | Generate encouraging daily recap, suggest tomorrow's focus |

Each step has its own **dedicated prompt** designed for the task — not one generic prompt. The parse and plan steps are chained via `POST /api/process` for a seamless user experience.

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter + Dart | Cross-platform mobile UI (Material 3) |
| **State** | Provider | Reactive state management |
| **Backend** | Python FastAPI | Async REST API with auto-docs |
| **AI** | Anthropic Claude (Haiku 4.5) | Multi-step LLM pipeline |
| **Database** | SQLite + aiosqlite | Lightweight async persistence |
| **Voice** | speech_to_text | On-device speech recognition |

## Features

- **Brain dump input** — Text or voice, messy is fine
- **AI task extraction** — Finds tasks you didn't even realize you had
- **Eisenhower Matrix prioritization** — Color-coded by urgency × importance
- **Sub-task breakdown** — Big tasks split into manageable steps
- **Auto-complete parent tasks** — All sub-tasks done? Parent checks itself
- **Completed tasks sink** — Done items move to the bottom, stay organized
- **Daily recap** — AI-generated progress summary with encouragement
- **Dark mode** — Warm Claude-style dark theme
- **Frosted glass UI** — Modern floating navigation bar
- **ADHD-friendly design** — No time pressure, calm colors, encouraging tone

## Quick Start

### Backend

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env    # Add your API keys
python run.py           # → http://localhost:8000/docs
```

### Frontend

```bash
cd frontend/clarity_app
flutter pub get
flutter run
```

### Environment Variables

```env
# Required — pick one LLM provider
ANTHROPIC_API_KEY=sk-ant-...
ANTHROPIC_MODEL=claude-haiku-4-5-20251001

# Optional fallbacks
OPENAI_API_KEY=sk-...
AWS_ACCESS_KEY_ID=...
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/health` | Health check |
| `POST` | `/api/parse` | Brain dump → structured tasks |
| `POST` | `/api/plan` | Tasks → prioritized plan |
| `POST` | `/api/summarize` | Tasks → daily recap |
| `POST` | `/api/process` | Full pipeline (parse + plan) |
| `GET` | `/api/tasks/{date}` | Get tasks for a date |
| `POST` | `/api/tasks/{date}` | Save tasks for a date |

## Project Structure

```
clarity/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI routes
│   │   ├── models.py            # Pydantic schemas
│   │   ├── database.py          # SQLite operations
│   │   └── llm/
│   │       ├── client.py        # Multi-provider LLM client
│   │       ├── parser.py        # Step 1: brain dump → tasks
│   │       ├── planner.py       # Step 2: prioritize & order
│   │       └── summarizer.py    # Step 3: daily recap
│   └── prompts/
│       ├── parse.txt            # Task extraction prompt
│       ├── plan.txt             # Prioritization prompt
│       └── summarize.txt        # Recap prompt
│
├── frontend/clarity_app/
│   └── lib/
│       ├── main.dart            # App entry + theming
│       ├── models/task.dart     # Data models
│       ├── providers/           # State management
│       ├── screens/             # Home, Recap, Settings
│       ├── services/            # API client, speech
│       └── widgets/             # Task cards, input, summary
│
└── TECH_DOC.md                  # Detailed technical documentation
```

## Social Good

Clarity is designed with **cognitive accessibility** as a core principle:

- **No time estimates** — Timers and deadlines cause anxiety for ADHD users
- **Quick wins first** — Ordering based on behavioral activation therapy
- **Encouraging tone** — AI never judges, always reframes positively
- **Voice input** — Lowers barrier when typing feels overwhelming
- **Calm UI** — Low-stimulation colors, generous whitespace, no clutter

> *366M+ people worldwide are affected by ADHD. Executive dysfunction isn't laziness — it's a neurological difficulty with task initiation and planning. Clarity helps bridge that gap.*

## Team

Built at the **AWS Kiro × CS Careers Hackathon** at Virginia Tech — March 28, 2026.

## License

MIT
