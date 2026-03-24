# Workflow: Competitive Intelligence

## Overview

Specialized research mode for competitor analysis. Builds on the research loop engine but
structures queries and output around competitive positioning: who are the players, what do
they offer, where are the gaps, and how should you position.

## Prerequisites
- Config loaded, sources validated (from SKILL.md)
- Topic is a domain/market/product category (e.g., "SaaS CRM for startups", "AI code review tools")

## Process

### Step 1: Define Competitive Landscape

Parse the topic to extract:
- **Domain**: The market or product category
- **Target segment**: Who the competitors serve (if specified)
- **Focus area**: Specific aspect to compare (if specified)

Generate initial competitor discovery queries:

1. "Top {domain} tools and platforms in 2024-2025. List companies with: name, URL, pricing model, target market, key differentiator."
2. "Emerging startups and new entrants in the {domain} space. Include funding status and launch date."
3. "{domain} market map — categories of solutions and major players in each"
4. "Open-source alternatives for {domain}. Active projects with GitHub stars, last commit date, and community size."

### Step 2: Execute Discovery (Hop 1)

Run queries using the research loop engine (Step 3 of `research-loop.md`).

From the results, build a competitor list:
```
competitors: [
  { name: "...", url: "...", category: "direct|indirect|adjacent", initial_data: {...} }
]
```

**Categorize competitors:**
- **Direct**: Same product category, same target market
- **Indirect**: Different product, solves the same problem
- **Adjacent**: Same technology space, different use case

Select top 8-10 competitors for deep analysis (prioritize direct, include 2-3 indirect).

### Step 3: Deep Competitor Profiles (Hop 2)

For each selected competitor, generate targeted queries:

1. "{competitor_name} pricing plans features comparison 2024"
2. "{competitor_name} technology stack architecture"
3. "{competitor_name} reviews user complaints common issues"
4. "{competitor_name} company size funding revenue" (if startup)

If `ahref` source is available, also run:
```
site-explorer-metrics(target: "{competitor_domain}")
site-explorer-organic-keywords(target: "{competitor_domain}", limit: 10)
```

Build detailed profiles:
```
For each competitor:
  name, url, founded, funding, team_size
  pricing: { model, tiers, starting_price, enterprise }
  features: [list of key features]
  stack: { frontend, backend, database, infra }
  strengths: [from reviews and analysis]
  weaknesses: [from reviews and complaints]
  traffic: { monthly_visits, growth_trend } (if ahref available)
  seo_keywords: [top organic keywords] (if ahref available)
```

### Step 4: Gap Analysis (Hop 3, if depth allows)

If depth budget allows another hop, investigate gaps:

1. "Common complaints about {domain} tools — unmet needs and missing features"
2. "What users wish {top_competitor} would add or fix"
3. "{domain} feature requests and wishlists from Reddit, HackerNews, ProductHunt"

Cross-reference user complaints against competitor feature lists to identify:
- **Underserved needs**: Features no competitor offers well
- **Price gaps**: Market segments with no affordable option
- **UX gaps**: Common usability complaints across competitors
- **Technical gaps**: Architectural limitations shared by incumbents

### Step 5: Generate Comparison Matrix

Write `.research/{slug}/matrix.md`:

```markdown
# Competitive Matrix — {Domain}

> Generated: {date} | Competitors analyzed: {count}

## Overview Matrix

| | {Comp 1} | {Comp 2} | {Comp 3} | {Comp 4} | {Comp 5} |
|---|---|---|---|---|---|
| **Category** | Direct | Direct | Indirect | Direct | Adjacent |
| **Founded** | {year} | {year} | {year} | {year} | {year} |
| **Pricing From** | ${X}/mo | ${X}/mo | Free | ${X}/mo | ${X}/mo |
| **Target** | {segment} | {segment} | {segment} | {segment} | {segment} |

## Feature Comparison

| Feature | {Comp 1} | {Comp 2} | {Comp 3} | {Comp 4} | {Comp 5} |
|---------|---|---|---|---|---|
| {Feature 1} | Y | Y | N | Y | P |
| {Feature 2} | Y | N | Y | N | Y |
| {Feature 3} | P | Y | Y | Y | N |

Legend: Y = Full support | P = Partial | N = Not available

## Pricing Comparison

| Tier | {Comp 1} | {Comp 2} | {Comp 3} | {Comp 4} |
|------|---|---|---|---|
| Free | {details} | {details} | {details} | {details} |
| Starter | {price + limits} | ... | ... | ... |
| Pro | {price + limits} | ... | ... | ... |
| Enterprise | {price + limits} | ... | ... | ... |

## Strengths & Weaknesses

### {Competitor 1}
- Strengths: {list}
- Weaknesses: {list}
- Best for: {use case}

### {Competitor 2}
...

## Gap Analysis

### Underserved Needs
1. {Need} — no competitor addresses this well. Opportunity: {description}
2. ...

### Price Gaps
1. {Segment} has no option between ${low} and ${high}
2. ...

### UX/Technical Gaps
1. {Common complaint across competitors}
2. ...

## Positioning Recommendations

Based on this analysis, the strongest positioning opportunities are:

1. **{Position 1}**: {Why — based on gaps identified}
2. **{Position 2}**: {Why}
3. **{Position 3}**: {Why}
```

### Step 6: Synthesize Report

Use the standard synthesis from `research-loop.md` Step 5-6, but with competitive-specific sections:

The report.md should include:
- Executive summary focused on competitive landscape
- Competitor profiles (summarized from detailed analysis)
- Market dynamics (trends, consolidation, emerging categories)
- Opportunity assessment (gaps + positioning)
- Recommended differentiators
- Actionable next steps

### Step 7: Report Summary

```
Competitive Intelligence: {domain}

  Competitors found: {total} ({direct} direct, {indirect} indirect, {adjacent} adjacent)
  Deep profiles: {count}
  Gaps identified: {count}

  Report: .research/{slug}/report.md
  Matrix: .research/{slug}/matrix.md
  Sources: .research/{slug}/sources.md

  Top opportunities:
  1. {opportunity 1}
  2. {opportunity 2}
  3. {opportunity 3}
```

## Integration with /cks:monetize

When invoked from the monetize skill's research phase:
- Skip the competitor discovery step (competitors already identified in discover phase)
- Focus on pricing analysis and gap identification
- Output feeds directly into monetize evaluation scoring
