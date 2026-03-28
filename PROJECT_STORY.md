# Clarity ✨ — Project Story

## Inspiration

As college students, we've all been there — staring at a mountain of tasks, not knowing where to start. It's not laziness. It's **executive dysfunction**, and it affects over 366 million people worldwide with ADHD.

Traditional todo apps assume you already have clarity. You need to break down goals, set priorities, estimate time. But that planning overhead *is* the barrier. We asked: **what if an AI could do the organizing for you?**

The idea clicked during a late-night brainstorming session before the hackathon. One teammate mentioned how they write messy notes to themselves but never turn them into action items. Another talked about the guilt spiral of seeing unchecked boxes with time estimates. We realized the problem wasn't motivation — it was the cognitive cost of planning itself.

## What We Built

**Clarity** is an AI-powered smart todo list where you just dump your thoughts — messy, unstructured, stream of consciousness — and a 3-step AI pipeline organizes everything for you:

1. **Parse** — Extracts discrete tasks from unstructured text, even finding implicit tasks you didn't explicitly state
2. **Plan** — Prioritizes using the Eisenhower Matrix and orders by workflow (quick wins first to build momentum)
3. **Summarize** — Generates an encouraging daily recap that leads with what you *did*, never what you didn't

Key features include:
- 📱 Cross-platform Flutter app with voice input
- 📅 Calendar view with urgency-colored progress bars and Google Calendar-style timeline
- 🎉 Celebration moments (dopamine hits for completing tasks — behavioral activation therapy in action)
- 🌙 Warm dark mode inspired by Claude's UI
- 🔔 Gentle daily check-in notifications
- 🧪 Hidden development mode for testing (triple-tap the About section)

## How We Built It

**Frontend:** Flutter + Dart with Material 3 design. Provider for state management. Custom frosted glass navigation bar using `BackdropFilter`. Platform-aware API detection (Android emulator vs web vs device).

**Backend:** Python FastAPI with async SQLite. Three dedicated prompt files — each AI step has its own carefully engineered prompt, not one generic catch-all. Rate limiting, input validation, atomic database transactions.

**AI:** We started with AWS Kiro Credits through the CodeWhisperer Streaming API, reverse-engineering the authentication flow from the Kiro IDE's SSO token. When that account got rate-limited, we pivoted to the Anthropic API with Claude Haiku 4.5 — fast enough for real-time task parsing, smart enough for nuanced prioritization.

**Design:** We studied Things 3, Todoist, and Claude's mobile app for UI inspiration. Every design decision was filtered through an ADHD-friendly lens: no time estimates (they cause anxiety), encouraging tone, calm colors, generous whitespace, celebration moments for positive reinforcement.

## Challenges

**Kiro Credits ≠ API Keys.** We initially assumed Kiro Credits would give us Bedrock API access. They don't — they power the IDE's AI agent. We had to reverse-engineer how Kiro authenticates with AWS (Bearer tokens via CodeWhisperer Streaming API) to use our credits for the backend. When the account got suspended for too many requests, we pivoted to direct Anthropic API in under 5 minutes thanks to our multi-provider fallback architecture.

**Android Emulator + Memory.** Running Android Studio, an Android emulator, Kiro IDE, and our backend simultaneously on a 32GB server left us with 1.7GB free RAM. Gradle builds kept failing with OOM errors. We had to carefully manage which processes were running and reduced Gradle's JVM heap from 8GB to 2GB.

**Prompt Engineering for JSON.** Getting the LLM to consistently return valid JSON without markdown wrapping or extra explanation took several iterations. The Kiro API's CodeWhisperer endpoint also refused non-coding requests — our summarize prompt initially got rejected because it asked for "warm, encouraging" language. We reframed it as a "productivity analytics engine generating structured reports" and it worked perfectly.

**Immutable State in Flutter.** Our initial Task model used mutable fields, leading to subtle bugs where completing a sub-task would mutate shared list references. Refactoring to fully immutable models with `copyWith` mid-hackathon was nerve-wracking but eliminated an entire class of state management bugs.

## What We Learned

- **Multi-provider LLM architecture pays off.** Having Anthropic → Kiro → Bedrock → OpenAI fallback saved us when our primary provider went down mid-demo prep.
- **ADHD-friendly design benefits everyone.** Every design choice we made for cognitive accessibility (no time pressure, encouraging feedback, quick wins first) made the app better for *all* users.
- **Reverse-engineering auth flows is a valuable skill.** Understanding how Kiro's SSO tokens work taught us about AWS Builder ID, OIDC, and Bearer token authentication.
- **Ship fast, iterate faster.** We made 40+ commits in one day, each one a working improvement. Small, focused changes beat big rewrites.

## What's Next

- Offline mode with local task caching
- Scheduled notifications with per-task due date reminders
- Multi-day task planning ("this week" brain dumps)
- Sharing task lists for group projects
- Widget for home screen quick-add

---

*Built with Flutter, FastAPI, Claude Haiku 4.5, and Kiro IDE at the AWS Kiro × CS Careers Hackathon — Virginia Tech, March 28, 2026.*
