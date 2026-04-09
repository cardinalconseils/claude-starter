---
description: "Phase 2: Design — UX research, API contract, screen generation (Stitch MCP), component specs"
argument-hint: "[phase number]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:design — Phase 2: Design

Dispatch the **prd-designer** agent (which has `skills: prd` loaded at startup).

```
Agent(subagent_type="cks:prd-designer", prompt="Run Phase 2: Design for the current feature. Read .prd/PRD-STATE.md to identify the active phase. Read the CONTEXT.md from Phase 1. Read workflows/design-phase.md for step-by-step process. MANDATORY: You MUST use AskUserQuestion at every interactive checkpoint — [2a] UX flow review, [2b] API contract approval, [2d] screen review, [2f] design sign-off. Do NOT skip any checkpoint. Arguments: $ARGUMENTS")
```

## Quick Reference

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

## After Agent Completes

When the designer agent returns, **always suggest the next step**:

```
Read .prd/PRD-STATE.md to check the current status, then tell the user:

  ✅ Design complete for Phase {NN}.
  Next → /cks:sprint {NN}
  (Run /compact first if the conversation is long)
```

## Argument Handling

- No args: Design the current phase from STATE.md
- Phase number: Design that specific phase
