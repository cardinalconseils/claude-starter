---
description: "Phase 2: Design — UX, API contract, screens, component specs; or studio websites and decks rendered and checked with Playwright, REA and Figma"
argument-hint: "[phase number] | website|deck <brief or URL>"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
  - ExitPlanMode
---

# /cks:design — Phase 2: Design

Dispatch the `cks:architect` (which has `skills: prd` loaded at startup).

```
Agent(subagent_type="cks:architect", prompt="Run Phase 2: Design for the current feature. Read .prd/PRD-STATE.md to identify the active phase. Read the CONTEXT.md from Phase 1. Read workflows/design-phase.md for step-by-step process. MANDATORY: You MUST use AskUserQuestion at every interactive checkpoint — [2a] UX flow review, [2b] API contract approval, [2d] screen review, [2f] design sign-off. Do NOT skip any checkpoint. Arguments: $ARGUMENTS")
```

**Studio route** — first argument `website`, `site`, `landing`, `deck`, `slides` or `presentation` (no phase needed): dispatch this instead and skip "After Agent Completes":

```
Agent(subagent_type="cks:architect", prompt="Mode: studio — read skills/design-studio/SKILL.md and the matching workflow. Brief: $ARGUMENTS. Return the DESIGN block with artifact and screenshot paths.")
```

## Quick Reference

`/cks:design 2` · `/cks:design website pricing page like https://linear.app` · `/cks:design deck Q4 board update`

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

When the designer agent returns:

1. Read `.prd/PRD-STATE.md` to confirm status is `designed`.
2. Dispatch a design fluency review on all generated screens:
   ```
   Agent(subagent_type="cks:reviewer", prompt="Run a design fluency review on all screens in .prd/phases/ (find the active phase from .prd/PRD-STATE.md). Target: the design/screens/ directory for that phase. Report findings table and gate status. Do not modify files.")
   ```
3. Call `ExitPlanMode` — design is approved; sprint will execute directly.
4. Tell the user:
   ```
   ✅ Design complete for Phase {NN}.
   Next → /cks:sprint {NN}
   (Run /compact first if the conversation is long)
   ```

## Argument Handling

- No args: Design the current phase from STATE.md
- Phase number: Design that specific phase
