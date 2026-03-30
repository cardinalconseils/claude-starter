---
description: "End a work session — runs adherence check, captures learnings, updates CLAUDE.md if needed"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# /cks:sprint-close — Session Closing Ritual

Wraps up a work session by auditing rule adherence, capturing learnings, and proposing constitution updates.

## How It Relates to Other Commands

- `/cks:sprint-start` — loads context (session open)
- `/cks:sprint-close` — audits + captures learnings (session close)
- `/cks:eod` — writes DEVLOG journal entry (daily log)
- `/cks:standup` — reads DEVLOG (morning review)

Sprint-close is the **governance** close. EOD is the **journal** close.

## Step 1: Quick Adherence Check (inline — fast)

Read all `.claude/rules/*.md` files. For each rule:
1. Extract `globs:` frontmatter to know which files it governs
2. Get changed files: `git diff --name-only HEAD~1`
3. Filter changed files against each rule's globs
4. Grep for violation patterns in matching files
5. Score: A (0 violations) through F (11+)

If no `.claude/rules/` files exist, skip and note: "No guardrails — consider /cks:bootstrap."

Display summary:
```
Adherence: {grade} — {N} violations across {M} rule files
```

## Step 2: Capture Learnings via Retrospective Agent

```
Agent(subagent_type="retrospective", prompt="SESSION CLOSE MODE — lightweight end-of-session learning capture. Read git log --since='8 hours ago', .prd/PRD-STATE.md, and .learnings/ if they exist. Ask the user ONE question about learnings via AskUserQuestion. If they have something, propose a CLAUDE.md or .claude/rules/ update (never auto-edit). Save session entry to .learnings/session-{date}.md. Be fast — this is a closing ritual, not a deep retro.")
```

## Step 3: Display Summary

```
Sprint Close — {date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Commits:    {N} (last 8h)
  Adherence:  {grade} ({N} violations)
  CLAUDE.md:  {Updated / No changes}
  Learnings:  {Captured / None}

  Next session: /cks:sprint-start
```

## Rules

1. **Always run adherence check first** — key differentiator from /cks:eod
2. **Never auto-update CLAUDE.md** — always ask user first
3. **Respect the 150-line cap** — if at limit, propose swap (remove + add)
4. **Graceful if no rules** — skip adherence, still capture learnings
5. **Fast** — adherence is inline grep, only learnings use an agent
