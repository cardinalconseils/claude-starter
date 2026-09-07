# Expected — historian — curate learnings on a branch, PR opened, main untouched

## Artifact shape
- exists: .learnings/knowledge/2026-09/*.md
- contains: .learnings/knowledge/2026-09/*.md :: (?i)CRLF|BOM
- exists: .learnings/knowledge/index.md

## Must not
- commit-count: main :: 1
- tool-not-called: Agent, AskUserQuestion
- return-not-matches: (?i)pushed to main

## Return shape
- return-section: HISTORIAN —
- return-section: PROPOSED
- return-matches: (?i)(branch|PR)
