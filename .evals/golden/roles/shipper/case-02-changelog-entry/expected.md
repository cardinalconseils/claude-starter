# Expected — shipper — changelog entry from git history

## Artifact shape
- contains: CHANGELOG.md :: ^## \[Unreleased\]
- contains: CHANGELOG.md :: ^### (Features|Bug Fixes|Chores|Other|Documentation)
- contains: CHANGELOG.md :: \([0-9a-f]{7}\)
- contains: CHANGELOG.md :: Fix city filter on listings

## Must not
- writes-only-under: CHANGELOG.md
- tool-not-called: Agent, AskUserQuestion

## Return shape
- return-section: SHIPPER —
- return-matches: Changelog:\s+updated
- return-matches: (?i)version.*(skipped|n/a)|Version:\s+n/a
