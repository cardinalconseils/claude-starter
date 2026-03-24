# Workflow: Verify Phase

## Overview
Checks acceptance criteria for an executed phase. Uses the **prd-verifier** agent. Produces a VERIFICATION.md with pass/fail results.

## Pre-Conditions
- Phase has been executed (SUMMARY.md exists)
- Acceptance criteria defined in PLAN.md or PRD

## Steps

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the phase to verify.

- If phase argument provided → verify that specific phase
- If no argument → verify the most recently executed phase

Verify that SUMMARY.md exists:
```
Read .prd/phases/{NN}-{name}/{NN}-SUMMARY.md
```

If no SUMMARY.md → tell the user: "Phase not yet executed. Run `/prd:execute {NN}` first."

### Step 2: Load Verification Context

Read:
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` — For acceptance criteria
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` — For what was implemented
- PRD document — For broader acceptance criteria
- `.claude/skills/prd/references/verification-patterns.md` — For verification techniques

### Step 3: Dispatch Verifier Agent

Dispatch the **prd-verifier** agent with:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Plan: {PLAN.md content}
- Summary: {SUMMARY.md content}
- PRD acceptance criteria: {from PRD}
- Verification patterns: {from references}

Your job: Follow your agent instructions to:
1. Check each acceptance criterion
2. Run tests if available
3. Verify code quality and conventions
4. Write results to .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md
```

### Step 4: Process Results

Read the VERIFICATION.md output. Determine:
- **All pass** → Phase is complete
- **Some fail** → Phase needs fixes
- **Blockers** → Cannot proceed

### Step 5: Update State

**If all criteria pass:**

Update PRD-STATE.md:
```yaml
active_phase: {NN}
phase_status: verified
last_action: "Verification passed"
next_action: "Phase complete. Run /prd:next for next phase"
```

Update PRD-ROADMAP.md:
- Set phase status to "Complete" with today's date

**If some criteria fail:**

Update PRD-STATE.md:
```yaml
phase_status: verification_failed
last_action: "Verification failed — {N} criteria not met"
next_action: "Fix issues and re-run /prd:execute or /prd:verify"
```

Keep PRD-ROADMAP.md as "Executed — Verification Failed"

### Step 6: Report

**If passed:**
```
Verification PASSED for Phase {NN}: {name}

All {N} acceptance criteria met.
Details: .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md

Next: Run /prd:next to advance to the next phase
```

**If failed:**
```
Verification FAILED for Phase {NN}: {name}

Results: {X}/{Y} criteria passed

Failed criteria:
  - {criterion} — {reason}

Options:
  1. Fix and re-execute: /prd:execute {NN}
  2. Re-verify after manual fixes: /prd:verify {NN}
  3. Accept and move on: update criteria in PLAN.md
```

## Post-Conditions
- `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` exists
- PRD-STATE.md updated
- PRD-ROADMAP.md updated
