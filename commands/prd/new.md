---
name: prd:new
description: Initialize project and run the full lifecycle — discuss → plan → execute → verify → ship. No interruption.
argument-hint: "[feature description]"
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

# /prd:new — Initialize + Full Autonomous Cycle

<objective>
Initialize the project (if needed), then immediately run the full autonomous lifecycle for all phases: discuss → plan → execute → verify → commit → ship. No pauses, no confirmation prompts. The flow runs to completion.
</objective>

<execution_context>
@.claude/skills/prd/workflows/new-project.md
@.claude/skills/prd/workflows/autonomous.md
@.claude/skills/prd/workflows/ship.md
</execution_context>

<process>

<step name="initialize">
## 1. Initialize Project

Check if `.prd/` exists:

**If no `.prd/`:** Run the new-project workflow to create PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md. Gather project context from the codebase (read CLAUDE.md, package.json, README.md) — do NOT ask interactive questions. Infer what you can.

**If `.prd/` exists:** Read existing state. Skip initialization.

If `$ARGUMENTS` is provided, use it as the feature brief. If not, read ROADMAP.md for the next undone phase.
</step>

<step name="setup_phases">
## 2. Ensure Phases Exist

If ROADMAP.md has no phases yet:
- If `$ARGUMENTS` provided → create Phase 01 from the brief
- If no arguments → read PROJECT.md goals and create initial phases from them

Create phase directories: `.prd/phases/01-{name}/`, etc.

Update ROADMAP.md with the phase structure.
</step>

<step name="autonomous_cycle">
## 3. Run Full Autonomous Cycle

For each incomplete phase, invoke the sub-workflows via Skill():

```
FOR EACH incomplete phase (sorted by number):

  Display: "━━━ Phase {NN}/{total}: {name} [████░░░░] {%}% ━━━"

  IF no CONTEXT.md:
    → Dispatch prd-discoverer agent (autonomous mode — no questions)
    → Display: "Phase {NN}: Discuss ✓"

  IF no PLAN.md:
    → Dispatch prd-planner agent
    → Display: "Phase {NN}: Plan ✓"

  IF no SUMMARY.md:
    → Dispatch prd-executor agent
    → Display: "Phase {NN}: Execute ✓"

  IF no VERIFICATION.md:
    → Dispatch prd-verifier agent
    → IF PASS: Display "Phase {NN}: Verify ✓"
    → IF FAIL (1st time): Delete SUMMARY.md, re-execute, re-verify
    → IF FAIL (2nd time): Log failure, continue to next phase

  Commit phase work:
    git add -A
    git commit -m "feat(phase-{NN}): {phase name}"

  Update STATE.md + ROADMAP.md

  Display: "Phase {NN} ✓ — {X}/{total} complete"
```
</step>

<step name="ship">
## 4. Ship

After all phases complete, run the ship workflow:

1. Create feature branch (if on main)
2. Push to remote
3. Create PR with auto-generated body from planning artifacts
4. Run code review (invoke available review skill)
5. Deploy (invoke deploy skill if available)
6. Update ROADMAP.md — move feature to "Completed"
7. Update STATE.md — mark as shipped
</step>

<step name="report">
## 5. Final Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Feature: PRD-{NNN} — {name}
 Phases: {total}/{total} ✓
 PR: #{number} ({url})
 Deploy: {status}

 discuss ✓ → plan ✓ → execute ✓ → verify ✓ → ship ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
</step>

</process>

<guardrails>
- NO interactive questions during discuss — infer from codebase and project context
- NO confirmation prompts before execution — just execute
- NO stopping between phases — chain automatically
- Max 1 retry on verification failure — then continue
- Update STATE.md after EVERY step — enables resume via /prd:next if interrupted
- Commit after each phase — atomic, recoverable history
</guardrails>
