---
name: social-content
description: Social content expertise — platform-specific constraints, 30-day content calendar, hook formulas, content pillar ratios for Twitter/X, LinkedIn, Instagram, TikTok/Reels adapted to brand voice
allowed-tools: Read
---

# Social Content Skill

Expertise in building social content that grows audiences and converts them — not content that fills a calendar. The difference: every post has a job (educate, prove, humanize, convert). Content without a job is noise.

## How to Use This Skill

1. Read `platforms.yaml` for character limits and posting constraints — hard limits
2. Pick content pillars from the ratio table to build a balanced 30-day calendar
3. Apply hook formulas from `platforms.yaml` to first line of every post
4. Adapt brand voice from `.marketing/brand.md` if available

## Platform Selection by Audience

Not all platforms are worth the effort. From `platforms.yaml`:

- **Twitter/X**: founder voice, real-time commentary, B2B thought leadership. Threads > single tweets for reach. 1-2 hashtags max.
- **LinkedIn**: B2B sales, hiring, investor visibility. The algorithm rewards dwell time — posts that make people stop and read. 210 chars above fold before "see more" — that's your hook.
- **Instagram**: visual products, lifestyle brands, B2C. Reels > static for reach. Hook in 3 seconds.
- **TikTok/Reels**: educational entertainment. Hook in 3 seconds. 60 seconds ideal length. Authentic beats produced.

If the target audience is B2B: LinkedIn + Twitter/X. If B2C: Instagram + TikTok/Reels. Don't spread across all four without a full content team.

## Content Pillar Ratios

From `platforms.yaml` content_pillars. The ratios prevent three failure modes:
- Over-promoting (audience disengages): keep promotion <= 10%
- Under-converting (lots of engagement, no revenue): ensure 10% direct promo exists
- Too polished (low algorithmic reach): culture content humanizes and boosts engagement

Build the 30-day calendar by slot: 12 education, 6 proof, 6 culture, 3 engagement, 3 promotion.

## Hook Writing

Every post lives or dies on its first line. From `hook_formulas` in `platforms.yaml`:

- **Curiosity**: hides the answer just enough to force the click
- **List**: promises specific, scannable value
- **Contrarian**: pattern-interrupts the scroll — requires confidence to back up
- **Story**: "I [did thing]" — first-person narrative earns attention because brains are wired for story
- **Question**: only works if the reader has already asked themselves that question

Never start a post with "In today's post..." or "I wanted to share...". These are visibility death.

## Brand Voice on Social

Social is where brand voice is most visible. From `.marketing/brand.md` tone axes:
- `formal_casual >= 4`: use contractions, short sentences, conversational asides
- `conservative_bold >= 4`: use the contrarian hook formula freely, take positions
- `rational_emotional >= 4`: lead with a story or person, not a stat

## Output Format

Produces `.marketing/social.md` with:
- 30-day content calendar (date, platform, pillar, hook, post body, CTA if any)
- Platform-specific versions where format differs significantly
- Hashtag sets per platform

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We post when we have something to say" | Algorithms reward consistency. Irregular posting gets deprioritized. A content calendar exists so you always have something to say. |
| "Our content gets engagement but no sales" | Engagement without conversion means missing the 10% promotion pillar. Add it. |
| "LinkedIn is too formal for our brand" | LinkedIn rewards authentic > formal. The most viral LinkedIn content reads like a personal story, not a press release. |
| "We need better design before we post" | Text posts on LinkedIn outperform graphics. Words > design on most platforms for B2B. |
