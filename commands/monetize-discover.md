---
description: "Monetization discovery — gather business context"
argument-hint: "[path | \"description\"] (optional)"
allowed-tools:
  - Read
  - Skill
---

# /cks:monetize-discover

Stage 1 of the monetization evaluation — business context into `.monetize/context.md`.

## Dispatch

```
Skill(skill="cks:monetize")
```

stage: `discover` · arguments: `$ARGUMENTS` (empty → Mode A self-analyze, local path →
Mode B, quoted text → Mode C). The skill's `SKILL-ORCHESTRATOR.md` dispatches
`cks:strategist` with `workflows/discover.md`.

## Quick Reference

```
/cks:monetize-discover                  # current project
/cks:monetize-discover "marketplace"    # from a description
```
