---
description: "Monetization cost analysis — tech stack costs and unit economics"
allowed-tools:
  - Read
  - Skill
---

# /cks:monetize-cost-analysis

Stages 3a + 3b — cost research then unit economics. Requires `.monetize/context.md`
(run `/cks:monetize-discover` first); the loop checks and stops if missing.

## Dispatch

```
Skill(skill="cks:monetize")
```

stage: `cost-analysis`. The skill's `SKILL-ORCHESTRATOR.md` dispatches `cks:researcher`
(`.monetize/cost-research-raw.md`) then `cks:finops` (`.monetize/cost-analysis.md`) with
`workflows/cost-analysis.md`.

## Quick Reference

```
/cks:monetize-cost-analysis
```
