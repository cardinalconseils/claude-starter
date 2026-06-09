---
name: analytics-tracking
description: Use when the user wants to set up, audit, or improve their analytics and tracking. Also use when the user mentions 'analytics,' 'tracking,' 'GA4,' 'Google Analytics,' 'GTM,' 'events,' 'conversions,' 'pixels,' 'UTMs,' 'attribution,' or 'what data should we track.'
---

# Analytics Tracking

Expertise in instrumentation that connects user behavior to business outcomes. Bad tracking is noise. Good tracking answers: where do users drop off, which channels actually convert, and what does activation look like before churn?

## Event Priority by Product Stage

Not all events are worth instrumenting immediately.

**MVP/Prototype:** Instrument `sign_up`, `page_view`, and one activation event specific to the product. Everything else is noise until the core loop is validated.

**Early Users/Pilot:** Add `feature_used` for each key feature and `upgrade_intent`. These two events tell you whether users understand the product and whether they're hitting the paywall at the right moment.

**Growth/Candidate:** Full event taxonomy. Add `churn_signal` — 90-day retention hinges on catching users before they cancel, not after.

**Production:** Add server-side events for purchase confirmation (prevents ad platform under-reporting due to browser blocking).

## Core Event Taxonomy

### Universal Events (every product stage)

| Event | When to fire | Key properties |
|---|---|---|
| `page_view` | Every page load | page_path, page_title, referrer |
| `sign_up` | Account created | method (google/email/github), plan |
| `login` | User authenticates | method |
| `sign_out` | User logs out | session_duration |

### Activation Events (Pilot stage+)

| Event | When to fire | Key properties |
|---|---|---|
| `feature_used` | First time user uses a key feature | feature_name, user_id |
| `onboarding_complete` | User finishes setup flow | steps_completed, time_to_complete |
| `aha_moment` | User reaches the product's core value | specific to product |
| `upgrade_intent` | User views pricing/upgrade page | source, plan_viewed |

### Revenue Events (Candidate stage+)

| Event | When to fire | Key properties |
|---|---|---|
| `purchase` | Successful payment | revenue, currency, plan, billing_cycle |
| `subscription_started` | Trial converts to paid | plan, trial_duration |
| `subscription_cancelled` | User cancels | plan, reason, tenure |
| `churn_signal` | User hasn't activated in N days | days_inactive, plan |

## GTM vs Direct Implementation

GTM (Google Tag Manager) is worth the setup cost as soon as you have 2+ tracking destinations.

**Without GTM:** Every new pixel means a code deploy.
**With GTM:** New pixel = 10-minute GTM configuration, no code change.

**Setup order:**
1. Install GTM snippet (one code deploy)
2. Route all events through `dataLayer.push()`
3. Add destinations (GA4, Meta Pixel, LinkedIn Insight Tag) as GTM tags
4. New destinations never require code changes again

**dataLayer push pattern:**
```javascript
window.dataLayer = window.dataLayer || [];
window.dataLayer.push({
  event: 'sign_up',
  method: 'google',
  plan: 'free'
});
```

## GA4 Setup

**Required configuration:**
- [ ] GA4 property created and connected to GTM
- [ ] Enhanced measurement enabled (page views, scrolls, outbound clicks, file downloads)
- [ ] Conversion events marked (sign_up, purchase, activation event)
- [ ] Data retention set to 14 months (default is 2 months — change this immediately)
- [ ] Audiences created (signed in users, paying customers, churned users)

**Key reports to configure:**
- Funnel exploration: sign_up → activation → upgrade
- Cohort exploration: retention by signup week
- User explorer: individual user journey for debugging

## Pixel Setup by Platform

### Meta Pixel

**Required events:**
- `PageView` — fires on every page (handled by pixel base code)
- `Lead` — fires on lead magnet download or demo request
- `CompleteRegistration` — fires on account creation
- `Purchase` — fires on successful payment (with value and currency)

**Conversions API (CAPI):** Implement server-side events for purchases. Browser-blocking loses 15-30% of conversion events. CAPI sends directly from your server, bypassing blockers.

### Google Ads Tag

**Required:** Conversion action for each key goal (sign_up, purchase). Import conversions from GA4 rather than implementing a separate tag — reduces measurement fragmentation.

### LinkedIn Insight Tag

**Required for B2B:** Fires on all pages. Powers demographic reporting (job title, industry, seniority of your website visitors) and retargeting audiences.

## UTM Parameter Strategy

Every link in every email, ad, and social post must have UTMs. Without UTMs, GA4 attributes traffic to "direct" and your channel data is unusable.

**Standard UTM structure:**
```
?utm_source=[source]&utm_medium=[medium]&utm_campaign=[campaign]&utm_content=[content]&utm_term=[term]
```

**Naming convention:** snake_case, lowercase, no spaces. Inconsistent UTMs = broken attribution.

| Field | What it tracks | Examples |
|---|---|---|
| `utm_source` | Where traffic comes from | `google`, `linkedin`, `newsletter` |
| `utm_medium` | Marketing channel type | `cpc`, `email`, `organic_social` |
| `utm_campaign` | Specific campaign name | `q1_lead_gen`, `product_launch` |
| `utm_content` | Ad variant or link variant | `hero_cta`, `footer_link` |
| `utm_term` | Keyword (paid search) | `project_management_software` |

**Create a UTM builder spreadsheet** so every team member uses the same naming convention. One inconsistency (e.g., `Email` vs `email`) creates a separate source in GA4.

## Attribution Models

**Last-click:** All credit to the last touchpoint before conversion. Undervalues top-of-funnel content. Use at MVP stage.

**Data-driven (GA4 default):** Requires 400+ conversions/30 days to activate. Use at Growth stage+.

**First-click:** Useful for understanding acquisition channels. Run alongside last-click.

Never make channel budget decisions based on last-click alone after early stage — it systematically underfunds content and SEO.

## Tracking Audit

When auditing existing tracking, grep for:

```bash
grep -rn "gtag\|dataLayer\|analytics\|pixel\|fbq\|_gaq" src/ --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx"
```

Findings tell you: what's already tracked, where events fire, whether GTM is in place.

**Common audit findings:**
- Events firing on every render instead of once per action
- Missing properties on events (events fire but have no useful data)
- Duplicate tracking (both GTM and hardcoded pixels)
- Events not verified in GA4 DebugView or Meta Events Manager

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll add tracking after launch" | You lose launch-day data forever. Attribution for your best traffic day is gone. |
| "We just need Google Analytics" | GA4 alone is fine at MVP. At Pilot you need conversion events. At Candidate you need the full pixel stack. |
| "UTMs are too much overhead" | One UTM naming convention doc prevents months of broken attribution. The overhead is 30 minutes once. |
| "Server-side tracking is too complex" | Browser-side tracking loses 15-30% of conversions to ad blockers at Candidate stage. Server-side is a sprint, not a rewrite. |

## Verification

- [ ] GTM installed and dataLayer events confirmed firing (GTM Preview mode)
- [ ] GA4 receiving events (DebugView shows events in real time)
- [ ] Conversion events marked in GA4
- [ ] Meta Pixel verified in Events Manager (events showing)
- [ ] UTM naming convention documented and shared with team
- [ ] Attribution model selected and documented
- [ ] Data retention set to 14 months in GA4
- [ ] Server-side CAPI implemented for purchase events (if running Meta ads)
