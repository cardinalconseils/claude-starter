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

Dispatch the **sprint-reviewer** agent (which has `skills: prd` loaded at startup).

```
Agent(subagent_type="cks:sprint-reviewer", prompt="Run Phase 4: Sprint Review for the current feature. Read .prd/PRD-STATE.md to identify the active phase. Read workflows/review-phase.md for step-by-step process. Build a sprint summary from artifacts, show it to the user, collect feedback, run retrospective, and make the iteration decision. Arguments: $ARGUMENTS")
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

## After Agent Completes

When the reviewer agent returns, **always suggest the next step** based on the iteration decision:

```
Read .prd/PRD-STATE.md to check the current status and iteration decision, then tell the user:

  If decision = "Release":
    ✅ Review approved Phase {NN} for release.
    Next → /cks:release {NN}

  If decision = "Sprint" (iterate on code):
    🔄 Review sent Phase {NN} back for code changes.
    Next → /cks:sprint {NN}

  If decision = "Design" (iterate on design):
    🔄 Review sent Phase {NN} back for redesign.
    Next → /cks:design {NN}

  If decision = "Discover" (re-gather requirements):
    🔄 Review sent Phase {NN} back for re-discovery.
    Next → /cks:discover {NN}

  (Run /compact first if the conversation is long)
```

## Argument Handling

- No args: Review the most recently sprinted phase
- Phase number: Review that specific phase
