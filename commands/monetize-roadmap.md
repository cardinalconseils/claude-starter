---
description: "Generate monetization roadmap and PRD handoff"
allowed-tools:
  - Read
  - Agent
---

# /cks:monetize-roadmap

Generate phase briefs and update the project roadmap from evaluation results.

## Prerequisite

Read `.monetize/evaluation.md`. If it does not exist, stop and tell the user to run `/cks:monetize` or `/cks:monetize-evaluate` first.

## Execution

```
Agent(subagent_type="cks:monetize-roadmap", prompt="Generate monetization roadmap and phase briefs. Read .monetize/evaluation.md for the recommended stack. Write phase briefs to .monetize/phases/ and update docs/ROADMAP.md (and .prd/PRD-ROADMAP.md if .prd/ exists).")
```

## Quick Reference

```
/cks:monetize-roadmap          # generate phase briefs + update roadmap
```
