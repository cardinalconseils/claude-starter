---
description: "[legacy] Begin a work session — loads full operating context (CLAUDE.md, rules, PRD state, git) and validates guardrails are in place"
allowed-tools:
  - Read
  - Skill
---

# /cks:sprint-start — Session Opening Ritual

> ⚠ **Legacy (v4)** — `/cks:standup` now handles both session recap and context loading. Use `/cks:standup` instead.

Load everything Claude needs to work effectively. Run at the start of every work session.

## How It Relates to Other Commands

- `/cks:standup` — reads DEVLOG, shows yesterday's activity, loads session context (use this instead)
- `/cks:eod` — writes DEVLOG entry (end of day journal)

## Dispatch

The chief of staff is a top-level skill (`.claude/rules/commands.md`, Orchestrator Exception):

```
Skill(skill="cks:chief-of-staff")
```

Inbound: "Load full session context for the current project, then check for a recent handoff in this order:
  (1) .prd/HANDOFF.md — pointer file (exists only if session-start hook has not yet consumed it)
  (2) latest file under .prd/handoffs/ — permanent archive (ls -t .prd/handoffs/HANDOFF-*.md | head -1)
  If found, display its full contents under a '📋 Handoff from last session' header
  before suggesting the next action. This is the primary context source for resuming work."

## Quick Reference

```
/cks:standup          → Use this instead (handles both recap and context loading)
/cks:sprint-start     → Legacy — loads the chief-of-staff skill for backward compat
```
