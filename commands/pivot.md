---
description: "Formalize a strategic pivot — ingest a research conversation, extract the new direction, update CONTEXT.md and learnings"
argument-hint: "[path/to/conversation.txt] [--icp \"new target\"] [--why \"trigger summary\"]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:pivot — Strategic Pivot

Dispatch the **pivot-analyzer** agent to extract a strategic pivot decision and update project artifacts.

```
Agent(subagent_type="cks:pivot-analyzer", prompt="Run a strategic pivot analysis. Read .prd/PRD-STATE.md to identify the current project state and active CONTEXT.md. The user may provide a conversation transcript, a file path, or shorthand flags as arguments — use all of them as pivot signal input. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:pivot                              → interactive — agent asks what changed and why
/cks:pivot path/to/research.txt         → ingest a saved conversation or research doc
/cks:pivot --icp "solopreneur"          → shorthand: pivot on ICP only
/cks:pivot --why "competitor closed gap" → shorthand: record trigger, pivot interactively
```

## What This Does

1. Reads current CONTEXT.md and project direction
2. Accepts conversation transcript or flags as pivot signal
3. Extracts: broken assumption, new direction, supporting evidence
4. Confirms the pivot with you via `AskUserQuestion` before writing anything
5. Updates CONTEXT.md with revised ICP, positioning, acceptance criteria
6. Creates `.learnings/pivots/{date}-{slug}.md` — pivot audit trail

## When to Use

- Research revealed a competitor closed your gap
- A user interview broke a core assumption
- Deep-research agent recommended a new ICP or direction
- You discovered the real pain point differs from what you originally specced

## After Agent Completes

The agent will show what changed. Review the diff, then continue with:
- `/cks:design` — redesign for the new direction
- `/cks:discover` — re-discover if scope changed significantly
- `/cks:retro` — capture this as a learning milestone
