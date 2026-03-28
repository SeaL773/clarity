# Clarity — 3-Minute Pitch Script

---

**[0:00 — Open with the problem]**

Raise your hand if you've ever stared at a blank todo list and thought… "I know I have things to do, I just can't figure out where to start."

Now imagine feeling that way every single day. That's the reality for over 366 million people worldwide living with ADHD. The hardest part isn't doing the work — it's the planning. Breaking down goals, setting priorities, estimating time — that cognitive overhead *is* the barrier.

And here's the thing — traditional todo apps don't help. They require you to already be organized. They assume you can break down "I'm overwhelmed" into neat little checkboxes. But what if you can't?

---

**[0:40 — Introduce Clarity]**

That's why we built **Clarity**.

Clarity is an AI-powered smart todo list where you just… dump your thoughts. Type whatever's on your mind — messy, unstructured, stream of consciousness. "I have a midterm Thursday, haven't started studying, need to do laundry, my room's a mess, and I told Sarah I'd review her resume."

Hit one button. That's it.

---

**[1:00 — How it works]**

Behind the scenes, Clarity runs a **three-step AI pipeline** — not a single API call.

**Step one: Parse.** The AI reads your brain dump and extracts every task — even the ones you didn't explicitly say. "I need to eat healthier" becomes "plan meals for the week" and "go grocery shopping."

**Step two: Plan.** It prioritizes using the Eisenhower Matrix — urgent and important first, quick wins next to build momentum. Tasks are ordered by workflow, so you always know what to do *right now*.

**Step three: Summarize.** At the end of the day, the AI generates an encouraging recap. It always leads with what you accomplished — never what you didn't. Because for ADHD users, positive reinforcement isn't a nice-to-have. It's therapy.

---

**[1:40 — Key features]**

Let me show you what makes Clarity different.

When you complete a task, it gently sinks to the bottom — no harsh deletions, no guilt. Complete all the sub-tasks? The parent automatically checks itself off. And when you hit milestones — first task done, halfway there, all complete — you get celebration moments. Real dopamine hits, baked into the UX.

We have a **calendar view** where every day shows a progress bar. The color tells you how urgent that day is, and the fill shows completion. It's like a GitHub contribution graph, but for your life.

There's voice input powered by **OpenAI Whisper** — because sometimes typing feels like too much. And daily check-in notifications that are gentle, not nagging.

Everything is designed with **zero time pressure**. No timers. No countdown clocks. No "you're behind schedule." Just clarity.

---

**[2:20 — Technical depth]**

On the technical side: **Flutter** frontend for cross-platform, **FastAPI** backend with async SQLite, and **Claude Haiku 4.5** powering three dedicated AI prompts — each one carefully engineered for its specific task.

We built a **multi-provider LLM fallback** system — Anthropic, Kiro, Bedrock, OpenAI — so if one goes down, we seamlessly switch. We have rate limiting, input validation, atomic database transactions. The code passed a full security review with all critical issues resolved.

We built all of this today, in one day, using **Kiro IDE** — which honestly made the development process feel like pair programming with an AI. Scaffolding features, debugging, iterating — significantly faster than a traditional workflow.

---

**[2:50 — Social impact + close]**

366 million people have ADHD. 10 percent of American college students. Executive dysfunction isn't laziness — it's a neurological reality. And every design decision in Clarity — from the calm colors to the encouraging language to the quick-wins-first ordering — is rooted in **behavioral activation therapy** principles.

You don't need to have it all figured out. Just tell Clarity what's on your mind.

We'll figure out the rest.

Thank you.

---

*Total: ~3 minutes at natural speaking pace*
