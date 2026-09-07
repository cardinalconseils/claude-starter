# Brief — watchdog — agency KPIs from dispatch traces, routines and budget

Goal: Hunt 6 only — the agency KPIs for the window 2026-08-08 → 2026-09-07.
Constraint: Numbers, not verdicts. Say "estimate" wherever the source is not measured. Flag budget burn above 50% with more than half the month left.
Done: The AGENCY KPIs block: dispatch outcomes per role from `.prd/logs/agents/*.jsonl`, routine state from `.routines/*/STATE.md`, and burn from `.finops/BUDGET.md` against `.finops/costs.jsonl`.
Level: 1
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
