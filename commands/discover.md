---
description: "Phase 1: Discovery — structured requirements gathering with the 11 Elements"
argument-hint: "[phase number or feature name]"
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

# /cks:discover — Phase 1: Discovery

Load the workflow instructions from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/discover-phase.md` and follow them exactly.

## Quick Reference

Launches the **prd-discoverer** agent for structured requirements gathering using the **9 Elements of Discovery**. Produces a CONTEXT.md file in the phase directory.

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

## Argument Handling

- No args: Detect the current phase from STATE.md and discover it
- Phase number (e.g., `1`, `01`): Discover that specific phase
- Feature name: Start new feature discovery with that as the brief
