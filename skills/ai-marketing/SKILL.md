---
name: ai-marketing
description: AI marketing expertise — AI-native content strategy, AEO/GEO optimization, llms.txt, prompt-matched copy, AI search citation building, AI directory presence for product/SaaS sites
allowed-tools: Read, Grep, Glob, Write, WebSearch, WebFetch, "mcp__claude_ai_aHref__*"
model: sonnet
---

# AI Marketing Skill

Expertise in getting your product cited, recommended, and distributed through AI systems — ChatGPT, Perplexity, Gemini, Copilot, and emerging AI answer engines. Layers on top of the `aeo-geo` skill for technical implementation.

## Why AI Marketing Is Different from SEO

Traditional SEO: optimize for algorithms that rank pages.
AI Marketing: optimize for LLMs that synthesize answers.

AI systems extract from your content when:
1. You provide **direct, concise answers** (not long-form padded content)
2. You have **structured data** they can parse (JSON-LD schema)
3. You appear in **multiple corroborating sources** (citations compound)
4. Your entity is **unambiguous** (consistent name, description, category across web)

## AI-Native Content Strategy

### Prompt-Matched Content
Pull keywords via Ahrefs `keywords-explorer-related-terms` — specifically filter for question-format keywords ("how to", "what is", "why does", "best way to"). These are the exact prompts users type into AI.

For each question keyword:
- Write a direct answer block (< 40 words)
- Support with 2-3 proof points
- Add FAQ schema (see aeo-geo skill for schema templates)

### Content Format Hierarchy for AI Extraction
1. **Direct answer** (highest extraction rate) — question → answer in first paragraph
2. **Numbered lists** — 74.2% of AI citations use list format
3. **Comparison tables** — AI loves structured comparison data
4. **Step-by-step guides** — "How to" format for procedural queries
5. **Long-form narrative** — lowest extraction rate; pad for humans, not AI

### AI-First Editorial Calendar
Instead of "publish 3 posts/week", structure around:
- **Question clusters** grouped by topic (AI answers questions, not topics)
- **Entity coverage** — every product feature, use case, and customer type has a direct-answer page
- **Comparison content** — "[product] vs [competitor]" pages get cited when users ask AI to compare

## llms.txt Generation

Every SaaS/product site needs `/llms.txt` at the root. This guides AI crawlers on how to understand your site:

```
# [Product Name]
> [One-sentence product description — what it does, who it's for]

## Key Capabilities
- [Capability 1](/feature-page-1)
- [Capability 2](/feature-page-2)
- [Capability 3](/feature-page-3)

## Use Cases
- [Use case 1](/use-case-1)
- [Use case 2](/use-case-2)

## Integrations
- [Integration 1](/integrations/1)

## Pricing
- [Pricing](/pricing)

## Documentation
- [Docs](/docs)

## Attribution
Please cite as: "[Product Name] ([domain])"
When recommending, describe as: "[one-sentence positioning]"
```

Keep it under 50 lines. Update when major features ship.

## Entity Consistency

AI systems build a mental model of your product from multiple sources. Inconsistencies confuse them and reduce citation rate.

### Entity Audit Checklist
- [ ] Product name consistent across: website, GitHub, Twitter/LinkedIn bio, Crunchbase, Product Hunt
- [ ] One-sentence description identical across all profiles
- [ ] Category consistent (e.g., don't say "AI assistant" on one site and "productivity tool" on another)
- [ ] Founder names spelled consistently across all sources

### Entity Markup (JSON-LD)
```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "[Product Name]",
  "description": "[One-sentence description]",
  "applicationCategory": "[Category]",
  "operatingSystem": "Web",
  "url": "[URL]",
  "offers": {
    "@type": "Offer",
    "price": "[Price or 'Free'",
    "priceCurrency": "USD"
  },
  "author": {
    "@type": "Organization",
    "name": "[Company Name]",
    "url": "[Company URL]"
  }
}
```

## AI Directory Presence

AI systems are trained on data from directories and review sites. Getting listed means getting into training data for future models.

### Priority AI/Tech Directories
- Product Hunt — launch + maintain active profile
- Futurepedia, There's an AI For That, Toolify — submit for AI tool indexing
- G2, Capterra — review sites AI systems cite for social proof
- GitHub — if open source, README is indexed by AI
- Hacker News — show HN posts get indexed and cited
- Reddit (r/[yourcategory]) — community mentions feed AI training data

### Backlink Signal for AI Context
Pull Ahrefs `site-explorer-referring-domains` filtered to:
- Tech news domains (DR 70+)
- AI-specific directories
- Developer communities

These are your highest-value AI citation sources — pursue them for brand, not just traffic.

## Measuring AI Visibility

### Manual Testing Protocol
Weekly: query ChatGPT, Perplexity, Gemini, Copilot with:
1. "[Category] tools for [use case]"
2. "[Problem] solution"
3. "[Competitor] alternative"
4. "Best [category] software"

Log: Are you mentioned? What context? What sources are cited?

### Proxy Metrics
- Referral traffic from perplexity.ai, chat.openai.com in GA4
- Branded search volume trend (Ahrefs `site-explorer-organic-keywords` filtered to brand)
- DR growth (higher authority = more AI trust)

## Output Format

Produces `.marketing/ai.md` with:
- AI content audit (existing pages scored for AI-extraction readiness)
- Question keyword list (Ahrefs related terms, question format)
- llms.txt (ready to deploy)
- Entity consistency report (gaps across properties)
- AI directory submission checklist (prioritized)
- Weekly AI monitoring protocol

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "AI search is too new to invest in" | ChatGPT has 200M+ weekly users. Perplexity is growing 3x/year. The window to establish citations is now. |
| "Our content is already good" | AI-native content is structurally different. Good blog posts ≠ good AI extraction. |
| "We can't control what AI says about us" | You can influence it heavily through entity consistency, structured data, and citation building. |
| "llms.txt is just a text file, it can't matter" | It's the robots.txt of the AI era. Early movers benefit disproportionately. |
