---
description: "Phase 1: Discovery — structured requirements gathering with the 11 Elements"
argument-hint: "[phase number or feature name]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:discover — Phase 1: Discovery

Dispatch the **prd-discoverer** agent (which has `skills: prd` loaded at startup).

```
Agent(subagent_type="prd-discoverer", prompt="Run Phase 1: Discovery for the current feature. Read .prd/PRD-STATE.md to identify the active phase. Gather all 11 Elements. Read workflows/discover-phase.md for step-by-step process. Write CONTEXT.md to the phase directory. Arguments: $ARGUMENTS")
```

## Quick Reference

Structured requirements gathering using the **11 Elements of Discovery**. Produces a CONTEXT.md file in the phase directory.

### The 11 Elements

1. Problem Statement & Value Proposition
2. User Stories
3. Scope (In / Out)
4. API Surface Map
5. Acceptance Criteria
6. Constraints & Negative Cases
7. Test Plan (unit + integration + E2E scenarios)
8. UAT Scenarios
9. Definition of Done
10. Success Metrics / KPIs
11. Cross-Project Dependencies (manifest-aware — N/A for single projects)

## After Agent Completes

When the discoverer agent returns, **always suggest the next step**:

```
Read .prd/PRD-STATE.md to check the current status, then tell the user:

  ✅ Discovery complete for Phase {NN}.
  Next → /cks:design {NN}
  (Run /compact first if the conversation is long)
```

## Argument Handling

- No args: Detect the current phase from STATE.md and discover it
- Phase number (e.g., `1`, `01`): Discover that specific phase
- Feature name: Start new feature discovery with that as the brief
