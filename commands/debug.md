---
description: "Debug anything — trace app runtime errors, GitHub issues, or diagnose CKS skill/agent/command issues"
argument-hint: "[error message] [--issue N] [--cks [phase|command|agent]] or no arg for exploratory mode"
allowed-tools:
  - Read
  - Agent
  - Bash
  - "mcp__plugin_github_github__issue_read"
---

# /cks:debug — Unified Debugger

Dispatch the **debugger** agent (which has `skills: debug` loaded at startup).

## Mode Detection

Parse `$ARGUMENTS` to determine mode, then dispatch:

| Pattern | Mode |
|---------|------|
| `--issue N` present | `issue-driven` — debug a specific GitHub issue |
| `--cks` present | `cks-self` — CKS plugin introspection |
| Error string (no flags) | `app-error` — trace a specific error |
| No args | `app-exploratory` — ask what's wrong |

## Pre-Dispatch: issue-driven

Extract issue number N. Get repo coordinates:
```bash
git remote get-url origin  # parse owner/repo
```

Read the issue via `mcp__plugin_github_github__issue_read(owner, repo, issue_number=N)`.
Pass the full issue body as context to the debugger.

## Dispatch

```
Agent(subagent_type="cks:debugger", prompt="Mode: {detected mode}. Context: {error message, issue body, 'exploratory', or CKS component}. Issue number: {N or 'none'}. Repo: {owner/repo or 'none'}. Project root: {cwd}. Arguments: $ARGUMENTS. Diagnose the issue, present a structured report, and ask before applying any fix.")
```

## Quick Reference

```
/cks:debug                              → Exploratory: ask what's wrong
/cks:debug "TypeError: cannot read..."  → Error-driven: trace a specific error
/cks:debug --issue 42                   → Issue-driven: debug and fix GitHub issue #42
/cks:debug --cks                        → CKS self-debug: why did CKS just do that?
/cks:debug --cks discover               → CKS self-debug: specific phase/command
```

The debugger agent handles: diagnosis, evidence collection, report formatting, fix proposals, user confirmation before applying changes, and closing GitHub issues when fixed.
