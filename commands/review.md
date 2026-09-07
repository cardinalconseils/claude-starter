---
description: "[legacy] Phase 4: Sprint Review & Retrospective — feedback, retro, iteration decision"
argument-hint: "[phase number]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:review — Phase 4: Sprint Review & Retrospective

> ⚠ **Legacy (v4)** — This command is superseded in v5. Use `/cks:sprint` to enter the Attractor pipeline.

> **Note:** Usually not needed. `/cks:sprint` includes an inline review at completion
> that lets you ship, iterate, or request a full review. Use `/cks:review` explicitly
> when you want a deeper retrospective or detailed backlog refinement.

Dispatch the historian (loads `skills: prd, retrospective`).

```
Agent(subagent_type="cks:historian", prompt="Mode: sprint-review. Run Phase 4: Sprint Review for the current feature. Read .prd/PRD-STATE.md to identify the active phase. Read workflows/review-phase.md for step-by-step process. Build a sprint summary from artifacts, show it to the user, collect feedback, run retrospective, and make the iteration decision with AskUserQuestion. Arguments: $ARGUMENTS")
```

## Quick Reference

```
[4a] Sprint Review          — build summary, demo, collect feedback
[4b] Retrospective          — what worked, what didn't
[4c] Backlog Refinement     — prioritize action items
[4d] Iteration Decision     — route to next phase:
      ├── Release     → Phase 5
      ├── Design      → back to Phase 2
      ├── Sprint      → back to Phase 3
      └── Re-discover → back to Phase 1
```

## After the role completes

Read `.prd/PRD-STATE.md` for the iteration decision, then **always suggest the next step**:

```
Release  → ✅ Review approved Phase {NN} for release.      Next → /cks:release {NN}
Sprint   → 🔄 Review sent Phase {NN} back for code changes. Next → /cks:sprint {NN}
Design   → 🔄 Review sent Phase {NN} back for redesign.     Next → /cks:design {NN}
Discover → 🔄 Review sent Phase {NN} back for re-discovery. Next → /cks:discover {NN}
(Run /compact first if the conversation is long)
```

## Argument Handling

- No args: Review the most recently sprinted phase
- Phase number: Review that specific phase
