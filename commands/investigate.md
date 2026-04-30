---
description: "Scan for issues, log them to GitHub, and queue for debugging — broad investigation or targeted area"
argument-hint: "[area or symptom] [--issue N to debug a specific filed issue]"
allowed-tools:
  - Read
  - Agent
  - Bash
---

# /cks:investigate — Investigation → GitHub Issues → Debug Queue

Scan for problems, file every finding to GitHub, return a prioritized issue list.

## Mode Detection

Parse `$ARGUMENTS`:

| Pattern | Mode |
|---------|------|
| `--issue N` | `debug-issue` — debug a specific filed GitHub issue |
| Area/symptom string | `targeted` — investigate a specific area or symptom |
| No args | `broad` — full-project health sweep |

## Mode: debug-issue

Extract issue number N from `--issue N`. Dispatch the debugger in issue mode:

```
Agent(subagent_type="cks:debugger", prompt="Mode: issue-driven. Issue number: {N}. Read GitHub issue #{N} from the current repo (owner/repo from git remote). Use the issue title, body, and labels as your debug context. Diagnose the root cause, propose a fix, ask user to confirm before applying. After fix is verified, close the issue.")
```

## Mode: targeted or broad

Dispatch the investigator agent:

```
Agent(subagent_type="cks:investigator", prompt="Mode: {targeted|broad}. Area/symptom: {$ARGUMENTS or 'full project sweep'}. Project root: {cwd}. Scan for issues, file each to GitHub, return a prioritized list.")
```

## After Agent Completes

Display the result from the agent, then show:

```
Next steps:
  /cks:debug --issue N         → debug and fix a specific issue
  /cks:investigate             → run another broad sweep
```

## Quick Reference

```
/cks:investigate                   → Broad sweep — find all issues, file to GitHub
/cks:investigate "auth flow"       → Targeted — investigate a specific area
/cks:investigate "login is broken" → Symptom-driven — trace a specific symptom
/cks:investigate --issue 42        → Debug and fix GitHub issue #42 (prefer /cks:debug --issue 42)
```
