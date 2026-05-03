---
name: online-marketing
description: Online marketing expertise — keyword opportunity discovery, content gap analysis, funnel architecture, email sequences, paid ads briefs, CRO — backed by Ahrefs MCP and DataForSEO API for real SERP and traffic data
allowed-tools: Read, Grep, Glob, Write, Bash, WebSearch, WebFetch, "mcp__claude_ai_aHref__*"
model: sonnet
---

# Online Marketing Skill

Expertise in finding and capturing traffic, converting it into leads, and optimizing every step of the funnel — grounded in real keyword data from Ahrefs and SERP intelligence from DataForSEO.

## Data Source Detection

At runtime, check for DataForSEO credentials:
```bash
export $(grep -v '^#' .env.local 2>/dev/null | xargs) 2>/dev/null
export $(grep -v '^#' .env 2>/dev/null | xargs) 2>/dev/null
echo "${DATAFORSEO_LOGIN:+set}"
```
- **Credentials present** → DataForSEO API for SERP features (featured snippets, PAA, ad competition)
- **Credentials absent** → Ahrefs + WebSearch fallback

## Keyword Opportunity Framework

### Low-Hanging Fruit Filter
Pull via Ahrefs `keywords-explorer-matching-terms` for seed keyword. Filter for:
- KD (Keyword Difficulty) < 30
- Volume > 100/month
- CPC > $1 (validates commercial intent)

Sort by: Volume ÷ KD ratio → highest ratio = easiest traction per effort.

### Content Gap Analysis
1. Pull `site-explorer-organic-competitors` for target domain
2. For top 3 competitors, pull `site-explorer-organic-keywords`
3. Cross-reference: keywords ranking for 2+ competitors but not you → content gaps
4. Prioritize gaps where you have topical authority (related to existing content)

### Keyword Clustering
Group keywords by intent and topic cluster:
- **Cluster A** (Primary): high-volume, target content pillar
- **Cluster B** (Supporting): medium-volume, feed pillar via internal links
- **Cluster C** (Long-tail): low-volume, high-intent, embed in pillar content

## Funnel Architecture

### Intent-to-Stage Mapping
| Search Intent | Funnel Stage | Content Type | Goal |
|---------------|-------------|-------------|------|
| "what is [problem]" | ToFu | Blog, guide | Capture email |
| "how to [solve problem]" | MoFu | Tool, template, webinar | Nurture |
| "[competitor] alternative" | BoFu | Comparison page | Demo/trial |
| "[product] pricing" | BoFu | Pricing page | Purchase |

### Lead Magnet Tier
Pull top-traffic pages via Ahrefs `site-explorer-pages-by-traffic`. For each high-traffic page:
- What is the user's next logical step?
- What can you offer that makes the email trade feel obvious?

## Email Sequences

### Cold Outreach (5-email sequence)
- Email 1: Specific, relevant hook — no pitch
- Email 2: Value drop — data, insight, or resource relevant to them
- Email 3: Soft ask — "Would this be relevant to you?"
- Email 4: Social proof — one-line case study
- Email 5: Break-up — "Last email. Worth connecting?"

### Drip Sequence (new subscribers)
- Day 0: Welcome + deliver lead magnet
- Day 2: Quick win — one actionable tip
- Day 5: Problem framing — why the quick win isn't enough
- Day 8: Solution introduction — what you do, how it helps
- Day 14: Case study or proof point
- Day 21: Direct CTA

### Re-engagement
- Trigger: 90 days of inactivity
- Email 1: "Still relevant?" + update what's changed
- Email 2: New resource or win
- Email 3: Explicit unsubscribe offer — keep list clean

## Paid Ads Briefs

### Audience Framework
1. Pull high-converting organic keywords (Ahrefs `site-explorer-organic-keywords` sorted by traffic value)
2. These are your paid targeting seeds — people already buying in this space
3. Layer with competitor targeting (keyword + competitor brand name combinations)

### Ad Copy Framework (PAS)
- **Problem**: State the pain in their language (match search query)
- **Agitate**: What does it cost them to keep living with this problem?
- **Solution**: Your product, one outcome, one CTA

### Creative Direction
- Headline A: Outcome-first ("Stop [problem]. Start [outcome].")
- Headline B: Social proof ("Join [N] teams who [outcome]")
- Headline C: Fear of missing out ("[Competitor users] are already [outcome]")

## DataForSEO SERP Analysis

When credentials present, pull SERP features for target keywords:
- Featured snippets present → format content as direct answer blocks
- PAA boxes present → build FAQ section matching those questions
- Ad competition high (CPC > $5) → validates commercial intent, prioritize this cluster
- Shopping results present → not your channel, deprioritize

## CRO Framework

### Landing Page Audit
Pull top-traffic pages via Ahrefs `site-explorer-top-pages`. For each:
1. Does headline match the keyword intent that brought them here?
2. Is there a single clear CTA above the fold?
3. Does social proof appear within the first screen?
4. Is the form/CTA friction appropriate for the funnel stage?

### A/B Test Hypothesis Format
```
We believe [changing X] for [audience segment]
will [increase/decrease] [metric]
because [reason based on data].
We'll know this works when [specific measurable outcome].
```

## Output Format

Produces `.marketing/online.md` with:
- Top 20 keyword opportunities (KD, volume, CPC, intent stage)
- Content gap list (keywords competitors rank for, you don't)
- Funnel architecture map (intent → stage → content type → CTA)
- 90-day content calendar tied to keyword clusters
- Email sequence templates (cold, drip, re-engagement)
- Paid ads brief (audience + 3 headline variants per ad set)
- CRO audit for top 5 pages

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We need more traffic first" | Wrong order. Fix conversion first, then scale traffic. |
| "Email is dead" | Email converts 3-5x better than social for B2B. |
| "Paid ads are too expensive" | CPC data from Ahrefs tells you exactly where paid is viable before you spend. |
| "We'll write content when we have time" | Keyword opportunities have windows. Competitors are publishing right now. |
