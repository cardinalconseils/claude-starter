# Workflow: Session Journal

Compose a dated DEVLOG entry from evidence. Ported from the `session-journalist` agent
(journal half; the handoff/DEVLOG state lines belong to the project manager). Run by the
historian role. Output: `memory/log.md` when the project has an Agentic OS `memory/`
directory (OKF `type: log`, `## [YYYY-MM-DD] Title` headers), else `.prd/DEVLOG.md`.

## 1. Gather evidence

Skip missing sources gracefully:
- `git log --since=midnight --oneline` — today's commits
- `.prd/PRD-STATE.md` — phase, status, next action
- `.learnings/session-{date}.md` — session learnings
- `.prd/logs/agents/*.jsonl` — today's dispatch outcomes per role (`.claude/rules/telemetry.md`)
- `git diff --stat` and `git status --short` — uncommitted work
- `grep -rn "TODO\|FIXME\|HACK"` (first 10)

No activity at all → report "Nothing to log" and stop.

## 2. Notes

If the dispatch carries user notes, include them. The historian holds no `AskUserQuestion`:
when notes would help, return the entry with a one-line "Add notes? Reflections, blockers,
or context for tomorrow" for the chief of staff to put to the founder; unattended → skip.

## 3. Compose

```markdown
## [{YYYY-MM-DD}] {Day of Week}

### Done
- {one bullet per meaningful commit or dispatch; group related work}

### State
- **Phase:** {from PRD-STATE}   **Branch:** {current}   **Uncommitted:** {count or Clean}

### Next
- {PRD-STATE next action; open TODOs worth noting}

### Blockers
- {FIXME/HACK items, failed dispatches, or "None"}

### Notes
{user notes — omit when skipped}
```

Human-readable summaries, not hashes; deduplicate; 30-second read.

## 4. Write

- `memory/log.md`: append (newest last, per the OKF reserved log format)
- `.prd/DEVLOG.md`: create with a header if absent; otherwise prepend after the header
  separator (newest first); a second entry for the same day goes above the first
- Never fabricate activity — only what git, logs, and session files show

## 5. Hand back

Return the entry path and a one-line summary. The project manager, not the historian,
updates the `Session History` table in `.prd/PRD-STATE.md` — include the line it should add:
`| {date} | {phase or —} | EOD summary logged | {path} updated |`.
