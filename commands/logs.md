---
description: "View and query CKS lifecycle logs — filter by feature, phase, severity, date"
argument-hint: "[--feature ID] [--phase NAME] [--severity LEVEL] [--since DATE] [--metrics] [--summary] [--extract ID]"
allowed-tools:
  - Read
  - Bash
  - Glob
---

# /cks:logs — Lifecycle Log Viewer

Read and filter structured events from `.prd/logs/lifecycle.jsonl`.

## Pre-Check

If `.prd/logs/lifecycle.jsonl` does not exist:
```
No logs found. Logs are created automatically as you use CKS lifecycle commands.
```

## Argument Handling

| Flag | Filter | Example |
|------|--------|---------|
| (none) | Last 20 events | `/cks:logs` |
| `--feature ID` | By feature_id prefix | `/cks:logs --feature 01` |
| `--phase NAME` | Events containing phase name | `/cks:logs --phase discover` |
| `--severity LEVEL` | By severity (INFO/WARN/ERROR) | `/cks:logs --severity ERROR` |
| `--since DATE` | Events after date | `/cks:logs --since 2026-03-27` |
| `--metrics` | Velocity metrics dashboard | `/cks:logs --metrics` |
| `--summary` | Human-readable activity timeline | `/cks:logs --summary` |
| `--extract ID` | Extract per-feature log file | `/cks:logs --extract 01-backend` |

Multiple filters combine with AND logic.

## Default View

Use `jq` to filter `.prd/logs/lifecycle.jsonl` by flags, or `tail -20` for no flags. Display as formatted table: Time | Severity | Event | Message.

## Metrics Dashboard (`--metrics`)

Compute from lifecycle.jsonl:
- Feature counts (completed vs in-progress)
- Phase durations (paired started/completed events)
- Iteration counts, agent dispatches, user decisions per feature

Cache to `.prd/logs/metrics.json` (recompute if log is newer).

## Summary View (`--summary`)

Group events by feature_id, then by phase. Show timeline with status indicators: completed, in-progress, pending.

## Extract (`--extract ID`)

Write filtered events to `.prd/logs/features/{ID}.jsonl`.
