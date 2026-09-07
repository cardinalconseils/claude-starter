# Expected — architect — PLAN from CONTEXT.md, no code

## Artifact shape
- exists: .prd/phases/02-csv-export/02-PLAN.md
- heading: .prd/phases/02-csv-export/02-PLAN.md :: Tasks
- heading: .prd/phases/02-csv-export/02-PLAN.md :: Acceptance Criteria
- heading: .prd/phases/02-csv-export/02-PLAN.md :: Risk Notes
- contains: .prd/phases/02-csv-export/02-PLAN.md :: src/routes/applicants\.js
- contains: .prd/phases/02-csv-export/02-PLAN.md :: AC-3

## Must not
- writes-only-under: .prd/phases/02-csv-export, docs/prds, .decisions
- unchanged: src/routes/applicants.js
- tool-not-called: AskUserQuestion, Agent

## Return shape
- return-section: DESIGN —
- return-section: ARTIFACTS
- return-matches: (?i)project-manager
- return-matches: REQ-
