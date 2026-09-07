---
description: "Invoke an expert persona for architecture, product, debugging, or specialist deep-dives"
argument-hint: "[builder|product|debugger|specialist <name>] \"question\""
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:expert — Expert Persona System

Invoke a consolidated core expert or a named specialist for deep domain guidance.

## Routing

Parse `$ARGUMENTS`:
- First token: `builder`, `product`, `debugger`, or `specialist`
- If `specialist`, second token is the specialist name (e.g., `jensen-huang`)
- Remaining tokens form the question

| Type | Role | Persona |
|------|------|---------|
| `builder` | `cks:architect` | `experts/builder` — pragmatic architecture, implementation, deployment |
| `product` | `cks:strategist` | `experts/product` — user-centered features, UX, prioritization, metrics |
| `debugger` | `cks:debugger` | `experts/debugger` — root cause analysis, testing strategy, performance |
| `specialist <name>` | `cks:strategist` | `experts/specialists/<name>` — deep-dive domain guidance |
| *(no args)* | AskUserQuestion to select type | |

## No-Args Flow

If invoked with no arguments, call `AskUserQuestion`:
- "What kind of help do you need?"
  1. Build / Architecture / Deploy → builder
  2. Features / UX / Prioritization → product
  3. Debug / Test / Performance → debugger
  4. Deep specialist dive → ask for specialist name

## Dispatch

```
Agent(
  subagent_type="{role from the table}",
  prompt="Persona: {persona from the table}. Load that persona from the experts skill and answer as the {type} expert — advice only, no file changes.\n\nQuestion: {question}"
)
```

## Quick Reference

```
/cks:expert builder "how do I implement real-time notifications?"
/cks:expert product "should we build in-app chat or use SMS?"
/cks:expert debugger "payment processing fails intermittently"
/cks:expert specialist jensen-huang "what is our 10-year architecture?"
```
