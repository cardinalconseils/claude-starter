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
Agent(subagent_type="cks:standup-reader", prompt="
  project_root: {current directory}
")
```

Then load session context:

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
/cks:standup        → Morning recap + load session context + suggested next action
/cks:eod            → Write end-of-day DEVLOG entry
```
