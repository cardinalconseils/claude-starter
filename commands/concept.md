---
description: "Evaluate a concept for CKS plugin (or project) feasibility — brainstorm first, then score across business value, technology fit, and data impact. Produces FEASIBILITY.md and auto-enters plan mode."
argument-hint: "[concept description]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
  - EnterPlanMode
---

# /cks:concept — Concept Feasibility Evaluator

Evaluate whether a new concept (command, agent, skill, hook, workflow, rule, or integration) is worth adding to the CKS plugin — or to a CKS-powered project.

Runs brainstorming first, then scores three pillars in parallel, then enters PLAN mode.

## Dispatch

```
# Step 1: Get concept brief if not provided
If $ARGUMENTS is empty:
  AskUserQuestion:
    question: "What concept do you want to evaluate?"
    header: "Concept"
    options:
      - label: "New command"
        description: "A new /cks:* slash command"
      - label: "New agent"
        description: "A new subagent for an existing or new workflow"
      - label: "New skill"
        description: "New domain knowledge for agents to load"
      - label: "Other"
        description: "Describe your concept"

# Step 2: Dispatch orchestrator
Agent(
  subagent_type="cks:concept-orchestrator",
  prompt="Evaluate this concept: {$ARGUMENTS or user answer}. Run the full pipeline: detect mode, classify type, scan codebase, run brainstorming interactively, confirm refined concept, dispatch 3 parallel pillar workers, aggregate, write FEASIBILITY.md, display scorecard."
)

# Step 3: Enter plan mode
EnterPlanMode
```

## Quick Reference

```
/cks:concept                        — prompts for concept description
/cks:concept "add voice transcription skill"   — evaluates immediately
/cks:concept "add Stripe webhook retry"        — works in plugin or project
```

## What It Produces

`.concept/{slug}/FEASIBILITY.md` — scored feasibility report with:
- Business Value (1–5) with evidence
- Technology Fit (1–5) with evidence
- Data Impact (1–5) with evidence
- Overall score + Go / Defer / Reject recommendation
- Next step (branch name for plugin mode; `/cks:new` for project mode)

## When to Use

- Before `/cks:new` — validate the concept is worth a full discovery cycle
- When you have an idea for a new CKS command, agent, or skill
- When evaluating whether to add a feature to a project that uses CKS
