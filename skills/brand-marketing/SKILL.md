---
name: brand-marketing
description: Brand marketing expertise — brand voice, identity system, domain authority benchmarking, backlink gap analysis, citation building, brand consistency auditing backed by Ahrefs data
allowed-tools: Read, Grep, Glob, Write, WebSearch, WebFetch, "mcp__claude_ai_aHref__*"
model: sonnet
---

# Brand Marketing Skill

Expertise in building brand authority and recognition — grounded in real domain rating data, backlink gap analysis, and brand voice consistency, all backed by Ahrefs.

## Domain Authority Benchmarking

### Pull Competitor DR via Ahrefs
Use `site-explorer-domain-rating` to benchmark:
- Your DR vs top 5 competitors
- DR trajectory over 12 months (`site-explorer-domain-rating-history`)
- Gap between you and the market leader

DR < competitor by 10+: backlink acquisition is your #1 brand priority.
DR within 5: content quality and citation strategy matters more.

### What DR Actually Measures
DR = aggregate backlink quality. It predicts:
- How quickly Google trusts new content you publish
- How well product launches rank from day one
- How much authority flows through internal links

## Backlink Gap Analysis

### Finding Your Targets
1. Pull referring domains for target domain: `site-explorer-referring-domains`
2. Pull referring domains for top 3 competitors
3. Find high-DR domains linking to 2+ competitors but not to you → priority outreach list

### Backlink Quality Tiers
| Tier | DR Range | Strategy |
|------|----------|----------|
| 1 | 80+ | Editorial — earn via data studies, tools, press |
| 2 | 50-79 | Partnerships — guest posts, integrations, co-marketing |
| 3 | 30-49 | Directories — industry listings, review sites, communities |
| 4 | <30 | Low priority unless niche relevance is very high |

### Citation Opportunities
Pull `site-explorer-all-backlinks` for a competitor with high DR. Filter for:
- Domain type: directories, media, communities
- Anchor text: brand name (these are citation patterns, not SEO links)

Submit to all directories where competitors appear but you don't.

## Brand Voice System

### Personality Sliders
Rate 1-5 on each axis (1=left, 5=right):
- Formal ←→ Casual
- Serious ←→ Playful
- Technical ←→ Accessible
- Bold ←→ Understated
- Traditional ←→ Innovative

### Vocabulary Guide
| Use | Avoid |
|-----|-------|
| [positive vocabulary] | [negative vocabulary] |
| Active voice | Passive voice |
| Specific numbers | Vague qualifiers ("many", "some") |
| Outcome-first sentences | Feature-first sentences |

### Voice in Practice
- **Headlines**: [tone + formula]
- **Error messages**: [tone — users are frustrated, be human]
- **Success states**: [tone — celebrate without being annoying]
- **Support copy**: [tone — empathetic, not corporate]

## Brand Consistency Audit

### What to Scan
1. All `.md` files in project — does copy match voice guide?
2. `README.md`, `CLAUDE.md` — do they represent the brand accurately?
3. Landing page copy, email templates, social bios

### Red Flags
- Inconsistent product name casing
- Mixed formality levels in the same surface
- Passive voice in CTAs
- Generic claims without proof ("best", "leading", "innovative")

## Building Brand in AI Systems

AI models (ChatGPT, Perplexity, Gemini) form brand impressions from:
1. Consistent entity markup across web properties
2. High citation volume in authoritative sources
3. Clear, unambiguous product descriptions in structured data

Brand authority and AI citations are now the same problem.

## Output Format

Produces `.marketing/brand.md` with:
- DR benchmark table (you vs. top 5 competitors)
- Backlink gap: top 20 outreach targets (domain, DR, why they link to competitors)
- Brand voice guide (personality sliders + vocabulary)
- Citation gap list (directories/media where competitors appear, you don't)
- Consistency audit findings

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "Brand is just our logo" | Brand is what people say about you when you're not in the room. DR is the measurable proxy. |
| "We'll build links later" | DR compounds. A 6-month head start is very hard to close. |
| "Our voice is obvious" | Every team member has a different mental model. Write it down or it doesn't exist. |
| "Brand takes years to build" | A focused backlink + citation campaign can move DR 10-15 points in 90 days. |
