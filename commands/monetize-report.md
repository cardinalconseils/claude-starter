---
description: "Generate monetization assessment report"
allowed-tools:
  - Read
  - Skill
---

# /cks:monetize-report

Stage 5 — the business case at `docs/monetization-assessment.md`. Requires
`.monetize/evaluation.md` (run `/cks:monetize-evaluate` first); the loop checks and stops
if missing.

## Dispatch

```
Skill(skill="cks:monetize")
```

stage: `report`. The skill's `SKILL-ORCHESTRATOR.md` dispatches `cks:strategist` with
`workflows/report.md` and `references/report-template.md`.

## Quick Reference

```
/cks:monetize-report
```
