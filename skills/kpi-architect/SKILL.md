---
name: kpi-architect
description: When the user wants to define the right KPIs, stress-test a strategy through adversarial scenarios, identify and mitigate risks, or establish governance triggers. Use when PMC says "war game this", "what could kill this", "stress test", "what are the risks", "RAID", "KPIs for X", "how do I know if this is working", "what metrics matter", "value realization", or "governance model."
allowed-tools: Read, Write, AskUserQuestion
---

# KPI Architecture, Risk & Governance

Module 05 of the McKinsey Strategy OS. Stress-tests before committing, defines the right indicators, and sets the governance trigger that forces a strategy review. For deep adversarial interrogation of a plan, load `grill-me` skill.

## KPI Philosophy

Most dashboards are graveyards of lagging metrics. They tell you what happened, not what's about to happen. By the time a lagging metric moves, the window to intervene has often closed.

**The 2-3-2 rule:**
- 2 leading indicators (early warning system)
- 3 operational indicators (health of the core loop)
- 2 lagging indicators (outcome confirmation)

More than 7 KPIs means you're measuring outputs, not driving decisions. Every metric above 7 is noise that competes with signal.

## Leading Indicators

A leading indicator moves before the outcome moves.

Requirements for a valid leading indicator:
1. Causally linked to the lagging metric (not just correlated)
2. Moves within a 30-90 day window before the outcome metric moves
3. Actionable — if it degrades, you know what lever to pull

Test: "If this leading indicator improves 20%, does the outcome metric improve within 90 days?" If yes, it's leading. If not, it's coincident or lagging.

Common leading indicators by business type:
- SaaS: activation rate, time-to-first-value, feature adoption depth
- Marketplace: supply-demand ratio by category, repeat transaction rate
- Services: proposal pipeline velocity, utilization rate
- E-commerce: email list growth, repeat purchase rate at 30 days

## Lagging Indicators

The 1-2 outcome metrics that define whether the strategy worked.

Revenue and retention are almost always lagging indicators. NPS is lagging. MRR growth rate is lagging.

Lagging indicators are confirmation, not navigation. You need them to declare success or failure. You don't steer by them — you steer by the leading indicators that predict them.

Do not confuse vanity metrics (page views, registered users, app downloads) with lagging indicators. Vanity metrics move without predicting business outcomes.

## War-Gaming

Adversarial scenario modeling. The goal is to find the credible, high-damage scenario — not the most likely one.

Three-step war-game:
1. **Name the attacker** — who is best positioned to hurt this strategy? (Incumbent, new entrant, customer behavior shift, regulatory change, technical obsolescence)
2. **Describe the move** — what specifically would they do, and on what timeline? (Be specific: "AWS launches a managed version of this at 60% of our price within 18 months")
3. **Name the defense** — what would you do if that move happened? Is the defense viable? If not, the strategy has a structural vulnerability.

The most dangerous scenario is not the most likely. It's the one that is:
- Credible (someone could actually do it)
- High damage (it would materially harm the strategy)
- Fast (it would happen before you could adapt)

For full interrogation of a plan across multiple attack vectors, load `grill-me` skill.

## Risk Register

A risk with no mitigation is an accepted risk. Name it explicitly.

Format for each risk:
- **Risk**: one sentence description
- **Probability**: High / Medium / Low
- **Impact**: High / Medium / Low (if it occurs)
- **Mitigation**: a concrete action that reduces probability OR reduces impact (not both — one lever is enough)

Top 3 risks only. More than 3 means you haven't prioritized. If you have 10 risks, rank them and keep the top 3.

Mitigation is not "monitor and respond." That's acceptance. Mitigation is a concrete, pre-committed action: "We will sign a second supplier before Q2 to reduce dependency on the primary."

## Governance Trigger

A governance trigger is the specific metric threshold that forces a strategy review.

It is NOT a calendar date. Calendar reviews happen regardless of performance — they produce false confidence when things are going well and delayed response when they're not.

A governance trigger fires when performance demands it:
- "If monthly churn exceeds 5% for 2 consecutive months, the strategy is reviewed and the retention hypothesis is challenged."
- "If CAC exceeds 18-month LTV, we pause paid acquisition and revisit the channel mix."
- "If net revenue retention drops below 90% for the enterprise segment, we trigger a customer success review."

One governance trigger per strategic bet. It should be the metric that, if it moves the wrong way, means the core assumption behind the strategy is in question.

## Output Structure

Every KPI and risk analysis delivers:

1. **Most dangerous scenario** — credible, high-damage, fast; named with specificity (not generic)
2. **Top 3 risks** — probability × impact, one concrete mitigation each
3. **Leading indicators** — 2-3, with causal link to the outcome metric stated
4. **Lagging indicators** — 1-2 outcome metrics
5. **Governance trigger** — specific metric + threshold that forces a review

## Quality Bar

- [ ] Leading indicators are causally linked to lagging metrics (not just correlated)
- [ ] Most dangerous scenario is specific — names the attacker, the move, and the timeline
- [ ] Every risk has a mitigation action (not just "monitor")
- [ ] Governance trigger is a metric + number, not a schedule

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We track too many things to pick 7" | That's the problem this skill fixes. Apply the 2-3-2 rule. Archive the rest — they're not driving decisions. |
| "War-gaming feels pessimistic" | Pessimism is refusing to plan for failure. War-gaming is optimism with discipline — you're confident enough to stress-test your confidence. |
| "Risks are obvious — we know them" | Known risks without mitigations are accepted risks. Name them explicitly as accepted, or act on them. Knowing is not enough. |
| "Governance review is a calendar meeting" | A calendar meeting happens regardless of performance. A governance trigger fires when performance demands it. Calendar reviews produce false confidence. |
