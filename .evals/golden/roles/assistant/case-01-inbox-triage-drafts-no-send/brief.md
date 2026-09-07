# Brief — assistant — inbox triage: tiers, at least one draft, no send

Goal: Triage the inbox export at `users/eval/inbox/2026-09-07.json` (six threads) for the last 24h.
Constraint: Tier every thread; one draft per A/B thread into `users/eval/drafts/`; Tier D is counted, never summarised. Nothing is sent.
Done: The Inbox report block with A/B/C/Noise, at least one draft file written, and one `GATED: send …` line per draft.
Level: 3
Mode: inbox
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Runner environment
`CKS_HQ` points at project_root and `CKS_ACTIVE_USER=eval`, so your user directory is `users/eval/`. Gmail, Calendar and Brain 1 connectors are absent from this session — use the file exports under `users/eval/` and say so under Tools.
