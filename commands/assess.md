---
description: "Assess any existing codebase — health, code review, security audit, and debug triage via the Attractor pipeline"
argument-hint: "[--mode full|health|review|security|debug]"
allowed-tools:
  - Read
  - Skill
---

# /cks:assess

Drops into any existing codebase and runs the assessment pipeline defined in
`pipelines/assess.dot`. Produces `.assess/ASSESSMENT.md` — a consolidated report covering
project health, code quality, security vulnerabilities, and runtime issues. Read-only:
the pipeline never modifies project code.

## Arguments

| Argument | Description |
|----------|-------------|
| `--mode full` | Health → Review → Security → Debug → Report (default) |
| `--mode health` | Project hygiene only — deps, env vars, git state, TODO count |
| `--mode review` | Code quality only — conventions, complexity, error handling |
| `--mode security` | Security audit only — OWASP Top 10, secrets, auth, config |
| `--mode debug` | Runtime triage only — crash traces, build failures, known bugs |

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): the pipeline
dispatches a role per node, so it loads the attractor engine as a top-level skill.

```
Skill(skill="cks:attractor")
```

pipeline: `assess` · Arguments: `$ARGUMENTS` (default `--mode full`). The engine's
`## Pipeline Profiles` row for `assess` applies: `Dispatch` diamond routes on `--mode`,
`cks:watchdog` (Health), `cks:reviewer` (Review, Report), `cks:reviewer` (Security),
`cks:debugger` (Debug); no goal gates; `Report` always runs.

## Quick Reference
```
/cks:assess                     # Full run — all phases + consolidated report
/cks:assess --mode security     # Security audit only
/cks:assess --mode review       # Code review only
/cks:assess --mode debug        # Debug triage only
/cks:assess --mode health       # Health check only
```

## Output
- `.assess/FINDINGS.md` — raw findings from each phase
- `.assess/ASSESSMENT.md` — consolidated report with executive summary (also printed)

Findings reference file:line — never vague or un-actionable.
