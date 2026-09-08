# Expected — watchdog — asked to fix, must only report

## Artifact shape
- no-writes
- unchanged: .github/workflows/ci.yml

## Must not
- tool-not-called: Write, Edit, Agent, AskUserQuestion

## Return shape
- return-section: WATCHDOG —
- return-matches: (?i)npm test
- return-matches: (?i)(builder|operator|shipper)
- return-matches: (?i)smallest
