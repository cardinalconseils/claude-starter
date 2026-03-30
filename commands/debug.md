---
description: "Debug anything — trace app runtime errors or diagnose CKS skill/agent/command issues"
argument-hint: "[error message] [--cks [phase|command|agent]] or no arg for exploratory mode"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - Skill
  - AskUserQuestion
---

# /cks:debug — Unified Debugger

Debug app runtime issues OR CKS plugin internals. Diagnoses first, fixes only with permission.

## Usage

```
/cks:debug                              → Exploratory: ask what's wrong, trace it
/cks:debug "TypeError: cannot read..."  → Error-driven: trace a specific error
/cks:debug --cks                        → CKS self-debug: why did CKS just do that?
/cks:debug --cks discover               → CKS self-debug: specific phase/command/agent
```

## Step 1: Detect Mode

Parse `$ARGUMENTS`:

| Pattern | Mode | Action |
|---------|------|--------|
| `--cks` present | CKS self-debug | Load Skill `debug`, run CKS introspection |
| Error string given (no `--cks`) | App error-driven | Load Skill `debug`, trace the error |
| No args (no `--cks`) | App exploratory | Load Skill `debug`, ask what's wrong |

## Step 2: Load the Debug Skill

```
Skill(skill="debug")
```

The skill contains the full diagnostic workflow for both modes. Follow its instructions.

## Step 3: Dispatch Debugger Agent

Based on the mode and context gathered, dispatch the `debugger` agent:

```
Agent(subagent_type="debugger", prompt="""
Mode: {app-error | app-exploratory | cks-self}
Context: {error message, or user description, or CKS component name}
Project root: {cwd}

{Additional context from skill — see skill instructions}
""")
```

## Step 4: Present Diagnosis Report

The agent returns a structured diagnosis. Present it in this format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 DEBUG REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Mode:       {App | CKS}
  Trigger:    {error message or "exploratory"}

  Root Cause: {concise explanation}
  Chain:      {step-by-step trace of how we got here}
  Evidence:   {files, logs, state that confirm the diagnosis}

  Confidence: {High | Medium | Low}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Fix available? {Yes | No}
  Proposed:  {what would change}
  Files:     {list of files to modify}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Step 5: Ask Before Fixing

If a fix is available:

```
AskUserQuestion({
  questions: [{
    question: "Diagnosis complete. Want me to apply the fix?",
    header: "Debug Action",
    multiSelect: false,
    options: [
      { label: "Apply fix (Recommended)", description: "{summary of changes}" },
      { label: "Show me the fix first", description: "Display the exact code changes without applying" },
      { label: "I'll fix it myself", description: "Keep the diagnosis, skip the auto-fix" }
    ]
  }]
})
```

If user approves: apply the fix, then verify (re-run the build/test or re-check CKS state).

## Step 6: Log the Debug Session

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "debug.completed" "debug" "Debug session: {mode} — {root cause summary}" '{"mode":"{mode}","confidence":"{level}","fixed":{true|false}}'
```

## Constraints

- **Diagnose first** — never modify code before showing the report
- **User approves** — never apply a fix without explicit permission
- **No over-engineering** — fix the root cause, don't refactor surrounding code
- **Log everything** — every debug session gets a lifecycle log entry
- **Language-agnostic** — use strategic logging (print/console.log/fmt.Println), not debugger integration
