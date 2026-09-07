---
description: "Autonomous full-session sprint — peers-aware, AI decides at every gate, worktrees, no interruptions"
argument-hint: "[--resume] [--start-at <node>] [--dry-run]"
allowed-tools:
  - Read
  - Skill
---

# /cks:sprint-auto — Autonomous Full-Session Sprint

Runs the full Attractor sprint pipeline in autonomous mode. The AI evaluates artifacts
at every decision gate instead of pausing for user input. Checks peer sessions at startup
to detect conflicts before work begins.

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): the pipeline
dispatches a role per node, so it loads the attractor engine as a top-level skill.

```
Skill(skill="cks:attractor")
```

pipeline: `sprint` · Arguments: `$ARGUMENTS --auto`.

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

Use `/cks:sprint-run` instead when you want to approve the plan before implementation or
give feedback at sprint review before releasing.
