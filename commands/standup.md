---
description: "Morning standup — recap last DEVLOG entry, load session context, suggest next action (replaces sprint-start)"
allowed-tools:
  - Read
  - Agent
---

# /cks:standup — Morning Standup

Dispatch the standup-reader agent to review what happened and suggest where to pick up.

## Related Commands

- `/cks:standup` — **What happened + What do I need?** Reviews DEVLOG AND loads context (backward + forward-looking)
- `/cks:eod` — **End of day** — writes DEVLOG entry
- `/cks:standup` now handles both session recap AND context loading — sprint-start is no longer needed

## Dispatch

```
Agent(subagent_type="cks:assistant", prompt="
  Mode: daily-brief
  project_root: {current directory}
  Load session context first (.prd/PRD-STATE.md, work-hierarchy, newest .learnings/session-*.md),
  then check for a handoff: (1) .prd/HANDOFF.md, (2) newest .prd/handoffs/HANDOFF-*.md.
  If found, show it in full under a '📋 Handoff from last session' header before the brief.
")
```

## Quick Reference

```
/cks:standup        → Morning recap + load session context + suggested next action
/cks:eod            → Write end-of-day DEVLOG entry
```
