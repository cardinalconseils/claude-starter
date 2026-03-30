---
description: "End of day — summarize today's work into a dated DEVLOG entry with state and next steps"
allowed-tools:
  - Read
  - Agent
---

# /cks:eod — End of Day

Dispatch the **session-journalist** agent (which has `skills: prd` loaded at startup).

## Dispatch

```
Agent(subagent_type="session-journalist", prompt="Compose an end-of-day DEVLOG entry for today. Gather git activity (commits since midnight), PRD state, session learnings, uncommitted work, and open TODOs. Ask the user for optional notes. Write the entry to .prd/DEVLOG.md (newest first). Update PRD-STATE.md session history.")
```

## Quick Reference

Composes a dated DEVLOG entry summarizing today's work, current state, and next steps.

## Related Commands

- `/cks:sprint-close` — **Governance close:** audits rules, captures learnings
- `/cks:eod` — **Journal close:** writes DEVLOG entry for tomorrow
- `/cks:standup` — Reads DEVLOG entry (next morning)

Typical end of day: run `sprint-close` first (audit + learnings), then `eod` (journal).
