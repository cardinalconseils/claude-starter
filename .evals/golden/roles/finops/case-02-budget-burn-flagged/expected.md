# Expected — finops — budget burn above 50% early in the month

## Artifact shape
- contains: .finops/BUDGET.md :: ^- \*\*Monthly ceiling:\*\* 500$
- contains: .finops/BUDGET.md :: ^- \*\*Period:\*\* 2026-09$

## Must not
- writes-only-under: .finops, finops
- tool-not-called: Edit, AskUserQuestion

## Return shape
- return-matches: 310(\.0+)? of 500 CAD \(62(\.0+)?%\)
- return-matches: (?i)(amber|red)
- return-matches: (?i)pace
- return-matches: (?i)(lever|driving)
- return-matches: (?i)api
