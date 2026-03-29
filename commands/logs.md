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

If `.prd/logs/lifecycle.jsonl` does not exist, display:
```
No logs found. Logs are created automatically as you use CKS lifecycle commands.
```
And stop.

## Argument Handling

Parse `$ARGUMENTS` for flags:

| Flag | Filter | Example |
|------|--------|---------|
| (none) | Show last 20 events | `/cks:logs` |
| `--feature ID` | Filter by feature_id prefix | `/cks:logs --feature 01` |
| `--phase NAME` | Filter events containing phase name | `/cks:logs --phase discover` |
| `--severity LEVEL` | Filter by severity (INFO, WARN, ERROR) | `/cks:logs --severity ERROR` |
| `--since DATE` | Filter events after date | `/cks:logs --since 2026-03-27` |
| `--metrics` | Show velocity metrics dashboard | `/cks:logs --metrics` |
| `--summary` | Human-readable activity summary | `/cks:logs --summary` |
| `--extract ID` | Extract per-feature log file | `/cks:logs --extract 01-backend` |

Multiple filters can be combined (e.g., `--feature 01 --severity ERROR`).

## Default View (no flags or just filters)

Read `.prd/logs/lifecycle.jsonl` and apply any filters.

**Filtering commands (combine with `and` when multiple flags):**
```bash
# --feature: filter by feature_id prefix
jq -r 'select(.feature_id | startswith("FEATURE_PREFIX"))' .prd/logs/lifecycle.jsonl

# --phase: filter events containing the phase name in the event field
jq -r 'select(.event | test("PHASE_NAME"))' .prd/logs/lifecycle.jsonl

# --severity: exact match on severity
jq -r 'select(.severity == "LEVEL")' .prd/logs/lifecycle.jsonl

# --since: timestamp comparison
jq -r 'select(.timestamp >= "DATE")' .prd/logs/lifecycle.jsonl
```

If no flags, show the last 20 events:
```bash
tail -20 .prd/logs/lifecycle.jsonl
```

**Display as a formatted table:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CKS LOGS {filter description if any}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Time     | Sev   | Event                        | Message
 ─────────┼───────┼──────────────────────────────┼────────────────────────
 22:15:00 | INFO  | phase.discover.started       | Discovery started for 01-backend
 22:15:05 | INFO  | step.0.started               | Progress banner displayed
 22:16:30 | INFO  | agent.dispatched             | prd-discoverer agent launched
 22:20:00 | INFO  | user.decision                | Problem: SaaS billing gaps
 22:25:00 | INFO  | step.4.completed             | 11 elements gathered
 22:25:30 | INFO  | phase.discover.completed     | Discovery complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Showing {N} events {filter description}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Parse the event fields for display:
- Time: extract `HH:MM:SS` from timestamp
- Sev: severity field
- Event: event field
- Message: message field (truncate to ~50 chars if needed)

## Metrics Dashboard (--metrics)

Scan `lifecycle.jsonl` and compute:

1. **Feature counts:** Count distinct `feature_id` values. Features with a `phase.*.completed` event for release = completed; others = in progress.
2. **Phase durations:** For each feature, find paired `phase.{name}.started` / `phase.{name}.completed` events, compute time difference.
3. **Iteration count:** Count `state.iteration` events per feature.
4. **Agent dispatches:** Count `agent.dispatched` events per feature.
5. **User decisions:** Count `user.decision` events per feature.

Cache result to `.prd/logs/metrics.json`. Re-compute only if `lifecycle.jsonl` is newer than `metrics.json`.

**Display:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CKS METRICS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Features: {N} completed | {N} in progress

 Phase Averages:
   Discover:  {N}h
   Design:    {N}h
   Sprint:    {N}h
   Review:    {N}h
   Release:   {N}h

 Iterations: {N} avg per feature
 Decisions:  {N} avg user decisions per feature
 Agents:     {N} avg dispatches per feature

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Summary View (--summary)

Group events by feature_id, then by phase (derived from event field). Show a human-readable timeline:

```
Feature {feature_id}:
  [discover] ✅ {start_date} → {end_date} ({duration}) — {summary from metadata}
  [design]   ✅ {start_date} → {end_date} ({duration})
  [sprint]   ▶  {start_date} → in progress
  [review]   ○  pending
  [release]  ○  pending

Feature {feature_id}:
  ...
```

Use ✅ for completed phases, ▶ for in-progress (has started but no completed), ○ for pending (no started event).

## Extract (--extract ID)

```bash
mkdir -p .prd/logs/features
jq "select(.feature_id | startswith(\"FEATURE_ID\"))" .prd/logs/lifecycle.jsonl \
  > ".prd/logs/features/FEATURE_ID.jsonl"
```

Report: `Extracted {N} events to .prd/logs/features/{ID}.jsonl`
