---
name: analytics-tracking
description: Analytics tracking expertise — GA4 event taxonomy, GTM setup, ad pixel configuration (Meta/Google/TikTok), UTM parameter strategy, tracking gap audit for web and SaaS products
allowed-tools: Read, Bash, Glob, Grep
---

# Analytics Tracking Skill

Expertise in instrumentation that connects user behavior to business outcomes. Bad tracking is noise. Good tracking answers: where do users drop off, which channels actually convert, and what does activation look like before churn?

## How to Use This Skill

1. Read `events.yaml` for the event taxonomy — these are the events that matter across any web/SaaS product
2. Read `pixels.yaml` for platform-specific setup requirements and when to add each pixel
3. Read `workflows/tracking-architecture.dot` to understand the GTM-centric data flow
4. Scan codebase for existing tracking calls before proposing new events

## Event Priority by Business Stage

Not all events are worth instrumenting immediately.

**Prototype**: Instrument `sign_up`, `page_view`, and one activation event specific to the product. Everything else is noise until the core loop is validated.

**Pilot**: Add `feature_used` for each key feature and `upgrade_intent`. These two events tell you whether users understand the product and whether they're hitting the paywall at the right moment.

**Candidate**: Full taxonomy from `events.yaml`. Add `churn_signal` — 90-day retention hinges on catching users before they cancel, not after.

**Production**: Add server-side events for purchase confirmation (prevents ad platform under-reporting due to browser blocking).

## GTM vs Direct Implementation

GTM (Google Tag Manager) is worth the setup cost as soon as you have 2+ tracking destinations — from `pixels.yaml`. Without GTM: every new pixel means a code deploy. With GTM: new pixel = 10-minute GTM configuration, no code change.

Install GTM first, route all events through the dataLayer, then add destinations in the GTM UI.

## Attribution Model Guidance

- **Last-click**: easiest to set up, undervalues top-of-funnel content. Use at Prototype stage.
- **Data-driven (GA4 default)**: requires 400+ conversions/30 days to activate. Use at Candidate+.
- **First-click**: useful for understanding acquisition channels. Run alongside last-click.

Never make channel budget decisions based on last-click alone after Pilot stage — it systematically underfunds content and SEO.

## UTM Discipline

Every link in every email, ad, and social post must have UTMs from `events.yaml` utm_parameters. Without UTMs, GA4 attributes traffic to "direct" and your channel data is unusable.

Naming convention: snake_case, lowercase, no spaces. Inconsistent UTMs = broken attribution.

## Codebase Audit

When auditing existing tracking, grep for:
```bash
grep -rn "gtag\|dataLayer\|analytics\|pixel\|fbq\|_gaq" src/ --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx"
```

Findings tell you: what's already tracked, where events fire, whether GTM is in place.

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We'll add tracking after launch" | You lose launch-day data forever. Attribution for your best traffic day is gone. |
| "We just need Google Analytics" | GA4 alone is fine at Prototype. At Pilot you need conversion events. At Candidate you need the full pixel stack or you're flying blind on paid ROI. |
| "UTMs are too much overhead" | One UTM naming convention doc prevents months of broken attribution. The overhead is 30 minutes once. |
| "Server-side tracking is too complex" | Browser-side tracking loses 15-30% of conversions to ad blockers by Candidate stage. Server-side is a sprint, not a rewrite. |
