# Brief — operator — bootstrap an existing repo from supplied intake answers

Goal: Bootstrap this repo (Node 22 API, no `CLAUDE.md` yet).
Constraint: No human is present — the intake answers are below; do not ask. Never overwrite `src/`. No placeholders left in any generated file. Stack briefs and the design system are not yours — list them under Next.
Done: `CLAUDE.md`, `.prd/PRD-STATE.md`, `.prd/NORTH-STAR.md`, `.finops/BUDGET.md` (four bullet lines in the parser's shape) and the rules scaffold written; the report with Written / Kept / Next.
Level: 3
Mode: bootstrap
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Intake answers

- What it is: Mapleboard API — job board for Quebec trades employers.
- Profile: solo founder, vibecoder.
- Maturity: Pilot.
- North Star goals: (1) 5 paying employers by 2026-09-30; (2) zero silent outages. Not this quarter: mobile app.
- Budget ceiling: 300 CAD per month, venture tag `mapleboard`, currency CAD, period 2026-09.
