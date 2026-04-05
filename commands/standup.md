---
description: "Morning standup — recap last DEVLOG entry, cross-reference current state, suggest next action"
allowed-tools:
  - Read
  - Agent
---

# /cks:standup — Morning Standup

Dispatch the standup-reader agent to review what happened and suggest where to pick up.

## Related Commands

- `/cks:standup` — **What happened?** Reviews DEVLOG (backward-looking)
- `/cks:sprint-start` — **What do I need?** Loads context + guardrails (forward-looking)
- `/cks:eod` — **End of day** — writes DEVLOG entry

## Dispatch

```
Agent(subagent_type="standup-reader", prompt="
  project_root: {current directory}
")
```

## Quick Reference

```
/cks:standup        → Morning recap + suggested next action
/cks:sprint-start   → Load full session context
/cks:eod            → Write end-of-day DEVLOG entry
```
