# Workflow: Research

## Overview
Uses Perplexity API to gather real market intelligence — competitor pricing, market sizing,
conversion benchmarks, and comparable business models. Produces `.monetize/research.md`.

## Prerequisites
- `.monetize/context.md` must exist (run discover first)
- `PERPLEXITY_API_KEY` environment variable must be set

## Steps

### Step 1: Validate Prerequisites

1. Check `.monetize/context.md` exists. If not → "Run `/monetize:discover` first."
2. Load `PERPLEXITY_API_KEY` from `.env.local` (or `.env` as fallback) if not already in shell:
   ```bash
   export $(grep -v '^#' .env.local 2>/dev/null | xargs) 2>/dev/null
   export $(grep -v '^#' .env 2>/dev/null | xargs) 2>/dev/null
   echo "${PERPLEXITY_API_KEY:+set}"
   ```
   If empty → "Add `PERPLEXITY_API_KEY=your-key` to `.env.local` or run `export PERPLEXITY_API_KEY=your-key`.
   Get a key at: https://www.perplexity.ai/settings/api
   Then resume with `/monetize:research`."

3. Read `.monetize/context.md` to extract: product description, category, target market, differentiation.

### Step 2: Execute Research Queries

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

**Queries to execute (construct from context.md data):**

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

**Error handling per query:**
- If a query fails (non-200 status or timeout): retry once after 5 seconds
- If retry fails: log "Research gap: {query_topic} — Perplexity unavailable" and continue
- Parse the JSON response: extract `.choices[0].message.content` and any `.citations`

### Step 3: Save Research

Write findings to `.monetize/research.md`:

```markdown
# Market Research Findings

**Generated:** {date}
**Source:** Perplexity API (sonar-pro)
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
*Citations from Perplexity API. Verify critical numbers independently before making business decisions.*
```

Display: "Research complete. {N} queries successful, {M} gaps flagged. Saved to `.monetize/research.md`. Moving to evaluation."
