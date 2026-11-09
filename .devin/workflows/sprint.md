---
description: "Phase 3 — Sprint: Plan, implement, verify, and merge the feature"
---

# Sprint Workflow

## Purpose
Build the feature following the design, with TDD and quality gates.

## Prerequisites
- Design phase complete (`.phases/{feature_id}/DESIGN.md` exists)

## Steps

### 3a: Planning

1. **Read state:** Load `.phases/PRD-STATE.json`, `CONTEXT.md`, and `DESIGN.md`.

2. **Create technical design:** Define the implementation approach:
   - File structure
   - Key modules and responsibilities
   - Integration points
   - Technical risks and mitigations

3. **Break down tasks:** Split work into tasks under 4 hours each. Each task should be:
   - Atomic and independently testable
   - Clearly defined with acceptance criteria
   - Ordered by dependency

4. **Write test cases (TDD):** For each task, write the test cases before implementation.

5. **Generate artifact:** Write plan to `.phases/{feature_id}/PLAN.md`.

### 3b: Implementation

6. **Implement one task at a time:**
   - Write failing test
   - Implement minimal code to pass test
   - Refactor if needed
   - Run tests
   - Commit with descriptive message

7. **After all tasks:** Run full test suite, lint, and type checks.

8. **Generate artifact:** Write summary to `.phases/{feature_id}/SUMMARY.md`.

### 3c: Verification

9. **Verify acceptance criteria:** For each criterion from CONTEXT.md:
   - Run the relevant test
   - Document the result (pass/fail)
   - Provide evidence (test output, screenshot, etc.)

10. **Check for regressions:** Run existing tests to ensure no regressions.

11. **Classify issues:** If any criteria fail, classify by severity (critical/high/medium/low).

12. **Generate artifact:** Write verification to `.phases/{feature_id}/VERIFICATION.md`.

### 3d: Merge

13. **Create PR:** If all criteria pass, create a pull request with:
    - Descriptive title
    - Summary of changes
    - Link to CONTEXT.md and DESIGN.md
    - Test results

14. **Update state:** Set `phase_status` to "complete", `current_phase` to "review", `next_action` to "Starting review phase automatically".

15. **Report and auto-advance:** Show what was built in plain English. Say: "I've built the feature and created a pull request. Let me review it for you." Then automatically continue to the review workflow.

## Convergence Loop
If verification fails:
1. Read failure classification from VERIFICATION.md
2. Re-implement with targeted fix (not blind re-run)
3. Re-verify
4. Max 3 iterations before escalating to user

## Rules
- Always write tests before implementation (TDD)
- Prefer minimal changes over refactoring
- Commit after each task (atomic history)
- Never skip verification
- Use confirmation for destructive changes
- **Auto-advance to review after sprint completes** — don't make the user run the next command
- **Plain English only** — no jargon, no command names, no phase numbers
