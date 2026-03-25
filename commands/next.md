---
description: Auto-advance to the next logical step in the workflow
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

# /cks:next — Auto-Advance to Next Step

Load the workflow instructions from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/next.md` and follow them exactly.

## Quick Reference

Detects the current workflow state and automatically runs the next logical command:

| Current State | Next Action |
|---|---|
| No `.prd/` | Run new-project workflow |
| Phase needs discussion | Run discuss workflow |
| Phase has CONTEXT.md but no PLAN.md | Run plan workflow |
| Phase has PLAN.md but not executed | Run execute workflow |
| Phase executed but not verified | Run verify workflow |
| Phase verified, more phases remain | Advance to next phase's discuss |
| All phases complete | Report completion |

This is the "just keep going" command.
