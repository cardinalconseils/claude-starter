---
description: "Snapshot current session decisions and next steps to persistent memory — survives /clear and next session"
allowed-tools:
  - Agent
---

# /cks:save-context

Save this session's decisions to `.cks/control-plane/memory/sessions/` so nothing is lost across `/clear`, compaction, or next session.

The save trigger is you — not Claude guessing. Run this whenever a real decision was made.

## Dispatch

```
Agent(
  subagent_type="cks:memory-agent",
  prompt="
    Mode: save-session

    Review this session and save each real decision made.
    Skip chatter, restatements, and exploratory discussion.
    Save: architectural choices, tool selections, approach decisions, dead ends worth remembering, next concrete steps.

    One entry per decision. Confirm what was saved in 1-2 lines.
  "
)
```

## Quick Reference

```
/cks:save-context          — save this session's decisions to memory
/cks:memory --sessions     — browse saved sessions
/cks:memory --decisions    — view project-level decisions
```
