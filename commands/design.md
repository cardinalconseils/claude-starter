---
description: "Phase 2: Design — UX research, screen generation (Stitch SDK), component specs"
argument-hint: "[phase number]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - WebSearch
  - WebFetch
  - Skill
  - AskUserQuestion
  - TodoRead
  - TodoWrite
  - "mcp__*"
---

# /cks:design — Phase 2: Design

Load the workflow instructions from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/design-phase.md` and follow them exactly.

## Quick Reference

Launches the **prd-designer** agent to:
1. Analyze user stories and acceptance criteria from Discovery
2. Create UX flows and information architecture
3. Generate UI screens using Stitch SDK
4. Iterate on designs with stakeholder feedback
5. Extract component specs for Sprint implementation

### Sub-steps

```
[2a] UX Research          — user flows, journey maps, IA
[2b] Screen Generation    — Stitch SDK generates screens from prompts
[2c] Design Iteration     — edit screens, generate variants, browser review
[2d] Component Specs      — HTML extraction, component hierarchy, design tokens
[2e] Design Review        — stakeholder sign-off
```

## Argument Handling

- No args: Design the current phase from STATE.md
- Phase number: Design that specific phase
