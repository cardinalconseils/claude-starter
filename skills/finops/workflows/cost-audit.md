# Cost Audit

Token, API, and infra spend for one period — where it went, what it should be capped at,
what to cut. Absorbs the token-optimizer's context-budget analysis and the cost-analyzer's
unit-economics stack. Output: `.finops/reports/YYYY-MM-cost-audit.md`, new ledger lines,
hard caps in `.finops/BUDGET.md`.

## 1. Sources, in order

Read what exists; never guess a number that a source could give.

| Source | How | Gives |
|---|---|---|
| `.finops/costs.jsonl`, `$(cks_finops_dir)/ledger.jsonl` | grep by `period` | what is already booked |
| `.finops/BUDGET.md` | read the four bullet lines + `## Burn` | ceiling, category lines not yet in the ledger |
| Anthropic usage | owner exports from the console; or `WebFetch` a usage URL the owner provides | model API spend by day and by key |
| OpenRouter | `WebFetch` the activity/usage page the owner provides; credits per model | routed generation spend (marketing batch runs) |
| Vercel | `WebFetch` the team usage page the owner provides | bandwidth, function invocations, plan tier |
| Supabase | `WebFetch` the project usage page the owner provides | database size, egress, compute add-ons |
| `.cks/control-plane/observability/` | read session metrics files (`/cks:cost` summary, sessions, trends, single session) | dev-time and tool-call counts per session — the labour side of cost to serve |
| `.prd/logs/agents/*.jsonl` | count dispatches per role | which roles burn the most runs |
| `~/.claude/settings.json`, `.claude/settings.json` | read `enabledPlugins`, `env` | context-budget drivers (below) |

Provider pages need the owner logged in: when a fetch fails, surface `▶ ACTION REQUIRED`
asking for the export or the figure, and mark the category "unconfirmed" in the report.
Never ask for, echo, or store an API key.

## 2. Book what is missing

For every provider figure not yet in the ledger, append one line per vendor per period
to `.finops/costs.jsonl` and to the HQ ledger (`references/ledger-schema.md`), `source`
naming the page or export and its date. Allocate to `client` where the spend is
attributable (a client's agent key, a client's Supabase project); the rest is `venture: hq`.

## 3. Unit economics (from the cost-analyzer)

Identify the unit of value the venture sells — per conversation minute, per message, per
document, per API call, per active user per month, per generated asset. Build the stack:

| Component | Provider | Cost per unit | Notes |
|---|---|---|---|
| model inference | … | … | tokens per unit × price |
| retrieval / embeddings | … | … | |
| telephony / delivery | … | … | |
| platform fee | … | … | |
| **Total** | | **…** | |

Show budget / mid / premium stacks, gross margin at the current price, break-even volume,
and the scaling curve at 1K / 10K / 100K units with volume discounts the providers publish.
Split fixed (hosting floor, auth, monitoring) from variable (inference, storage, bandwidth).
Sensitivity: top 3 drivers at ±50%. Every price traces to a published page or an invoice;
an interpolated price says so.

## 4. Context-budget audit (from the token-optimizer)

Context is the largest hidden API cost in an agentic workflow. Report:

```
Context Budget (estimated)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Output-style plugins:  <list or none>   ← injected every session, highest cost per token
Project-specific plugins enabled globally: <count>  ← tool schemas loaded in every repo
CLAUDE.md + rules:     ~<n>K tokens
Memory files:          ~<n>K tokens
Estimated startup cost: ~<n>% of the context window
```

Rules of thumb: each output-style plugin ~2–5K tokens per session; each project-specific
plugin ~1–3K tokens of schemas; keep globally enabled plugins under 15. Settings that cap
waste: a thinking-token ceiling and an auto-compact threshold matching the plugin's
context guard. Compaction timing: between lifecycle phases, never mid-implementation, mid
review, or mid debug. Check for the RTK output proxy (`command -v rtk`); absent → suggest
it (60–90% reduction in Bash output tokens). Finops has no `Edit` and does not change
settings — every change is a recommendation for the operator role to apply after the owner
agrees.

## 5. Hard caps

Propose one cap per category as a share of the ceiling (default `api` 50%, `infra` 25%,
`tools` 20%, `contractors` 5%; adjust to the venture). Write them under a `## Caps` heading
in `.finops/BUDGET.md` **after** the four bullet lines and the `## Burn` section, as
`- <category>: <amount>` lines. Never alter the four bullet lines' shape.

## 6. Report

`.finops/reports/YYYY-MM-cost-audit.md`:

```
# Cost Audit — <venture> — <YYYY-MM>

Spend:     <total> <currency> of <ceiling> (<pct>%)   [confirmed: api, infra] [unconfirmed: tools]
By category:  api <n> · infra <n> · tools <n> · contractors <n>
By client:    <client> <n> (<pct>%) · hq <n>
Top vendors:  <vendor> <n> · <vendor> <n> · <vendor> <n>
Spikes:       <vendor> +<pct>% vs last period — <cause or "unexplained">

## Unit economics
<stack, margin, break-even, scaling, sensitivity>

## Context budget
<block from step 4>

## Recommendations (ranked by saving)
1. <action> — saves ~<n> <currency>/month — owner: <role>
2. …

## Caps written to .finops/BUDGET.md
<list>
```

Close with the burn line the chief of staff needs: `<spend> of <ceiling> <currency> (<pct>%)`.
