---
description: "Monetization discovery — gather business context"
argument-hint: "[path | \"description\"] (optional)"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:monetize-discover

Dispatch the monetize-discoverer agent to gather business context.

## Mode Detection

Parse `$ARGUMENTS`:
- No arguments → Mode A (self-analyze current project)
- Local path → Mode B (analyze target project)
- Quoted text → Mode C (business description)

## Execution

```
Agent(subagent_type="cks:monetize-discoverer", prompt="Gather business context. Mode: {detected_mode}. Arguments: $ARGUMENTS. Write to .monetize/context.md.")
```
