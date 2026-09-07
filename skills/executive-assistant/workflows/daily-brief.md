# Daily Brief

Morning standup for one owner: what happened, what is on today, where to pick up. Ported
from the standup reader and widened with the inbox, calendar, and reminders side.
Read-only except `conversation-state.json`.

## 1. Project side

```bash
ls -t .learnings/session-*.md 2>/dev/null | head -1
git log --oneline -5
git status --short
git branch --show-current
```

Read the latest session file's most recent `## Session` entry (none → note "no DEVLOG yet;
`/cks:sprint-close` writes one"). Read `.prd/PRD-STATE.md` for phase and status and
`.prd/status-packet.json` when present. Commits since the DEVLOG date
(`git log --since="<devlog date>" --oneline`) are "overnight changes". Check for a handoff:
`.prd/HANDOFF.md`, else the newest `.prd/handoffs/HANDOFF-*.md` — quote it in full under
its own header when found; it is the primary source for where to resume.

## 2. Person side

- Tier-A threads from `workflows/inbox-triage.md` (window: since last triage)
- Today's events with gaps, conflicts, and missing prep from `workflows/calendar-review.md`
  (window: today only)
- Due or overdue reminders (`## [` lines with due ≤ now)
- Follow-ups whose nudge date is today or past (`followups.md`)
- Burn line when `.finops/BUDGET.md` exists: `<spend> of <ceiling> <currency> (<pct>%)`

Skip a section cleanly when its tools are absent; say which.

## 3. Display

```
Daily Brief — <date> — <owner>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Yesterday: <3–5 lines from the DEVLOG — done, decided>
Handoff:   <full contents, or "none">

Project:   phase <…> · branch <…> · uncommitted <n|clean> · overnight commits <n>
Budget:    <spend> of <ceiling> (<pct>%)

Inbox A:   <sender> — "<subject>" — <ask> — draft <id|path>
Calendar:  <time> <event> — <flag or ok> · focus block <kept|missing>
Reminders: <due lines>
Follow-ups:<person> — "<subject>" — nudge due

Today:     → <one suggested action from phase + DEVLOG + inbox>
           → /cks:<command>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GATED: <one line per draft produced>
```

Rules: yesterday in 3–5 lines; always end with one next command; no draft is sent.
