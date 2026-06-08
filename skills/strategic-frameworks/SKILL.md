---
name: strategic-frameworks
description: "PM strategy frameworks — Lean Canvas, OST, Pre-Mortem, North Star, PESTLE, Ansoff, Porter's Five Forces — for discovery, validation, competitive analysis, and risk review"
allowed-tools: Read, Write, AskUserQuestion
---

# Strategic Frameworks — Domain Knowledge

Loaded into agents via `skills: strategic-frameworks`. Provides domain expertise for PM strategy facilitation — not execution logic. Agents read workflow files in `workflows/` for step-by-step processes.

## Overview

Seven battle-tested PM frameworks for product strategy, validation, and risk. Each framework maps to a specific lifecycle moment. Use the right tool at the right phase.

## Frameworks

### Lean Canvas
One-page business model. 9 sections covering problem, solution, UVP, unfair advantage, customer segments, channels, revenue, costs, and metrics.

Use when: validating a new product idea before committing to a PRD. Best in Phase 1 Discovery.

Workflow: `skills/strategic-frameworks/workflows/lean-canvas.md`
Schema: `skills/strategic-frameworks/workflows/lean-canvas.yaml`

### Opportunity Solution Tree (OST)
4-level tree: desired outcome → opportunities (customer needs) → solutions → experiments. Forces outcome-first thinking over solution-first.

Use when: stuck on what to build next, or when the team is jumping to solutions without validating needs. Best in Phase 1-2.

Opportunity scoring: Importance × (1 − Satisfaction). Higher score = better opportunity.

Workflow: `skills/strategic-frameworks/workflows/opportunity-solution-tree.md`
Structure: `skills/strategic-frameworks/workflows/opportunity-solution-tree.dot`

### Pre-Mortem
Imagine the product launched and failed. Work backward to identify risks before they happen. Produces tigers (real risks), paper tigers (overstated fears), and elephants (unspoken assumptions).

Use when: pre-launch risk review, sprint planning, stakeholder alignment. Best before Phase 3 Sprint.

Workflow: `skills/strategic-frameworks/workflows/pre-mortem.md`
Schema: `skills/strategic-frameworks/workflows/pre-mortem.yaml`

### North Star Metric
Single metric that best captures the value your product delivers to customers. Paired with 3-5 input metrics owned by teams.

Use when: aligning product and business on what to optimize. Three business game types: Attention, Transaction, Productivity.

Workflow: `skills/strategic-frameworks/workflows/north-star-metric.md`
Schema: `skills/strategic-frameworks/workflows/north-star-metric.yaml`

### PESTLE Analysis
Macro-environment scan across 6 dimensions: Political, Economic, Social, Technological, Legal, Environmental. Each dimension assessed for impact × probability.

Use when: launching in a new market, regulated space, or when external factors are high-risk. Best in Phase 1 Discovery.

Workflow: `skills/strategic-frameworks/workflows/pestle-analysis.md`
Schema: `skills/strategic-frameworks/workflows/pestle-analysis.yaml`

### Ansoff Matrix
4-quadrant growth strategy tool: Market Penetration, Market Development, Product Development, Diversification. Maps product × market combinations against risk.

Use when: defining growth strategy or evaluating expansion options. Best in strategic planning sessions.

Workflow: `skills/strategic-frameworks/workflows/ansoff-matrix.md`
Schema: `skills/strategic-frameworks/workflows/ansoff-matrix.yaml`

### Porter's Five Forces
Competitive analysis across 5 forces: competitive rivalry, supplier power, buyer power, threat of substitutes, threat of new entrants. Produces an overall industry attractiveness score.

Use when: entering a new market, assessing competitive moat, or before a major product pivot.

Workflow: `skills/strategic-frameworks/workflows/porters-five-forces.md`
Schema: `skills/strategic-frameworks/workflows/porters-five-forces.yaml`

## Framework Selection Guide

| Situation | Best Framework |
|-----------|----------------|
| New idea, validate business model | Lean Canvas |
| Stuck on what to build | Opportunity Solution Tree |
| Pre-launch risk review | Pre-Mortem |
| Team misaligned on success | North Star Metric |
| New market or regulated space | PESTLE Analysis |
| Growth strategy choices | Ansoff Matrix |
| Competitive positioning | Porter's Five Forces |

## Output

All frameworks write to `.strategic-frameworks/{name}-{date}.yaml` and append a Working Notes row to `.prd/PRD-STATE.md`. Field schemas defined in `skills/strategic-frameworks/output-schemas.yaml`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The idea is obvious, skip the canvas" | Lean Canvas takes 15 minutes. A wrong pivot takes 3 months. |
| "We know the risks" | Pre-Mortem surfaces elephants — things the team knows but won't say. You can't self-report your own blind spots. |
| "North Star is just a vanity metric exercise" | NSM forces explicit choice between attention, transaction, and productivity games. Without it, teams optimize different things. |
| "Porter's is too academic" | It's a structured way to surface buyer/supplier leverage before you're locked into contracts. 20 minutes now saves months of negotiation. |
| "We don't need all dimensions in PESTLE" | Skip a dimension and it becomes the one that bites you at launch. Run all 6. |

## Verification

- [ ] Framework selected matches the lifecycle phase and situation
- [ ] Output written to `.strategic-frameworks/{name}-{date}.yaml`
- [ ] Working Notes row appended to `.prd/PRD-STATE.md`
- [ ] CONTEXT.md section patched per `output-schemas.yaml` if in Phase 1
- [ ] All AskUserQuestion calls used for user decisions — no plain text questions
