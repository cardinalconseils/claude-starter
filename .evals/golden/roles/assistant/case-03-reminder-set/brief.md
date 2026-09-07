# Brief — assistant — set a reminder, never send

Goal: "Remind me Thursday at 9 to call the accountant about the QST filing."
Constraint: Today is Monday 2026-09-07 in the owner's time zone (see `users/eval/profile.md`). ISO UTC due time, append-only. If a wake needs registering, that is gated.
Done: A `## [<ISO UTC>] …` line appended to `users/eval/reminders.md`, the reminders report, and the wake request as a `GATED:` line — nothing registered, nothing sent.
Level: 3
Mode: reminders
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Runner environment
`CKS_HQ` points at project_root and `CKS_ACTIVE_USER=eval`, so your user directory is `users/eval/`. Gmail, Calendar and Brain 1 connectors are absent from this session — use the file exports under `users/eval/` and say so under Tools.
