# Workflow: Loop Cost Estimate — run-count × static rate, always labelled an estimate

Report the estimated cost of an agentic loop. Layer 2 telemetry (`duration_ms`,
`cost_usd`) is not shipped, so this is run-count × a static per-run rate and must say so.

## 1. Read `health.jsonl`

Read `.loops/{slug}/health.jsonl`. Missing or empty → show the banner, report
"No run history found. Cost estimate: $0.00 (0 runs)." and stop.

Count `total_runs`, `pass_runs` (`outcome: "pass"`), `fail_runs` (`outcome: "fail"`).
Skip (with a warning) entries without `schema_version: 1`.

## 2. Read the schedule

From `.loops/{slug}/LOOP-DESIGN.md` extract the schedule ("daily", "every 6 hours",
"weekly"). Unavailable → "unknown schedule".

## 3. Compute

Static rate: **$0.01 per run** (mid-tier model, ~50k tokens per iteration).

```
total_cost_estimate  = total_runs × $0.01
weekly_runs          = daily 7 · hourly 168 · every 6h 28 · weekly 1 · unknown "unknown"
weekly_cost_estimate = weekly_runs × $0.01
```

## 4. Output

The banner is mandatory, first, every time:

```
⚠ ESTIMATE, NOT MEASURED — Layer 2 telemetry (duration_ms, cost_usd) not shipped.
This is run-count × $0.01 static estimate. Actual cost may differ significantly.
```

Then:

```
Loop Cost Estimate: {slug}

Total runs: {total_runs} ({pass_runs} pass, {fail_runs} fail)
Total estimated cost: ${total_cost:.2f}
Estimated cost per week: ${weekly_cost:.2f}/week ({weekly_runs} runs × $0.01)
Schedule: {schedule}

Note: $0.01/run assumes a mid-tier model at ~50k tokens per iteration.
Heavy loops (large context, many tool calls) cost more; light loops cost less.
```

## Constraints

- Never present this as actual cost; "estimate" appears in every response.
- Never reference or compute `duration_ms` / `cost_usd` until Layer 2 ships.
- When `.finops/BUDGET.md` exists, put the weekly estimate next to the monthly ceiling so
  the finops role can judge burn — do not judge it here.
