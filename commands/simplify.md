---
description: "Simplify recent code changes for clarity and maintainability while preserving behavior"
allowed-tools:
  - Agent
---

# /cks:simplify — Code Simplification

Dispatch the **code-simplifier** agent (which has `skills: code-simplification, core-behaviors` loaded at startup).

## Dispatch

Agent(subagent_type="cks:code-simplifier", prompt="Simplify code for clarity and maintainability. Scope: $ARGUMENTS (default: recent changes via git diff). Read the code-simplification skill for the 5 principles. Preserve behavior exactly. Run tests after each change. Report what was simplified and why.")

## Quick Reference

```
/cks:simplify              Simplify recent changes (git diff)
/cks:simplify file.ts      Simplify a specific file
/cks:simplify all           Scan full project (use with caution)
```
