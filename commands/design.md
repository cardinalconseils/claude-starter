---
description: "Phase 2: Design — UX research, API contract, screen generation (Stitch MCP), component specs"
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
3. Define API contracts (if feature has API surface)
4. Generate UI screens using Stitch MCP
5. Iterate on designs with stakeholder feedback
6. Extract component specs for Sprint implementation

### Sub-steps

```
[2a] UX Research          — user flows, journey maps, IA
[2b] API Contract         — request/response schemas, auth, examples (if API feature; skip if N/A)
[2c] Screen Generation    — Stitch MCP generates screens from prompts
[2d] Design Iteration     — edit screens, generate variants, browser review
[2e] Component Specs      — HTML extraction, component hierarchy, design tokens
[2f] Design Review        — stakeholder sign-off
```

## Argument Handling

- No args: Design the current phase from STATE.md
- Phase number: Design that specific phase
