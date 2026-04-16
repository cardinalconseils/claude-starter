---
description: "Assess any existing codebase — health, code review, security audit, and debug triage via the Attractor pipeline"
allowed-tools:
  - Agent
  - Read
---

# /cks:assess

## What It Does
Drops into any existing codebase and runs an assessment pipeline defined in
`pipelines/assess.dot`. Produces `.assess/ASSESSMENT.md` — a consolidated report
covering project health, code quality, security vulnerabilities, and runtime issues.

Can run all phases in sequence or target a single phase for a quick focused audit.

## Usage
```
/cks:assess [--mode full|health|review|security|debug]
```

## Arguments
| Argument | Required | Description |
|----------|----------|-------------|
| `--mode full` | No | Run all phases: Health → Review → Security → Debug → Report (default) |
| `--mode health` | No | Project hygiene only — deps, env vars, git state, TODO count |
| `--mode review` | No | Code quality only — conventions, complexity, error handling |
| `--mode security` | No | Security audit only — OWASP Top 10, secrets, auth, config |
| `--mode debug` | No | Runtime triage only — crash traces, build failures, known bugs |

## Dispatch

```
Agent(subagent_type="cks:assess-runner", prompt="Run the CKS assessment pipeline at pipelines/assess.dot. Args: $ARGUMENTS")
```

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
- `.assess/ASSESSMENT.md` — consolidated report with executive summary
- Console: executive summary printed at the end

## Constraints
- Never modify project code — this pipeline is read-only assessment
- Report phase always runs, even if earlier phases partially fail
- Findings reference file:line — never vague or un-actionable
