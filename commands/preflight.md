---
description: "PRE-FLIGHT dependency mapping — position, risks, done criteria, gotchas, phase order, instrumentation before any build"
argument-hint: "[feature brief or phase number]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:preflight — PRE-FLIGHT Dependency Map

Dispatch the **agile-eagle** agent to walk the PRE-FLIGHT protocol before any code is written.

```
Agent(subagent_type="cks:agile-eagle", prompt="Run PRE-FLIGHT for this feature. Read .prd/PRD-STATE.md to find the active phase. If a feature brief was provided, use it: $ARGUMENTS. Walk the user through P→R→E→F→L→I→G using AskUserQuestion. Write PREFLIGHT.md to .preflight/{NN}-{slug}/. Report completion with phase count and gotcha summary.")
```

## Quick Reference

Maps what a feature touches before a line is written. Produces `.preflight/{NN}-{slug}/PREFLIGHT.md`.

```
P — Position      Tables, routes, services this feature touches
R — Risk          Blockers, regressions, parallel-safe work
E — Establish     Acceptance criteria + edge cases = done
F — Flag          Security, schema, auth, error propagation gotchas
L — Lock          Phase build order with verify steps
I — Instrument    Log checkpoints stubbed before feature logic
G — Go            All above confirmed → start Phase 1
```

## When to Run

- Before any `/cks:sprint` on a new feature
- After `/cks:adopt` on an in-flight project
- Any time you're unsure what a change will break

## Argument Handling

- No args: use active phase from `.prd/PRD-STATE.md`
- Feature brief (e.g., `"add Stripe webhook retry"`): use as starting context
- Phase number (e.g., `03`): run pre-flight for that specific phase
