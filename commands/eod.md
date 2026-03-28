---
description: "End of day — summarize today's work into a dated DEVLOG entry with state and next steps"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# /cks:eod — End of Day

Compose a dated DEVLOG entry summarizing today's work, current state, and next steps.
Writes to `.prd/DEVLOG.md` (rolling journal, newest entries first).

## Steps

### 1. Gather Context

Collect today's activity from all available sources:

- **Git commits today:** `git log --since=midnight --oneline`
- **PRD state:** Read `.prd/PRD-STATE.md` for current phase, status, last/next action
- **Session snapshots:** Read `.learnings/session-{YYYY-MM-DD}.md` (today's date) if it exists
- **Uncommitted work:** `git diff --stat` and `git status --short`
- **Open markers:** Quick grep for `TODO|FIXME|HACK` in source directories (limit to 10 results)

If no commits, no session file, and no uncommitted changes exist, tell the user:
```
Nothing to log — no activity detected today.
Run /cks:status to check project state.
```
And stop.

### 2. Ask for Notes (optional)

Use `AskUserQuestion` to ask:
> "Anything to add to today's entry? Reflections, blockers, or context for tomorrow?"

Provide two options:
- **"Skip"** — no notes, continue
- **"Add notes"** — user types freeform text

### 3. Compose Entry

Build a markdown block with this exact structure:

```markdown
## {YYYY-MM-DD} — {Day of Week}

### Done
- {one bullet per meaningful commit or activity, derived from git log + session learnings}
- {group related commits into single bullets when they're part of the same change}

### State
- **Phase:** {from PRD-STATE, e.g. "03 — Sprint (executing)" or "— (not started)"}
- **Branch:** {current git branch}
- **Uncommitted:** {count of modified files, or "Clean"}

### Next
- {from PRD-STATE next action}
- {any open TODO/FIXME items worth noting}

### Blockers
- {any FIXME/HACK annotations found, or "None"}

### Notes
{user's notes if provided — omit this entire section if user skipped}
```

**Writing rules:**
- "Done" bullets should be human-readable summaries, not raw commit hashes
- Deduplicate — if the same work appears in commits and session file, mention it once
- Keep the entry concise — aim for something you'd want to read in 30 seconds

### 4. Write to DEVLOG.md

**If `.prd/DEVLOG.md` does not exist**, create it with:

```markdown
# Development Log

_Rolling journal of daily development activity. Newest entries first._

---

{composed entry}
```

**If `.prd/DEVLOG.md` already exists**, prepend the new entry directly after the `---` separator line that follows the header. The entry goes BEFORE any existing dated entries to maintain newest-first ordering.

**If an entry for today's date already exists**, prepend the new entry above the existing one (don't merge — multiple EODs in a day are fine, they show progression).

### 5. Update PRD-STATE.md

Append a row to the **Session History** table in `.prd/PRD-STATE.md`:

```
| {YYYY-MM-DD} | {current phase or "—"} | EOD summary logged | DEVLOG.md updated |
```

### 6. Log Event

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "devlog.eod" "global" "End of day logged for {YYYY-MM-DD}"
```

If the script doesn't exist or fails, skip silently — logging is not critical.

### 7. Confirmation

Display:

```
EOD Logged
━━━━━━━━━━━━━━━━━━━━━━
  Date:     {YYYY-MM-DD}
  Commits:  {N} today
  DEVLOG:   .prd/DEVLOG.md updated
  State:    PRD-STATE session history updated

  Tomorrow: run /cks:standup to resume
━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

1. **Never fabricate activity** — only report what git and session files show
2. **Keep entries concise** — this is a journal, not a report
3. **Graceful degradation** — if any source (learnings, PRD-STATE) is missing, skip it and work with what's available
