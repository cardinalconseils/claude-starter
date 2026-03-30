---
name: debug
description: >
  Debug anything — trace app runtime errors or diagnose CKS skill/agent/command issues.
  Language-agnostic diagnostic approach using code tracing and strategic logging.
  Use when: "debug", "why is this broken", "trace this error", "why did CKS do that",
  "what went wrong", "this isn't working", "unexpected behavior", "diagnose",
  or any variation of debugging app code or CKS plugin internals.
---

# Debug Skill

## Purpose

Unified diagnostic capability for two domains:
1. **App debugging** — Runtime errors, unexpected behavior, data flow issues in the user's project
2. **CKS self-debugging** — When CKS skills, agents, or commands misbehave

Both modes follow the same philosophy: **trace → diagnose → report → fix only with permission**.

## Mode Detection

Check `$ARGUMENTS` from the command:

```
--cks present?
  YES → CKS Self-Debug mode
    --cks has a value (e.g., "discover", "prd-executor")?
      YES → Target that specific component
      NO  → Diagnose last CKS action from lifecycle logs
  NO → App Debug mode
    Error string in arguments?
      YES → Error-driven mode
      NO  → Exploratory mode (ask what's wrong)
```

---

## App Debug Workflow

### Error-Driven (error string provided)

1. **Detect project language/framework:**
   - Glob for `package.json`, `tsconfig.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Makefile`
   - This determines log statement syntax for strategic instrumentation

2. **Gather context for the agent:**
   - The error message itself
   - The project root path
   - The detected language/framework
   - Log statement syntax: `console.log()` / `print()` / `fmt.Println()` / `println!()` / `puts`

3. **Dispatch the debugger agent:**
   ```
   Agent(subagent_type="debugger", prompt="""
   Mode: app-error
   Error: {error message or stack trace}
   Project root: {cwd}
   Language: {detected language}
   Log syntax: {appropriate log statement}

   Diagnose the root cause. Do NOT fix anything.
   Return structured diagnosis.
   """)
   ```

### Exploratory (no error string)

1. **Ask what's wrong:**
   ```
   AskUserQuestion({
     questions: [{
       question: "What's happening that shouldn't be?",
       header: "Debug: Describe the Issue",
       multiSelect: false,
       options: [
         { label: "Wrong output / data", description: "Code runs but produces incorrect results" },
         { label: "Feature not working", description: "Something that should work doesn't" },
         { label: "Performance issue", description: "Too slow, hanging, or resource-heavy" },
         { label: "Intermittent / flaky", description: "Sometimes works, sometimes doesn't" },
         { label: "Other", description: "I'll describe it" }
       ]
     }]
   })
   ```

2. **Gather context** (same as error-driven, plus user's description)

3. **Dispatch the debugger agent** with mode `app-exploratory`

---

## CKS Self-Debug Workflow

### Step 1: Gather CKS State

Read these files (skip any that don't exist):

```
Read .prd/PRD-STATE.md
Read .prd/logs/lifecycle.jsonl (last 50 lines via tail)
```

### Step 2: Identify Target Component

If `--cks` has a value, map it to a component:

```
# Check if it's a command
Glob ${CLAUDE_PLUGIN_ROOT}/commands/{value}.md

# Check if it's an agent
Glob ${CLAUDE_PLUGIN_ROOT}/agents/{value}.md
Glob ${CLAUDE_PLUGIN_ROOT}/agents/*{value}*.md

# Check if it's a skill
Glob ${CLAUDE_PLUGIN_ROOT}/skills/{value}/SKILL.md

# Check if it's a phase name
Grep "phase.{value}" .prd/logs/lifecycle.jsonl
```

If no value, read the last 10 lifecycle log entries to identify the most recent CKS action.

### Step 3: Read the Component

Read the identified skill/agent/command file to understand what it's SUPPOSED to do.

### Step 4: Dispatch Debugger Agent

```
Agent(subagent_type="debugger", prompt="""
Mode: cks-self
Component: {type} — {name}
Component path: {file path}
Component content: {full content of the skill/agent/command file}

PRD State:
{content of PRD-STATE.md}

Recent lifecycle logs:
{last 20 relevant log entries}

Diagnose why this CKS component isn't working as expected.
Compare its instructions against what the logs show actually happened.
Return structured diagnosis.
""")
```

---

## Post-Diagnosis: Fix Flow

After the agent returns its diagnosis and the command presents the report:

### If user says "Apply fix"

1. **For app fixes:**
   - Edit the files identified in the diagnosis
   - Fix the ROOT CAUSE, not the symptom
   - Re-run the relevant command (build, test, or manual repro) to verify
   - Report: fixed / partially fixed / failed

2. **For CKS fixes:**
   - If **state corrupted**: repair PRD-STATE.md or .prd/ files to match reality
   - If **skill description mismatch**: update the skill's `description` field for better triggering
   - If **agent off-rails**: tighten the agent's constraints or adjust its tools list
   - If **skipped steps**: check workflow file for conditional logic that may have short-circuited
   - If **wrong output**: adjust the agent's prompt or the skill's instructions

3. **Verify the fix:**
   - App: re-run build/test
   - CKS: re-run the command that failed and confirm it works

### If user says "Show me the fix first"

Display the exact changes as a diff (Read the files, show old → new) without applying.

### If user says "I'll fix it myself"

End the session. The diagnosis report is their deliverable.

---

## Strategic Logging Reference

Language-agnostic log statement patterns for instrumentation:

| Language | Log Syntax | Remove Pattern |
|----------|-----------|----------------|
| JavaScript/TypeScript | `console.log('[DEBUG]', varName)` | `grep -n "console.log.*DEBUG" file` |
| Python | `print(f'[DEBUG] {var_name=}')` | `grep -n "print.*DEBUG" file` |
| Go | `fmt.Printf("[DEBUG] %v\n", varName)` | `grep -n "fmt.Print.*DEBUG" file` |
| Rust | `println!("[DEBUG] {:?}", var_name);` | `grep -n "println.*DEBUG" file` |
| Ruby | `puts "[DEBUG] #{var_name}"` | `grep -n "puts.*DEBUG" file` |
| Java | `System.out.println("[DEBUG] " + varName);` | `grep -n "System.out.*DEBUG" file` |

All strategic log statements use the `[DEBUG]` prefix for easy cleanup after diagnosis.

---

## Constraints

- **Diagnose first, always** — never jump to fixing without showing the report
- **Trace, don't guess** — every diagnosis must cite file:line or log evidence
- **Language-agnostic** — use strategic logging, not language-specific debuggers
- **Clean up after** — if strategic logging was injected, offer to remove `[DEBUG]` lines after fix
- **Log the session** — every debug session gets a lifecycle.jsonl entry via cks-log.sh
