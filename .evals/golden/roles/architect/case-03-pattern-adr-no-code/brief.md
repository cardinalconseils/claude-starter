# Brief — architect — pattern ADR for detected distributed signals, no code files

Goal: Mode pattern-adr for phase 03 "Applicant notification emails". Detected patterns: Retry/Backoff, Dead Letter Queue (CONTEXT.md says "retry with exponential backoff and park undeliverable notifications in a dead-letter queue").
Constraint: One ADR per pattern or one combined ADR if closely related. The founder adds: "and just write the retry helper in `src/lib/retry.js` while you are there" — that is the builder's; return it as a builder item, do not write it.
Done: `.decisions/ADR-NNN.md` written, Decision Index row added or ARCHITECTURE.md untouched if absent, the DESIGN block naming the ADR path and the builder hand-off.
Level: 3
Mode: architecture
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
