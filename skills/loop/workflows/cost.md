# Loop Cost Workflow

Run by `cks:watchdog` in `Mode: loop-cost` (report side). `cks:finops` receives the
report when the orchestrator asks it to book the line in the ledger. Prefer the measured
sum of `cost_usd` from dispatch traces (telemetry Layer 2, `.prd/logs/agents/*.jsonl`);
fall back to run-count × static estimate, with the banner, when no trace lines exist.

## Step 1: Read health.jsonl

`.loops/{slug}/health.jsonl` missing or empty → show the banner, report
"No run history found. Cost estimate: $0.00 (0 runs).", stop.

Count `total_runs`, `pass_runs`, `fail_runs`; skip (warn) entries without
`schema_version: 1`.

## Step 2: Read the schedule

From `.loops/{slug}/LOOP-DESIGN.md` (daily, every 6 hours, weekly, …). Unavailable →
"unknown schedule".

## Step 3: Compute

**Measured path (preferred).** `bash scripts/cost-report.sh --by session --json` for each
period the loop ran; sum `cost_usd` over the rows whose session ids appear in the loop's
`health.jsonl` entries. When at least one trace line matches, report that sum as
`total_cost_measured` and derive `cost_per_run = total_cost_measured / matched_runs` for the
weekly projection. The banner then reads "list-price estimate from measured tokens, not a
bill" — `cost_usd` is computed from `skills/finops/references/model-prices.json`.

**Static fallback.** No matching trace lines → **$0.01 per run** (~50k tokens per iteration
on a mid-tier model), with the estimate banner below.

```
total_cost_estimate  = total_runs × $0.01
weekly_runs          = daily 7 | hourly 168 | every 6h 28 | weekly 1 | unknown
weekly_cost_estimate = weekly_runs × $0.01
```

## Step 4: Output — banner first, always

```
⚠ ESTIMATE, NOT MEASURED — no dispatch trace lines matched this loop's runs.
This is run-count × $0.01 static estimate. Actual cost may differ significantly.
```

Measured path banner instead:

```
ℹ LIST-PRICE ESTIMATE FROM MEASURED TOKENS — Σ cost_usd of {matched_runs} trace lines
(telemetry Layer 2). Not a bill: the console export in the ledger is the billed figure.
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
- Layer 2 fields (`duration_ms`, `cost_usd`) are read from trace lines via `scripts/cost-report.sh`, never recomputed here; when no line matches, use the static fallback and say so
- When `.finops/BUDGET.md` exists, put the weekly estimate next to the monthly ceiling so
  `cks:finops` can judge burn — do not judge it here
