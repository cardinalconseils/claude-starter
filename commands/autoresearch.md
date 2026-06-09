---
description: "Autonomous keep/discard optimization loop — runs overnight, ratchets a single metric"
argument-hint: "start <tag> --metric=<cmd> --target=<file> --budget=<N> [--dry-run] [--schedule=<cron>]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:autoresearch — Autonomous Keep/Discard Loop

Runs an autonomous overnight optimization loop inspired by Karpathy's autoresearch pattern.
Edits a target file, measures a metric, keeps improvements, resets failures. Repeats.

## Dispatch

```
ARGS="${ARGUMENTS:-}"

If ARGS is empty:
  AskUserQuestion:
    question: "What do you want to do?"
    header: "Action"
    options:
      - label: "Start a loop"
        description: "Launch a new run — tag, metric command, target file, budget"
      - label: "Check status"
        description: "See results.tsv for a running or completed tag"
      - label: "Stop a loop"
        description: "Write STOP signal — loop exits after current iteration"

Agent(
  subagent_type="cks:autoresearch-runner",
  prompt="$ARGS",
  isolation="worktree"
)
```

## Quick Reference

```
/cks:autoresearch start perf --metric="npm run build:size" --target=src/config.ts --budget=20
/cks:autoresearch start evals --metric="cks:evals" --target=prompts/system.md --budget=10
/cks:autoresearch start vitals --metric="lighthouse p95" --target=next.config.js --budget=50 --dry-run
/cks:autoresearch start perf --metric="npm run build:size" --target=src/config.ts --budget=20 --schedule="0 2 * * *"
/cks:autoresearch status perf
/cks:autoresearch stop perf
```

## What It Produces

`.autoresearch/<tag>/results.tsv` — iteration log:
`iteration | commit | metric_value | delta | status | description`

`status` values: `baseline` | `kept` | `reset` | `crash`
