# Step 4: Validate Output

<context>
Phase: Design (Phase 2)
Requires: Designer agent has completed
Produces: Validation pass/fail result
</context>

## Instructions

**Check that design artifacts exist:**
- `.prd/phases/{NN}-{name}/design/ux-flows.md` exists
- `.prd/phases/{NN}-{name}/design/diagrams/` directory has at least one diagram (or Mermaid in ux-flows.md)
- `.prd/phases/{NN}-{name}/design/api-contract.md` exists (if feature has API surface from CONTEXT.md)
- `.prd/phases/{NN}-{name}/design/screens/` directory has at least one screen
- `.prd/phases/{NN}-{name}/design/component-specs.md` exists
- `.prd/phases/{NN}-{name}/design/review-signoff.md` exists with approval

**If validation fails:**
```
  [2] Design      ✗ validation failed
      Missing: {what's missing}
      Retrying design for missing artifacts...
```
Re-dispatch the designer agent for missing sub-steps. If it fails again, ask the user.
