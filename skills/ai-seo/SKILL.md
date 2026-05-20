---
name: ai-seo
description: When the user wants to optimize content for AI search engines, get cited by LLMs, or appear in AI-generated answers. Also use when the user mentions 'AI SEO,' 'AEO,' 'GEO,' 'LLMO,' 'answer engine optimization,' or 'AI citations.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# AI SEO — Answer Engine & LLM Optimization

Expert knowledge for getting your brand, product, and content cited by AI systems including ChatGPT, Perplexity, Claude, Gemini, and AI-powered search.

## What AI SEO Is (and Isn't)

AI SEO (also called AEO — Answer Engine Optimization, GEO — Generative Engine Optimization, or LLMO — Large Language Model Optimization) is the practice of making your content the authoritative source LLMs cite when answering questions relevant to your domain.

Traditional SEO → rank in blue-link results.
AI SEO → be the source AI systems quote, summarize, or recommend.

These goals overlap significantly but differ in emphasis:
- AI SEO prioritizes answer-shaped content, entity clarity, and corroborating citations
- Traditional SEO prioritizes keyword density, backlink profile, and click-through signals

## How LLMs Source Information

LLMs are trained on large web corpora (Common Crawl, Wikipedia, news, forums, Reddit, docs). They also increasingly use Retrieval-Augmented Generation (RAG) to pull live web content. Understanding both paths is key:

**Training data path:** Your content must exist, be crawlable, and be repeatedly cited across authoritative sources before the LLM training cutoff.

**RAG/live retrieval path:** Your content must be indexed, fast-loading, and structured for snippet extraction. Perplexity and Bing Copilot lean heavily on this.

## Core Strategy: The 7 Pillars of AI SEO

### 1. Entity Disambiguation

LLMs build knowledge graphs. Your brand/product must be a clearly defined entity.

**Requirements:**
- Consistent NAP (Name, Address, Phone) across all web properties
- Wikipedia page or Wikidata entry (if scale justifies it)
- Google Knowledge Panel claimed and verified
- Crunchbase, LinkedIn Company, G2 profiles all matching
- About page that clearly states: who you are, what you do, who you serve, where you're located

**Entity signals the AI reads:**
- Brand name mentioned alongside consistent descriptors across many sources
- Your domain cited by other authoritative domains
- Your brand mentioned in the same context as established competitors

### 2. Answer-Shaped Content

LLMs prefer content that directly answers questions. Write content as if you're answering a specific question — because you are.

**Format rules:**
- Lead with the direct answer in 1-2 sentences
- Follow with the explanation, evidence, and context
- Use clear heading questions ("What is X?" "How does Y work?")
- Include definition blocks for key terms
- Use numbered steps for processes
- Use comparison tables for alternatives

**The "Answer Block" formula:**
```
[Question as H2]
[Direct 1-sentence answer]
[2-3 sentence elaboration]
[Evidence or example]
[Link to deeper content]
```

### 3. Prompt-Matched Content

LLMs get asked questions in natural language. Your content must match the phrasing of those questions — not just the keywords.

**Research approach:**
- Use "People also ask" in Google to find natural-language questions
- Use Reddit, Quora, and forums to find how your audience phrases problems
- Use Answer The Public for question mapping
- Monitor what questions Perplexity and ChatGPT are answering in your niche

**Content coverage checklist:**
- "What is [your category]?"
- "How does [your product/approach] work?"
- "Best [your category] for [specific use case]"
- "[Your product] vs [competitor]"
- "How to [achieve outcome your product enables]"

### 4. Corroborating Citations

LLMs trust information that appears across multiple authoritative sources. A claim you make alone is weak. A claim corroborated by industry reports, news, and other sites is strong.

**Build your citation network:**
- Publish original research and data (studies, surveys, benchmark reports)
- Get your data cited in industry publications
- Contribute guest articles to authoritative domains in your space
- Earn mentions in analyst reports (Gartner, Forrester, G2 reviews)
- Build case studies that other sites reference

**The corroboration flywheel:**
1. Publish original data
2. Pitch it to industry journalists
3. They cite it → you earn backlinks
4. LLMs see your data cited in multiple sources → trust increases

### 5. Structured Data (Schema Markup)

Schema markup helps AI systems understand your content's structure and context.

**Priority schemas for AI SEO:**
- `Organization` — entity definition
- `FAQPage` — explicitly marks Q&A content for AI extraction
- `HowTo` — marks step-by-step processes
- `Article` / `BlogPosting` — marks editorial content with author and date
- `Product` — if you have product pages
- `Review` / `AggregateRating` — social proof signals

### 6. llms.txt

Emerging standard (analogous to robots.txt) that tells AI crawlers what content is most important to index. Create `/llms.txt` at your domain root with:
- Brief description of your site and its purpose
- Links to your most important pages for AI context
- Links to documentation, FAQs, or knowledge base

**Format:**
```
# [Brand Name]
> [One-sentence description of what you do and who you serve]

## Important Pages
- [Page Title]: [URL] — [One-sentence description]
- ...

## Documentation
- [Doc section]: [URL]
```

### 7. AI Directory and Platform Presence

AI-powered discovery tools maintain their own indexes. Be present in:
- **Perplexity:** Ensure your site is crawlable; Perplexity cites heavily from indexed sources
- **ChatGPT with Browse:** Bing-indexed content surfaces in browsing mode
- **Product Hunt, G2, Capterra:** LLMs frequently cite these for product comparisons
- **GitHub:** If you have open-source components, README + docs are indexed
- **YouTube:** Transcripts are indexed; create educational content that answers target questions

## Content Optimization Checklist

For each page targeting AI citation:

**Structure:**
- [ ] H1 is a clear, question-shaped title or a definitive statement
- [ ] First paragraph answers the core question directly
- [ ] Subheadings are phrased as questions or clear topic signals
- [ ] Answer blocks used for each key question
- [ ] Comparison table present where alternatives exist

**Entity signals:**
- [ ] Brand name used consistently with same descriptor phrase
- [ ] Author byline present with credentials
- [ ] Publication date and last-updated date present
- [ ] Internal links to related authoritative pages
- [ ] External links to corroborating sources (not competitors)

**Technical:**
- [ ] FAQPage schema implemented
- [ ] Page loads in under 2 seconds (Core Web Vitals)
- [ ] Content accessible without JavaScript
- [ ] llms.txt references this page

## Measuring AI SEO Success

Traditional rank tracking doesn't capture AI citation. Use:

**Direct testing:**
- Prompt ChatGPT, Perplexity, Gemini, Claude with your target questions
- Track whether your brand/domain/content appears in answers
- Screenshot and date-stamp for trend tracking

**Indirect signals:**
- Branded search volume growth (people looking for you by name after discovering via AI)
- Traffic from Perplexity (appears in referral analytics)
- Increase in zero-click branded traffic

**Tools:**
- Perplexity Pages analytics (if you publish there)
- BrandMentions / Mention for tracking AI output mentions
- Manual weekly prompting and logging

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We already do SEO, so AI SEO is covered" | Traditional SEO optimizes for crawlers. AI SEO requires answer-shaped content and entity disambiguation — different skill set. |
| "LLMs don't crawl the web, so this doesn't matter" | Modern AI tools (Perplexity, Copilot, ChatGPT Browse) use RAG with live retrieval. Training data is only part of the picture. |
| "We'll wait until AI SEO standards stabilize" | Early movers in AI citation earn training data advantages that persist. Waiting means you start behind. |
| "Our content is good, it'll naturally get cited" | Structured answer blocks and schema markup significantly increase citation probability. Quality alone is not enough. |
| "We can't measure it, so it's not worth the effort" | Direct prompting tests give measurable results. Branded search growth is a reliable proxy signal. |

## Verification

- [ ] Entity disambiguation complete (Knowledge Panel, Crunchbase, LinkedIn all consistent)
- [ ] llms.txt created and published at domain root
- [ ] Priority pages rewritten with answer-block format
- [ ] FAQPage schema implemented on key pages
- [ ] Original research or data published and pitched for citations
- [ ] AI citation baseline established (manual prompting test with screenshots)
- [ ] Weekly prompting test scheduled to track citation changes
