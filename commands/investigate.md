---
description: "Scan for issues, log them to GitHub, and queue for debugging — broad investigation or targeted area"
argument-hint: "[area or symptom] [--issue N to debug a specific filed issue]"
allowed-tools:
  - Read
  - Agent
  - Bash
  - AskUserQuestion
---

# /cks:investigate — Investigation → GitHub Issues → Debug Queue

Scan for problems, file every finding to GitHub, return a prioritized issue list.

## Pre-Check

```bash
find .preflight -name "PREFLIGHT.md" 2>/dev/null | sort | tail -1
```

Pass `preflight_path` to the agent if found (advisory — not a gate).

## Mode Detection

| Pattern | Mode |
|---------|------|
| `--issue N` | `debug-issue` — debug a specific filed GitHub issue |
| Area/symptom string | `targeted` — investigate a specific area or symptom |
| No args | `broad` — full-project health sweep |

## Mode: debug-issue

```
Agent(subagent_type="cks:debugger", prompt="Mode: issue-driven. Issue number: {N}. Read GitHub issue #{N} from the current repo (owner/repo from git remote). Diagnose root cause, propose fix, ask user to confirm before applying. After fix verified, close the issue.")
```

## Mode: targeted or broad

```
Agent(subagent_type="cks:investigator", prompt="Mode: {targeted|broad}. Area/symptom: {$ARGUMENTS or 'full project sweep'}. Project root: {cwd}. PREFLIGHT.md: {preflight_path or 'not found'} — if found, read §P (Position) to scope your scan to the feature's tables/routes/services, and §F (Flag) for known gotchas. Scan for issues, file each to GitHub, return a prioritized list.")
```

## After Agent Completes

Display the result. Parse the report for blocking issues (lines matching `#N 🔴`).

**Blocking issues found:** Ask: `"Investigation complete. {N} blocking issue(s) filed (#{list}). Debug and fix them now?"` Options: `["Yes — start parallel debugging", "No — I'll debug manually later"]`

If yes: `Agent(subagent_type="cks:debugger", prompt="Mode: multi-issue. Issues: {comma-separated issue numbers}. Repo: {owner/repo from git remote}. Project root: {cwd}. Group by file scope, dispatch parallel workers in worktrees, merge fixes, report results.")`

**No blocking issues:** Show `Next steps: /cks:debug --issue N` or `/cks:investigate`

## Quick Reference

```
/cks:investigate                   → Broad sweep — find all issues, file to GitHub
/cks:investigate "auth flow"       → Targeted — investigate a specific area
/cks:investigate "login is broken" → Symptom-driven — trace a specific symptom
/cks:investigate --issue 42        → Debug and fix GitHub issue #42
```
