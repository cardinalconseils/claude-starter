# Workflow: Execute Phase

## Overview
Implements code changes for a planned phase. Uses the **prd-executor** agent. Produces a SUMMARY.md with results.

## Pre-Conditions
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` exists (if not, redirect to `/prd:plan`)
- PRD document exists in `docs/prds/`

## Steps

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the active phase, or use the phase number argument.

Verify that PLAN.md exists:
```
Read .prd/phases/{NN}-{name}/{NN}-PLAN.md
```

If no PLAN.md → tell the user: "No plan found. Run `/prd:plan {NN}` first."

### Step 2: Load Execution Context

Read all necessary files:
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` — Execution plan
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — Discovery context
- PRD document (path from PRD-STATE.md or find in `docs/prds/`)
- `CLAUDE.md` — Project conventions
- `.prd/PRD-PROJECT.md` — Project context

### Step 3: Confirm Scope

Before dispatching the executor, present to the user:
```
Phase {NN}: {name}
Goal: {from PLAN.md}
Files to modify: {list}
Acceptance criteria:
  - {criterion 1}
  - {criterion 2}

Proceed? [y/n]
```

### Step 4: Dispatch Executor Agent

Dispatch the **prd-executor** agent with:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Plan: {PLAN.md content}
- PRD: {PRD content}
- Context: {CONTEXT.md content}
- Conventions: {CLAUDE.md content}

Your job: Follow your agent instructions to:
1. Implement all tasks from the plan
2. Follow project conventions
3. Write a summary to .prd/phases/{NN}-{name}/{NN}-SUMMARY.md
```

### Step 5: Update State

After execution completes:

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: executed
last_action: "Implementation complete"
last_action_date: {today}
next_action: "Run /prd:verify to check acceptance criteria"
```

**Update PRD-ROADMAP.md:**
- Set the phase status to "Executed — Pending Verification"

**Update PRD:**
- Add implementation notes to the relevant phase section

### Step 6: Report

Show the user:
```
Execution complete for Phase {NN}: {name}

Files changed:
  - {file1} — {what changed}
  - {file2} — {what changed}

Summary: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md

Next: Run /prd:verify {NN} to check acceptance criteria
```

## Post-Conditions
- Code changes implemented
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` exists
- PRD-STATE.md updated
- PRD-ROADMAP.md updated
- PRD updated with implementation notes
