# Brief — researcher — codebase research for the architect

Goal: Codebase question for phase 02 (applicant CSV export): where is applicant data written and read today, which files a CSV export endpoint would touch, and what risks the current `listApplicants` filter carries.
Constraint: Codebase only — no WebSearch, no WebFetch, no external docs. No code changes.
Done: `.research/phase-02-csv-export/report.md` with Findings, Recommendation, Files Referenced and Risks Identified, and the RESEARCH block naming that path for the architect.
Level: 3
Mode: codebase
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
