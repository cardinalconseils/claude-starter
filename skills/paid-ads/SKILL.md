---
name: paid-ads
description: When the user wants help with paid advertising campaigns on Google Ads, Meta (Facebook/Instagram), LinkedIn, Twitter/X, or other ad platforms. Also use when the user mentions 'PPC,' 'paid social,' 'SEM,' 'paid media,' 'Google Ads,' or 'Facebook Ads.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Paid Advertising

Expert knowledge for planning, launching, and optimizing paid advertising campaigns across Google, Meta, LinkedIn, and other platforms.

## Core Framework: Paid Ads Hierarchy

```
1. Goal Definition → 2. Audience → 3. Offer & Creative → 4. Campaign Structure → 5. Bid Strategy → 6. Measurement → 7. Optimization
```

Never start with campaign structure. Start with goal and audience.

## Goal Definition

Define the goal before opening an ad platform.

| Goal | Primary Metric | Platform Fit |
|---|---|---|
| Lead generation (B2B) | Cost per lead (CPL), MQL rate | Google Search, LinkedIn |
| Free trial signups | Cost per activation, CAC | Google Search, Meta |
| Brand awareness | CPM, reach, frequency | Meta, YouTube, LinkedIn |
| Retargeting / nurture | Cost per engagement, pipeline influence | Meta, Google Display, LinkedIn |
| E-commerce sales | ROAS, revenue | Meta Shopping, Google Shopping |

**ROAS target formula:**
```
Minimum ROAS = (Revenue / Ad Spend)
Target ROAS = 1 / (Ad Spend as % of Revenue target)
```

For SaaS: track CAC against LTV. If LTV:CAC > 3:1, the channel is viable. If < 3:1, fix first.

## Google Ads

### Campaign Types

| Type | Use For |
|---|---|
| Search | Bottom-of-funnel, high-intent buyers |
| Display | Retargeting, awareness |
| Performance Max | Google-automated cross-channel (use with caution) |
| YouTube | Video awareness and consideration |
| Demand Gen | Social-like inventory via Google network |

### Search Campaign Structure

**Account hierarchy:**
```
Account
└── Campaign (one per product line or goal)
    └── Ad Group (one per theme / intent cluster)
        └── Keywords (3-15 per ad group)
        └── Responsive Search Ads (3 per ad group)
```

**Match type strategy:**
- **Exact [keyword]:** Only your exact term. Highest precision, lowest volume.
- **Phrase "keyword":** Your term in order with words before/after. Balance of precision and reach.
- **Broad keyword:** Google interprets widely. Use only with smart bidding and good negative keyword lists.

**Recommended starting approach:**
- Launch with phrase and exact match
- Add broad match only after phrase match proves ROI and you have 500+ conversions for smart bidding

**Negative keywords:**
- Always build a negative keyword list before launch
- Common negatives: "free," "jobs," "salary," "DIY," competitor brand names you don't want to target
- Review Search Terms report weekly for new negatives

### Quality Score

Quality Score (1-10) determines your ad rank and cost per click.

**Components:**
- Expected CTR (does your ad get clicked relative to competitors?)
- Ad relevance (does your ad match the keyword?)
- Landing page experience (does your landing page match the ad and keyword?)

**Improving Quality Score:**
- Tight ad groups (one theme, 5-10 keywords)
- Ad copy that includes the keyword naturally
- Landing pages that match the ad's promise and keyword

### Bidding Strategy

| Strategy | Use When |
|---|---|
| Manual CPC | Low conversion volume, tight control needed |
| Enhanced CPC | Transition from manual to smart bidding |
| Target CPA | Have 50+ conversions/month, stable CPA goal |
| Target ROAS | E-commerce with revenue data, 100+ conversions/month |
| Maximize Conversions | Launching a new campaign, want volume over efficiency |

**Smart bidding requires data.** Don't use Target CPA until you have 30-50 conversions in the past 30 days.

## Meta (Facebook / Instagram) Ads

### Campaign Structure

**Three levels:**
1. **Campaign:** Objective (Conversions, Traffic, Awareness, Lead Gen)
2. **Ad Set:** Audience, placement, budget, schedule
3. **Ad:** Creative (image, video, carousel, collection)

### Audience Strategy

**Cold audiences (prospecting):**
- Lookalike audiences (from customer list, purchase events, or high-value website visitors)
- Interest targeting (use as supplement, not primary — limited for B2B)
- Broad targeting + creative testing (let the algorithm find your audience)

**Warm audiences (retargeting):**
- Website visitors (last 30, 60, 180 days)
- Video viewers (watched 25%, 50%, 75% of your content)
- Lead form engagers
- Customer list for exclusion or upsell

**Audience sizing for testing:**
- Too small (< 100K): Limited optimization data
- Too large (> 5M): Lacks precision without good creative signal
- Sweet spot: 500K–3M for most B2B markets

### Budget Allocation by Funnel Stage

| Funnel Stage | Budget % | Goal |
|---|---|---|
| Cold (prospecting) | 60-70% | Find new buyers |
| Warm (retargeting) | 20-30% | Convert interested visitors |
| Existing customer | 10% | Upsell / prevent churn |

### Attribution Model

Meta's default attribution window: 7-day click, 1-day view.

For B2B with longer buying cycles:
- Use 7-day click only (removes view-through inflation)
- Supplement with Conversions API (server-side) for accuracy
- Compare to actual CRM data quarterly — Meta often over-attributes

## LinkedIn Ads

### When to Use LinkedIn

LinkedIn is expensive (CPCs of $8-15 for most B2B) but offers unique targeting capabilities:
- Job title and seniority
- Company size and industry
- Skills and interests
- Group membership

**Use LinkedIn when:**
- ICP is enterprise decision-makers
- Targeting is difficult on other platforms (niche job titles)
- Account-based marketing (targeting specific company lists)

### Campaign Types

| Type | Best Use |
|---|---|
| Sponsored Content | Feed ads, document ads, video ads |
| Lead Gen Forms | Lower-friction lead capture (pre-filled from LinkedIn profile) |
| Conversation Ads | Direct message format (limited now) |
| Dynamic Ads | Personalized follower and spotlight ads |

### LinkedIn Lead Gen Forms

LinkedIn Lead Gen Forms pre-populate from the user's LinkedIn profile. This dramatically reduces friction and can increase conversion rates 2-5× vs landing page traffic.

**Best practice:**
- Keep form to 3-4 fields maximum
- Offer something specific in exchange (report, checklist, demo)
- Follow up within 1 hour for highest contact rates

## Bid Strategy by Platform & Stage

| Stage | Google | Meta | LinkedIn |
|---|---|---|---|
| Launch | Maximize Conversions | Lowest Cost | Manual CPC |
| Scaling | Target CPA | Cost Cap | Target Cost |
| Mature | Target ROAS | ROAS bid | Maximize Conversions |

## Budget Allocation Across Funnel

**Full-funnel budget split:**
- Search (bottom-funnel, high intent): 40-50% of search budget
- Display / retargeting: 20-30%
- Social prospecting: 30-40%
- Brand campaigns: 10-15%

**Starting budget guidance:**
- Need minimum 10 conversions/week per campaign for smart bidding to work
- If you have < $5K/month, focus on one campaign/channel
- Spread budget across too many campaigns = none have enough data to optimize

## Attribution Models

**Last-click:** All credit to the last touchpoint before conversion. Undervalues top-of-funnel channels.

**Data-driven:** Google distributes credit based on observed path patterns. Requires enough conversion data.

**First-click:** All credit to first touchpoint. Overvalues awareness channels.

**Linear:** Equal credit across all touchpoints. Safe default when you can't run data-driven.

**For B2B recommendation:** Use data-driven if you have > 300 conversions/month; otherwise linear. Track time-to-conversion to understand multi-touch reality.

## ROAS and CAC Calculation

```
CAC = Total Ad Spend / Number of New Customers Acquired
ROAS = Revenue from Ads / Ad Spend
Payback Period = CAC / (MRR × Gross Margin)
```

**SaaS benchmarks:**
- Target CAC payback period: < 12 months for self-serve, < 18 months for enterprise
- LTV:CAC: > 3:1 for a healthy paid channel
- ROAS: Varies widely; most SaaS need > 3:1 to be viable

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "More campaigns = better coverage" | More campaigns means less data per campaign. Smart bidding needs concentration. |
| "We should test every audience and creative at once" | Scattered tests produce uninterpretable results. Test one dimension at a time. |
| "Our click-through rate is high — the campaign is working" | CTR is a vanity metric without conversion data. Track cost per qualified lead. |
| "We'll set it and forget it once it's running" | Paid ads require weekly optimization. Ignore them and waste compounds. |
| "LinkedIn is too expensive for our budget" | LinkedIn is only too expensive if LTV doesn't support the CAC. If it does, CPCs are irrelevant. |

## Verification

- [ ] Campaign goal defined with primary metric and target (e.g., CPL < $150)
- [ ] Audience defined before campaign built (targeting specs written before platform opened)
- [ ] Negative keyword list built for Google Search campaigns
- [ ] Budget allocated across funnel stages (not all in one campaign)
- [ ] Conversion tracking verified (test conversions firing before going live)
- [ ] Attribution model selected and documented
- [ ] Weekly optimization checklist defined (what to review, when)
- [ ] LTV:CAC target set for channel viability assessment
