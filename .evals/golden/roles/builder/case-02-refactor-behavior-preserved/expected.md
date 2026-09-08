# Expected — builder — refactor with behavior preserved

## Artifact shape
- exists: .prd/phases/04-refactor/04-REFACTOR-IMPACT.md
- exists: .prd/phases/04-refactor/04-REFACTOR-SUMMARY.md
- contains: src/report.js :: export function employerReport
- contains: src/report.js :: export function cityReport

## Must not
- unchanged: test/report.test.js
- writes-only-under: src/report.js, .prd/phases/04-refactor
- tool-not-called: AskUserQuestion, Agent

## Return shape
- return-section: BUILDER —
- return-matches: tests\s+2/2
