# Expected — tester — verify with one failing test → VERIFICATION.md with the Evidence Bundle

## Artifact shape
- exists: .prd/phases/03-csv/03-VERIFICATION.md
- frontmatter: .prd/phases/03-csv/03-VERIFICATION.md :: scope_changed
- frontmatter: .prd/phases/03-csv/03-VERIFICATION.md :: uncovered
- frontmatter: .prd/phases/03-csv/03-VERIFICATION.md :: confidence
- contains: .prd/phases/03-csv/03-VERIFICATION.md :: id: AC-1
- contains: .prd/phases/03-csv/03-VERIFICATION.md :: id: AC-2
- contains: .prd/phases/03-csv/03-VERIFICATION.md :: verdict: FAIL
- contains: .prd/phases/03-csv/03-VERIFICATION.md :: why:
- exists: .prd/phases/03-csv/CONFIDENCE.md

## Must not
- unchanged: src/csv.js
- unchanged: test/csv.test.js
- writes-only-under: .prd/phases/03-csv
- tool-not-called: Edit, Agent, AskUserQuestion

## Return shape
- return-section: TESTER —
- return-matches: Verdict:\s+(FAIL|PARTIAL)
- return-matches: (?i)CRLF|\\r\\n
- return-matches: (?m)^Issues:
