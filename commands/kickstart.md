---
description: "Project enabler — idea to scaffolded project"
argument-hint: "[idea pitch]"
allowed-tools:
  - Read
  - Agent
---

# /cks:kickstart

Dispatch the kickstart orchestrator to take an idea from pitch to scaffolded project.

## Dispatch

```
Agent(subagent_type="cks:kickstart-orchestrator", prompt="
  pitch: $ARGUMENTS
  project_root: {current directory}
")
```

Phases: Ideate (0) → Intake + Compose (1 / 1b) → Research (2) → Monetize (3) → Feature Scope (3.5) → Brand (4) → Design (5) → Handoff (6)

## Quick Reference

```
/cks:kickstart                     → Start from scratch (guided)
/cks:kickstart AI recipe generator → Start with a pitch
```
