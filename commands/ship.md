---
description: Commit, create PR, review, and deploy completed work
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

# /cks:ship — Ship Completed Work

Load the workflow instructions from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/ship.md` and follow them exactly.

## Quick Reference

Handles the tail end of the lifecycle:
1. Commit all phase work (atomic commits per phase)
2. Create feature branch (if needed)
3. Push to remote
4. Create PR with auto-generated body from planning artifacts
5. Run code review
6. Deploy (if deploy skill available)
7. Update roadmap + state

## Argument Handling

- No args: Ship the most recently verified phase
- Phase number: Ship that specific phase
- `all`: Ship all verified phases as one PR
