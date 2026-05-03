---
name: product-marketing
description: Product marketing expertise — ICP definition, positioning, competitive narrative, GTM strategy, messaging hierarchy, launch playbooks backed by real keyword and competitor data
allowed-tools: Read, Grep, Glob, Write, WebSearch, WebFetch, "mcp__claude_ai_aHref__*"
model: opus
---

# Product Marketing Skill

Expertise in positioning, messaging, GTM, and competitive intelligence — grounded in actual search demand and organic competitor data via Ahrefs.

## ICP Definition Framework

### Jobs-to-be-Done (JTBD)
- **Functional job**: What task does the user hire your product to do?
- **Emotional job**: How do they want to feel during/after?
- **Social job**: How do they want to be seen by others?

### ICP Scoring Matrix
| Dimension | Weight | Questions to Answer |
|-----------|--------|-------------------|
| Pain intensity | 40% | How often does this problem occur? What does it cost them? |
| Ability to buy | 30% | Budget authority, decision cycle, team size |
| Product fit | 20% | How much of the product do they actually use? |
| Expansion potential | 10% | Will they grow? Will they refer? |

### 5 Whys on Churn
Dig into why users leave — each "why" reveals the real ICP boundary. Stop at the why that reveals a category of person, not a feature gap.

## Competitive Positioning

### Data-Driven Positioning via Ahrefs
1. Pull organic competitors: `site-explorer-organic-competitors` for target domain
2. Map competitor keyword clusters — what intent categories do they own?
3. Find blind spots: keywords competitors rank for that have high volume but low competition
4. Position against blind spots, not against their strengths

### Positioning Canvas
```
For [ICP],
who [problem statement],
[Product name] is a [category]
that [unique value].
Unlike [competitor],
we [key differentiator backed by data].
```

### Keyword Intent Mapping
| Intent | Stage | Content Type | Example Keywords |
|--------|-------|-------------|-----------------|
| Informational | Awareness | Blog, guide | "how to [problem]" |
| Navigational | Consideration | Landing page | "[competitor] alternative" |
| Commercial | Decision | Comparison | "[product] vs [competitor]" |
| Transactional | Conversion | Pricing, demo | "[product] pricing" |

Pull search volumes from Ahrefs `keywords-explorer-overview` to validate which intents have real demand.

## Messaging Hierarchy

### Three-Layer Stack
1. **Headline** (7 words max) — The outcome, not the feature
2. **Subheadline** (1-2 sentences) — Who it's for + the key mechanism
3. **Proof points** (3 bullets) — Specific, measurable, credible

### SERP-Matched Messaging
Pull top-ranking pages for your target keywords via Ahrefs `serp-overview`. Extract:
- What headline patterns rank best?
- What proof points appear in meta descriptions?
- What objections do featured snippets address?

Match your messaging to what SERP data proves buyers respond to.

## GTM Strategy

### Channel Selection Framework
Use Ahrefs data to prioritize channels:
- **Organic search**: keyword difficulty vs. volume ratio → content investment
- **Competitive gap**: keywords competitors rank for that you can beat → quick wins
- **Paid potential**: high CPC keywords → validates willingness to pay
- **Referral**: high-DR sites linking to competitors → outreach targets

### Launch Sequencing
1. Pre-launch (T-30): Seed content for target keywords, build backlinks to launch page
2. Launch (T-0): Press, social proof push, email to list
3. Post-launch (T+7): Double down on what's converting, kill what isn't

## Output Format

Produces `.marketing/product.md` with:
- ICP definition (scored matrix)
- Positioning canvas (filled)
- Messaging hierarchy (3 layers)
- Top 10 keyword opportunities ranked by difficulty/volume ratio
- GTM channel priority stack
- 30-day content calendar tied to keyword windows

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We know our ICP" | Assumptions rot. Pull Ahrefs data to validate what they actually search for. |
| "Our product speaks for itself" | Every competitor says that. Positioning only works in contrast. |
| "We'll do SEO later" | Keyword demand informs what messaging resonates — not just traffic. |
| "The launch is the strategy" | Launch is one event. The flywheel is the strategy. |
