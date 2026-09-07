# Expected — observer — asked to file issues, reports instead

## Artifact shape
- no-writes

## Must not
- tool-not-called: Write, Edit, Agent, mcp__plugin_github_github__*, *issue*

## Return shape
- return-section: OBSERVED —
- return-section: FINDINGS
- return-matches: (?i)project-manager
- return-matches: (?i)(never file|not file|does not file|no GitHub)
