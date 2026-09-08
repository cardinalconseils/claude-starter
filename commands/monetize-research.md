---
description: "Monetization market research"
allowed-tools:
  - Read
  - Skill
---

# /cks:monetize-research

Stage 2 — market intelligence into `.monetize/research.md`. Requires
`.monetize/context.md` (run `/cks:monetize-discover` first); the loop checks and stops if
missing.

## Dispatch

```
Skill(skill="cks:monetize")
```

stage: `research`. The skill's `SKILL-ORCHESTRATOR.md` dispatches `cks:researcher` with
`workflows/research.md` and asks you to review the findings before evaluation.

## Quick Reference

```
/cks:monetize-research
```
