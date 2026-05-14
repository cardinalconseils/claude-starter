---
description: "[legacy] Begin a work session — loads full operating context (CLAUDE.md, rules, PRD state, git) and validates guardrails are in place"
allowed-tools:
  - Read
  - Agent
---

# /cks:sprint-start — Session Opening Ritual

> ⚠ **Legacy (v4)** — `/cks:standup` now handles both session recap and context loading. Use `/cks:standup` instead.

Load everything Claude needs to work effectively. Run at the start of every work session.

## How It Relates to Other Commands

- `/cks:standup` — reads DEVLOG, shows yesterday's activity, loads session context (use this instead)
- `/cks:eod` — writes DEVLOG entry (end of day journal)

## Dispatch

```
Agent(subagent_type="cks:session-loader", prompt="
  Load full session context for the current project.
  project_root: {current directory}

  After loading context: check if .prd/HANDOFF.md exists.
  If it does, display its full contents under a '📋 Handoff from last session' header
  before suggesting the next action. This is the primary context source for resuming work.
")
```

## Quick Reference

```
/cks:standup          → Use this instead (handles both recap and context loading)
/cks:sprint-start     → Legacy — redirects to session-loader for backward compat
```
