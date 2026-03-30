---
description: "Refactor a feature, layout, component, or pattern with safety checks and verification"
argument-hint: "<target> [--type layout|component|data-flow|api|pattern|performance]"
allowed-tools:
  - Read
  - Agent
---

# /cks:refactor — Safe Refactoring

Dispatch the **prd-refactorer** agent (which has `skills: prd` loaded at startup).

## Dispatch

```
Agent(subagent_type="prd-refactorer", prompt="Refactor: $ARGUMENTS. Read .prd/PRD-STATE.md for current phase context. Analyze impact, design a step-by-step plan, execute with build checks, and verify behavior is preserved. Arguments: $ARGUMENTS")
```

## Quick Reference

**Target required:** file path, component name, or description of what to refactor.

```
/cks:refactor ProcessFlow.tsx --type component
/cks:refactor "sidebar layout" --type layout
/cks:refactor "icon rendering across all node types" --type pattern
/cks:refactor BpmnNodes.tsx --type performance
```

The prd-refactorer agent handles: impact analysis, step-by-step planning, parallel worker dispatch, build checks, and behavior verification.
