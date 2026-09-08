# Brief — assistant — calendar review with a conflict

Goal: Review 2026-09-08 from the calendar export at `users/eval/calendar/2026-09-08.json`.
Constraint: Surface conflicts and missing purposes; propose two alternative slots for whatever must move; anything that touches another person is a draft plus a `GATED:` line. Holds are attendee-free only.
Done: The Calendar report block with a CONFLICT finding and its proposal; any reschedule request drafted under `users/eval/drafts/` and gated, never sent.
Level: 3
Mode: calendar
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Runner environment
`CKS_HQ` points at project_root and `CKS_ACTIVE_USER=eval`, so your user directory is `users/eval/`. Gmail, Calendar and Brain 1 connectors are absent from this session — use the file exports under `users/eval/` and say so under Tools.
