# Brief — finops — budget burn above 50% early in the month

Goal: Burn check for `mapleboard`, period 2026-09, as of 2026-09-07.
Constraint: Read `.finops/BUDGET.md` burn lines and `.finops/costs.jsonl`, dedup lines present in both. Never soften a flag with an estimate.
Done: The one-line `<spend> of <ceiling> <currency> (<pct>%) — <status> — pace …` plus the category driving it and one lever, and the four bullet lines of BUDGET.md untouched.
Level: 3
Mode: burn
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Runner environment
`CKS_HQ` points at project_root, so `$(cks_finops_dir)` is `finops/` here and the HQ ledger is `finops/ledger.jsonl`. No Stripe MCP, no WebFetch targets — the ledger files are the only sources.
