---
description: "Autonomous full-session sprint — peers-aware, AI decides at every gate, worktrees, no interruptions"
argument-hint: "[--resume] [--start-at <node>] [--dry-run]"
allowed-tools:
  - Agent
  - Read
---

# /cks:sprint-auto — Autonomous Full-Session Sprint

Runs the full Attractor sprint pipeline in autonomous mode. The AI evaluates artifacts
at every decision gate instead of pausing for user input. Checks peer sessions at startup
to detect conflicts before work begins.

## Dispatch

```
Agent(subagent_type="cks:sprint-runner", prompt="Run the CKS sprint pipeline at pipelines/sprint.dot in autonomous mode. Pass --auto flag. Arguments: $ARGUMENTS --auto")
```

## What Makes This Different from `/cks:sprint-run`

| | `/cks:sprint-run` | `/cks:sprint-auto` |
|---|---|---|
| ReviewPlan gate | Asks user to approve/revise | AI evaluates PLAN.md, decides |
| SprintReview gate | Asks user to approve/iterate | AI checks goal gates, decides |
| Peer awareness | None | Checks all repo sessions at startup |
| Worktrees | Yes | Yes |
| Checkpoints | Yes | Yes |
| Resume support | Yes | Yes |

## Quick Reference

```
/cks:sprint-auto                       # Full autonomous run from start
/cks:sprint-auto --resume              # Resume an interrupted autonomous run
/cks:sprint-auto --start-at Implement  # Skip discovery/planning, start at implementation
/cks:sprint-auto --dry-run             # Print execution plan without running
```

## When to Use

- You trust the AI to evaluate plan quality and sprint outcomes
- You want a fully unattended sprint session
- You're running multiple features across sessions (peers check prevents conflicts)

## When to Use `/cks:sprint-run` Instead

- You want to review and approve the plan before implementation starts
- You want to give feedback at sprint review before releasing
