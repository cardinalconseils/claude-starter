---
description: "Just tell me what you want to build — I handle the rest"
---

# Vibe Build — Zero-Knowledge Entry Point

## Purpose
You don't need to know commands, phases, or task order. Just describe what you want. This workflow handles everything.

## How It Works

You say what you want. I figure out the rest.

I'll ask you questions when I need answers, confirm before doing anything risky, and tell you what's happening in plain English. You never need to know command names or phase order.

## Steps

### Step 1: What do you want?

Ask the user: "What do you want to do?"

Accept anything:
- "I want a login page" → new feature
- "I need a Stripe payment integration" → new feature
- "Make my app faster" → improvement
- "I want users to be able to upload photos" → new feature
- "Fix the bug where checkout crashes" → bug fix
- "Audit my codebase" → audit
- "Check my code for security issues" → audit
- "Why is my app crashing?" → investigate
- "Something's wrong with login" → investigate
- "Investigate why users can't sign up" → investigate

### Step 2: What kind of thing is this?

Classify automatically based on the user's words:

| User says | Route to |
|-----------|----------|
| "build", "create", "add", "I want", "I need" | **New feature** → Step 3 |
| "fix", "broken", "bug", "crash", "error" | **Bug fix** → Step 4 |
| "audit", "review code", "check quality", "security check" | **Audit** → Step 5 |
| "why", "investigate", "debug", "what's wrong", "something's wrong" | **Investigate** → Step 6 |
| "improve", "make faster", "refactor", "optimize" | **Improvement** → Step 3 (from design) |
| Unclear | Ask: "Is this something new, fixing something broken, checking your code, or figuring out why something's wrong?" |

### Step 3: Full Lifecycle (New Features)

Run all 5 phases automatically. Only stop to ask questions or get confirmations.

**Phase 1 — Discover (I ask you questions):**
- I'll ask you about your problem, users, scope, etc.
- You just answer in plain English
- I write everything down
- When done, I show you a summary and ask: "Does this look right?"
- You say yes → I continue
- You say no → I ask what to change

**Phase 2 — Design (I show you the plan):**
- I design how it will work
- I show you the design and ask: "Does this design work for you?"
- You say yes → I continue
- You say no → I ask what to change

**Phase 3 — Sprint (I build it):**
- I plan the tasks
- I write tests first
- I implement the code
- I verify everything works
- If something fails, I fix it automatically (up to 3 times)
- I create a pull request
- I show you what I built and ask: "Ready to review?"

**Phase 4 — Review (I summarize):**
- I review what was built
- I tell you what went well and what didn't
- I ask: "Are you happy with this, or do you want changes?"
- Happy → I continue to release
- Want changes → I go back and fix them

**Phase 5 — Release (I deploy it):**
- I deploy to dev and check it works
- I deploy to staging and run tests
- I deploy to RC and set up monitoring
- I ask: "Ready to go to production?"
- You say yes → I deploy to production
- You say no → I wait
- I watch monitoring for 15 minutes
- I report: "Your feature is live!"

### Step 4: Bug Fix (Fixing Broken Things)

- I reproduce the bug
- I find the root cause
- I fix it with minimal changes
- I verify the fix works
- I check nothing else broke
- I create a pull request
- I show you the fix and ask: "Ready to merge?"

### Step 5: Audit (Checking Your Code)

- I scan your entire codebase
- I check for security issues, performance problems, code quality, test coverage, and maintainability
- I categorize every issue by severity (critical, high, medium, low)
- I write a full report to `.phases/AUDIT-REPORT.md`
- I show you a plain-English summary:
  - "I found {N} issues in your codebase"
  - "{N} critical, {N} high, {N} medium, {N} low"
  - "The most important thing to fix is: {top issue}"
- I ask: "Want me to fix any of these? Just tell me which ones."
- If you say yes → I fix them automatically (with confirmation on each)

### Step 6: Investigate (Figuring Out Why Something's Wrong)

- I ask you what's happening and what should be happening
- I check error logs, stack traces, and recent changes
- I trace the problem to its root cause
- I explain what's wrong in plain English
- I propose a fix and tell you how complex it is
- I write a full report to `.phases/INVESTIGATION-REPORT.md`
- I ask: "Want me to fix it? I can do that right now."
- If you say yes → I fix it, add a test to prevent it from happening again, and create a PR

### Step 7: Done

When everything is complete, I show you:
```
✅ DONE!

What was built: {plain English summary}
Where to find it: {PR link or file paths}
What's next: {suggestion in plain English}
```

## Rules

- **Never expect the user to know commands** — I handle all routing
- **Never expect the user to know phase order** — I handle the sequence
- **Always explain in plain English** — no jargon, no technical terms unless necessary
- **Always ask before doing anything risky** — deployments, deletions, migrations
- **Always show progress** — tell the user what's happening at each step
- **Always pause for input when needed** — don't rush past questions
- **Always recover from errors** — if something fails, fix it or explain what happened
- **State is on disk** — if we get interrupted, we can pick up where we left off

## State Recovery

If the user comes back after an interruption:
1. Read `.phases/PRD-STATE.json`
2. Tell the user: "Last time we were working on {feature_name}. We got to {phase}. Want to continue?"
3. If yes → resume from where we left off
4. If no → start something new

## What the User Sees

The user should never see technical details unless they ask. They see:
1. Questions (when I need answers)
2. Confirmations (before risky actions)
3. Progress updates (what I'm doing)
4. Results (what I built/fixed)
4. Next steps (what to do after)

That's it. No commands, no phases, no task lists. Just a conversation.
