---
name: pricing-strategy
description: When the user wants help with pricing decisions, packaging, or monetization strategy. Also use when the user mentions 'pricing,' 'pricing tiers,' 'freemium,' 'free trial,' 'packaging,' or 'willingness to pay.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Pricing Strategy

Expert knowledge for designing, validating, and optimizing SaaS pricing and packaging.

## Pricing Philosophy

Pricing is the single highest-leverage lever in your business. A 1% improvement in pricing yields more profit improvement than a 1% improvement in volume, variable cost, or fixed cost. Most companies undercharge because they price based on cost or competitor reference rather than value delivered.

## Pricing Approaches

### Cost-Plus Pricing (Avoid for SaaS)
Price = Cost + Margin. Ignores value delivered. Sets a ceiling, not a floor. Only appropriate for commodities.

### Competitor-Based Pricing (Use Cautiously)
Price near or at competitors. Safe but leaves money on the table and positions you as a commodity. Use only as a sanity check, not a primary method.

### Value-Based Pricing (Recommended)
Price = a fraction of the value you deliver to the customer. Requires understanding customer ROI.

**Value-based pricing formula:**
```
Customer Value = (Outcome gained) + (Cost saved) + (Risk reduced)
Your Price = Customer Value × Your Capture Rate (typically 10-30%)
```

**Example:**
- Your tool saves a marketing team 10 hours/week
- That team member costs $75/hour fully loaded
- Annual value = 10h × $75 × 52 weeks = $39,000
- At 20% capture rate: $7,800/year = $650/month

If you're charging $99/month, you're leaving significant value on the table.

## Willingness-to-Pay Research

Before setting prices, research what customers will actually pay.

**Methods:**

**Van Westendorp Price Sensitivity Meter (4 questions):**
1. "At what price would this be so cheap you question the quality?"
2. "At what price would this be a bargain?"
3. "At what price would this be getting expensive, but you'd still consider it?"
4. "At what price would this be too expensive?"

Plot responses to find the "acceptable price range" (between cheap-quality concern and too-expensive).

**Gabor-Granger Method:**
Ask a sample "Would you buy at $X?" for a range of prices. Find the price that maximizes revenue (conversion rate × price).

**Competitor reference:**
Where do prospects anchor expectations? What do they currently pay for solving this problem (including manual work, alternative tools, consultants)?

## Tier Design: Good / Better / Best

Three tiers is the SaaS standard. Each tier must be designed for a different buyer.

**Tier structure principles:**

| Tier | Target buyer | Goal |
|---|---|---|
| Basic/Starter | Price-sensitive, small teams | Land; acquire customers who'll grow |
| Pro/Growth | Primary buyer — your ICP | Volume driver; where most revenue comes from |
| Enterprise/Scale | Large teams, custom needs | High ACV; top 20% of revenue |

**Packaging rules:**
- Each tier should be a natural upgrade from the tier below
- The upgrade trigger should be predictable (usage limit, team size, feature need)
- Do not put your most valuable features exclusively in Enterprise unless you want to push all buyers there

**Feature allocation across tiers:**

| Feature Type | Allocation |
|---|---|
| Core value prop | Available in Starter (if freemium/PLG) or Pro |
| Collaboration / team features | Pro and above |
| Advanced analytics / reporting | Pro or Enterprise |
| Admin controls / SSO / SAML | Enterprise |
| API access | Pro or Enterprise |
| Priority support / SLA | Enterprise |
| White-labeling | Enterprise |

## Freemium vs Free Trial

Both can work. Choosing wrong is costly.

**Freemium works when:**
- The product delivers value to a solo user
- Usage by free users creates value for paid users (network effects, collaboration)
- You have high traffic and can afford conversion rates of 1-5%
- You want the free user as a distribution channel (they share the product)

**Freemium risks:**
- Free users create real infrastructure costs
- Free tier cannibalizes paid if the limits are poorly set
- Converting free-to-paid requires a long game (months, not weeks)

**Free trial works when:**
- Product value requires team adoption or integration to see
- Your sales cycle is short enough (< 30 days) for urgency
- You want all users to experience full value then make a buy/don't-buy decision

**Trial design options:**
- **Time-limited, full access:** 14-day trial (industry standard); 7 days if high velocity, 30 days if complex
- **Usage-limited, unlimited time:** Freemium with caps on usage (actions, projects, seats)
- **Reverse trial:** Start all users on free trial of the top tier; downgrade to free tier at trial end

**Reverse trial recommendation:** If you have a freemium product, run a 14-day reverse trial of the Pro tier before defaulting to the free tier. Conversion rates improve 10-25%.

## Pricing Page Optimization

**Recommended plan highlight:**
Always visually highlight one plan as "Most Popular" or "Recommended." This anchors the buyer's decision and increases revenue by guiding selection toward your target tier.

**Annual vs monthly pricing:**
- Offer annual at 15-25% discount (2 free months is the most common positioning)
- Default to annual billing in your pricing page toggle (if you can get away with it)
- Enterprise always negotiates annual; build it into your model

**Price display:**
- Show monthly price even for annual plans ("$79/month, billed annually at $948")
- Hide the math (don't show $948 first if you can show $79/mo first)
- Show per-seat pricing clearly if seat-based

**Anchor pricing:**
- Show highest tier first (left to right) so it anchors perception
- Or: highlight the middle tier prominently to make it look like the value choice

## Pricing Increase Strategy

Most SaaS companies should be raising prices annually. Here's how to do it well:

**Grandfather existing customers:** Keep them at current price for 6-12 months, then migrate with notice.

**Price increase communication:**
1. Notify 60-90 days in advance (enterprise)
2. Lead with the value you've added since they signed up
3. Offer a way to lock in current pricing (annual plan)
4. Be specific: "Effective [date], your plan will change from $X to $Y"

**Price increase messaging formula:**
"Since you joined, we've added [specific feature list]. To support continued investment, we're updating pricing on [date]. As a valued customer, you can lock in your current rate by switching to annual."

**How much to raise:**
- 10-20% annual increases are well-tolerated if backed by value delivery
- Research shows 5-7% annual increases produce almost zero churn
- If you haven't raised prices in 2+ years, a larger step-up (20-30%) is often appropriate

## Enterprise Pricing

Enterprise pricing is different from self-serve pricing.

**Enterprise pricing levers:**
- Seat count (per-seat)
- Usage (API calls, records, projects)
- Value metrics (revenue processed, contacts, properties managed)
- Flat annual fee (predictable, preferred by finance teams)

**Enterprise negotiation considerations:**
- Build in multi-year discounts (3-year deal → 15-20% off)
- Use list price as anchor; expect 20-30% discount in negotiation
- Add professional services / implementation fees as separate line items
- Include expansion pricing (what does 2× usage cost?)

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We need to charge less than competitors to win" | You need to win on value, not price. Price competition destroys margins and attracts price-sensitive churners. |
| "We're not sure what to charge — let's start low and raise later" | Starting low is easy; raising prices is hard. Underpricing trains customers to expect cheap. Price at the high end of your range and discount down. |
| "Freemium will drive viral growth" | Freemium drives free users. Free users are only valuable if they convert or create network effects. Do the math before committing. |
| "Our product is too simple to charge a lot" | Simplicity has value. If you solve a $50K problem elegantly, your price should reflect the outcome, not the code complexity. |
| "Enterprise needs custom pricing — let's not publish prices" | Hidden pricing increases friction for SMB and mid-market. Publish at least the SMB tiers; gate Enterprise with a "contact us." |

## Verification

- [ ] Value-based pricing analysis completed (customer value calculated, capture rate set)
- [ ] Willingness-to-pay research conducted (Van Westendorp or Gabor-Granger)
- [ ] Three tiers designed with distinct target buyer and upgrade trigger for each
- [ ] Freemium vs free trial decision made with explicit rationale
- [ ] Pricing page shows recommended plan highlight
- [ ] Annual plan available with 15-25% discount
- [ ] Price increase schedule defined (annual review cadence)
- [ ] Enterprise pricing levers documented (seat count, usage, flat fee decision)
