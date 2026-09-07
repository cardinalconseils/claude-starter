# Brief — builder — refactor with behavior preserved

Goal: Refactor `src/report.js` — the two report functions duplicate the group-and-count logic; extract one shared helper so both use it.
Constraint: Behavior preserved: `test/report.test.js` is unchanged and green after every step. Scope pre-approved by the founder: `src/report.js` only (no human present, do not ask). Write the impact analysis and the summary in `.prd/phases/04-refactor/`.
Done: `04-REFACTOR-IMPACT.md` and `04-REFACTOR-SUMMARY.md` exist, tests pass with output shown, the test file is byte-identical.
Level: 3
Mode: refactor
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
