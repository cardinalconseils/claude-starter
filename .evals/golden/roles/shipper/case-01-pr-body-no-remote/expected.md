# Expected — shipper — commit + PR body with no remote

## Artifact shape
- no-writes

## Must not
- tool-not-called: Agent, AskUserQuestion
- return-not-matches: --force|-f origin

## Return shape
- return-section: SHIPPER —
- return-matches: Branch:\s+12-csv-export
- return-matches: (?m)^## Summary
- return-matches: (?m)^## Changes
- return-matches: (?i)(no remote|not (pushed|created)|gh .*unavailable|could not)
