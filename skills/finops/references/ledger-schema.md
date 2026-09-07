# Ledger Schema

Two append-only JSONL files share one line schema. Never edit or delete a line; correct
a mistake with a new line carrying a negative `amount` and a `note` that names the line it
reverses.

| File | Scope | Extra rule |
|---|---|---|
| `.finops/costs.jsonl` | one project, gitignored | `venture` is the project's tag from `.finops/BUDGET.md` |
| `$(cks_finops_dir)/ledger.jsonl` | user-global, every venture | `venture` is required and is the roll-up key |

`cks_finops_dir` is `$CKS_HQ/finops` when `CKS_HQ` points at an existing directory, else
`~/.cks/finops` (`scripts/hq-path.sh`). Only the finops role appends to either file; other
roles append burn lines to `.finops/BUDGET.md` and finops reconciles them monthly.

## Line

```json
{"ts":"2026-09-01T14:03:00Z","venture":"acme-app","project":"acme-app","period":"2026-09","category":"api","vendor":"anthropic","amount":42.17,"currency":"CAD","client":"acme","kind":"cost","source":"console.anthropic.com usage export 2026-09-01","note":"agent runs, support triage"}
```

| Field | Type | Required | Rule |
|---|---|---|---|
| `ts` | ISO 8601 UTC | yes | when the line was written, not when the spend occurred |
| `venture` | slug | yes | matches `Venture:` in the project's `BUDGET.md`; `hq` for unallocated |
| `project` | slug | yes | repo or product slug; equals `venture` for single-product ventures |
| `period` | `YYYY-MM` | yes | the month the amount belongs to |
| `category` | `api` \| `infra` \| `tools` \| `contractors` \| `revenue` | yes | the four BUDGET categories plus `revenue` for the credit side |
| `vendor` | string | yes | provider or payer, lowercase (`anthropic`, `openrouter`, `vercel`, `supabase`, `stripe`, `apollo`) |
| `amount` | number | yes | positive for cost and revenue lines; negative only for reversals |
| `currency` | ISO 4217 | yes | as billed; convert only in reports, never in the ledger |
| `client` | slug | no | who the spend serves; absent means agency overhead |
| `kind` | `cost` \| `revenue` \| `passthrough` | yes | `passthrough` marks client ad spend and other reimbursables — excluded from COGS and margin |
| `source` | string | yes | where the number came from: dashboard + date, invoice id, Stripe object id, commit |
| `note` | string | no | one line of context; never a credential, never a card number |
| `recognition` | `cash` \| `accrual` | revenue only | required on every `revenue` line |
| `invoice_id` | string | no | Stripe invoice id or local draft path |

## Derived views

Reports compute, never store:

- **burn (period)** = Σ `amount` where `kind = cost` and `period = P`, per currency
- **COGS (client, period)** = Σ `amount` where `kind = cost` and `client = C` and `period = P`
- **revenue (client, period)** = Σ `amount` where `kind = revenue` and `client = C` and `period = P`
- **margin** = (revenue − COGS) / revenue; undefined when revenue = 0 — report "no revenue" not 0%
- **cross-venture roll-up** = the same sums over `ledger.jsonl` grouped by `venture`

## Reading and validating

```bash
# lines for one period, one venture
grep '"period":"2026-09"' "$(cks_finops_dir)/ledger.jsonl" | grep '"venture":"acme-app"'

# required-field check: every line must contain all of these keys
grep -vE '"ts":.*"venture":.*"project":.*"period":.*"category":.*"vendor":.*"amount":.*"currency":.*"kind":.*"source":' .finops/costs.jsonl
```

An empty second command means every line carries the required keys in canonical order.
Write lines in that order so the check stays a one-liner.

## Month roll

On the 1st: for each `- YYYY-MM-DD | category | amount | note` burn line in
`.finops/BUDGET.md` from the closed period, append a ledger line (`source: BUDGET.md burn
line <date>`), then leave `BUDGET.md`'s `## Burn` section empty for the new period and
advance `Period:`. The four bullet lines keep their exact shape — the session banner
parses them.
