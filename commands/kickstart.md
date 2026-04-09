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

Phases: Ideate → Intake → Research → Monetize → Brand → Design → Handoff

## Quick Reference

```
/cks:kickstart                     → Start from scratch (guided)
/cks:kickstart AI recipe generator → Start with a pitch
```
