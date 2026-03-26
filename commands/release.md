---
description: "Phase 5: Release Management — environment promotion (Dev → Staging → RC → Production)"
argument-hint: "[phase number or 'all']"
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

# /cks:release — Phase 5: Release Management

Load the workflow instructions from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/release-phase.md` and follow them exactly.

## Quick Reference

Environment promotion with quality gates at each stage:

```
[5a] Dev Deploy + Internal Validation
[5b] Staging Deploy + Feedback
[5c] RC Deploy + E2E Regression Suite
[5d] Production Deploy + Smoke Test + E2E Validation
[5e] Post-Deploy Monitoring + CLAUDE.md Update
```

## Argument Handling

- No args: Release the most recently reviewed phase
- Phase number: Release that specific phase
- `all`: Release all reviewed phases together
