# Clarity ✨ — Project Story

## Inspiration

366 million people worldwide have ADHD. The hardest part isn't doing the work — it's figuring out where to start. Traditional todo apps assume you already have clarity. We wanted to build one that *gives* you clarity instead.

## What It Does

Dump your thoughts — messy, unstructured, whatever's on your mind — and a 3-step AI pipeline (Parse → Prioritize → Summarize) organizes everything for you. No time pressure, no guilt, just actionable tasks with smart prioritization.

## How We Built It

Flutter frontend with Material 3, FastAPI backend, Claude Haiku 4.5 powering three dedicated AI prompts. Kiro IDE was a huge help throughout development — its AI agent made scaffolding features and debugging significantly faster than a traditional IDE workflow. We also integrated Kiro Credits via the CodeWhisperer API as our initial LLM provider.

Key features: calendar with urgency progress bars, Google Calendar-style timeline, celebration moments (⚡🔥🎉), warm dark mode, frosted glass UI, voice input, daily check-in notifications.

## Challenges

Running Android Studio, Kiro IDE, an Android emulator, and our backend simultaneously pushed our 32GB server to its limits — at one point only 1.7GB free. We also iterated heavily on prompt engineering to get consistent JSON output from the LLM without markdown wrapping or extra explanation.

## What We Learned

- Multi-provider LLM fallback saves you when things go wrong
- ADHD-friendly design (no timers, encouraging tone, quick wins first) makes the app better for *everyone*
- Kiro IDE's agentic coding workflow is genuinely productive — felt like pair programming with an AI
- Ship small, ship fast — 40+ commits in one day, each one a working improvement

---

*Built with Flutter, FastAPI, Claude Haiku 4.5, and Kiro IDE at Virginia Tech — March 28, 2026.*
