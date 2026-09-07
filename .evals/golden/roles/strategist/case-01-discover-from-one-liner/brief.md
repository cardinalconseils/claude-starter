# Brief — strategist — 11-element discovery from a one-line idea, non-interactive

Goal: Discover (11 elements) for the feature "Employers on Mapleboard want to export applicants to CSV".
Constraint: No human is present, so every question you would put through `AskUserQuestion` is returned instead — batched (max four per batch), each with a recommended answer and one sentence of reasoning, `(Recommended)` on the first option, and an escape hatch. Pre-fill from `CLAUDE.md` and `src/`. The hard gate holds: no `CONTEXT.md` until stories, criteria, test plan and UAT have answers.
Done: The STRATEGY block with the element questions under OPEN, nothing written under `.prd/phases/`.
Level: 3
Mode: discover
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
