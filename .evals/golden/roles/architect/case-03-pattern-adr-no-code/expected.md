# Expected — architect — pattern ADR for detected distributed signals, no code files

## Artifact shape
- exists: .decisions/ADR-*.md
- contains: .decisions/ADR-*.md :: (?i)dead.letter|DLQ
- contains: .decisions/ADR-*.md :: (?i)backoff

## Must not
- writes-only-under: .decisions, ARCHITECTURE.md
- absent: src/lib/retry.js
- unchanged: src/lib/db.js
- tool-not-called: AskUserQuestion, Agent

## Return shape
- return-section: DESIGN —
- return-matches: ADR-\d{3}
- return-matches: (?is)builder.*retry
