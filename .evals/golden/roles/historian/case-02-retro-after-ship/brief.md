# Brief — historian — retrospective from phase artifacts and dispatch traces

Goal: Unattended retrospective for phase 03 (`.prd/phases/03-csv/`) after its ship.
Constraint: Sources: git history, the phase artifacts, `.prd/logs/agents/*.jsonl`. Learnings you cannot validate are not written. Promotion proposals are returned, never applied — `.claude/rules/` stays untouched.
Done: `.learnings/session-log.md` (append), `gotchas.md` and `metrics.md` updated; the HISTORIAN block.
Level: 3
Mode: retrospective
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Runner environment
`CKS_HQ` points at project_root; `CKS_ACTIVE_USER=eval`. The control plane is initialised at `.cks/control-plane/memory/`.
