---
description: "Morning standup — recap last DEVLOG entry, cross-reference current state, suggest next action"
allowed-tools: Read, Bash, Glob, Grep
---

# /cks:standup — Morning Standup

Read the latest DEVLOG entry, cross-reference with current project state, and suggest where to pick up.

This command is **read-only** — it never modifies any files.

## Steps

### 1. Check for DEVLOG

Read `.prd/DEVLOG.md`.

If the file does not exist or contains no dated entries (no `## YYYY-MM-DD` sections), display:

```
No DEVLOG entries found.

  Options:
  - Run /cks:eod to create your first entry
  - Run /cks:status for current project state
```

And stop.

### 2. Parse Latest Entry

Extract the first `## YYYY-MM-DD` section from DEVLOG.md (this is the newest entry since the file is newest-first).

Read all content from that `## YYYY-MM-DD` header down to the next `## YYYY-MM-DD` header (or end of file if it's the only entry).

Note the entry date for cross-referencing.

### 3. Cross-Reference Current Reality

Gather current state to detect what changed since the DEVLOG entry:

- `git log --oneline -10` — check for commits after the DEVLOG entry date
- `git status --short` — any uncommitted changes right now?
- `git branch --show-current` — current branch
- `.prd/PRD-STATE.md` — current phase, status, suggested command

Compare:
- **New commits?** Count commits with dates after the DEVLOG entry date
- **Branch changed?** Is the current branch different from what the DEVLOG recorded?
- **New uncommitted work?** Files modified since the entry

### 4. Display Standup

Format the output as:

```
Morning Standup — {today's date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Last Session ({DEVLOG entry date}):
  {Done bullets from the DEVLOG entry, indented with 2 spaces}

Current State:
  Phase:      {from PRD-STATE, e.g. "03 — Sprint (executing)"}
  Branch:     {current branch}
  Since EOD:  {N new commits / "no changes" / "branch changed to X"}

Remaining:
  {Next items from the DEVLOG entry}

{Only if blockers existed in DEVLOG:}
Blockers:
  {blockers from DEVLOG entry}

Suggested Next:
  → /cks:{command}  — {reason}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 5. Suggest Next Command

Use this priority order:
1. If PRD-STATE has a `Suggested Command`, use it with its context
2. If there are uncommitted changes, suggest reviewing them: `/cks:status`
3. If no active phase, suggest `/cks:new` to start a feature
4. Default to `/cks:progress`

## Rules

1. **Read-only** — never modify any file
2. **Fast** — no agent dispatching, no heavy scans
3. **Graceful** — if PRD-STATE or learnings are missing, work with what's available
4. **Honest** — if the DEVLOG entry is stale (more than 3 days old), note it: "Entry is {N} days old — consider running /cks:eod to refresh"
