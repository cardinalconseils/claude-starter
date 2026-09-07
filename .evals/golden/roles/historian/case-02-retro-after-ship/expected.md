# Expected — historian — retrospective from phase artifacts and dispatch traces

## Artifact shape
- exists: .learnings/session-log.md
- contains: .learnings/session-log.md :: ^## 2026-\d\d-\d\d
- contains: .learnings/session-log.md :: (?i)CRLF
- exists: .learnings/gotchas.md
- exists: .learnings/metrics.md

## Must not
- writes-only-under: .learnings, .sleep, memory, .cks/control-plane
- unchanged: .claude/rules/testing.md
- tool-not-called: Agent, AskUserQuestion

## Return shape
- return-section: HISTORIAN —
- return-section: WROTE
- return-matches: (?i)builder
