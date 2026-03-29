# Workflow: Evaluate

## Overview
Scores each of the 12 monetization models against the discovery context and research data.
Pre-filters obviously inapplicable models, fully scores viable ones, then builds an optimal
monetization stack combining 2-4 models.

## Prerequisites
- `.monetize/context.md` must exist
- `.monetize/research.md` must exist (research gaps are acceptable)
- `.monetize/cost-analysis.md` should exist (enables margin-aware scoring — warn if missing)

## Reference
Read `references/models-catalog.md` for model definitions, evaluation criteria, and applicability signals.

## Steps

### Step 1: Load Context

Read `.monetize/context.md`, `.monetize/research.md`, and `.monetize/cost-analysis.md` (if available).
Extract key decision factors:
- Product type & architecture
- Target market & ICP
- Team size & stage
- Growth priority
- Competitor models & pricing
- Market size numbers
- Conversion benchmarks
- **Unit economics** — cost per unit of value, margins, scaling curves (from cost-analysis.md)
- **Top cost drivers** — which components dominate costs (from cost-analysis.md)

### Step 2: Pre-Filter

For each of the 12 models, check **Applicability Signals** and **Red Flags** from the models catalog
against the product context.

Mark as **Not Applicable** (with one-line reason) if:
- Red flags clearly match the product
- No applicability signals match
- The model requires capabilities the team clearly doesn't have (e.g., IaaS for a 2-person team)

Typically 4-8 models should pass the filter. If fewer than 3 pass, relax criteria — every
product has at least 3 viable models.

### Step 3: Evaluate Viable Models (Evidence-Based Tiers)

**Do NOT use numeric scores.** For each model that passed pre-filter, evaluate across 5 dimensions
using the tier system defined in `references/models-catalog.md`:

| Dimension | Strong | Possible | Weak |
|-----------|--------|----------|------|
| **Market Fit** | Competitors use this model; ICP expects it. Cite specific companies. | Plausible but no direct comparable. State what's missing. | Market doesn't buy this way. Cite counter-evidence. |
| **Revenue Potential** | Evidence-based path to >$500K/yr net. Show the assumption chain. | $100K-$500K/yr possible but assumptions are thin. Flag which ones. | <$100K/yr ceiling or negative unit economics. Show why. |
| **Implementation Complexity** | Team can build this in <3 months with current stack. | 3-6 months or requires 1-2 new capabilities. | >6 months, major new infrastructure, or architectural rewrite. |
| **Team Feasibility** | Team has the skills and capacity now. | Need 1-2 hires or can outsource specific pieces. | Need fundamentally different team (e.g., enterprise sales, DevOps org). |
| **Strategic Alignment** | Reinforces differentiation and stated growth priority. | Neutral to strategy. | Dilutes focus or contradicts stated priority. |

**For each dimension, provide:**
- **Verdict:** Strong / Possible / Weak
- **Evidence:** Specific data point from research.md, context.md, or cost-analysis.md
- **For Possible:** What would upgrade it to Strong (the testable condition)

**Overall Model Verdict:**
- **Recommended** — Market Fit AND Revenue Potential are both Strong
- **Conditional** — At least one is Possible; state the conditions clearly
- **Not Recommended** — Market Fit OR Revenue Potential is Weak

**Legal/Compliance Gate:** Before any other dimension, check `.monetize/context.md` "Legal, Regulatory & Compliance" section. If a regulation structurally blocks a model (e.g., HIPAA blocks open marketplace data sharing, GDPR blocks usage-based analytics monetization), mark the model as **Blocked (Compliance)** with the specific regulation cited. Do not evaluate further.

For each evaluated model, also produce:

- **Revenue Assumption Chain** (replaces point-estimate projections):
  ```
  IF [acquisition channel] delivers [X users/month] (basis: [evidence])
  AND [Y%] convert to paid (basis: [benchmark from research.md])
  AND ARPU is $[Z]/mo (basis: [competitor pricing from research.md])
  AND cost per unit is $[C] (basis: [cost-analysis.md])
  THEN:
    Monthly net revenue = X × Y% × ($Z - $C) = $[result]
    12mo net = $[result] (ramp: assume 3mo to steady state)
    24mo net = $[result] (with [growth assumption and basis])
  ```
  Each variable MUST cite its source. If a variable is a guess, label it: **(assumed — no data)**

- **Confidence Grade:**
  - **High** — 3+ data points support each key assumption (comparable companies, published benchmarks)
  - **Medium** — 1-2 data points, some assumptions extrapolated
  - **Low** — mostly assumptions, no direct comparable data. Flag which assumptions are weakest.

- **Top 3 Risks** specific to this model + this product
- **Prerequisites** — what must exist before launch (billing system, auth tiers, API layer, etc.)
- **GTM Requirements** — what sales/marketing motion this model requires (content marketing, developer relations, enterprise sales, partner management, etc.) and whether the team can execute it

### Step 4: Build Monetization Stack

From the evaluated models, identify the optimal combination of 2-4 models.

**"Not Ready" Gate:** Before building a stack, check: if stage is pre-revenue AND user base is <100 AND no clear PMF signal in context.md, output a **Not Ready** recommendation instead:
```
RECOMMENDATION: Do not monetize yet.
Reason: [specific evidence — no users, no PMF signal, etc.]
Instead: [specific milestone to hit first — e.g., "reach 500 active users", "validate willingness to pay with 10 customer interviews"]
Revisit monetization when: [testable condition]
```

**Stack Selection Criteria:**
1. **Non-cannibalization:** Models shouldn't compete for the same revenue from the same users
2. **Sequenceability:** Phase 1 model should be launchable quickly and generate revenue to fund Phase 2
3. **Revenue diversification:** Stack should include at least one recurring revenue model
4. **Team capacity:** Total implementation effort across stack must be feasible
5. **Compound effects:** Prefer models that make each other stronger (e.g., OS + SaaS + CaaS)
6. **GTM coherence:** Models in the stack should share compatible go-to-market motions. A stack requiring content marketing + enterprise sales + developer relations simultaneously is not feasible for a small team. Favor stacks where Phase 1's GTM feeds Phase 2.
7. **Compliance compatibility:** All models in the stack must be compatible with the legal/regulatory constraints from context.md. A stack where Phase 2 is blocked by a regulation the team hasn't addressed is not viable.

**Rank top 3 possible stacks** and select the best one.

For the recommended stack, produce:
- **Combined revenue assumption chain** (not just sum — show how Phase 1 revenue/users feed Phase 2)
- **Phased timeline** — which model launches first, second, third
- **GTM plan per phase** — what marketing/sales motion each phase requires
- **Risk matrix** covering the stack as a whole
- **Compliance checklist** — what regulatory work must be done before each phase launches

### Step 5: Save Evaluation

Write to `.monetize/evaluation.md`:

```markdown
# Monetization Evaluation

**Generated:** {date}
**Methodology:** Evidence-based tier evaluation (Strong / Possible / Weak)

## Pre-Filter Results

### Viable Models ({N} of 12)
{List of models that passed filter}

### Blocked (Compliance)
| Model | Regulation | Why It's Blocked |
|-------|-----------|-----------------|
| {model} | {regulation} | {specific reason} |

### Not Applicable
| Model | Reason |
|-------|--------|
| {model} | {one-line reason} |

## Individual Model Evaluations

### {Model Name} — Verdict: {Recommended / Conditional / Not Recommended}

| Dimension | Verdict | Evidence | Upgrade Path (if Possible) |
|-----------|---------|----------|---------------------------|
| Market Fit | {Strong/Possible/Weak} | {specific evidence with source} | {what would change the verdict} |
| Revenue Potential | {Strong/Possible/Weak} | {specific evidence with source} | {what would change the verdict} |
| Impl. Complexity | {Strong/Possible/Weak} | {specific evidence with source} | {what would change the verdict} |
| Team Feasibility | {Strong/Possible/Weak} | {specific evidence with source} | {what would change the verdict} |
| Strategic Alignment | {Strong/Possible/Weak} | {specific evidence with source} | {what would change the verdict} |

**Revenue Assumption Chain:**
```
IF [channel] → [X users/mo] (source: [evidence])
AND [Y%] convert (source: [benchmark])
AND ARPU $[Z]/mo (source: [competitor])
AND unit cost $[C] (source: [cost-analysis.md])
THEN net revenue = [calculation]
  12mo: $[X] (confidence: [High/Medium/Low])
  24mo: $[X] (confidence: [High/Medium/Low])
```
**Weakest Assumptions:** {list the 1-2 assumptions with least evidence}

**Confidence Grade:** {High / Medium / Low} — {why}

**GTM Requirements:** {what sales/marketing motion is needed}
**Risks:** 1) {risk} 2) {risk} 3) {risk}
**Prerequisites:** {list}
**Compliance Work Required:** {list or "none"}

{Repeat for each viable model}

## Recommended Monetization Stack

### Selected Stack: {Model A} → {Model B} → {Model C}

**Why this combination:**
{Rationale — non-cannibalization, sequencing, compound effects, GTM coherence}

**Phased Timeline:**
| Phase | Model | Timeline | Key Deliverables | GTM Motion | Compliance Prerequisites |
|-------|-------|----------|-----------------|------------|------------------------|
| 1 | {model} | Month {x}-{y} | {deliverables} | {motion} | {compliance work} |
| 2 | {model} | Month {x}-{y} | {deliverables} | {motion} | {compliance work} |
| 3 | {model} | Month {x}-{y} | {deliverables} | {motion} | {compliance work} |

**Combined Revenue Assumption Chain:**
```
Phase 1 generates [X users] and $[Y] net revenue by month [Z]
  → This funds Phase 2 because [reason]
Phase 2 leverages Phase 1's [asset] to achieve [outcome]
  → Combined 24mo net: $[amount] (confidence: [grade])
```
**Reality Check:** To hit the Phase 1 target, you need to acquire [X] users via [channel].
At industry-average CAC of $[Y] (source: [evidence]), that requires $[Z] marketing spend.
{State whether this is realistic given team budget from context.md}

**Risk Matrix:**
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| {risk} | {H/M/L} | {H/M/L} | {strategy} |

**Compliance Checklist:**
- [ ] {regulation}: {what must be done} — required before Phase {N}
- [ ] {regulation}: {what must be done} — required before Phase {N}

### Runner-Up Stacks
{Brief description of 2nd and 3rd best stacks with why they weren't selected}
```

Display: "Evaluation complete. {N} models evaluated, stack recommended: {stack summary}. Moving to report generation."
