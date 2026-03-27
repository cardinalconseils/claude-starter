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

### Step 3: Score Viable Models

For each model that passed pre-filter, score across 5 dimensions (1-10):

| Dimension | Weight | Scoring Guidance |
|-----------|--------|-----------------|
| Market Fit (25%) | 8-10: competitors use this model successfully; ICP expects it. 5-7: plausible but unproven. 1-4: market doesn't buy this way. |
| Revenue Potential (25%) | Use research data. Compare market size x realistic market share x conversion rate x pricing. 8-10: >$500K/yr potential. 5-7: $100K-$500K. 1-4: <$100K. |
| Implementation Complexity (20%) | Score INVERSELY — 10 means trivial, 1 means massive effort. Factor in existing tech stack compatibility. |
| Team Feasibility (15%) | 8-10: team can do this now. 5-7: need 1-2 hires or skills. 1-4: need major team build-out. |
| Strategic Alignment (15%) | 8-10: reinforces differentiation and growth priority. 5-7: neutral. 1-4: dilutes focus or contradicts strategy. |

**Composite Score** = (MarketFit x 0.25) + (Revenue x 0.25) + (Complexity x 0.20) + (Feasibility x 0.15) + (Alignment x 0.15)

For each scored model, also produce:
- **Revenue Projection** (conservative/moderate/aggressive) for 12/24/36 months
  - Use research benchmarks: market size, conversion rates, competitor pricing
  - Conservative: 50th percentile assumptions
  - Moderate: 70th percentile
  - Aggressive: 90th percentile
- **Top 3 Risks** specific to this model + this product
- **Prerequisites** — what must exist before launch (billing system, auth tiers, API layer, etc.)

### Step 4: Build Monetization Stack

From the scored models, identify the optimal combination of 2-4 models:

**Stack Selection Criteria:**
1. **Non-cannibalization:** Models shouldn't compete for the same revenue from the same users
2. **Sequenceability:** Phase 1 model should be launchable quickly and generate revenue to fund Phase 2
3. **Revenue diversification:** Stack should include at least one recurring revenue model
4. **Team capacity:** Total implementation effort across stack must be feasible
5. **Compound effects:** Prefer models that make each other stronger (e.g., OS + SaaS + CaaS)

**Rank top 3 possible stacks** and select the best one.

For the recommended stack, produce:
- **Combined revenue projection** (not just sum — account for overlap and synergies)
- **Phased timeline** — which model launches first, second, third
- **Risk matrix** covering the stack as a whole

### Step 5: Save Evaluation

Write to `.monetize/evaluation.md`:

```markdown
# Monetization Evaluation

**Generated:** {date}

## Pre-Filter Results

### Viable Models ({N} of 12)
{List of models that passed filter}

### Not Applicable
| Model | Reason |
|-------|--------|
| {model} | {one-line reason} |

## Individual Model Scores

### {Model Name} — Composite: {score}/10

| Dimension | Score | Weight | Weighted | Rationale |
|-----------|-------|--------|----------|-----------|
| Market Fit | {n} | 25% | {w} | {rationale} |
| Revenue Potential | {n} | 25% | {w} | {rationale} |
| Impl. Complexity | {n} | 20% | {w} | {rationale} |
| Team Feasibility | {n} | 15% | {w} | {rationale} |
| Strategic Alignment | {n} | 15% | {w} | {rationale} |

**Revenue Projection:**
| Scenario | 12mo | 24mo | 36mo |
|----------|------|------|------|
| Conservative | ${x} | ${x} | ${x} |
| Moderate | ${x} | ${x} | ${x} |
| Aggressive | ${x} | ${x} | ${x} |

**Risks:** 1) {risk} 2) {risk} 3) {risk}
**Prerequisites:** {list}

{Repeat for each viable model}

## Recommended Monetization Stack

### Selected Stack: {Model A} + {Model B} + {Model C}

**Why this combination:**
{Rationale for selection — non-cannibalization, sequencing, compound effects}

**Phased Timeline:**
| Phase | Model | Timeline | Key Deliverables |
|-------|-------|----------|-----------------|
| 1 | {model} | Month {x}-{y} | {deliverables} |
| 2 | {model} | Month {x}-{y} | {deliverables} |
| 3 | {model} | Month {x}-{y} | {deliverables} |

**Combined Revenue Projection:**
| Scenario | 12mo | 24mo | 36mo |
|----------|------|------|------|
| Conservative | ${x} | ${x} | ${x} |
| Moderate | ${x} | ${x} | ${x} |
| Aggressive | ${x} | ${x} | ${x} |

**Risk Matrix:**
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| {risk} | {H/M/L} | {H/M/L} | {strategy} |

### Runner-Up Stacks
{Brief description of 2nd and 3rd best stacks with why they weren't selected}
```

Display: "Evaluation complete. {N} models scored, stack recommended: {stack summary}. Moving to report generation."
