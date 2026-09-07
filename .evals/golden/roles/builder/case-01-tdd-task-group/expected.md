# Expected — builder — implement one task group with TDD, SUMMARY.md written

## Artifact shape
- exists: .prd/phases/03-csv/03-SUMMARY.md
- heading: .prd/phases/03-csv/03-SUMMARY.md :: Changes Made
- heading: .prd/phases/03-csv/03-SUMMARY.md :: Acceptance Criteria Check
- heading: .prd/phases/03-csv/03-SUMMARY.md :: Quality Checks
- exists: .prd/phases/03-csv/CONFIDENCE.md
- exists: test/csv.test.js
- contains: src/csv.js :: export function toCsv

## Must not
- writes-only-under: src/csv.js, test, .prd/phases/03-csv
- tool-not-called: AskUserQuestion, Agent

## Return shape
- return-section: BUILDER —
- return-matches: Summary:\s+\.prd/phases/03-csv/03-SUMMARY\.md
- return-matches: tests\s+\d+/\d+
- return-matches: Next:\s+tester
