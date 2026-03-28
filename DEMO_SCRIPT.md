# Clarity Demo Recording Script

## Total Duration: 3-4 minutes

---

## Part 1: Opening + Problem (30s)

**Screen:** App splash screen → Good afternoon home page

**Actions:**
1. Open app, show splash screen (blue gradient + ✨ Clarity + "Your mind, organized")
2. Wait for transition to home screen with centered "Good afternoon" greeting

**Voiceover focus:** ADHD pain point — not lazy, just can't figure out where to start

---

## Part 2: Brain Dump Core Feature (60s)

**Screen:** Home page input box

**Actions:**
1. Type in the input box:
   ```
   I have a midterm on Thursday that I haven't started studying for, need to do laundry, my room is a mess, I promised my friend I'd help them move this weekend, and I need to email my professor about the extension
   ```
2. Tap **Clarity** button
3. Wait for loading animation ("Organizing your thoughts...")
4. Show generated task list — note the color bars (red = urgent+important, orange = urgent, blue = important, grey = other)
5. Expand "Study for midterm" to show sub-tasks
6. Show insights banner

**Voiceover focus:** 3-step AI pipeline (Parse → Plan → Summarize), not a single API call

---

## Part 3: Task Interaction (40s)

**Screen:** Task list

**Actions:**
1. Check a simple task (e.g. "Email professor") → show it sinks to bottom + greys out
2. Check sub-tasks → show parent auto-completes
3. Tap 💬 in top-right to reopen input, append new tasks:
   ```
   Also I have a dentist appointment Thursday morning and need to find my insurance card
   ```
4. Show new tasks appended (not replacing existing ones)

**Voiceover focus:** No time pressure, completed tasks gently sink instead of disappearing

---

## Part 4: Celebration Moment (15s)

**Screen:** Continue checking tasks

**Actions:**
1. First task completed → show ⚡ "First one done!" celebration
2. Or halfway → show 🔥 "Halfway there!" celebration

**Voiceover focus:** ADHD users need instant positive feedback (dopamine reward)

---

## Part 5: Calendar View (40s)

**Screen:** Switch to Calendar tab

**Actions:**
1. Go to Settings → triple-tap Clarity icon to enter dev mode
2. Switch to Calendar tab → show full month of progress bars (blue depth = urgency)
3. Tap a date → show timeline below (time on left, colored task cards on right)
4. Tap same date again → enter full-screen day detail
5. Tap "Today" button to jump back

**Voiceover focus:** Visual progress tracking — not pressure, but achievement

---

## Part 6: Daily Recap (30s)

**Screen:** Switch to Recap tab

**Actions:**
1. Tap "Generate Recap" button
2. Show AI-generated summary — completion ring + percentage + encouragement
3. Show "Tomorrow's Focus" suggestions
4. Tap "Regenerate" to refresh

**Voiceover focus:** Encouraging tone — always leads with what you did, not what you didn't

---

## Part 7: Dark Mode + Settings (20s)

**Screen:** Settings tab

**Actions:**
1. Show Settings page — About, Appearance, Reminders, How it works
2. Toggle Dark Mode → show warm brown-gray dark theme
3. Toggle Daily Check-in → show notification toggle
4. In dev mode, tap Test Notification → show system push notification

**Voiceover focus:** ADHD-friendly design — calm colors, gentle reminders

---

## Part 8: Technical Showcase (40s)

**Screen:** Switch to computer screen

**Actions:**
1. Open browser → `localhost:8000/docs` → show Swagger API docs
2. Show 3 prompt files (quick scroll through parse.txt, plan.txt, summarize.txt)
3. Open GitHub page (github.com/SeaL773/clarity) → show README badges + project structure
4. Show commit history (demonstrate development process)
5. Quick look at Sourcery code review

**Voiceover focus:** 3-step AI pipeline with dedicated prompts; multi-provider LLM fallback; rate limiting + input validation

---

## Part 9: Closing (15s)

**Screen:** Back to app home page

**Actions:** Show complete task list + frosted glass navigation bar

**Voiceover focus:** Clarity — you don't need to have it figured out. AI helps you get there. Designed for 366M+ people with ADHD.

---

## Recording Checklist

- [ ] Start backend first: `cd backend && python run.py`
- [ ] Emulator running, app installed
- [ ] Pre-fill calendar data with dev mode, then exit dev mode for live demo
- [ ] Have input text ready to paste
- [ ] Use light mode for first half, switch to dark in Part 7
- [ ] Enable notifications (allow permission prompt)

---

# English Voiceover Script

## [0:00 - Splash Screen]

Every day, millions of people struggle not because they're lazy — but because their brain works differently. For the 366 million people worldwide affected by ADHD, the hardest part isn't doing the work. It's figuring out where to start.

## [0:20 - Main Screen]

Meet Clarity. An AI-powered todo list that doesn't require you to already be organized. Just dump your thoughts — messy, unstructured, stream of consciousness — and AI handles the rest.

## [0:35 - Typing Brain Dump]

Watch. I type everything that's on my mind. A midterm I haven't studied for, laundry, a messy room, promises I've made. No structure needed.

## [0:50 - Tasks Appear]

In seconds, Clarity's three-step AI pipeline kicks in. First, it parses my text and extracts every task — even the ones I didn't explicitly state. Then, it prioritizes using the Eisenhower Matrix — you can see the color coding. Red means urgent and important. Blue means important but not urgent. Finally, it orders them by workflow — quick wins first to build momentum.

## [1:20 - Checking Tasks]

As I complete tasks, they gently fade to the bottom. No guilt, no pressure. And when I check off all the sub-tasks... the parent task automatically completes itself.

## [1:35 - Celebration]

And here's the magic for ADHD users — celebration moments. Every milestone gets acknowledged. First task done? You get a boost. Halfway there? Keep going. This isn't just UI polish — it's behavioral activation therapy built into the product.

## [1:50 - Adding More Tasks]

I can always add more. The input stays right there at the top. New tasks append to my existing list — nothing gets lost.

## [2:05 - Calendar]

The calendar view gives me a bird's eye view of my month. Each day shows a progress bar — the color depth tells me how urgent that day is, and how much I've completed. Tap a day to see the timeline — due times on the left, task cards on the right. Just like Google Calendar, but for your brain.

## [2:30 - Daily Recap]

At the end of the day, I generate a recap. The AI summarizes what I accomplished, highlights wins, and gently suggests what to focus on tomorrow. It always leads with what you did — never what you didn't.

## [2:50 - Dark Mode + Settings]

Warm dark mode for late night sessions. Daily check-in notifications — gentle, not nagging. And everything designed with cognitive accessibility in mind. No time estimates — they cause anxiety. Calm colors. Generous whitespace.

## [3:10 - Technical]

Under the hood: Flutter frontend, FastAPI backend, Claude Haiku powering a three-step AI pipeline. Each step has its own dedicated prompt — built and iterated with Kiro IDE, which made the development process significantly faster. Rate limiting, input validation, atomic database transactions. The code is open source on GitHub.

## [3:30 - Closing]

Clarity. You don't need to have it all figured out. Just tell us what's on your mind. We'll figure out the rest.

Built at the AWS Kiro Hackathon at Virginia Tech.
