---
description: "Run the CKS sprint lifecycle via the Attractor pipeline engine"
allowed-tools:
  - Agent
  - Read
---

# /cks:sprint-run

## What It Does
Executes the full CKS sprint lifecycle defined in `pipelines/sprint.dot` using the
Attractor pipeline engine. Phases run in order: Discover → Plan → Implement → Verify →
Sprint Review → Release. Goal gates on Plan, Implement, and Verify ensure the pipeline
cannot exit successfully unless all three phases produced a SUCCESS outcome.

Supports resuming interrupted runs via Attractor checkpoints.

## Usage
```
/cks:sprint-run [--resume] [--start-at <node>] [--dry-run]
```

## Arguments
| Argument | Required | Description |
|----------|----------|-------------|
| `--resume` | No | Resume from last saved checkpoint |
| `--start-at <node>` | No | Skip ahead to a specific node (e.g. `Implement`) |
| `--dry-run` | No | Parse and validate pipeline, print execution plan, do not run |

## Dispatch

```
Agent(subagent_type="cks:sprint-runner", prompt="Run the CKS sprint pipeline at pipelines/sprint.dot. Args: $ARGUMENTS")
```

## Quick Reference
```
/cks:sprint-run                       # Full run from start
/cks:sprint-run --resume              # Resume interrupted run
/cks:sprint-run --start-at Implement  # Skip to implementation phase
/cks:sprint-run --dry-run             # Validate + print execution plan only
```

## Checkpoints
State is saved to `.attractor/runs/<run_id>/checkpoint.json` after each node completes.
Pass `--resume` to continue from the last checkpoint, or `--start-at <node>` to jump
to a specific node.

## Constraints
- Never skip goal gates — Plan, Implement, and Verify must all produce SUCCESS
- Never proceed to Release without a passing Sprint Review approval
- If Verify fails twice, stop and report — do not loop forever
- Respect `max_retries` declared on each node in sprint.dot
