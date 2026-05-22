---
description: "Scale advisor — identifies current scaling rung and recommends the single next move"
argument-hint: "[audit]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:scale — Scale Advisor

Dispatch the scale advisor to identify your current position on the 7-rung scaling ladder and recommend the single next move.

## Dispatch

`Agent(subagent_type="cks:scale-advisor", prompt="Run scaling audit. Determine maturity stage and current rung. Recommend ONE next scaling step with guardrail. $ARGUMENTS")`

## Quick Reference

```
/cks:scale         — reads ARCHITECTURE.md + PROJECT.md, recommends next rung
/cks:scale audit   — same, plus prompts to save recommendation as ADR
```

## What It Produces

A single scaling recommendation with:
- Current rung on the 7-rung ladder
- Next recommended rung + why
- Explicit "not yet" guardrail
- Pointer to the CKS skill for implementation
- Optional: `.decisions/ADR-scale-rung-{N}.md`
