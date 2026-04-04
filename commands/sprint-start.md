---
description: "Begin a work session — loads full operating context (CLAUDE.md, rules, PRD state, git) and validates guardrails are in place"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# /cks:sprint-start — Session Opening Ritual

Loads everything Claude needs to work effectively in this session. Run this at the start of every work session.

**This command is read-only — it never modifies any files.**

## How It Relates to Other Commands

- `/cks:standup` — reads DEVLOG, shows yesterday's activity (backward-looking)
- `/cks:sprint-start` — loads full operating context, validates guardrails (forward-looking)
- `/cks:sprint-close` — captures learnings, runs adherence check, updates constitution (session end)
- `/cks:eod` — writes DEVLOG entry (end of day journal)

Use `sprint-start` at session open. Use `sprint-close` at session end.
Use `standup` and `eod` for the daily journal ritual.

## Steps

### 1. Load Project Context

Read the following files silently (do not display raw content):

```
CLAUDE.md                       — Project constitution
.prd/PRD-STATE.md               — Current lifecycle position
.prd/PRD-PROJECT.md             — Project context
.prd/prd-config.json            — Profile and config
```

If CLAUDE.md is missing or still has `[TOKENS]` placeholders, warn:
```
⚠ CLAUDE.md is not configured. Run /cks:bootstrap first.
```
And stop.

### 2. Load Guardrails

Scan for active rule files:

```bash
ls .claude/rules/*.md 2>/dev/null
```

For each rule file found, read it and note its `globs:` scope.

If no `.claude/rules/` directory or no rule files exist, warn:
```
⚠ No guardrails found in .claude/rules/
  Run /cks:bootstrap to generate rules from your stack.
```

### 3. Load Session Memory

Re-inject learnings from recent sessions to maintain continuity:

```
.learnings/session-{today}.md       — Today's earlier sessions (if any)
.learnings/session-{yesterday}.md   — Yesterday's session (if returning)
.learnings/conventions.md           — Pending convention proposals
.learnings/gotchas.md               — Known pitfalls
```

Read each file **if it exists** (skip silently if missing). Extract:
- **Last session summary** — the most recent `## Session HH:MM — ...` header
- **Pending conventions** — any `- [ ]` items from conventions.md
- **Recent gotchas** — last 3 entries from gotchas.md

Do NOT display raw file contents. Summarize into the session brief (step 5).

### 4. Git Context

Gather current git state:

```bash
git branch --show-current
git log --oneline -5
git status --short
git stash list 2>/dev/null | head -3
```

### 5. Display Session Brief

```
Sprint Start — {today's date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project:    {name from CLAUDE.md}
Profile:    {from prd-config.json}
Phase:      {from PRD-STATE — e.g. "03 — Sprint (executing)" or "idle"}
Branch:     {current branch}
Uncommitted: {count or "Clean"}

Guardrails Active:
  {filename}    → {globs scope summary, e.g. "API routes, auth"}
  {filename}    → {globs scope summary}
  ...

Session Memory:
  Last session: {summary from most recent session file}

  Learnings from previous phases:
  {If .learnings/gotchas.md has entries, show the last 3:}
    ⚠ {gotcha 1 — one-line summary}
    ⚠ {gotcha 2 — one-line summary}
    ⚠ {gotcha 3 — one-line summary}

  {If .learnings/conventions.md has pending proposals, show them:}
    📋 Pending conventions ({count}):
    - {convention 1}
    - {convention 2}
    → Run /cks:retro to review and apply these

Recent Commits:
  {last 5 one-liners}

Suggested Next:
  → /cks:{command}  — {from PRD-STATE suggested_command}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If no `.learnings/` directory exists, omit the "Session Memory" section entirely.

### 6. Stale Check

If the last action date in PRD-STATE is more than 7 days ago, add:
```
⚠ Last activity was {N} days ago. Consider:
  /cks:standup   — Review what happened
  /cks:status    — Full project health
```

## Rules

1. **Read-only** — never modify any file
2. **Fast** — no agent dispatching, no heavy scans, no research
3. **Graceful** — if any file is missing, work with what's available
4. **Always show guardrails** — the rules summary is the key differentiator from standup
5. **Reference sprint-close** — remind the user to close at the end: "End session with /cks:sprint-close"
