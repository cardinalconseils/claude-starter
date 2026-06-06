---
description: "Grill-me plan interrogator — relentless one-question-at-a-time plan stress-test with recommended answers"
argument-hint: "[path/to/plan-file or empty]"
allowed-tools:
  - Read
  - Agent
---

# /cks:grill — Grill-Me Plan Interrogator

Dispatch the **grill-me-interviewer** agent to walk every unresolved decision in a plan or design. One question at a time. Recommended answer per question. Explores the codebase before asking.

```
Agent(
  subagent_type="cks:grill-me-interviewer",
  prompt="Grill this plan. File or brief provided: $ARGUMENTS. If no file given, scan for the most recent CONTEXT.md or PLAN.md in .prd/phases/. Walk every unresolved decision in dependency order. One question at a time. Recommend an answer for each. Explore the codebase before asking anything the code can answer."
)
```

## Quick Reference

```
/cks:grill                         — finds most recent PLAN.md / CONTEXT.md
/cks:grill .prd/phases/03-auth/03-PLAN.md   — grills a specific plan file
/cks:grill "add Stripe webhook retry"       — grills an inline brief
```

## When to Use

- Before `/cks:sprint` to stress-test your plan
- After `/cks:preflight` to interrogate the feature design
- Any time you want a second opinion on a plan you wrote yourself
- When a design has too many implicit assumptions to feel safe shipping
