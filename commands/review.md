---
description: "Phase 4: Sprint Review & Retrospective — feedback, retro, iteration decision"
argument-hint: "[phase number]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:review — Phase 4: Sprint Review & Retrospective

> **Note:** Usually not needed. `/cks:sprint` includes an inline review at completion
> that lets you ship, iterate, or request a full review. Use `/cks:review` explicitly
> when you want a deeper retrospective, agent-based review, or detailed backlog refinement.

Dispatch the **prd-verifier** agent for review (which has `skills: prd` loaded at startup).

```
Agent(subagent_type="prd-verifier", prompt="Run Phase 4: Sprint Review for the current feature. Read .prd/PRD-STATE.md to identify the active phase. Read workflows/review-phase.md for step-by-step process. Arguments: $ARGUMENTS")
```

## Quick Reference

Sprint review, retrospective, and the **iteration decision** that determines what happens next:

```
[4a] Sprint Review          — demo, feedback, metrics
[4b] Retrospective          — what worked, what didn't
[4c] Backlog Refinement     — prioritize action items
[4d] Iteration Decision     — route to next phase:
      ├── Release     → Phase 5
      ├── Design      → back to Phase 2
      ├── Sprint      → back to Phase 3
      └── Re-discover → back to Phase 1
```

## Argument Handling

- No args: Review the most recently sprinted phase
- Phase number: Review that specific phase

## Note

This command replaced the previous `/review` (code review). Code review is now sub-step [3d] inside `/cks:sprint`.
