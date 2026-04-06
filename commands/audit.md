---
description: "4Ds quality audit — score features on Delegation, Description, Discernment, Diligence"
argument-hint: "[--diligence] or no arg for full audit"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:audit — 4Ds Quality Audit

Parse the argument and dispatch the appropriate agent.

## Routing

| Invocation | Action |
|------------|--------|
| `/cks:audit` | Full 4Ds audit — score all features |
| `/cks:audit --diligence` | Diligence-only scan of recent changes |

## Dispatch

If `--diligence` flag:
```
Agent(subagent_type="diligence-agent", prompt="
  Run a diligence review on recent code changes.
  Scan changed files, check for quality issues, cross-reference acceptance criteria.
  Write report to .prd/phases/{active-feature}/
")
```

Otherwise (full audit):
```
Agent(subagent_type="audit-agent", prompt="
  Run the full 4Ds audit.
  Score every feature on Delegation, Description, Discernment, Diligence.
  Log results to .prd/logs/audit.jsonl.
  Display the scored report with top 3 actionable gaps.
")
```

## Quick Reference

```
/cks:audit              → Full 4Ds quality score for all features
/cks:audit --diligence  → Quick scan of recent code for quality issues
```
