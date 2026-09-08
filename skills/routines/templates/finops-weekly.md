---
slug: finops-weekly
goal: "By Monday 09:00 local the founder has one brief with last week's spend per venture, margin per active client project, and burn against every BUDGET.md ceiling — with a push only when any ceiling is past 50%."
north_star_goal: "<slot: the NORTH-STAR.md goal about runway or margin — e.g. G3 'gross margin above 60% on every engagement'>"
owner_role: finops
sources:
  - "HQ: .finops/BUDGET.md (ceiling, venture tag hq), finops/ledger.jsonl (one line per spend across ventures)"
  - "Each active project repo's .finops/BUDGET.md and .finops/costs.jsonl — list from NORTH-STAR.md active ventures"
  - "Stripe: payouts and invoices settled in the last 7 days (revenue side of margin)"
  - "GitHub: commit counts per repo for the week (effort proxy when no time log exists)"
connectors: [Stripe, github]
cadence: "0 12 * * 1"
environment: inherit
repo: HQ
autonomy_level: 1
stop_condition: "NORTH-STAR.md lists no active venture with a BUDGET.md (nothing to audit); or 52 runs since created, whichever first — then re-interview."
report_to: [push, email]
budget_per_run: 2.00
quiet_hours: none
created: "<slot: ISO date the founder accepted this profile>"
trigger_id: ""
---

# finops-weekly

Cost audit, margin, burn. Reads only; the finops role appends to the ledger only when it
finds a spend that is in a project's `costs.jsonl` but missing from HQ's ledger (its write
scope), and says so.

## What one run produces

Three tables, in this order:

1. **Spend per venture, last 7 days vs the 7 before** — from `ledger.jsonl`; a venture
   absent from the ledger but present in NORTH-STAR is a finding (`medium`: untracked spend).
2. **Margin per active client project** — Stripe revenue settled in the window against
   the project's `costs.jsonl` plus the venture's share of HQ spend. A project below the
   North Star margin floor is `high`.
3. **Burn per BUDGET.md** — spent-to-date over ceiling, with the date the ceiling is hit at
   the current rate. Past 50% is `medium`; past 80% is `high`; past 100% is `high` with a
   `GATED:` line (raising a ceiling is a founder decision).

## Push rule

Push only when table 3 has a row past 50% or table 2 has a `high`. Otherwise the brief
goes by email only and the push stays silent — a weekly "all fine" on the phone trains the
founder to ignore the real one.

## What noise is

Spend under $1 per line; test-mode Stripe objects; the plugin's own `costs.jsonl` when the
run is on HQ. Figures the role cannot read (no Stripe connector, a private repo it cannot
reach) are `NOT READ`, never estimated.

## Level

Permanently 1: this routine never moves money, never sends an invoice, never edits a
`BUDGET.md`. Each of those is gated and appears as a recommendation under `NEEDS YOU`.
