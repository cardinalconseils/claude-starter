---
description: "Loop lifecycle manager — design, run, health check, triage, cost monitor, migrate"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:loop — Loop Lifecycle Manager

Dispatch `cks:loop-orchestrator` with the provided sub-command and slug.

```
Agent(
  subagent_type="cks:loop-orchestrator",
  prompt="sub-command: {sub-command}, slug: {slug}, args: {remaining args}"
)
```

Parse from user input:
- **sub-command**: first argument (design | run | health | triage | cost | migrate | status)
- **slug**: second argument (loop identifier, e.g. "daily-digest")
- **remaining args**: any additional flags

If sub-command is missing: pass empty string — orchestrator will ask.
If slug is missing: pass empty string — orchestrator will ask.

## Quick Reference

```
/cks:loop design <slug>    Design a new loop — interview + LOOP-DESIGN.md
/cks:loop run <slug>       Execute one iteration
/cks:loop health <slug>    Check run history + Sentry + LangSmith observers
/cks:loop triage <slug>    Curate findings → .triage/{slug}/{date}.md  ← PRIMARY UX
/cks:loop cost <slug>      Estimated cost (run-count × $0.01 static estimate)
/cks:loop migrate [slug]   Validate schema_version:1 compliance
/cks:loop status <slug>    Show last 5 runs (secondary — triage is primary)
```

Primary output: `.triage/{slug}/` — triage inbox, not a status console.
