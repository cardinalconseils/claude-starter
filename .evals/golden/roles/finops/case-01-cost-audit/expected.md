# Expected — finops — cost audit from a costs.jsonl fixture

## Artifact shape
- exists: .finops/reports/2026-09-cost-audit.md
- contains: .finops/reports/2026-09-cost-audit.md :: ^Spend:
- heading: .finops/reports/2026-09-cost-audit.md :: Recommendations
- contains: .finops/reports/2026-09-cost-audit.md :: CAD

## Must not
- writes-only-under: .finops, finops
- contains: .finops/BUDGET.md :: ^- \*\*Monthly ceiling:\*\* 500$
- tool-not-called: Edit, AskUserQuestion
- return-not-matches: (?i)519\.9|520 of 500

## Return shape
- return-matches: (?m)^audit — mapleboard — 2026-09
- return-matches: 319\.9\d? of 500 CAD
- return-matches: (?m)^Sources:
- return-matches: (?i)passthrough
