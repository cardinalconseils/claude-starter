---
name: refactor
description: Refactor a feature, layout, component, or pattern with safety checks and verification
argument-hint: "<target> [--type layout|component|data-flow|api|pattern|performance]"
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
  - TodoRead
  - TodoWrite
  - "mcp__*"
---

# /cks:refactor — Safe Refactoring with Impact Analysis

Load the workflow instructions from `.claude/skills/prd/workflows/refactor.md` and follow them exactly.

## Quick Reference

Launches the **prd-refactorer** agent to:
1. Analyze impact of the proposed refactoring
2. Design a step-by-step transformation plan
3. Execute changes with build checks after each step
4. Verify behavior is preserved (tests, build, visual)
5. Write summary to `.prd/phases/{NN}-{name}/`

## Argument Handling

- **Target required:** file path, component name, or description of what to refactor
  - `ProcessFlow.tsx` — refactor a specific file
  - `node palette layout` — refactor a feature area
  - `all BPMN components` — refactor a group
- **--type flag (optional):** layout, component, data-flow, api, pattern, performance
  - If not provided, the agent detects the type from the target

## Examples

```
/cks:refactor ProcessFlow.tsx --type component
/cks:refactor "sidebar layout" --type layout
/cks:refactor "icon rendering across all node types" --type pattern
/cks:refactor BpmnNodes.tsx --type performance
```
