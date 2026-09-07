---
name: finops
description: "Money model for a solopreneur AI agency — revenue, COGS including API and token spend, margin per client and per venture, budget burn against the ceiling, runway, Stripe invoicing (gated), SR&ED evidence from git history. Ledger schema and the five finops workflows. Load for any cost, margin, burn, budget, invoice, pricing-floor, or R&D-credit question."
allowed-tools: Read, Grep, Glob, Bash, Write, WebFetch, AskUserQuestion
---

# FinOps — Money on Track

The agency sells built AI agents and the hours around them. It spends on models, infra,
tools, and occasionally contractors. Finops keeps four numbers honest at all times:
**revenue**, **cost to serve**, **margin**, and **burn against ceiling**. Everything else
(runway, pricing floors, SR&ED) derives from those four.

## Money model

```
Revenue        = retainers + project milestones + performance bonuses + product revenue
COGS           = api + infra + tools + contractors   (per client, per venture, per period)
Gross margin   = (Revenue − COGS) / Revenue          target ≥ 40% per client; flag < 25%
Burn           = Σ costs.jsonl amounts this period   reported as <spend> of <ceiling>
Runway (months)= cash on hand / trailing-3-month net burn
Cost to serve  = COGS + owner hours × internal rate  (hours from .prd/logs when present)
```

Rules the model never bends:

- **Ad spend is client pass-through, not agency cost.** It never enters COGS or margin.
- **Revenue states its recognition period** — cash or accrual, monthly retainer or milestone.
- **API and token spend is COGS**, allocated to the client or venture that consumed it.
  Unallocated spend goes to `venture: hq` and is surfaced as a finding, not hidden.
- **Numbers trace to a source** — a ledger line, a provider dashboard, an invoice, a commit.
  An estimate says "estimate" and names what it was derived from.
- **Every figure carries currency and period.** No bare numbers.

## Categories

Same four as `.finops/BUDGET.md`; nothing else exists until it is added there.

| Category | Includes |
|---|---|
| `api` | model API calls and token usage, image/video generation, embeddings, enrichment credits |
| `infra` | hosting, databases, storage, bandwidth, domains |
| `tools` | SaaS subscriptions used by the venture (analytics, monitoring, design, prospecting) |
| `contractors` | human work paid per hour or per deliverable |

## State

| File | Scope | Who writes |
|---|---|---|
| `.finops/BUDGET.md` | per project — venture tag, monthly ceiling, currency, period, burn lines | bootstrap creates; finops rolls the period and appends burn |
| `.finops/costs.jsonl` | per project — one line per spend (gitignored) | finops appends, never edits |
| `$(cks_finops_dir)/ledger.jsonl` | user-global, cross-venture roll-up with a `venture` field | finops appends, never edits |
| `.finops/reports/YYYY-MM-*.md` | audits, margin reports, burn briefs, SR&ED skeletons | finops |
| `.finops/invoices/<client>-YYYY-MM.md` | invoice drafts awaiting approval | finops |

Schema for both JSONL files: `references/ledger-schema.md`. `cks_finops_dir` resolves to
`$CKS_HQ/finops` when HQ is set, else `~/.cks/finops` (`scripts/hq-path.sh`).

## Workflows

| Workflow | Produces | Read when |
|---|---|---|
| `workflows/cost-audit.md` | `.finops/reports/YYYY-MM-cost-audit.md`, ledger lines, hard caps in `BUDGET.md` | "what are we spending", token/API/infra review, `/cks:finops audit`, `/cks:cost` |
| `workflows/margin-per-client.md` | `.finops/reports/YYYY-MM-margin.md` | pricing review, "is this client profitable", `/cks:finops margin` |
| `workflows/invoice.md` | `.finops/invoices/<client>-YYYY-MM.md` + `GATED:` send | billing date, milestone reached, `/cks:finops invoice` |
| `workflows/budget-burn.md` | one-line burn brief + `.finops/BUDGET.md` burn lines | every chief-of-staff mandate brief, `/cks:finops burn`, session banner |
| `workflows/sred-evidence.md` | `.finops/sred/<fiscal-year>/<project>.md` | fiscal year end, "SR&ED", R&D tax credit prep, `/cks:finops sred` |
| `workflows/payment-advice.md` | findings + code samples, no files unless asked | Stripe integration design or review, `/cks:payments` |

## Cadence

| When | What |
|---|---|
| Every mandate brief | burn line: `<spend> of <ceiling> <currency> (<pct>%)`, flag ≥ 80% |
| Weekly | spend vs ceiling by category (green / amber / red), spikes > 15% week-over-week, invoice status |
| Monthly, on the 1st | roll `BUDGET.md` period forward; move old burn lines to the HQ ledger; margin per client; efficiency ratio (API + infra per revenue dollar); top 3 savings |
| Quarterly | tools audit (unused subscriptions); pricing floor check against actual cost to serve; renewals due in 30/60/90 days |
| Fiscal year end | SR&ED skeleton per project with experimental work |

## Alert thresholds

Surface immediately, in full prose (auto-clarity applies to money):

- any single vendor bill up > 25% month-over-month without a known cause
- API spend > 110% of the `api` share of the ceiling
- burn ≥ 80% of ceiling before the 20th of the month
- a client invoice unpaid at 30 days (flag) and 45 days (escalate)
- a new tool > $500/month proposed
- gross margin on any client < 25% two months running

## Pricing floor

When asked what a retainer or project must cost: cost to serve per tier × (1 / (1 − target
margin)). Show the math, name every input, mark estimates. Anything priced below cost to
serve is a finding, not a recommendation.

## Gated actions

Sending an invoice, issuing a refund or credit note, changing a subscription, moving money,
and creating a Stripe customer or product are gated. Draft the exact call and its inputs,
write the artifact, return a `GATED:` line, stop.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Token spend is too small to allocate per client" | Small until the one client that runs an agent 24/7. Allocate from day one; `venture: hq` is the catch-all, not the default. |
| "Ad spend went through our card, so it is our cost" | Pass-through. It distorts margin by hundreds of percent if it leaks into COGS. |
| "I can estimate this month from last month" | Say "estimate", show the basis. A silent estimate becomes a fact in the next brief. |
| "The invoice is routine, I'll send it" | Sending is gated every time. Draft, `GATED:`, stop. |
| "Runway is not relevant to a solopreneur" | Runway is the number that decides whether next month is a build month or a sales month. Report it. |
| "SR&ED is the accountant's job" | The accountant needs the technical narrative only the commits and `.prd/` artifacts can supply. Build the skeleton; let them price it. |

## Verification

- [ ] Every number in a report carries currency, period, and a source line (`costs.jsonl` line, dashboard, invoice, commit)
- [ ] `costs.jsonl` and `ledger.jsonl` lines validate against `references/ledger-schema.md` (all required fields, `venture` present in the ledger)
- [ ] `.finops/BUDGET.md` keeps its four bullet lines in the parser's shape after any edit
- [ ] Ad spend appears nowhere in COGS or margin
- [ ] Every gated action is a written artifact plus a `GATED:` line, with no send, refund, or subscription change executed
- [ ] The burn brief matches `scripts/north-star-status.sh` output for the same period
