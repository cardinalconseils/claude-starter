---
description: "Auto-advance to the next logical step in the workflow"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:next — Auto-Advance to Next Step

Read `.prd/PRD-STATE.md` to determine current state, then dispatch the appropriate agent.

## State Detection & Routing

| Current State | Action |
|---|---|
| No `.prd/` | Tell user to run `/cks:bootstrap` or `/cks:kickstart` first |
| No active phase | Tell user to run `/cks:new` to create a feature |
| Status: `discovering` | Dispatch `prd-discoverer` — `Agent(subagent_type="prd-discoverer", prompt="Continue Phase 1: Discovery for the active phase. Read .prd/PRD-STATE.md.")` |
| Status: `designing` | Dispatch `prd-designer` — `Agent(subagent_type="prd-designer", prompt="Continue Phase 2: Design for the active phase. Read .prd/PRD-STATE.md.")` |
| Status: `sprinting` | Dispatch `prd-planner` — `Agent(subagent_type="prd-planner", prompt="Continue Phase 3: Sprint for the active phase. Read .prd/PRD-STATE.md.")` |
| Status: `reviewing` | Dispatch `prd-verifier` — `Agent(subagent_type="prd-verifier", prompt="Continue Phase 4: Review for the active phase. Read .prd/PRD-STATE.md.")` |
| Status: `releasing` | Dispatch `deployer` — `Agent(subagent_type="deployer", prompt="Continue Phase 5: Release for the active phase. Read .prd/PRD-STATE.md.")` |
| Phase complete, more phases remain | Advance to next phase's discovery |
| All phases complete | Report completion |

This is the "just keep going" command.
