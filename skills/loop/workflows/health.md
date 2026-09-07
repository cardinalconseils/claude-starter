# Loop Health Workflow

Run by `cks:watchdog` in `Mode: loop-health` (steps 1–3 and 5). The orchestrator
(`SKILL-ORCHESTRATOR.md` §3) dispatches `cks:observer` for step 4 in the same message and
fills the observer sections of the report afterwards — a role cannot dispatch, so never
try to reach Sentry or LangSmith from here. When dispatched outside the orchestrator (by
the chief of staff), end the report with the observer dispatch it still needs.

## Step 1: Read health.jsonl

`.loops/{slug}/health.jsonl` missing or empty → write `health-report.md` with
"No run history found. Loop has not executed yet." and stop.

Parse each line as JSON. Entries without `schema_version: 1` are logged as warnings and
skipped — never counted as failures.

## Step 2: Read state.json

Note `sentry_dsn` and `langsmith_project` (empty string = explicit opt-out; absent field =
scaffolding incomplete — say so in the report).

## Step 3: Anomaly checks

- **Consecutive failures** — flag ≥ 3 consecutive `outcome: "fail"` at the end of the log
- **Error rate spike** — last 10 runs; flag when fails > 2 (> 20%)
- **Missing entries** — timestamp gaps > 2× the expected interval from the LOOP-DESIGN.md schedule
- **Last outcome** — most recent entry's outcome and summary

## Step 4: Observers (orchestrator-owned)

Mandatory whenever configured, even when every entry passed: `cks:observer` checks Sentry
(error count, latest issues, unresolved in 24h) and LangSmith (run count, error rate, avg
token usage, anomalous traces in 24h). `health.jsonl` alone is never sufficient.

## Step 5: Write `.loops/{slug}/health-report.md`

```markdown
# Health Report: {slug}

**Generated:** {ISO8601 UTC}
**Runs analyzed:** {n}

## Summary
| Metric | Value |
|---|---|
| Total runs | {n} |
| Pass rate | {pct}% ({pass}/{total}) |
| Last outcome | {pass/fail} |
| Last run | {ts} |
| Last summary | {summary} |

## Anomalies
{"No anomalies detected." or one bullet per flag:
- **[consecutive_failures]** {n} consecutive failures ending at iteration {n}
- **[error_rate]** {fail}/10 failures in last 10 runs ({pct}% — threshold 20%)
- **[missing_entries]** Gap of {duration} between iterations {a} and {b} (expected {expected})}

## Sentry Observer
{pending} — or "Not configured (sentry_dsn empty)"

## LangSmith Observer
{pending} — or "Not configured (langsmith_project empty)"

## Observer dispatch needed
{only when run outside the orchestrator: the cks:observer brief — slug, DSN/project name, 24h window}

## Recommended Action
{one clear action, or "No action required."}
```

Always write the report, even with no anomalies — silence must be a result.
