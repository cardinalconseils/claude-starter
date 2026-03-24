# Workflow: Plan Phase

## Overview
Takes the discovery output ({NN}-CONTEXT.md) and produces a PRD document + execution plan (PLAN.md). Uses the **prd-planner** agent.

## Pre-Conditions
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists (if not, redirect to `/prd:discuss`)
- `.prd/` state files exist

## Steps

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the active phase, or use the phase number argument.

Verify that {NN}-CONTEXT.md exists for the target phase:
```
Read .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
```

If no {NN}-CONTEXT.md → tell the user: "No discovery found. Run `/prd:discuss {NN}` first."

### Step 2: Gather Planning Inputs

Read all necessary context:
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — Discovery output
- `.prd/PRD-PROJECT.md` — Project context
- `.prd/PRD-REQUIREMENTS.md` — Existing requirements (for REQ-ID numbering)
- `.prd/PRD-ROADMAP.md` — Current roadmap state
- `CLAUDE.md` — Project conventions

### Step 3: Dispatch Planner Agent

Dispatch the **prd-planner** agent with:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Discovery context: {{NN}-CONTEXT.md content}
- Project context: {PROJECT.md content}
- Existing requirements: {REQUIREMENTS.md content}
- Existing PRDs: {list of docs/prds/ files}

Your job: Follow your agent instructions to produce:
1. A PRD document at docs/prds/PRD-{NNN}-{name}.md
   Use template: .claude/skills/prd/templates/prd.md
2. An execution plan at .prd/phases/{NN}-{name}/{NN}-PLAN.md
3. Updated REQUIREMENTS.md with new REQ-IDs
4. Updated PRD-ROADMAP.md with phases and success criteria
   Use format: .claude/skills/prd/references/roadmap-format.md
```

### Step 4: Update State

After planning completes:

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: planned
last_action: "PRD and plan created"
last_action_date: {today}
next_action: "Run /prd:execute to implement"
prd_path: docs/prds/PRD-{NNN}-{name}.md
```

**Update PRD-ROADMAP.md:**
- Set the phase status to "Planned"
- Include success criteria from the PRD

### Step 5: Present for Review

Show the user:
```
Plan complete for Phase {NN}: {name}

PRD: docs/prds/PRD-{NNN}-{name}.md
Plan: .prd/phases/{NN}-{name}/{NN}-PLAN.md

Phases:
  1. {sub-phase name} — {scope}
  2. {sub-phase name} — {scope}

Key acceptance criteria:
  - {criterion 1}
  - {criterion 2}

Ready to execute? Run /prd:execute {NN}
Want to adjust? Tell me what to change.
```

## Post-Conditions
- `docs/prds/PRD-{NNN}-{name}.md` exists
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` exists
- `.prd/PRD-REQUIREMENTS.md` updated with new REQ-IDs
- `.prd/PRD-ROADMAP.md` updated with phase details
- PRD-STATE.md updated
