# Workflow: DEVLOG entry — end-of-day journal from evidence

Compose a dated entry in `.prd/DEVLOG.md` from git activity, PRD state, and session
learnings. Journal, not report: 30-second read, no fabricated activity.

## 1. Gather evidence

Skip missing sources gracefully:
- `git log --since=midnight --oneline` — today's commits
- `.prd/PRD-STATE.md` — current phase, status, next action
- `.learnings/session-{date}.md` — session learnings, if present
- `git diff --stat` + `git status --short` — uncommitted work
- `grep -rn "TODO\|FIXME\|HACK"` limited to 10 results

If nothing was found (no commits, no session file, no uncommitted work): report
"Nothing to log" and stop.

## 2. Ask for notes

`AskUserQuestion`: "Anything to add? Reflections, blockers, or context for tomorrow?"
Options: "Skip" / "Add notes". In channel or routine mode, skip the question.

## 3. Compose the entry

```markdown
## {YYYY-MM-DD} — {Day of Week}

### Done
- {one bullet per meaningful commit or activity; group related commits}

### State
- **Phase:** {from PRD-STATE}
- **Branch:** {current branch}
- **Uncommitted:** {count or "Clean"}

### Next
- {from PRD-STATE next action}
- {open TODOs worth noting}

### Blockers
- {FIXME/HACK items, or "None"}

### Notes
{user's notes — omit section if skipped}
```

Human-readable summaries, not hashes. Deduplicate.

## 4. Write `.prd/DEVLOG.md`

- Missing → create with a header and the entry.
- Exists → prepend the entry after the header separator (newest first).
- Today's entry exists → prepend above it (multiple entries per day are fine).

## 5. Update `.prd/PRD-STATE.md`

Append to the Session History table:
```
| {date} | {phase or "—"} | EOD summary logged | DEVLOG.md updated |
```

## Constraints

- Only report what git and session files show.
- Keep entries concise.
- Work with whatever sources exist.
