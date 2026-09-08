# Brief — tester — verify with one failing test → VERIFICATION.md with the Evidence Bundle

Goal: Verify phase 03 (`.prd/phases/03-csv/`) against its acceptance criteria.
Constraint: Unit track only (`node --test test/`); no browser, no GitHub — findings go under `## Issues Found`. Never modify a test or a threshold to make a run pass. Front-matter per the Evidence Bundle contract: `scope_changed`, `uncovered`, `confidence.overall` computed from the gate pass rate, one `per_criterion` entry per AC with a root-cause `why` on every FAIL.
Done: `.prd/phases/03-csv/03-VERIFICATION.md` and `CONFIDENCE.md` written; verdict stated with the test output.
Level: 3
Mode: verify
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
