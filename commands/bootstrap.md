---
description: "Scan an existing codebase, guided intake, then generate CLAUDE.md and initialize .prd/ lifecycle"
argument-hint: "[--update]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - Skill
---

# /cks:bootstrap — Set Up CKS for an Existing Codebase

Load the skill from `${CLAUDE_PLUGIN_ROOT}/skills/cicd-starter/SKILL.md` and follow it exactly.

## Quick Reference

Scans your codebase, asks guided questions, generates CLAUDE.md and initializes `.prd/`.

```
/cks:bootstrap          Fresh setup (or update if CLAUDE.md exists)
/cks:bootstrap --update Re-scan and merge into existing CLAUDE.md
```

For new projects from scratch, use `/cks:kickstart` instead.
