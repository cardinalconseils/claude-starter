# Model Prices

`model-prices.json` is the one machine-readable price table in CKS. `scripts/agent-trace.sh`
reads it to stamp `cost_usd` on every dispatch trace, `/cks:model` reads it to show what each
tier costs, and `scripts/cost-report.sh` sums what the traces already carry. Every figure is a
**list price in USD per million tokens** — an estimate of what the API would bill at list, never
the invoice. Volume discounts, credits, and batch pricing are not modelled.

## Columns

| Key | Meaning |
|---|---|
| `updated` | Date the table was last checked against `source` |
| `source` | The pricing page the numbers come from |
| `tiers.<tier>.model` | The model id `/cks:model` currently maps that tier (`opus` / `sonnet` / `haiku`) to |
| `tiers.<tier>.input`, `.output` | List price of that tier's model — the figure `/cks:model` shows next to each tier |
| `cache_write_multiplier` | Cache-creation input tokens cost `input × 1.25` |
| `cache_read_multiplier` | Cache-read input tokens cost `input × 0.1` |
| `models.<id>.input`, `.output` | Per-model list price, keyed by the exact `message.model` id seen in transcripts |

Cost of one dispatch, all counts divided by 1e6:

```
cost_usd = tokens_in × input
         + tokens_out × output
         + tokens_cache_write × input × cache_write_multiplier
         + tokens_cache_read  × input × cache_read_multiplier
```

## Tier → model map

| Tier | Model | Used for |
|---|---|---|
| `opus` | `claude-opus-5` | reason: decisions, design, review |
| `sonnet` | `claude-sonnet-5` | execute: implementation, testing, deploy |
| `haiku` | `claude-haiku-4-5` | bulk: docs, scanning, reports |

The tier map follows `skills/prd/references/model-strategy.md`; when a tier moves to a new
model, change `tiers.<tier>.model` here in the same PR.

## How an unknown model id resolves

`agent-trace.sh` looks the transcript's `message.model` up in this order and records which
step matched as `price_source`:

1. Exact key in `models` → `price_source: "model"`.
2. Otherwise the family segment of the id (`claude-<family>-…` → `opus`, `sonnet`, `haiku`)
   names a tier → that tier's price, `price_source: "tier-fallback"`. A new `claude-opus-6`
   is therefore priced as opus until the table catches up.
3. Otherwise `price_source: "unknown"`, `cost_usd: 0`, and the id is kept verbatim in
   `model` so the gap is visible in `scripts/cost-report.sh --by model`.

A `0` cost with `price_source: "unknown"` is a prompt to update the table, not a free run.

## Update procedure

Open `source`, edit the changed numbers in `model-prices.json`, set `updated` to today, and run
`python3 -c "import json;json.load(open('skills/finops/references/model-prices.json'))"` — one
commit, no other file changes needed.
