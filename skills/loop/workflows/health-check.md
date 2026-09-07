# Workflow: Loop Health Check — anomalies from `health.jsonl`, report side

Read a loop's run history and flag anomalies. Report only: the runner writes
`health-report.md`; the role running this returns the report text and names any observer
dispatch the chief of staff should make.

## 1. Read `health.jsonl`

Read every line of `.loops/{slug}/health.jsonl`.

Missing or empty → report "No run history found. Loop has not executed yet." and stop.

Parse each line as JSON. Skip (with a warning) any entry whose `schema_version` is absent
or not `1` — never count it as a failure.

## 2. Read `state.json`

From `.loops/{slug}/state.json` extract `sentry_dsn` and `langsmith_project`
(empty string = explicit opt-out; absent field = scaffolding incomplete — say so).

## 3. Anomaly checks

- **Consecutive failures** — count `outcome: "fail"` from the end; flag at ≥ 3.
- **Error rate spike** — last 10 runs; flag if fail count > 2 (> 20%).
- **Missing entries** — timestamp gaps > 2× the expected interval from `LOOP-DESIGN.md`.
- **Last outcome** — most recent entry's outcome and summary.

## 4. External observers

`health.jsonl` alone is insufficient. When `sentry_dsn` is non-empty, the observer role must
check Sentry for errors from this loop in the last 24h; when `langsmith_project` is
non-empty, it must check trace count, error rate, token usage and anomalous traces. A
sub-agent cannot dispatch a sub-agent: end the report with the dispatch the chief of staff
needs (`cks:observer`, slug, DSN/project name, window), even when every run passed.

## 5. Report

```markdown
# Health Report: {slug}

**Generated:** {ISO8601 UTC}
**Runs analyzed:** {total}

| Metric | Value |
|---|---|
| Total runs | {n} |
| Pass rate | {pct}% ({pass}/{total}) |
| Last outcome | {pass/fail} |
| Last run | {ts} |
| Last summary | {summary} |

## Anomalies
{"No anomalies detected." or one line per anomaly:}
- **[consecutive_failures]** {n} consecutive failures ending at iteration {n}
- **[error_rate]** {fail}/10 failures in last 10 runs ({pct}% — threshold 20%)
- **[missing_entries]** Gap of {duration} between iterations {a} and {b} (expected {expected})

## Observer dispatch needed
{cks:observer brief, or "Not configured (sentry_dsn / langsmith_project empty)"}

## Recommended action
{one clear action, or "No action required."}
```

The report is always produced, even with no anomalies — silence must be a result.
