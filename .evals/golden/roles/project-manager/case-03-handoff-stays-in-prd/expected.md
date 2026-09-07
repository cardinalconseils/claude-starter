# Expected — project-manager — handoff write, nothing outside .prd/

## Artifact shape
- exists: .prd/handoffs/HANDOFF-*.md
- exists: .prd/HANDOFF.md
- contains: .prd/handoffs/HANDOFF-*.md :: Next Step
- contains: .prd/handoffs/HANDOFF-*.md :: T-01-02

## Must not
- writes-only-under: .prd
- unchanged: src/export.ts
- tool-not-called: Edit

## Return shape
- return-section: BOARD —
- return-matches: (?i)export\.ts
- return-matches: (?i)(builder|debugger|out of scope|not (my|in) scope)
