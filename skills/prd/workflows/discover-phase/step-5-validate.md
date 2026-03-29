# Step 5: Validate Output

<context>
Phase: Discover (Phase 1)
Requires: {NN}-CONTEXT.md should exist
Produces: Validation pass/fail result
</context>

## Inputs

- Read: `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md`
- Read: `.prd/phases/{NN}-{name}/{NN}-SECRETS.md`

## Instructions

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.5.started" "{NN}-{name}" "Step 5: Validate output"`

**Check that `{NN}-CONTEXT.md` exists and has all 10 elements with substantive content:**

1. File exists at `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md`
2. Contains `## Problem Statement` or `## Value Proposition`
3. Contains `## User Stories` — **at least 3 stories with "so that" clause**
4. Contains `## Scope`
5. Contains `## API Surface` (or marked N/A if no API)
6. Contains `## Acceptance Criteria` — **at least 2 testable criteria per user story**
7. Contains `## Constraints`
8. Contains `## Test Plan` with unit, integration, AND E2E sections — **specific test cases, not placeholders**
9. Contains `## UAT Scenarios` — **at least 3 Given/When/Then scenarios**
10. Contains `## Definition of Done`
11. Contains `## Success Metrics`

**Quality gate:** If User Stories, Acceptance Criteria, Test Plan, or UAT Scenarios contain only template placeholders (e.g., `{action}`, `{value}`, `TBD`), validation FAILS.

**Also check:** `{NN}-SECRETS.md` exists (can have empty table if no secrets needed).

**If validation fails:**

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh WARN "artifact.validation_failed" "{NN}-{name}" "CONTEXT.md validation failed" '{"path":"{NN}-CONTEXT.md"}'`

```
  [1] Discover    ✗ validation failed
      Expected: .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
      Missing: {which elements are missing}
      Retrying discovery for missing elements...
```
Re-dispatch the discoverer agent for ONLY the missing elements. If it fails again, ask the user.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.5.completed" "{NN}-{name}" "Step 5: Validation passed"`

## Success Condition

- All 10 elements present with real content
- {NN}-SECRETS.md exists

## On Failure

- Re-dispatch discoverer for missing elements (once)
- If still failing: ask the user to fill in missing elements manually
