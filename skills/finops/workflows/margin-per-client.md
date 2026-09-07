# Margin per Client and per Venture

Is each client, and each venture, worth its cost to serve? Output:
`.finops/reports/YYYY-MM-margin.md`.

## 1. Gather

- Revenue lines (`kind: revenue`) per client for the period, with `recognition`
- Cost lines (`kind: cost`) per client for the period, all four categories
- Pass-through lines (`kind: passthrough`) — listed for completeness, excluded from margin
- Owner hours per client when available: session durations from
  `.cks/control-plane/observability/` and dispatch counts from `.prd/logs/agents/*.jsonl`,
  mapped to the client by repo or by the mandate name; internal hourly rate from
  `NORTH-STAR.md` constraints or the owner (ask once, store in `BUDGET.md` under `## Caps`
  as `- internal_rate: <amount>`)
- Cross-venture: the same sums grouped by `venture` from the HQ ledger

## 2. Compute

Per client and per venture, per currency:

```
COGS          = api + infra + tools + contractors
Cost to serve = COGS + hours × internal_rate
Gross margin  = (revenue − COGS) / revenue
Net margin    = (revenue − cost to serve) / revenue
Efficiency    = (api + infra) / revenue
```

Revenue of zero → "no revenue this period", never a percentage. Mixed currencies → report
each, convert only in a clearly labelled summary line with the rate and its date.

## 3. Classify

| Band | Gross margin | Action |
|---|---|---|
| healthy | ≥ 40% | keep; note what makes it cheap to serve |
| watch | 25–40% | list the top cost driver and one lever |
| at risk | < 25% | pricing floor recalculation (`SKILL.md`, Pricing floor); propose re-price, re-scope, or exit |
| no revenue | — | is this a pipeline investment with a date, or drift? |

Two consecutive periods "at risk" is an alert (`SKILL.md`, Alert thresholds).

## 4. Report

```
# Margin — <YYYY-MM>

| Client | Revenue | COGS | Gross | Hours | Cost to serve | Net | Band | Top driver |
|---|---|---|---|---|---|---|---|---|

| Venture | Revenue | COGS | Gross | Net | Trend (3 mo) |
|---|---|---|---|---|---|

Pass-through (excluded): <client> ad spend <n>

## Findings
- <client>: <band> — <driver> — <lever with estimated effect>

## Pricing floors
<client or tier>: cost to serve <n> → floor at 40% margin <n> → current price <n> → <above/below>
```

Every cell traces to ledger lines or a named log; estimated hours say "estimate". Hand the
findings to the chief of staff; re-pricing a client is a decision, not a finops action.
