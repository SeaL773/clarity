<div align="center">

# ✨ Clarity

**AI-powered smart todo list for people who think faster than they organize.**

*Just tell me what you need to do. I'll figure out the rest!*

[![Built with Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter)](https://flutter.dev)
[![Powered by FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![AI by Claude](https://img.shields.io/badge/AI-Claude_Haiku_4.5-D97757?logo=anthropic)](https://anthropic.com)
[![Built with Kiro](https://img.shields.io/badge/IDE-Kiro_by_AWS-7B2FBE?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0id2hpdGUiPjxwYXRoIGQ9Ik0xMiAyQzEyLjUgNi41IDE3LjUgMTEuNSAyMiAxMkMxNy41IDEyLjUgMTIuNSAxNy41IDEyIDIyQzExLjUgMTcuNSA2LjUgMTIuNSAyIDEyQzYuNSAxMS41IDExLjUgNi41IDEyIDJaIi8+PC9zdmc+&logoColor=white)](https://kiro.dev)
[![Virginia-Tech CS](https://img.shields.io/badge/Virginia_Tech-CS-861F41)](https://github.com/Jerry-NotesHub/Virginia-Tech-Shields)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

### 🏆 3rd Place — [AWS Kiro × CS Careers Hackathon at Virginia Tech](https://aws-kiro-cs-careers-vt.devpost.com/)

<img src="cover.png" alt="Clarity Cover" width="600"/>

</div>

---

## Demo Video

[![Watch the Demo](https://img.youtube.com/vi/-MrSHfICSuc/maxresdefault.jpg)](https://www.youtube.com/watch?v=-MrSHfICSuc)

▶️ **[Watch on YouTube](https://www.youtube.com/watch?v=-MrSHfICSuc)**

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

### Backend Security & Reliability
- **Rate limiting** — 20 requests per minute per client
- **Input validation** — Date parameters validated (YYYY-MM-DD)
- **Atomic transactions** — SQLite writes wrapped in BEGIN/COMMIT/ROLLBACK
- **Generic error messages** — No internal details leaked to clients
- **Multi-provider fallback** — Anthropic → Kiro → Bedrock → OpenAI

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter + Dart | Cross-platform mobile UI (Material 3) |
| **State** | Provider | Reactive state management |
| **Backend** | Python FastAPI | Async REST API with auto-docs |
| **AI** | Anthropic Claude (Haiku 4.5) | Multi-step LLM pipeline |
| **Database** | SQLite + aiosqlite | Lightweight async persistence |
| **Voice** | speech_to_text + OpenAI Whisper | On-device STT + cloud transcription |
| **Audio** | record | Native audio recording for Whisper |
| **Notifications** | flutter_local_notifications | Daily reminder system |
| **Calendar** | table_calendar | Monthly view with task tracking |

## Features

### Core
- **Brain dump input** — Text or voice, messy is fine
- **AI task extraction** — Finds tasks you didn't even realize you had
- **Eisenhower Matrix prioritization** — Color-coded by urgency × importance
- **Sub-task breakdown** — Big tasks split into manageable steps
- **Auto-complete parent tasks** — All sub-tasks done? Parent checks itself
- **Completed tasks sink** — Done items move to the bottom, stay organized
- **Append mode** — Add more tasks without losing existing ones

### Calendar
- **Monthly calendar view** — See all your tasks at a glance
- **Urgency progress bars** — Each day shows a color-coded bar (blue depth in light mode, amber in dark mode)
- **Google Calendar timeline** — Due times on the left, color-coded task cards on the right
- **Tap to preview, double-tap to expand** — Single tap switches timeline, second tap opens full day view
- **Today button** — Quick jump back from any date
- **Historical view** — Browse past days' tasks (read-only)
- **Due time support** — Tasks show their scheduled time in the timeline

### Daily Recap
- **AI-generated summary** — Encouraging progress report
- **Completion ring** — Visual progress indicator
- **Tomorrow's focus** — AI suggests what to carry over
- **Dedicated recap screen** — Full-screen experience

### Voice Input
- **Dual mode speech** — On-device STT (instant) or OpenAI Whisper (accurate)
- **Record + transcribe** — Native audio recording → server-side Whisper transcription
- **Platform-aware** — Mobile uses native recording, web falls back gracefully
- **Dev mode testing** — Bundled test audio files for Whisper verification

### Notifications & Celebrations
- **Daily check-in reminder** — Toggle on/off, gentle morning notification
- **System notifications** — Custom ✨ sparkle icon, branded push notifications
- **Celebration moments** — ⚡ First task done, 🔥 halfway there, 🎉 all complete
- **ADHD-friendly** — Encouraging, never nagging

### Design
- **Dark mode** — Warm Claude-style dark theme (brown-gray tones)
- **Frosted glass navigation** — Floating pill bar with backdrop blur
- **Branded splash screen** — Gradient launch with fade-in animation
- **Platform-aware API** — Auto-detects Android emulator vs web vs device
- **Collapsible input** — Shrinks on scroll, expands on tap
- **Hidden development mode** — Triple-tap About to toggle, generates full month of test data
- **Recap regeneration** — Regenerate AI summary anytime

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
| `POST` | `/api/transcribe` | Audio file → Whisper transcription |
| `GET` | `/api/tasks/{date}` | Get tasks for a date |
| `POST` | `/api/tasks/{date}` | Save tasks for a date |
| `DELETE` | `/api/tasks/{date}` | Delete tasks for a date |

## Project Structure

```
clarity/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI routes + rate limiting
│   │   ├── models.py            # Pydantic schemas
│   │   ├── database.py          # SQLite with atomic transactions
│   │   └── llm/
│   │       ├── transcriber.py   # OpenAI Whisper audio transcription
│   │       ├── client.py        # Multi-provider LLM client (Anthropic/Kiro/Bedrock/OpenAI)
│   │       ├── parser.py        # Step 1: brain dump → tasks
│   │       ├── planner.py       # Step 2: prioritize & order
│   │       └── summarizer.py    # Step 3: daily recap
│   └── prompts/
│       ├── parse.txt            # Task extraction prompt
│       ├── plan.txt             # Prioritization prompt
│       └── summarize.txt        # Recap prompt
│
├── frontend/clarity_app/
│   ├── assets/
│   │   └── clarity_icon.svg     # Branded app icon (sparkle + checkmark)
│   └── lib/
│       ├── main.dart            # App entry + light/dark theming
│       ├── models/
│       │   └── task.dart        # Immutable data models with dueTime
│       ├── providers/
│       │   └── task_provider    # State management, test mode, celebrations
│       ├── screens/
│       │   ├── splash_screen    # Branded gradient launch screen
│       │   ├── main_shell       # 4-tab navigation with frosted glass bar
│       │   ├── home_screen      # Brain dump + task list + celebrations
│       │   ├── calendar_screen  # Monthly view + urgency bars + timeline
│       │   ├── calendar_day     # Full day detail view (read-only history)
│       │   ├── recap_screen     # AI summary + regenerate button
│       │   └── settings_screen  # Dark mode, reminders, hidden dev mode
│       ├── services/
│       │   ├── api_service      # Platform-aware HTTP client (Android/Web/Desktop)
│       │   ├── speech_service   # Dual-mode voice (device STT + Whisper)
│       │   ├── whisper_service  # Audio recording + Whisper transcription
│       │   └── notification     # Local push notifications with custom icon
│       └── widgets/
│           ├── brain_dump_input # Collapsible text + voice input
│           ├── task_card        # Priority-colored cards with sub-tasks
│           └── summary_card     # Recap with progress ring + encouragement
│
└── README.md
```

## Social Good

Clarity is designed with **cognitive accessibility** as a core principle:

- **No time estimates** — Timers and deadlines cause anxiety for ADHD users
- **Quick wins first** — Ordering based on behavioral activation therapy
- **Encouraging tone** — AI never judges, always reframes positively
- **Voice input** — Lowers barrier when typing feels overwhelming
- **Calm UI** — Low-stimulation colors, generous whitespace, no clutter
- **Celebration moments** — Dopamine hits for completing tasks (⚡🔥🎉)
- **Gentle reminders** — Daily check-in, never nagging

> *366M+ people worldwide are affected by ADHD. Executive dysfunction isn't laziness — it's a neurological difficulty with task initiation and planning. Clarity helps bridge that gap.*

## Hackathon

**🏆 3rd Place Overall** at the [AWS Kiro × CS Careers Hackathon at Virginia Tech](https://aws-kiro-cs-careers-vt.devpost.com/) — March 28, 2026.

200 students, 10 hours, judged on a 60-point rubric across 6 categories:

| Category | Points |
|----------|--------|
| Social Good | 12 |
| AI Integration | 12 |
| Innovation | 10 |
| Impact & Storytelling | 10 |
| Technical Execution | 8 |
| Design & UI/UX | 8 |

Prize: $320 Kiro Credits

## License

MIT
