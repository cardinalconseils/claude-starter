---
description: "Debug anything — trace app runtime errors or diagnose CKS skill/agent/command issues"
argument-hint: "[error message] [--cks [phase|command|agent]] or no arg for exploratory mode"
allowed-tools:
  - Read
  - Agent
---

# /cks:debug — Unified Debugger

Dispatch the **debugger** agent (which has `skills: debug` loaded at startup).

## Mode Detection

Parse `$ARGUMENTS` to determine mode, then dispatch:

| Pattern | Mode |
|---------|------|
| `--cks` present | `cks-self` — CKS plugin introspection |
| Error string (no `--cks`) | `app-error` — trace a specific error |
| No args | `app-exploratory` — ask what's wrong |

## Dispatch

```
Agent(subagent_type="cks:debugger", prompt="Mode: {detected mode}. Context: {error message, or 'exploratory', or CKS component from --cks arg}. Project root: {cwd}. Arguments: $ARGUMENTS. Diagnose the issue, present a structured report, and ask before applying any fix.")
```

## Quick Reference

```
/cks:debug                              → Exploratory: ask what's wrong
/cks:debug "TypeError: cannot read..."  → Error-driven: trace a specific error
/cks:debug --cks                        → CKS self-debug: why did CKS just do that?
/cks:debug --cks discover               → CKS self-debug: specific phase/command
```

The debugger agent handles: diagnosis, evidence collection, report formatting, fix proposals, and user confirmation before applying changes.
