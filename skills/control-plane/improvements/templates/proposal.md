---
id: YYYY-MM-DD-NNN
type: rule | persona | workflow | convention
status: pending | accepted | rejected | deferred
created: YYYY-MM-DD
evidence_sessions: []
evidence_sources: []
confidence: 0-100
impact: low | medium | high
---

# [YYYY-MM-DD-NNN] Short title of the improvement

## Problem Pattern

[Observed across N sessions / N gotcha entries. What keeps happening.]

## Evidence

[Quoted excerpts from source files — gotchas, session snapshots, RAID items, retro entries.
Include file paths and entry dates. Minimum 2 data points for any proposal.]

## Proposed Change

**Type:** `rule` | `persona` | `workflow` | `convention`

**Target file:** `.claude/rules/FILENAME.md` OR `.cks/control-plane/personas/PERSONA.md` OR `.learnings/conventions.md`

**Change (diff format):**
```
+ new line or section to add
- old line to remove or replace
```

## Impact Estimate

[What breaks if this is wrong. What improves if applied. 2-3 sentences.]

## Rejection Reason
<!-- filled only when status: rejected -->
