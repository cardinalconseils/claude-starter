---
description: "Autonomous keep/discard optimization loop — runs overnight, ratchets a single metric"
argument-hint: "start <tag> --metric=<cmd> --target=<file> --budget=<N> [--dry-run] [--schedule=<cron>]"
allowed-tools:
  - Read
  - Skill
  - AskUserQuestion
---

# /cks:autoresearch — Autonomous Keep/Discard Loop

Runs an autonomous overnight optimization loop inspired by Karpathy's autoresearch pattern.
Mutates a target file, measures a metric, keeps improvements, resets failures. Repeats.

## Dispatch

```
ARGS="${ARGUMENTS:-}"

If ARGS is empty:
  AskUserQuestion:
    question: "What do you want to do?"
    header: "Action"
    options:
      - "Start a loop" — tag, metric command, target file, budget
      - "Check status" — results.tsv for a running or completed tag
      - "Stop a loop" — write STOP; loop exits after the current iteration

Skill(skill="cks:autoresearch")
```

Arguments: `$ARGS`. This is an Orchestrator Exception command (`.claude/rules/commands.md`):
every iteration dispatches `cks:builder` for the mutation (and `cks:tester` for eval
metrics), so the loop runs as a top-level skill. Its `SKILL-ORCHESTRATOR.md` owns the
consent block, the keep/discard shell, and the schedule registration.

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
