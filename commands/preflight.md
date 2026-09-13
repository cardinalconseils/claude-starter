---
description: "PRE-FLIGHT dependency mapping — position, risks, done criteria, gotchas, phase order, instrumentation before any build"
argument-hint: "[feature brief or phase number]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:preflight — PRE-FLIGHT Dependency Map

Dispatch the `cks:architect` (`Mode: preflight`) before any code is written. A `NO` verdict comes back as `▶ ACTION REQUIRED` — fix the BLOCK gotcha, re-run.

```
Agent(subagent_type="cks:architect", prompt="Mode: preflight — feature {slug}, phase {NN}. Resolve {NN} from .prd/PRD-STATE.md active_phase (00 when none); brief or phase from $ARGUMENTS when given. Read skills/agile-eagle/workflows/preflight.md; write .preflight/{NN}-{slug}/PREFLIGHT.md; return the Cleared for takeoff verdict and every BLOCK gotcha.")
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

- Required (`.claude/rules/preflight.md`) before Phase 1 Discovery and before any sprint run — `/cks:new`, `/cks:sprint`, the kickstart auto-chain and `/cks:adopt` gate on it
- Any time you're unsure what a change will break

## Argument Handling

- No args: use active phase from `.prd/PRD-STATE.md`
- Feature brief (e.g., `"add Stripe webhook retry"`): use as starting context
- Phase number (e.g., `03`): run pre-flight for that specific phase
