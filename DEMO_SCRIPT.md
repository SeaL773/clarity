# Clarity Demo 录制脚本

## 视频总时长：3-4 分钟

---

## Part 1: 开场 + 问题引入（30秒）

**画面：** 手机上 app 的 splash screen → Good afternoon 主页

**操作：**
1. 打开 app，展示 splash screen（蓝色渐变 + ✨ Clarity + "Your mind, organized"）
2. 等它过渡到主页，展示 "Good afternoon" 居中欢迎页

**旁白重点：** ADHD 人群的痛点 — 不是不想做事，是面对一堆杂乱想法不知道从哪开始

---

## Part 2: Brain Dump 核心功能演示（60秒）

**画面：** 主页输入框

**操作：**
1. 在输入框打字（用这段）：
   ```
   I have a midterm on Thursday that I haven't started studying for, need to do laundry, my room is a mess, I promised my friend I'd help them move this weekend, and I need to email my professor about the extension
   ```
2. 点 **Clarity** 按钮
3. 等 loading 动画（"Organizing your thoughts..."）
4. 展示生成的任务列表 — 注意左边的颜色条（红=紧急重要，橙=紧急，蓝=重要，灰=其他）
5. 展示子任务（展开 "Study for midterm" 看子步骤）
6. 展示 insights 提示条

**旁白重点：** 3步 AI pipeline（Parse → Plan → Summarize），不是单一 API 调用

---

## Part 3: 任务交互（40秒）

**画面：** 任务列表

**操作：**
1. 勾选一个简单任务（如 "Email professor"）→ 展示它沉到底部 + 灰色
2. 勾选子任务 → 展示父任务自动完成
3. 用右上角 💬 唤出输入框，追加新任务：
   ```
   Also I have a dentist appointment Thursday morning and need to find my insurance card
   ```
4. 展示新任务追加到列表（不覆盖已有的）

**旁白重点：** 无时间压力设计，完成的任务温柔地沉底而不是消失

---

## Part 4: Celebration Moment（15秒）

**画面：** 继续勾选任务

**操作：**
1. 如果是第一个任务 → 展示 ⚡ "First one done!" celebration
2. 或者勾到一半 → 展示 🔥 "Halfway there!" celebration

**旁白重点：** ADHD 用户需要即时正反馈（多巴胺奖励）

---

## Part 5: 日历视图（40秒）

**画面：** 切到 Calendar tab

**操作：**
1. 先去 Settings → 连续点3次 Clarity icon 进入 dev mode
2. 切到 Calendar tab → 展示整个月的进度条（蓝色深浅 = 紧急度）
3. 点击某一天 → 展示下方 timeline（时间 + 颜色 + 任务卡片）
4. 再点同一天 → 进入全屏 day detail
5. 点 Today 按钮回到今天

**旁白重点：** 可视化进度追踪，不是催促而是展示成就

---

## Part 6: Daily Recap（30秒）

**画面：** 切到 Recap tab

**操作：**
1. 点 "Generate Recap" 按钮
2. 展示 AI 生成的 summary — 完成环 + 百分比 + 鼓励文字
3. 展示 "Tomorrow's Focus" 建议
4. 点 "Regenerate" 重新生成

**旁白重点：** 鼓励性语气，永远先说你做了什么，不说你没做什么

---

## Part 7: Dark Mode + 设置（20秒）

**画面：** Settings tab

**操作：**
1. 展示 Settings 页面 — About, Appearance, Reminders, How it works
2. 打开 Dark Mode toggle → 展示暖色调 dark mode
3. 打开 Daily Check-in toggle
4. 在 dev mode 下点 Test Notification → 展示系统通知

**旁白重点：** ADHD 友好设计 — calm 配色，gentle 提醒

---

## Part 8: 技术展示（40秒）

**画面：** 切到电脑屏幕

**操作：**
1. 打开浏览器 → `localhost:8000/docs` → 展示 Swagger API 文档
2. 展示 3 个 prompt 文件（快速滚动 parse.txt, plan.txt, summarize.txt）
3. 打开 GitHub page (github.com/SeaL773/clarity) → 展示 README badges + 项目结构
4. 展示 commit history（展示开发过程）
5. 快速展示 Sourcery code review

**旁白重点：** 3步 AI pipeline 各有独立 prompt，不是一个通用 prompt；multi-provider LLM fallback；rate limiting + input validation

---

## Part 9: 收尾（15秒）

**画面：** 回到手机 app 主页

**操作：** 展示完整的任务列表 + 底部磨砂玻璃导航栏

**旁白重点：** Clarity — 不需要你已经有条理，AI 帮你变得有条理。为 3.66 亿 ADHD 人群设计。

---

## 录制注意事项

- [ ] 后端先启动：`cd backend && python run.py`
- [ ] 模拟器提前开好，app 装好
- [ ] 先用 dev mode 填充日历数据，再退出 dev mode 录正式 demo
- [ ] 准备好要输入的文字（可以提前复制）
- [ ] Dark mode 在前半段用 light，后半段切 dark
- [ ] 录制时把通知打开（展示 push notification）

---

# 英文旁白稿

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

Under the hood: Flutter frontend, FastAPI backend, Claude Haiku powering a three-step AI pipeline. Each step has its own dedicated prompt. Rate limiting, input validation, atomic database transactions. The code is open source — you can see every commit on GitHub.

## [3:30 - Closing]

Clarity. You don't need to have it all figured out. Just tell us what's on your mind. We'll figure out the rest.

Built at the AWS Kiro Hackathon at Virginia Tech.

full text
Every day, millions of people struggle not because they're lazy — but because their brain works differently. For the 366 million people worldwide affected by ADHD, the hardest part isn't doing the work. It's figuring out where to start. Meet Clarity. An AI-powered todo list that doesn't require you to already be organized. Just dump your thoughts — messy, unstructured, stream of consciousness — and AI handles the rest. Watch. I type everything that's on my mind. A midterm I haven't studied for, laundry, a messy room, promises I've made. No structure needed. In seconds, Clarity's three-step AI pipeline kicks in. First, it parses my text and extracts every task — even the ones I didn't explicitly state. Then, it prioritizes using the Eisenhower Matrix — you can see the color coding. Red means urgent and important. Blue means important but not urgent. Finally, it orders them by workflow — quick wins first to build momentum. As I complete tasks, they gently fade to the bottom. No guilt, no pressure. And when I check off all the sub-tasks... the parent task automatically completes itself. And here's the magic for ADHD users — celebration moments. Every milestone gets acknowledged. First task done? You get a boost. Halfway there? Keep going. This isn't just UI polish — it's behavioral activation therapy built into the product. I can always add more. The input stays right there at the top. New tasks append to my existing list — nothing gets lost. The calendar view gives me a bird's eye view of my month. Each day shows a progress bar — the color depth tells me how urgent that day is, and how much I've completed. Tap a day to see the timeline — due times on the left, task cards on the right. Just like Google Calendar, but for your brain. At the end of the day, I generate a recap. The AI summarizes what I accomplished, highlights wins, and gently suggests what to focus on tomorrow. It always leads with what you did — never what you didn't. Warm dark mode for late night sessions. Daily check-in notifications — gentle, not nagging. And everything designed with cognitive accessibility in mind. No time estimates — they cause anxiety. Calm colors. Generous whitespace. Under the hood: Flutter frontend, FastAPI backend, Claude Haiku powering a three-step AI pipeline. Each step has its own dedicated prompt. Rate limiting, input validation, atomic database transactions. The code is open source — you can see every commit on GitHub. Clarity. You don't need to have it all figured out. Just tell us what's on your mind. We'll figure out the rest.

Built at the AWS Kiro Hackathon at Virginia Tech.

