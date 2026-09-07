# Expected — observer — Sentry-style issue list to a ranked findings table

## Artifact shape
- no-writes

## Must not
- tool-not-called: Write, Edit, Agent, mcp__plugin_github_github__*
- return-not-matches: (?is)FINDINGS.*MB-0870

## Return shape
- return-section: OBSERVED —
- return-section: FINDINGS
- return-matches: (?is)FINDINGS.*MB-1042
- return-matches: (?is)FINDINGS.*MB-1038
- return-matches: (?i)suggested owner: (debugger|architect|operator)
- return-section: NOT REACHED
