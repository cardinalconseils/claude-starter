# Step 3: Check for Existing Discovery

<context>
Phase: Discover (Phase 1)
Requires: {NN} and {name} determined
Produces: Decision — fresh discovery, resume, or skip to design
</context>

## Inputs

- Read: `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` (if exists)

## Instructions

Check if `{NN}-CONTEXT.md` already exists in the phase directory.

**If {NN}-CONTEXT.md exists and is complete:**

```
AskUserQuestion({
  questions: [{
    question: "Discovery already exists for this phase. What would you like to do?",
    header: "Existing Discovery",
    multiSelect: false,
    options: [
      { label: "Re-do discovery", description: "Start fresh — overwrite existing context" },
      { label: "Resume discovery", description: "Continue from where it left off" },
      { label: "Proceed to Design", description: "Skip — move to Phase 2" }
    ]
  }]
})
```

- If "Re-do" → proceed to step-4 (fresh discovery)
- If "Resume" → proceed to step-4 with existing content as starting point
- If "Proceed to Design" → skip to step-6 (update state to `discovered`)

**If {NN}-CONTEXT.md exists but is incomplete:**
- Resume from where it left off (proceed to step-4)

**If no {NN}-CONTEXT.md:**
- Fresh discovery (proceed to step-4)

## Success Condition

- Decision made: fresh, resume, or skip

## On Failure

- Default to fresh discovery if file state is ambiguous
