# Loop Cost Workflow

Run by `cks:watchdog` in `Mode: loop-cost` (report side). `cks:finops` receives the
report when the orchestrator asks it to book the line in the ledger. Run-count × static
estimate only — Layer 2 telemetry (`duration_ms`, `cost_usd`) has not shipped.

## Step 1: Read health.jsonl

`.loops/{slug}/health.jsonl` missing or empty → show the banner, report
"No run history found. Cost estimate: $0.00 (0 runs).", stop.

Count `total_runs`, `pass_runs`, `fail_runs`; skip (warn) entries without
`schema_version: 1`.

## Step 2: Read the schedule

From `.loops/{slug}/LOOP-DESIGN.md` (daily, every 6 hours, weekly, …). Unavailable →
"unknown schedule".

## Step 3: Compute

Static estimate: **$0.01 per run** (~50k tokens per iteration on a mid-tier model).

```
total_cost_estimate  = total_runs × $0.01
weekly_runs          = daily 7 | hourly 168 | every 6h 28 | weekly 1 | unknown
weekly_cost_estimate = weekly_runs × $0.01
```

## Step 4: Output — banner first, always

```
⚠ ESTIMATE, NOT MEASURED — Layer 2 telemetry (duration_ms, cost_usd) not shipped.
This is run-count × $0.01 static estimate. Actual cost may differ significantly.
```

```
Loop Cost Estimate: {slug}

Total runs: {total_runs} ({pass_runs} pass, {fail_runs} fail)
Total estimated cost: ${total:.2f}
Estimated cost per week: ${weekly:.2f}/week ({weekly_runs} runs × $0.01)
Schedule: {schedule}

Note: $0.01/run assumes ~50k tokens per iteration. Heavy loops cost more, light loops less.
```

## Constraints

- Never claim this is the actual cost; "estimate" appears in every response
- The banner is never omitted
- Never reference or compute Layer 2 fields (`duration_ms`, `cost_usd`) until they ship
- When `.finops/BUDGET.md` exists, put the weekly estimate next to the monthly ceiling so
  `cks:finops` can judge burn — do not judge it here
