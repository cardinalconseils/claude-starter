# Brief — finops — cost audit from a costs.jsonl fixture

Goal: Cost audit for venture `mapleboard`, period 2026-09, from `.finops/BUDGET.md`, `.finops/costs.jsonl` and `finops/ledger.jsonl`.
Constraint: Passthrough lines are never COGS. Every figure carries currency and source. Caps may be proposed, not applied (the brief did not approve caps).
Done: `.finops/reports/2026-09-cost-audit.md` written with the report shape from the workflow, and the burn line `<spend> of 500 CAD (<pct>%)` returned.
Level: 3
Mode: audit
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Runner environment
`CKS_HQ` points at project_root, so `$(cks_finops_dir)` is `finops/` here and the HQ ledger is `finops/ledger.jsonl`. No Stripe MCP, no WebFetch targets — the ledger files are the only sources.
