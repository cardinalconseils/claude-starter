---
description: "Begin a work session — loads full operating context (CLAUDE.md, rules, PRD state, git) and validates guardrails are in place"
allowed-tools:
  - Read
  - Agent
---

# /cks:sprint-start — Session Opening Ritual

Load everything Claude needs to work effectively. Run at the start of every work session.

## How It Relates to Other Commands

- `/cks:standup` — reads DEVLOG, shows yesterday's activity (backward-looking)
- `/cks:sprint-start` — loads full operating context, validates guardrails (forward-looking)
- `/cks:sprint-close` — captures learnings, runs adherence check (session end)
- `/cks:eod` — writes DEVLOG entry (end of day journal)

## Dispatch

```
Agent(subagent_type="cks:session-loader", prompt="
  Load full session context for the current project.
  project_root: {current directory}
")
```

## Quick Reference

```
/cks:sprint-start     → Load context, show guardrails, suggest next action
/cks:sprint-close     → Close session, capture learnings
```
