---
description: "Debug anything — trace app runtime errors, GitHub issues, or diagnose CKS skill/agent/command issues"
argument-hint: "[error message] [--issue N] [--issues N1,N2,...] [--all] [--cks [phase|command|agent]] or no arg for exploratory mode"
allowed-tools:
  - Read
  - Agent
  - Bash
  - "mcp__plugin_github_github__issue_read"
---

# /cks:debug — Unified Debugger

Dispatch the **debugger** agent (which has `skills: debug` loaded at startup).

## Mode Detection

| Pattern | Mode |
|---------|------|
| `--issue N` | `issue-driven` — debug a specific GitHub issue |
| `--issues N1,N2,...` | `multi-issue` — parallel debug of multiple issues |
| `--all` | `multi-issue` — debug all open `cks:blocking` issues from this repo |
| `--cks` | `cks-self` — CKS plugin introspection |
| Error string (no flags) | `app-error` — trace a specific error |
| No args | `app-exploratory` — ask what's wrong |

## Pre-Dispatch: issue-driven

Extract N. Run `git remote get-url origin` (parse owner/repo). Read issue via `mcp__plugin_github_github__issue_read`. Pass full body to debugger.

## Pre-Dispatch: multi-issue

`--issues N1,N2,...`: parse numbers from `$ARGUMENTS`. `--all`: parse owner/repo from git remote, list open `cks:blocking` issues via GitHub MCP, collect numbers.

## Dispatch

**Single-issue or error modes:**
```
Agent(subagent_type="cks:debugger", prompt="Mode: {detected mode}. Context: {error message, issue body, 'exploratory', or CKS component}. Issue number: {N or 'none'}. Repo: {owner/repo or 'none'}. Project root: {cwd}. Arguments: $ARGUMENTS. Diagnose, present structured report, ask before applying fix.")
```

**Multi-issue mode:**
```
Agent(subagent_type="cks:debugger", prompt="Mode: multi-issue. Issues: {comma-separated issue numbers}. Repo: {owner/repo}. Project root: {cwd}. Group by file scope, dispatch parallel debugger-worker agents in worktrees (max 4), merge fixes, report summary.")
```

## Quick Reference

```
/cks:debug                              → Exploratory: ask what's wrong
/cks:debug "TypeError: cannot read..."  → Error-driven: trace a specific error
/cks:debug --issue 42                   → Issue-driven: debug and fix GitHub issue #42
/cks:debug --issues 12,14,17            → Parallel debug of issues #12, #14, #17
/cks:debug --all                        → Debug all blocking auto-filed issues
/cks:debug --cks                        → CKS self-debug: why did CKS just do that?
/cks:debug --cks discover               → CKS self-debug: specific phase/command
```

The debugger agent handles: diagnosis, evidence collection, fix proposals, user confirmation, and closing issues when fixed.
