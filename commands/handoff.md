---
description: "Save session context to .prd/HANDOFF.md so the next session resumes without re-discovery"
argument-hint: "[what the next session will focus on]"
allowed-tools:
  - Read
  - Agent
---

# /cks:handoff — Session Handoff

Dispatch the **cks:session-journalist** agent with the handoff skill to compact this session
into a pickup document for the next Claude session.

## Dispatch

```
Agent(subagent_type="cks:session-journalist",
      prompt="Run a session handoff. Load the handoff skill. Read .prd/PRD-STATE.md, git log --oneline -10, git status, and git branch --show-current. Produce .prd/HANDOFF.md following the handoff skill format. Do not duplicate artifact content — reference by path. User's focus for next session (if provided): $ARGUMENTS. After writing the handoff, output exactly this block: ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n▶ ACTION REQUIRED\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nRun:    /clear\nWhy:    Handoff written — fresh session resumes from .prd/HANDOFF.md\nThen:   New session auto-loads ⚡ Next Step from the handoff\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
```

## Quick Reference

```
/cks:handoff                     → capture current state, generic resume
/cks:handoff fix the auth tests  → tailor next-session steps to that focus
```

Run before:
- `/compact` on a long conversation
- Ending a session mid-sprint
- Handing off to a parallel session
- Going offline

The next session reads the handoff via `/cks:sprint-start` (auto-detected) or directly:
`cat .prd/HANDOFF.md`
