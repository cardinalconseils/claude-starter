# Sub-step [3c+]: De-Sloppify Pass

<context>
Phase: Sprint (Phase 3)
Requires: Implementation complete ([3c])
Produces: Cleaned source code, removed debug artifacts
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3c+.started" "{NN}-{name}" "Sprint: de-sloppify started"`

## Instructions

> **Expertise:** Read the `code-simplification` skill for the 5 simplification principles.

**Cleanup before review — remove implementation artifacts without constraining generation.**

Load the de-sloppify workflow from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/de-sloppify.md`.

Run a focused cleanup agent on all files listed in `{NN}-SUMMARY.md`:

```
Agent(
  model="sonnet",
  prompt="
    You are a code cleanup specialist.
    Read: .prd/phases/{NN}-{name}/{NN}-SUMMARY.md — get the file list
    Then review each file and remove ONLY:
      1. Debug artifacts (console.log, print(), commented-out code, debug imports)
      2. Tests that test the framework/language, not the application
      3. Over-defensive null checks where the type system guarantees non-null
      4. Wrapper functions used exactly once that add no logic
      5. Unused imports and variables

    Do NOT: refactor working code, change public APIs, remove error handling
    at system boundaries, remove WHY comments, or add new code.
  "
)
```

```
  [3c+] De-Sloppify           ✅ removed {N} artifacts
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3c+.completed" "{NN}-{name}" "Sprint: de-sloppify complete"`
