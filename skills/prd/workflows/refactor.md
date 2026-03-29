# Workflow: Refactor

## Overview
Safely refactor existing code — improving structure, readability, performance, or architecture — without changing external behavior. Uses the **prd-refactorer** agent. Produces impact analysis and refactoring summary in the phase directory.

## Pre-Conditions
- `.prd/` exists
- Target code exists in the codebase

## Steps

### Step 1: Parse Target

From `$ARGUMENTS`, determine:
- **Target:** What to refactor (file, component, feature area, pattern)
- **Type:** layout | component | data-flow | api | pattern | performance (from --type flag or auto-detect)

If no arguments provided, use `AskUserQuestion`:
```
AskUserQuestion({
  questions: [
    {
      question: "What do you want to refactor?",
      header: "Target",
      multiSelect: false,
      options: [
        { label: "A specific component", description: "Refactor a React component — extract subcomponents, simplify props, reduce complexity" },
        { label: "Page layout", description: "Refactor layout structure — CSS, grid/flex, responsive design, component nesting" },
        { label: "Data flow / state", description: "Refactor how data moves — lift state, extract hooks, simplify context" },
        { label: "Code pattern", description: "Apply consistent patterns across multiple files — naming, error handling, imports" }
      ]
    },
    {
      question: "Which area of the codebase?",
      header: "Scope",
      multiSelect: false,
      options: [
        { label: "ProcessFlow editor", description: "The main flowchart editor — ProcessFlow.tsx, BpmnNodes, canvas components" },
        { label: "Process cards", description: "Process card generation — evaluator, chatbot, card components" },
        { label: "Navigation / layout", description: "App shell — sidebar, header, routing, responsive layout" },
        { label: "Other (I'll describe)", description: "Something else not listed here" }
      ]
    }
  ]
})
```

### Step 2: Determine Phase Context

Check if refactoring fits within an existing phase:
- Read `.prd/PRD-STATE.md` for active phase
- If the refactoring is part of a current phase → use that phase directory
- If standalone refactoring → create a new phase directory: `.prd/phases/{NN}-refactor-{target}/`

### Step 3: Dispatch Refactorer Agent

```
Agent(
  subagent_type="prd-refactorer",
  prompt="
    Project root: {project_root}
    Target: {target description}
    Type: {refactoring type}
    Phase directory: .prd/phases/{NN}-{name}/

    Read these files (lazy — do not embed contents):
    - CLAUDE.md — conventions

    Your job: Follow your agent instructions to:
    1. Analyze impact — find all files affected, all dependencies
    2. Design the refactoring plan — ordered steps with rollback strategy
    3. Dispatch workers for independent file groups (you decide: solo or team)
    4. Verify behavior preserved — run tests, build, lint
    5. Write impact analysis to: .prd/phases/{NN}-{name}/{NN}-REFACTOR-IMPACT.md
    6. Write summary to: .prd/phases/{NN}-{name}/{NN}-REFACTOR-SUMMARY.md
  "
)
```

### Step 4: Post-Refactoring Checks

After the agent completes:

**4a. Build verification:**
```bash
npm run build 2>&1
```

**4b. Test verification:**
```bash
npm test 2>&1
```

**4c. Visual verification (frontend refactors):**
If the refactoring touched UI components:
```
Skill(skill="browse", args="Navigate to {app_url}. Verify the refactored {target} renders correctly. Take before/after screenshots.")
```

### Step 5: Update State

Update PRD-STATE.md:
```yaml
last_action: "Refactored {target}"
last_action_date: {today}
```

If the refactoring was part of a phase, don't change phase status.
If standalone, note it in session history.

### Step 6: Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► REFACTOR COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Target: {target}
 Type: {type}
 Files changed: {N}

 Verification:
   Build: {PASS/FAIL}
   Tests: {PASS/FAIL}
   Visual: {PASS/FAIL/SKIP}

 Impact: .prd/phases/{NN}-{name}/{NN}-REFACTOR-IMPACT.md
 Summary: .prd/phases/{NN}-{name}/{NN}-REFACTOR-SUMMARY.md
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then ask next action:
```
AskUserQuestion({
  questions: [{
    question: "Refactoring complete. What next?",
    header: "Next",
    multiSelect: false,
    options: [
      { label: "Commit changes (Recommended)", description: "Stage and commit the refactoring with a descriptive message" },
      { label: "Review the diff", description: "Show git diff of all changes before committing" },
      { label: "Refactor something else", description: "Continue with another refactoring target" },
      { label: "Done", description: "No more changes needed" }
    ]
  }]
})
```

## Post-Conditions
- Code refactored with build/test passing
- `.prd/phases/{NN}-{name}/{NN}-REFACTOR-IMPACT.md` exists
- `.prd/phases/{NN}-{name}/{NN}-REFACTOR-SUMMARY.md` exists
- PRD-STATE.md updated
