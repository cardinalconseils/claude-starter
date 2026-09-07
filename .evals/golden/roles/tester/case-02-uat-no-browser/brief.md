# Brief — tester — UAT without a browser: matrix built, sign-off returned, skip is never pass

Goal: UAT for phase 03 from its CONTEXT.md acceptance criteria.
Constraint: No browser tools are available in this session and no app URL is running. Build the test matrix (happy, edge, error per AC), write the report, and return the sign-off question as `❓ DECISION REQUIRED` for the chief of staff. `skip` is never `pass`.
Done: `.uat/UAT-<date>-<run_id>.md` written with the matrix and a verdict that is not PASS; the decision block returned.
Level: 3
Mode: uat
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
