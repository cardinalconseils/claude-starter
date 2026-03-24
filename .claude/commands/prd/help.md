---
name: prd:help
description: Show available PRD commands and usage guide
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - WebSearch
  - WebFetch
  - Skill
  - AskUserQuestion
  - TodoRead
  - TodoWrite
  - "mcp__*"
---

# /prd:help — Available Commands

Display the following help text:

```
PRD Plugin — Product Requirement Document Lifecycle
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMMANDS:
  /prd:new [brief]         Initialize project + run full cycle (no interruption)
  /prd:discuss [phase]     Interactive discovery session
  /prd:plan [phase]        Write PRD + execution plan
  /prd:execute [phase]     Implement the next planned phase
  /prd:verify [phase]      Verify acceptance criteria
  /prd:ship [phase|all]    Commit → push → PR → review → deploy
  /prd:progress            Show progress + suggest next action
  /prd:next                Auto-advance to next step (chains automatically)
  /prd:autonomous          Run all remaining phases + ship (no interruption)
  /prd:evaluate [phase]    Build Process Evaluator feature (complete process cards)
  /prd:status              Quick roadmap overview
  /prd:help                Show this help

FULL LIFECYCLE (automated):
  /prd:new → discuss → plan → execute → verify → commit → ship
  (runs to completion without stopping)

STEP-BY-STEP:
  /prd:discuss → /prd:plan → /prd:execute → /prd:verify → /prd:ship
  (run each step manually)

AUTO-CHAIN:
  /prd:next    Detects state, runs next step, chains forward
  /prd:autonomous  Runs everything remaining + ships

AGENTS:
  prd-orchestrator  Drives full lifecycle (used by /prd:new)
  prd-discoverer    Interactive requirements gathering
  prd-planner       Writes PRDs and execution plans
  prd-executor      Implements code changes
  prd-verifier      Checks acceptance criteria
  prd-researcher    Investigates codebase and technology

FILES:
  .prd/              Planning state directory
  .prd/PRD-PROJECT.md    Project context
  .prd/PRD-ROADMAP.md    Phase structure + status
  .prd/PRD-STATE.md      Session continuity
  .prd/PRD-REQUIREMENTS.md  Tracked requirements
  .prd/phases/       Per-phase artifacts (CONTEXT, PLAN, SUMMARY, VERIFICATION)
  docs/prds/              PRD documents

CD TIP:
  After shipping, use ralph-loop for continuous deployment:
  /ralph-loop:ralph-loop "monitor PR #{number} and deploy when merged"
```
