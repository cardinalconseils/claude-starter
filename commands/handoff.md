---
description: "Save session context to .prd/handoffs/HANDOFF-{date}-{time}.md (unique per session) so parallel sessions don't clobber each other"
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
      prompt="Run a session handoff. First, run these two commands to build the unique filename: (1) TZ=America/New_York date '+%Y-%m-%d-%H%M' for the EST timestamp; (2) git branch --show-current | tr '/' '-' | tr '[:upper:]' '[:lower:]' | cut -c1-30 for the branch slug. Create .prd/handoffs/ if it does not exist. Load the handoff skill. Read .prd/PRD-STATE.md, git log --oneline -10, git status. Produce the handoff document following the handoff skill format. Do not duplicate artifact content — reference by path. User's focus for next session (if provided): $ARGUMENTS. Write the handoff to TWO paths: (1) .prd/handoffs/HANDOFF-{timestamp}-{slug}.md (unique per session, preserves history); (2) .prd/HANDOFF.md (latest pointer, for sprint-start auto-detect). After writing both files, output exactly this block: ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n▶ ACTION REQUIRED\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nRun:    /clear\nWhy:    Handoff written — fresh session resumes from .prd/HANDOFF.md\nThen:   New session auto-loads ⚡ Next Step from the handoff\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
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

The next session reads the handoff via `/cks:sprint-start` (auto-detected from `.prd/HANDOFF.md`) or browse history:
`ls .prd/handoffs/`
