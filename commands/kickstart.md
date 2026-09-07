---
description: "Project enabler — idea to scaffolded project"
argument-hint: "[idea pitch]"
allowed-tools:
  - Read
  - Skill
---

# /cks:kickstart

Take an idea from pitch to scaffolded project, then straight into the feature lifecycle.

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): the kickstart
loop dispatches one role per phase, and only the top-level session can, so it loads as a
skill rather than running as a sub-agent.

```
Skill(skill="cks:kickstart")
```

Pitch: `$ARGUMENTS` (may be empty — the loop asks). Project root: current directory.
The skill's `SKILL-ORCHESTRATOR.md` resumes from `.kickstart/state.md`, gates every phase
with `AskUserQuestion`, and dispatches `cks:strategist` (ideate, intake, feature scope),
`cks:researcher`, the monetize stages, `cks:marketer` (brand), `cks:architect` (design),
`cks:operator` (handoff), then the auto-chain into discovery.

Phases: Ideate (0) → Intake (1) → Compose (1b) → Stack (1c) → Research (2) → Monetize (3) → Feature Scope (3.5) → Brand (4) → Design (5) → Handoff (6)

## Quick Reference

```
/cks:kickstart                     → Start from scratch (guided)
/cks:kickstart AI recipe generator → Start with a pitch
```
