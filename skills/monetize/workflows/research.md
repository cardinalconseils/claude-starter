# Workflow: Research

## Overview
Gathers real market intelligence — competitor pricing, market sizing,
conversion benchmarks, and comparable business models. Produces `.monetize/research.md`.

Uses **Perplexity API** when `PERPLEXITY_API_KEY` is available, otherwise falls back
to **WebSearch** (Claude's built-in search). Both paths produce the same output format.

## Prerequisites
- `.monetize/context.md` must exist (run discover first)
- `PERPLEXITY_API_KEY` environment variable — **optional** (enhances quality but not required)

## Steps

### Step 1: Validate Prerequisites

1. Check `.monetize/context.md` exists. If not → "Run `/monetize:discover` first."

2. Detect research source — check for Perplexity API key:
   ```bash
   export $(grep -v '^#' .env.local 2>/dev/null | xargs) 2>/dev/null
   export $(grep -v '^#' .env 2>/dev/null | xargs) 2>/dev/null
   echo "${PERPLEXITY_API_KEY:+set}"
   ```
   - If **set** → use Perplexity mode (Step 2A)
   - If **empty** → use WebSearch mode (Step 2B). Display:
     ```
     No PERPLEXITY_API_KEY found — using WebSearch for market research.
     For richer results with citations, add PERPLEXITY_API_KEY to .env.local
     ```

3. Read `.monetize/context.md` to extract: product description, category, target market, differentiation.

### Step 2A: Execute Research Queries (Perplexity Mode)

Run each query via Bash curl to the Perplexity API. Use model `sonar-pro` for deep research.

**API Pattern:**
```bash
curl -s https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [
      {"role": "system", "content": "You are a business analyst researching monetization strategies. Provide specific numbers, pricing data, and cite your sources."},
      {"role": "user", "content": "{query}"}
    ]
  }'
```

**Error handling per query:**
- If a query fails (non-200 status or timeout): retry once after 5 seconds
- If retry fails: fall back to WebSearch for that specific query and continue
- Parse the JSON response: extract `.choices[0].message.content` and any `.citations`

### Step 2B: Execute Research Queries (WebSearch Mode)

Use WebSearch tool for each query. Run queries in parallel where possible using Agent dispatches.

**Query pattern:**
```
WebSearch(query: "{search_query}")
```

For each query, run 2-3 targeted searches to compensate for lack of Perplexity's deep synthesis:
- Primary search: the main question
- Follow-up: refine with specific data points (e.g., pricing, market size numbers)
- Optional: fetch promising URLs with WebFetch for detailed data

### Research Queries (both modes)

Construct from context.md data:

1. **Competitor Pricing:**
   "What are the top 5-10 competitors to {product_description} in the {category} space? For each, list their pricing model, pricing tiers, and approximate revenue if available."

2. **Market Sizing:**
   "What is the Total Addressable Market (TAM), Serviceable Addressable Market (SAM), and Serviceable Obtainable Market (SOM) for {category} software targeting {icp}? Provide dollar figures and cite sources."

3. **Open Source Landscape:**
   "What open source projects exist in the {category} space? How do they monetize? List specific examples with their revenue models and any known revenue figures."

4. **Conversion Benchmarks:**
   "What are industry-average conversion rates for {category} software? Include free-to-paid conversion, trial-to-paid, freemium conversion rates, and average contract values. Cite sources."

5. **Comparable Exits & Funding:**
   "What companies in the {category} space have raised funding or been acquired in the last 3 years? List company, amount, valuation, and monetization model."

6. **Platform/Marketplace Precedents:**
   "Are there successful marketplace or platform models in the {category} space? What take rates do they use? How did they solve the chicken-and-egg problem?"

### Step 3: Save Research

Write findings to `.monetize/research.md`:

```markdown
# Market Research Findings

**Generated:** {date}
**Source:** {Perplexity API (sonar-pro) | WebSearch (Claude built-in)}
**Research Gaps:** {list any failed queries, or "none"}

## Competitor Analysis
{Formatted findings from Query 1}

### Pricing Comparison Table
| Competitor | Model | Free Tier | Paid Starts At | Enterprise |
|-----------|-------|-----------|----------------|------------|
| {data from research} |

## Market Size
| Metric | Value | Source |
|--------|-------|--------|
| TAM | {value} | {citation} |
| SAM | {value} | {citation} |
| SOM | {value} | {citation} |

## Open Source Landscape
{Formatted findings from Query 3}

## Conversion Benchmarks
- Free-to-paid: {rate}% ({source})
- Trial-to-paid: {rate}% ({source})
- Average Contract Value: ${acv} ({source})
- CAC Payback: {months} months ({source})

## Comparable Exits & Funding
| Company | Event | Amount | Valuation | Model |
|---------|-------|--------|-----------|-------|
| {data from research} |

## Platform/Marketplace Precedents
{Formatted findings from Query 6}

---
*Research via {Perplexity API | WebSearch}. Verify critical numbers independently before making business decisions.*
```

Display: "Research complete. {N} queries successful, {M} gaps flagged. Saved to `.monetize/research.md`. Moving to evaluation."
