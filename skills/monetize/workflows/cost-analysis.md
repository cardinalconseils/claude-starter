# Workflow: Cost Analysis

## Overview
Researches real-world operational costs for the product's tech stack and builds unit economics
models. Two-agent workflow: cost-researcher gathers pricing data, cost-analyzer builds models.
Produces `.monetize/cost-analysis.md`.

## Prerequisites
- `.monetize/context.md` must exist (for tech stack detection)
- `.monetize/research.md` should exist (for competitor pricing context — recommended but not required)

## Steps

### Step 1: Validate Prerequisites

1. Check `.monetize/context.md` exists. If not → "Run `/monetize:discover` first."
2. Check `.monetize/research.md` exists. If not → warn but continue:
   ```
   Market research not found — cost analysis will proceed without competitor pricing context.
   For margin calculations against market rates, run `/monetize:research` first.
   ```

### Step 2: Dispatch Cost Researcher

Dispatch the `cost-researcher` agent with this context:

```
Research real-world pricing for the tech stack described in .monetize/context.md.
Detect which cost categories are relevant (AI/ML, Speech/Voice, Infrastructure,
Third-party SaaS, Communication, Orchestration, Data/Storage, Media) and research
the top 3-5 providers per category.

Save raw pricing data to .monetize/cost-research-raw.md.
```

**Wait for completion.** The cost-researcher produces `.monetize/cost-research-raw.md`.

### Step 3: Validate Research Output

Check `.monetize/cost-research-raw.md` exists and has content:
- If empty or missing → report failure: "Cost research produced no data. Check WebSearch access."
- If partial (some categories missing) → proceed with available data, flag gaps

### Step 4: Dispatch Cost Analyzer

Dispatch the `cost-analyzer` agent with this context:

```
Build unit economics models from the raw pricing data in .monetize/cost-research-raw.md.
Read .monetize/context.md for product type and .monetize/research.md for competitor pricing.

Produce:
1. Cost stack per unit of value (e.g., cost per minute for voice agents)
2. Unit economics (cost, revenue, margin) across budget/mid/premium stacks
3. Scaling curves with volume discounts
4. Fixed vs variable cost split
5. Margin sensitivity analysis (top 3 cost drivers)

Save to .monetize/cost-analysis.md.
```

**Wait for completion.** The cost-analyzer produces `.monetize/cost-analysis.md`.

### Step 5: Display Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 MONETIZE -> COST ANALYSIS COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Unit of Value: {per minute / per message / per user}
 Cost per Unit: ${budget} — ${premium}
 Recommended Price Range: ${min} — ${max}
 Top Cost Driver: {component} ({%} of total)
 Categories Researched: {N}
 Gaps: {list or "none"}

 Artifacts:
   .monetize/cost-research-raw.md (raw pricing)
   .monetize/cost-analysis.md (unit economics)

 Moving to evaluation...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
