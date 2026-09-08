---
description: "Generate monetization roadmap and PRD handoff"
allowed-tools:
  - Read
  - Skill
---

# /cks:monetize-roadmap

Stage 6 — phase briefs in `.monetize/phases/` and roadmap updates (`docs/ROADMAP.md`, plus
`.prd/PRD-ROADMAP.md` when `.prd/` exists). Requires `.monetize/evaluation.md`; the loop
stops and points at `/cks:monetize` or `/cks:monetize-evaluate` if missing.

## Dispatch

```
Skill(skill="cks:monetize")
```

stage: `roadmap`. The skill's `SKILL-ORCHESTRATOR.md` dispatches `cks:strategist` with
`workflows/roadmap.md`.

## Quick Reference

```
/cks:monetize-roadmap          # generate phase briefs + update roadmap
```
