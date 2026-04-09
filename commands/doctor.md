---
description: "Run a full project health diagnostic — env vars, TODOs, tests, PRD state, git hygiene"
allowed-tools:
  - Read
  - Agent
---

# /cks:doctor — Project Health Diagnostic

Dispatch the health-checker agent to run a battery of checks and report a health score.

## Dispatch

```
Agent(subagent_type="cks:health-checker", prompt="
  project_root: {current directory}
")
```

## What It Checks

- Git hygiene (uncommitted changes, stale branches)
- Build health (auto-detects and runs build)
- Test health (auto-detects and runs tests)
- Dependency vulnerabilities
- Environment variables (.env setup)
- Code quality (TODO/FIXME/HACK counts)
- PRD state (phase, staleness)
- Branch freshness (commits behind main)

## Quick Reference

```
/cks:doctor     → Full health diagnostic with scored report
/cks:status     → Quick project dashboard
```
