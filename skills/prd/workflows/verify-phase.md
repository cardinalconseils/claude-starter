# Workflow: Verify Phase

## Overview
Checks acceptance criteria for an executed phase. Uses the **prd-verifier** agent. Produces a VERIFICATION.md with pass/fail results.

## Pre-Conditions
- Phase has been executed (SUMMARY.md exists)
- Acceptance criteria defined in PLAN.md or PRD

## Steps

### Step 0: Progress Banner

Display the lifecycle progress banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► VERIFY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discuss     ✅ done
 [2] Plan        ✅ done
 [3] Execute     ✅ done
 [4] Verify      ▶ current
 [5] Ship        ○ pending
 [6] Retro       ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the phase to verify.

- If phase argument provided → verify that specific phase
- If no argument → verify the most recently executed phase

Verify that SUMMARY.md exists:
```
Read .prd/phases/{NN}-{name}/{NN}-SUMMARY.md
```

If no SUMMARY.md → tell the user: "Phase not yet executed. Run `/cks:execute {NN}` first."

### Step 2: Load Verification Context

Read:
- `.prd/phases/{NN}-{name}/{NN}-PLAN.md` — For acceptance criteria
- `.prd/phases/{NN}-{name}/{NN}-SUMMARY.md` — For what was implemented
- PRD document — For broader acceptance criteria
- `.claude/skills/prd/references/verification-patterns.md` — For verification techniques

### Step 2b: Verification Rigor (Superpowers)

Before dispatching the verifier, enforce evidence-based verification:

```
Skill(skill="superpowers:verification-before-completion")
```

This ensures we actually run commands and check output before claiming anything passes — no "it should work" assumptions. Skip silently if superpowers not installed.

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

### Step 4: Validate & Process Results

**Validate that `{NN}-VERIFICATION.md` exists and has required content:**
- File exists at `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md`
- Contains `## Results` section with PASS/FAIL verdict
- Contains at least one criterion check

**If validation fails:**
```
  [4] Verify      ✗ validation failed
      Expected: .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md
      Missing: {what's missing}
      Retrying verification...
```
Re-dispatch the verifier agent once. If it fails again, ask the user.

**Process results from VERIFICATION.md:**
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
next_action: "Phase complete. Run /cks:next for next phase"
```

Update PRD-ROADMAP.md:
- Set phase status to "Complete" with today's date

**If some criteria fail:**

Update PRD-STATE.md:
```yaml
phase_status: verification_failed
last_action: "Verification failed — {N} criteria not met"
next_action: "Fix issues and re-run /cks:execute or /cks:verify"
```

Keep PRD-ROADMAP.md as "Executed — Verification Failed"

### Step 6: Completion Banner

**If passed:**
```
  [4] Verify      ✅ passed
      Output: .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md
      Results: {X}/{X} criteria passed
      Next: /cks:ship or /cks:next
```

**If failed:**
```
  [4] Verify      ✗ {X}/{Y} criteria failed
      Output: .prd/phases/{NN}-{name}/{NN}-VERIFICATION.md
      Passed: {list}
      Failed:
        - {criterion} — {reason}
        - {criterion} — {reason}

      Options:
        1. Fix and re-execute: /cks:execute {NN}
        2. Re-verify after manual fixes: /cks:verify {NN}
        3. Accept and move on: update criteria in PLAN.md
```

### Step 7: Context Reset

All state is persisted to disk. Instruct the user to clear the context window before continuing:

```
━━━ Context Reset ━━━
Phase artifacts saved. Clear context and continue:

  /clear
  /cks:next

State is on disk — nothing is lost.
━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here. The user runs `/clear` then `/cks:next` to continue with a fresh context window.

## Post-Conditions
- `.prd/phases/{NN}-{name}/{NN}-VERIFICATION.md` exists
- PRD-STATE.md updated
- PRD-ROADMAP.md updated
