---
name: page-cro
description: Use when the user wants to optimize, improve, or increase conversions on any marketing page — including homepage, landing pages, pricing pages, feature pages, or blog posts. Also use when the user mentions 'CRO,' 'conversion rate,' 'page optimization,' 'why are people not converting,' or 'improve my landing page.'
---

# Page Conversion Rate Optimization (CRO)

Expert knowledge for diagnosing, testing, and improving conversion rates across marketing pages.

## CRO Mindset

CRO is not about making pages prettier. It's about removing the reasons people don't convert.

Every visitor who doesn't convert has a reason. Your job is to find the most common reasons and fix them. Start with research, not redesign.

## Conversion Research Stack

Before changing anything, understand why people aren't converting.

### Quantitative Research (What is happening)
- **GA4:** Funnel visualization, scroll depth, device breakdown, traffic source by conversion rate
- **Heatmaps:** Click maps (what do people click?), scroll maps (how far do people scroll?)
- **Session recordings:** Watch real users navigate — Hotjar, FullStory, Microsoft Clarity (free)

### Qualitative Research (Why it's happening)
- **On-page surveys:** "What stopped you from signing up today?" (Hotjar, Qualaroo)
- **Exit intent surveys:** Ask visitors who are leaving why
- **User testing:** 5 users completing a task reveals ~80% of usability issues
- **Customer interviews:** Ask recent signups what almost stopped them

Research before hypothesis. Every optimization hypothesis should trace to a research finding.

## Above-the-Fold Optimization

The first screen determines whether visitors scroll. It must communicate:

1. **What you do** (in one sentence — no jargon)
2. **Who it's for** (your ICP, named explicitly)
3. **Why it matters** (the key outcome or transformation)
4. **What to do next** (one clear CTA)

**Hero copy formula:**
```
H1: [Specific outcome] for [ICP]
Subheadline: [How you deliver it] — [key differentiator or proof point]
CTA: [Specific action] — [friction reducer]
```

**Hero image/video checklist:**
- [ ] Shows the product in use (not abstract illustration)
- [ ] Human element when relevant (faces increase trust)
- [ ] Fast-loading (< 200kb for images)
- [ ] Not a stock photo of hands on laptops

**5-second test:** Show your above-the-fold to someone unfamiliar with your product for 5 seconds. Ask: "What does this company do? Who is it for?" If they can't answer, rewrite.

## Value Proposition Clarity

The value prop is the single most important element on any page.

**Testing your value prop:**
Ask three questions about your current headline:
1. Is it specific? ("Save 3 hours/week" beats "Save time")
2. Is it unique? (Could a competitor say the same thing?)
3. Is it relevant? (Does your ICP immediately recognize their situation?)

**Value prop testing matrix:**

| Angle | Example |
|---|---|
| Outcome | "Cut reporting time by 80%" |
| For ICP | "For ops teams that live in spreadsheets" |
| How you're different | "The only [category] that [unique approach]" |
| Problem statement | "Stop [painful thing] — finally" |
| Social proof | "How 500 teams replaced [competitor]" |

## Trust Signals

Trust is built in layers. Each element adds confidence. Missing elements create doubt.

### Trust Signal Checklist by Position

**Above the fold:**
- [ ] Logo (professional, current)
- [ ] Customer logos (recognizable brands in your market)
- [ ] Review rating (G2, Capterra stars with count)
- [ ] User count ("trusted by X teams")

**Mid-page:**
- [ ] Testimonials (specific outcome + full name + company + photo)
- [ ] Case study snippets (before/after with numbers)
- [ ] Named feature screenshots with real product UI

**Near CTA:**
- [ ] Security badges if handling sensitive data
- [ ] Money-back guarantee or risk reversal
- [ ] "No credit card required" if free trial
- [ ] Privacy signal ("We don't sell your data")

**Footer:**
- [ ] Contact information (real address, phone)
- [ ] Security/compliance certifications (SOC2, HIPAA, GDPR)
- [ ] Press mentions

## Friction Removal

Every step in your conversion path that requires effort is friction. Map and reduce it.

**Friction audit:**
1. Map every action required to convert (clicks, scrolls, form fields, decisions)
2. For each action: Is it necessary? Can it be eliminated? Can it be deferred?
3. Eliminate every unnecessary step

**High-friction elements to fix:**

| Friction | Fix |
|---|---|
| Long signup form | Reduce to email only; collect more after activation |
| Email verification before product access | Move email verification after first use |
| Credit card required for free trial | Remove if your business model allows |
| Complex pricing page | Add a recommendation ("Most teams choose X") |
| Navigation with too many options | Reduce nav on landing pages; focus on one path |
| Pop-up on entry | Delay to exit intent or after 60 seconds |

## CTA Optimization

**CTA placement rules:**
- Primary CTA visible without scrolling on desktop and mobile
- Repeat CTA every 2-3 scrolls on long pages
- Final CTA at bottom of page

**CTA copy rules:**
- Start with a verb ("Start," "Get," "Try," "See," "Book")
- Be specific about what happens next ("Start free 14-day trial")
- Add a friction reducer immediately below ("No credit card required")

**CTA design rules:**
- High contrast against background
- Large enough to tap easily on mobile (44px minimum touch target)
- One primary CTA per section (secondary CTAs must be visually subdominant)

## Social Proof Types and Placement

| Position | Best proof type |
|---|---|
| Hero section | Customer count, logo bar, review rating |
| Problem section | Quote acknowledging the pain |
| Solution section | Before/after comparison, feature-specific testimonial |
| Objection section | Trust-specific quote ("We were worried about security...") |
| CTA section | Short, outcome-specific quote with name and photo |

**Testimonial quality filter:**

Poor: "Great product. Highly recommend." (No specifics, no outcome)

Good: "We reduced onboarding time from 6 hours to 45 minutes. Our CSM team now handles 3× more accounts." — [Name, Title, Company]

## Pricing Page Optimization

- [ ] Clear tier names (outcome-oriented, not just Basic/Pro/Enterprise)
- [ ] Recommended plan highlighted (increases average order value)
- [ ] Annual/monthly toggle with annual discount shown
- [ ] FAQ section addressing pricing objections
- [ ] Enterprise CTA ("Need custom pricing? Talk to us")

**Anchoring on pricing page:**
- Show the highest tier first (left to right or top to bottom)
- Or: highlight the middle/recommended tier prominently

## Mobile CRO

Mobile visitors convert at ~50% the rate of desktop visitors for most B2B products.

**Mobile audit:**
- [ ] Hero above-fold visible without scrolling on iPhone SE
- [ ] CTA button thumb-reachable (bottom 1/3 of screen)
- [ ] Form fields large enough to tap accurately
- [ ] No horizontal scrolling
- [ ] Images optimized (< 150kb WebP)
- [ ] No hover-dependent interactions

## Heatmap Interpretation

**Click maps — what to look for:**
- People clicking on non-clickable elements → make them clickable or remove the expectation
- Low clicks on CTA → visibility, copy, or placement problem

**Scroll maps — what to look for:**
- Less than 50% scroll to important content → move it up or cut the preceding content
- People scrolling past CTAs → add more CTA repetitions

**Session recordings — what to look for:**
- Rage clicks (repeated clicking) → broken element or unclear affordance
- U-turns (scroll down, then back up) → looking for something they couldn't find
- Form abandonment at specific field → that field is asking for something users won't give

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We need a full redesign to fix conversions" | Most conversion lifts come from copy changes and friction removal, not redesigns. Research first. |
| "Our industry has naturally low conversion rates" | Industry benchmarks explain your current rate, not your ceiling. CRO finds your ceiling. |
| "More features on the page means more reasons to convert" | More choices create decision paralysis. Focus on one primary message per page. |
| "The design looks great — that should help conversions" | Aesthetics affect trust, not clarity. A beautiful page with a confusing value prop still doesn't convert. |

## Verification

- [ ] Qualitative research conducted before hypotheses formed (surveys, recordings, or interviews)
- [ ] Value prop tested with 5-second test on unfamiliar observer
- [ ] Trust signal checklist completed for above-fold, mid-page, and near CTA
- [ ] Friction audit completed: every conversion step mapped and unnecessary steps removed
- [ ] CTA visible above fold on mobile and desktop
- [ ] A/B test sized correctly (sample size calculated before running)
- [ ] Heatmap and session recording review completed for pages being optimized
