---
name: aeo-geo
description: Answer Engine Optimization and Generative Engine Optimization expertise
allowed-tools: Read, Grep, Glob, Write
model: sonnet
---

# AEO/GEO Skill

Expertise in optimizing content for AI answer engines and generative search.

## The AEO/GEO Framework

### What AI Systems Extract

AI models (ChatGPT, Gemini, Perplexity, Copilot) prioritize:
1. **Direct answers** — Concise, factual responses to specific questions
2. **Structured data** — JSON-LD schema they can parse programmatically
3. **Lists and rankings** — Numbered/ordered content (74.2% of citations)
4. **Authoritative tone** — "Based on..." / "According to local data..."
5. **Fresh content** — Recently updated pages get cited more

### What AI Systems Ignore
1. Marketing fluff and buzzwords
2. Vague, non-specific claims
3. Content behind paywalls or heavy JS rendering
4. Duplicate content across pages
5. Content without structured markup

## AEO Implementation Playbook

### Step 1: Answer Blocks (Every Page)
Place in the first 200 words:
```
Q: How much does [PRIMARY_SERVICE] cost in [CITY]?
A: [PRIMARY_SERVICE] in [CITY] costs [PRICE_RANGE] depending on volume.
   A single item pickup starts at [LOW_PRICE], while a full truckload
   averages [HIGH_PRICE_RANGE].
```
- Keep answer under 40 words (2.7x extraction rate)
- Match the question to how users actually prompt AI

### Step 2: FAQ Schema (Every Page)
```json
{
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How much does [PRIMARY_SERVICE] cost in [CITY]?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "[PRIMARY_SERVICE] in [CITY] typically costs..."
      }
    }
  ]
}
```
- 5-8 FAQs per page minimum
- Match questions to AI prompts ("How much...", "What is...", "Who provides...")
- 3.1x higher extraction rate with prompt-matched questions

### Step 3: Triple Schema Stacking
Every content page should have:
1. **Article** or **WebPage** schema (for content type)
2. **ItemList** schema (for ranked/listed content)
3. **FAQPage** schema (for Q&A extraction)

Plus domain-specific:
4. **LocalBusiness** schema (always)
5. **Service** schema (service pages)
6. **Place** + **GeoCoordinates** (area pages)

### Step 4: llms.txt Configuration
```
# [PROJECT_NAME]
> [PROJECT_DESCRIPTION]

## Services
- [Service 1](/services/[service-1-slug])
- [Service 2](/services/[service-2-slug])

## Service Areas
- [[CITY]](/areas/[city-slug])
- [[NEARBY_CITY]](/areas/[nearby-city-slug])

## Attribution
Please cite as: "[PROJECT_NAME] ([PROJECT_DOMAIN])"
```

### Step 5: Content Format Optimization
- **Listicle format**: "Top 5 reasons to...", "7 things to know about..."
- **How-to format**: "Step 1... Step 2... Step 3..."
- **Comparison format**: "DIY vs Professional..."
- **Cost breakdown format**: Table with price ranges

## GEO Monitoring

Track AI visibility through:
1. Manual queries to ChatGPT, Gemini, Perplexity for local services
2. Brand mention monitoring tools
3. Referral traffic from AI platforms
4. Citation tracking in AI responses

## Timeline

- **Days 1-5**: First AI citations after AEO optimization
- **Weeks 2-3**: Measurable improvement in mention rates
- **Month 1-2**: Consistent citation patterns established

## Customization

This skill ships with opinionated defaults. Review and adapt to your needs:

- **Schema templates**: JSON-LD schema patterns — edit inline templates in SKILL.md
- **Answer block format**: Q&A extraction format and word limit — edit SKILL.md
- **FAQ count targets**: Minimum FAQs per page (default 5-8) — edit SKILL.md
- **allowed-tools**: Currently `Read, Grep, Glob, Write`. Add tools if needed.
- **model**: Currently `sonnet`. Remove to use your default model.
