# Report Template — Monetization Assessment

Use this template when generating `docs/monetization-assessment.md`.
Fill in all sections from the discovery context, research findings, cost analysis, and evaluation results.

**Methodology note:** This report uses evidence-based tier evaluation (Strong / Possible / Weak)
instead of numeric scores. Revenue projections are presented as explicit assumption chains
with confidence grades so every number can be challenged and validated independently.

---

# Monetization Assessment — {project_name}

**Generated:** {date}
**Mode:** {mode_description}
**Prepared by:** Claude Code Monetization Skill
**Research reviewed by:** {Yes — founder confirmed | No — automated only}
**Data freshness:** {date range of sources used}

---

## Executive Summary

{2-3 paragraph summary: what the product is, the recommended monetization stack, and
the key assumptions that must hold true for the strategy to work.}

**Bottom line:** {one sentence — the single most important takeaway}

**Confidence level:** {High / Medium / Low} — {why, in one sentence}

**Critical assumptions:** {the 2-3 things that must be true for this to work}

> This assessment is a starting point for strategic discussion, not a financial forecast.
> Revenue figures are assumption-chain projections — each variable is cited and challengeable.
> Verify critical numbers independently before making investment decisions.

---

## Product & Market Context

### Product Overview
- **Name:** {name}
- **Category:** {category}
- **Tech Stack:** {tech_stack}
- **Architecture:** {architecture}
- **Current Stage:** {stage}
- **Team Size:** {team_size}

### Target Market
- **ICP:** {ideal_customer_profile}
- **Market Segment:** {segment}
- **Competitive Differentiation:** {differentiation}

### Distribution & Economics
- **Current Acquisition Channels:** {channels and known CAC}
- **Customer Willingness to Pay:** {price ceiling from discovery}

### Growth Priority
{revenue_speed | market_share | community — and why}

### Legal, Regulatory & Compliance

| Regulation | Applies? | Impact on Monetization | Compliance Status |
|-----------|----------|----------------------|-------------------|
| {GDPR/HIPAA/SOC2/PCI/etc.} | {Yes/No/Uncertain} | {which models it blocks or constrains} | {compliant / work needed / unknown} |

**Monetization Blockers:** {list of models structurally blocked by regulation, or "none identified"}

**Compliance Work Required Before Monetization:**
- {specific requirement — e.g., "BAA template needed before API customers can use health data"}
- {or "None — no regulatory constraints identified"}

---

## Research Findings

*Data freshness is tagged per data point. Sources older than 12 months are marked and should be treated as directional.*

### Market Size
| Metric | Value | Source | Date | Confidence |
|--------|-------|--------|------|------------|
| TAM | ${tam} | {citation} | {date} | {High/Medium/Low} |
| SAM | ${sam} | {citation} | {date} | {High/Medium/Low} |
| SOM | ${som} | {citation} | {date} | {High/Medium/Low} |

### Competitor Analysis
| Competitor | Model | Free Tier | Paid From | Enterprise | Source | Verified |
|-----------|-------|-----------|-----------|------------|--------|----------|
| {name} | {model} | {details} | {price} | {price} | {url} | {date} |

### Industry Benchmarks
| Metric | Value | Source | Date | Applies to this category? |
|--------|-------|--------|------|--------------------------|
| Free-to-paid conversion | {rate}% | {citation} | {date} | {Yes / Adjacent — explain} |
| Trial-to-paid conversion | {rate}% | {citation} | {date} | {Yes / Adjacent — explain} |
| Average contract value | ${acv} | {citation} | {date} | {Yes / Adjacent — explain} |
| CAC payback period | {months}mo | {citation} | {date} | {Yes / Adjacent — explain} |

### Open Source Landscape
{Summary of OS competitors, their monetization approaches, and lessons learned}

### Founder-Provided Intelligence
{Corrections, additions, or market knowledge the user provided during research review.
If none: "Founder confirmed automated research without additions."}

---

## Cost Structure

*Populated when `.monetize/cost-analysis.md` is available. Omit this section if cost analysis was not run.*

### Unit of Value
- **Primary unit:** {per minute / per message / per user / per API call}
- **Secondary units:** {if applicable}

### Cost per Unit
| Component | Provider | Cost per {unit} | % of Total |
|-----------|----------|-----------------|------------|
| {component} | {provider} | ${cost} | {%} |
| **Total** | | **${total}** | **100%** |

### Unit Economics
| Metric | Budget Stack | Mid-Tier Stack | Premium Stack |
|--------|-------------|----------------|---------------|
| Cost per {unit} | ${x} | ${x} | ${x} |
| Suggested price | ${x} | ${x} | ${x} |
| Gross margin | {%} | {%} | {%} |

### Fixed vs Variable Costs
| Type | Monthly Cost | Notes |
|------|-------------|-------|
| Fixed (infrastructure baseline) | ${x} | {details} |
| Variable (per-unit) | ${x} per {unit} | {details} |

### Scaling Summary
| Volume | Cost/Unit | Margin Impact |
|--------|-----------|---------------|
| {low} | ${x} | {%} |
| {medium} | ${x} | {%} |
| {high} | ${x} | {%} |

### Top Cost Drivers & Sensitivity
| Driver | % of Cost | +50% Impact | Mitigation |
|--------|-----------|-------------|------------|
| {driver} | {%} | {margin impact} | {strategy} |

---

## Individual Model Analysis

### Evaluated Models

#### {Model Name} — Verdict: {Recommended / Conditional / Not Recommended}

| Dimension | Verdict | Evidence | What Would Change This |
|-----------|---------|----------|----------------------|
| Market Fit | {Strong/Possible/Weak} | {specific evidence with source} | {upgrade/downgrade path} |
| Revenue Potential | {Strong/Possible/Weak} | {specific evidence with source} | {upgrade/downgrade path} |
| Impl. Complexity | {Strong/Possible/Weak} | {specific evidence with source} | {upgrade/downgrade path} |
| Team Feasibility | {Strong/Possible/Weak} | {specific evidence with source} | {upgrade/downgrade path} |
| Strategic Alignment | {Strong/Possible/Weak} | {specific evidence with source} | {upgrade/downgrade path} |

**Revenue Assumption Chain:**
```
IF [acquisition channel] delivers [X users/month]
   (basis: [specific evidence or "assumed — no data"])
AND [Y%] convert to paid
   (basis: [benchmark from research — cite source and date])
AND ARPU is $[Z]/mo
   (basis: [competitor pricing — cite which competitor])
AND unit cost is $[C]
   (basis: [cost-analysis.md component breakdown])
THEN:
   Monthly net revenue at steady state = X × Y% × ($Z - $C) = $[result]
   12mo net (with 3mo ramp): $[amount]
   24mo net (with [growth %] growth — basis: [evidence]): $[amount]
```

**Confidence:** {High / Medium / Low}
**Weakest assumptions:** {the 1-2 variables with least evidence — these are what you should validate first}

**GTM Requirements:** {marketing/sales motion needed — content, dev-rel, enterprise sales, partner, etc.}

**Top Risks:**
1. {risk_1}
2. {risk_2}
3. {risk_3}

**Prerequisites:** {what must exist before this model can be launched}
**Compliance Requirements:** {regulatory work needed, or "none"}

{Repeat for each viable model}

### Blocked by Compliance
| Model | Regulation | Reason |
|-------|-----------|--------|
| {model} | {regulation} | {specific blocker} |

### Not Applicable
| Model | Reason |
|-------|--------|
| {model} | {one-line reason} |

---

## Recommended Monetization Stack

### Stack: {Model A} → {Model B} → {Model C}

**Why this combination:**
{Rationale — non-cannibalization, sequencing, compound effects, GTM coherence, compliance compatibility}

| Phase | Model | Timeline | Investment | GTM Motion | Compliance Prerequisites |
|-------|-------|----------|------------|------------|------------------------|
| 1 | {model} | {months} | {effort/cost} | {motion} | {compliance work or "none"} |
| 2 | {model} | {months} | {effort/cost} | {motion} | {compliance work or "none"} |
| 3 | {model} | {months} | {effort/cost} | {motion} | {compliance work or "none"} |

### How the Phases Connect
```
Phase 1 generates [X users] and $[Y] net revenue by month [Z]
  → Phase 1 users become the pipeline for Phase 2 because [reason]
Phase 2 leverages Phase 1's [specific asset — user base, brand, infrastructure]
  → Combined 24mo net: $[amount]
```

### Reality Check
To hit the Phase 1 target of [X users/month]:
- Via {primary channel}: requires $[Y] monthly spend at $[Z] CAC (source: {evidence})
- Via {alternative channel}: requires [effort description]
- **Verdict:** {realistic / stretch / requires external funding}

### Risk Matrix
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {risk} | {H/M/L} | {H/M/L} | {strategy} |

### Compliance Checklist
- [ ] {regulation}: {specific action needed} — required before Phase {N}
- [ ] {regulation}: {specific action needed} — required before Phase {N}
{or "No compliance prerequisites identified."}

### Runner-Up Stacks
{Brief description of 2nd and 3rd best stacks with why they weren't selected}

---

## Implementation Roadmap

### Phase 1: {model_name} — {timeline}
**Objective:** {what this achieves}
**Key Deliverables:**
- {deliverable_1}
- {deliverable_2}
**GTM Plan:** {how you'll acquire customers for this model}
**Resource Requirements:** {team/cost}
**Revenue Milestone:** ${target} net MRR by end of phase
**Validation Milestone:** {the thing that proves this model works — e.g., "10 paying customers", "positive unit economics at 100 users"}

### Phase 2: {model_name} — {timeline}
{Same structure}

### Phase 3: {model_name} — {timeline}
{Same structure}

---

## What to Validate First

Before investing in implementation, validate these assumptions (ordered by impact):

1. **{Highest-impact assumption}** — How to test: {specific validation method — e.g., "run a landing page test", "interview 10 potential customers", "price test with existing users"}
2. **{Second assumption}** — How to test: {method}
3. **{Third assumption}** — How to test: {method}

---

## Next Steps

1. **Validate** — Test the critical assumptions listed above before building
2. **Decide** — Review this assessment with stakeholders and confirm strategic direction
3. **Build** — Run `/cks:new` for Phase 1 to begin implementation
4. Phase briefs available at `.monetize/phases/`

---

> **Methodology:** This assessment uses evidence-based tier evaluation (Strong / Possible / Weak) with
> explicit assumption chains. Every revenue figure traces back to cited sources and stated assumptions.
> Numbers labeled "(assumed — no data)" are the report's weakest points — prioritize validating these.
>
> *Generated by the Monetization Skill. Re-run `/monetize` to update with fresh research.*
