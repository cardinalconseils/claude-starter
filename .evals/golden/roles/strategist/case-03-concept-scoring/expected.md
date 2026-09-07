# Expected — strategist — concept feasibility scoring with FEASIBILITY.md first

## Artifact shape
- exists: .concept/weekly-applicant-digest/FEASIBILITY.md
- heading: .concept/weekly-applicant-digest/FEASIBILITY.md :: Pillar 1
- heading: .concept/weekly-applicant-digest/FEASIBILITY.md :: Pillar 2
- heading: .concept/weekly-applicant-digest/FEASIBILITY.md :: Pillar 3
- heading: .concept/weekly-applicant-digest/FEASIBILITY.md :: Continuous Improvement Impact
- contains: .concept/weekly-applicant-digest/FEASIBILITY.md :: src/

## Must not
- writes-only-under: .concept
- tool-not-called: AskUserQuestion, Edit, Agent
- no-written-file-matches: (?i)seems like a good fit

## Return shape
- return-section: STRATEGY —
- return-matches: (?i)\b(go|defer|reject)\b
- return-matches: (?i)pre-mortem
- return-matches: \d(\.\d)?\s*/\s*5|\b[1-5](\.\d)?\b
