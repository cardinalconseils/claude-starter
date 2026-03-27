# Report Template — Monetization Assessment

Use this template when generating `docs/monetization-assessment.md`.
Fill in all sections from the discovery context, research findings, and evaluation results.

---

# Monetization Assessment — {project_name}

**Generated:** {date}
**Mode:** {mode_description}
**Prepared by:** Claude Code Monetization Skill

---

## Executive Summary

{2-3 paragraph summary: what the product is, top-line market opportunity, recommended
monetization stack, and projected revenue range. This section should be readable by
a non-technical executive in under 2 minutes.}

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

### Growth Priority
{revenue_speed | market_share | community — and why}

---

## Research Findings

### Market Size
| Metric | Value | Source |
|--------|-------|--------|
| TAM | ${tam} | {citation} |
| SAM | ${sam} | {citation} |
| SOM | ${som} | {citation} |

### Competitor Analysis
| Competitor | Model | Pricing | Notes |
|-----------|-------|---------|-------|
| {name} | {model} | {pricing} | {notes} |

### Industry Benchmarks
- Free-to-paid conversion: {rate}% ({citation})
- Average contract value: ${acv} ({citation})
- CAC payback period: {months} months ({citation})

### Open Source Landscape
{Summary of OS competitors, their monetization approaches, and lessons learned}

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

### Viable Models (Full Scoring)

#### {Model Name} — Score: {composite}/10

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Market Fit | {n}/10 | {rationale} |
| Revenue Potential | {n}/10 | {rationale} |
| Implementation Complexity | {n}/10 | {rationale} |
| Team Feasibility | {n}/10 | {rationale} |
| Strategic Alignment | {n}/10 | {rationale} |

**Revenue Projection:**
| Scenario | 12 Month | 24 Month | 36 Month |
|----------|----------|----------|----------|
| Conservative | ${x} | ${x} | ${x} |
| Moderate | ${x} | ${x} | ${x} |
| Aggressive | ${x} | ${x} | ${x} |

**Top Risks:**
1. {risk_1}
2. {risk_2}
3. {risk_3}

**Prerequisites:** {what must exist before this model can be launched}

{Repeat for each viable model}

### Not Applicable
| Model | Reason |
|-------|--------|
| {model} | {one-line reason} |

---

## Recommended Monetization Stack

### Stack Overview
{2-3 sentences on why these models were selected as a combination}

| Phase | Model | Timeline | Investment |
|-------|-------|----------|------------|
| 1 | {model} | {months} | {effort/cost} |
| 2 | {model} | {months} | {effort/cost} |
| 3 | {model} | {months} | {effort/cost} |

### Why These Together
{Explanation of how models complement each other, don't cannibalize, and sequence properly}

### Combined Revenue Projection
| Scenario | 12 Month | 24 Month | 36 Month |
|----------|----------|----------|----------|
| Conservative | ${x} | ${x} | ${x} |
| Moderate | ${x} | ${x} | ${x} |
| Aggressive | ${x} | ${x} | ${x} |

### Risk Matrix
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {risk} | {H/M/L} | {H/M/L} | {strategy} |

---

## Implementation Roadmap

### Phase 1: {model_name} — {timeline}
**Objective:** {what this achieves}
**Key Deliverables:**
- {deliverable_1}
- {deliverable_2}
**Resource Requirements:** {team/cost}
**Revenue Milestone:** ${target} MRR by end of phase

### Phase 2: {model_name} — {timeline}
{Same structure}

### Phase 3: {model_name} — {timeline}
{Same structure}

---

## Next Steps

1. Review this assessment and confirm strategic direction
2. Run `/cks:new` for Phase 1 to begin implementation
3. Phase briefs available at `.monetize/phases/`

---

*Generated by the Monetization Skill. Re-run `/monetize` to update with fresh research.*
