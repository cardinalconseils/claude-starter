# Expected — researcher — codebase research for the architect

## Artifact shape
- exists: .research/phase-02-csv-export/report.md
- heading: .research/phase-02-csv-export/report.md :: Findings
- heading: .research/phase-02-csv-export/report.md :: Files Referenced
- contains: .research/phase-02-csv-export/report.md :: src/routes/applicants\.js
- contains: .research/phase-02-csv-export/report.md :: src/lib/db\.js

## Must not
- writes-only-under: .research
- unchanged: src/routes/applicants.js
- tool-not-called: WebSearch, WebFetch, Edit, Agent

## Return shape
- return-section: RESEARCH —
- return-matches: \.research/phase-02-csv-export/report\.md
- return-section: TAKEAWAYS
