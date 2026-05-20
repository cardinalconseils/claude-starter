---
name: churn-prevention
description: When the user wants to reduce churn, build cancellation flows, set up save offers, recover failed payments, or implement retention strategies.
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Churn Prevention & Retention

Expert knowledge for reducing customer churn through proactive signals, cancellation flow design, dunning sequences, and win-back campaigns.

## Churn Taxonomy: Know What You're Fighting

Treating all churn the same produces generic solutions that fix nothing.

**Voluntary churn:** Customer actively decides to leave.
- Value-not-realized: They never got the outcome they bought the product for
- Needs changed: Their situation changed (company downsized, project ended)
- Competitor switch: A competitor offered something compelling
- Price objection: They don't believe the price is worth it anymore

**Involuntary churn:** Customer leaves due to payment failure.
- Card expired
- Insufficient funds
- Bank fraud block
- Card lost/stolen

**Silent churn:** Customer stopped using the product but hasn't cancelled yet. Subscription still active, but they are a churner waiting to happen.

Involuntary churn often accounts for 20-40% of total SaaS churn. Fix it before building complex save flows.

## Churn Signals: Early Warning System

Build a customer health score from behavioral signals before implementing retention tactics.

**High-risk signals:**
- Login frequency dropped >50% vs their first 30 days
- Key feature usage (the one that correlates with retention) declined
- Support tickets opened about billing or "how do I cancel"
- Last session was >14 days ago for a daily-use product
- Decision-maker contact changed at the account
- Renewal date is within 30 days and QBR hasn't been scheduled

**Health score framework (simple version):**
```
Health = (Login frequency score × 0.3) 
       + (Key feature usage score × 0.4) 
       + (Expansion signals score × 0.2) 
       + (Support sentiment score × 0.1)
```

Score 0-100. Red < 40, Yellow 40-70, Green > 70.

**Trigger proactive outreach at Yellow.** Don't wait for Red.

## Proactive Retention Playbook

### Stage 1: Value Realization (Days 1-30)
Goal: Ensure they hit their first "aha moment."
- Onboarding sequence with activation milestones
- Success manager check-in at day 7 for paid accounts
- In-app prompts when key feature not yet used

### Stage 2: Engagement Maintenance (Days 31-90)
Goal: Build habits that make cancellation feel costly.
- Weekly usage digest emails ("Here's what you accomplished")
- Feature discovery campaigns for unused features
- Customer success call for accounts with declining usage

### Stage 3: Renewal Defense (30 days before renewal)
Goal: Preemptively address objections before they become cancellations.
- Health check for all accounts renewing in 30 days
- Proactive outreach for Yellow/Red accounts
- ROI report showing value delivered since last renewal

## Cancellation Flow Design

The cancellation flow is not about trapping users — it's about understanding why they're leaving and offering the right intervention at the right time.

### Cancellation Flow Architecture

```
Cancel button click
       ↓
[Pause / Downgrade offer — show alternatives]
       ↓
[Reason selection — 4-6 options]
       ↓
[Targeted save offer based on reason]
       ↓
[Confirmation + offboarding]
```

### Reason-Based Save Offers

| Stated Reason | Save Offer |
|---|---|
| Too expensive | Downgrade tier, pause account, annual plan discount |
| Not using it enough | Pause account for 1-3 months, usage coaching |
| Missing a feature | Roadmap preview, workaround, escalation to PM |
| Found a competitor | Competitive comparison, differentiation reframe |
| Business circumstances changed | Pause, downgrade, extended payment terms |
| Technical problems | Immediate escalation to technical success |

### Pause > Cancel

Offering a 1-3 month pause recovers a significant portion of would-be churners. They are not lost — they are in a holding state. Paused accounts reactivate at materially higher rates than full churns.

### Save Offer Principles

1. **Time the offer correctly.** Show the save offer after they've stated their reason, not before. Premature offers feel desperate.
2. **One offer, not five.** Multiple offers signal desperation and dilute perceived value.
3. **Set expectations for the offer.** "We'd like to offer you 2 months at 50% off" not "we have something special for you" (builds resistance).
4. **Don't offer what you can't sustain.** Discounts offered in cancellation flows get remembered by customers and expected on renewal.

## Dunning: Recovering Failed Payments

Involuntary churn from failed payments is 100% recoverable if you have a good dunning sequence.

### Dunning Sequence Design

**Day 0 (failure):** In-app banner + email "Payment failed — update your card to keep access"
**Day 3:** Soft reminder email — "Your card ending in XXXX failed. Update to avoid service interruption."
**Day 7:** Firm email — "Action required: Your account will be suspended in 3 days"
**Day 10:** Suspension with grace period — account suspended, data preserved
**Day 20:** Final email — "Your data will be deleted in 10 days. Download or reactivate."
**Day 30:** Deletion or archival per your data retention policy

**Smart retry schedule (for card errors):**
- Day 0: First attempt
- Day 3: Retry (cards often work again after banks clear temporary blocks)
- Day 7: Retry
- Day 14: Final retry before suspension

**Dunning email copy principles:**
- Lead with the consequence, not the process ("Your access is at risk" not "Payment processing issue")
- Make the CTA one click to card update page — never send them to login first
- Show specifically what they'll lose
- Show what they won't lose (their data is safe)

### Card Update Optimization

Dunning emails must link directly to a pre-filled billing update page. Friction = lost recoveries.
- Auto-fill account email
- Accept all major card types
- Support Apple Pay / Google Pay for mobile
- Show saved card last-4 for context

## Win-Back Campaigns

Churned customers who left on good terms are your best leads. They already know the product.

### Win-Back Timing

- **30 days post-churn:** Too soon. They just left. Exception: involuntary churn where you just fixed the issue.
- **60-90 days post-churn:** Prime window. Especially if they churned due to circumstances (budget, project ended).
- **6 months post-churn:** Second window. Use if competitor or product gaps were the reason — circumstances may have changed.

### Win-Back Offer Hierarchy

1. **New capability:** "Since you left, we launched [feature they asked for]"
2. **Special offer:** 2-3 months at a reduced rate to re-establish value
3. **Free audit/review:** Offer a free account audit or strategy session
4. **Social proof:** "[Customer like them] just [achieved outcome] — come see how"

### Win-Back Email Sequence (3-touch)

**Email 1 (60 days):** "A lot has changed since you left" — product updates relevant to their stated reason
**Email 2 (74 days):** "We want you back — here's an offer" — time-limited discount or extended trial
**Email 3 (88 days):** "Last chance — offer expires in 48 hours" — urgency close

## NPS Correlation to Churn

NPS (Net Promoter Score) is a leading indicator of churn if used correctly.

- **Detractors (0-6):** High churn risk. Trigger immediate account review. Do not wait for renewal.
- **Passives (7-8):** Moderate risk. Focus on converting to promoter via feature education.
- **Promoters (9-10):** Low churn risk. Focus on expansion and referral programs.

**NPS survey cadence:**
- 30 days after signup (first impression)
- 90 days (value realization check)
- Every 6 months thereafter

**Do not use NPS as vanity metric.** The score alone is useless. The follow-up action on detractors is where the retention value lives.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Churn is just part of SaaS — you can't prevent it" | 30-50% of churn is preventable with proactive signals and targeted interventions. |
| "Our cancellation flow is annoying customers — let's make it one-click" | One-click cancel removes your ability to save anyone. Friction in cancellation, when done right, recovers 10-30% of cancellations. |
| "Win-back campaigns don't work" | Win-back rates are consistently 20-40% when timed correctly and paired with a relevant offer. They already know your product. |
| "Failed payments are IT's problem, not marketing's" | Involuntary churn is a revenue problem. Marketing should own dunning email copy and recovery rates. |
| "We don't have enough data to build a health score" | Login date + feature usage + support tickets = enough for a basic health score. Start simple. |

## Verification

- [ ] Voluntary vs involuntary churn split measured and tracked separately
- [ ] Customer health score defined with at least 3 behavioral signals
- [ ] Yellow-threshold outreach automation configured
- [ ] Cancellation flow includes reason selection and reason-based save offers
- [ ] Pause option available as alternative to cancel
- [ ] Dunning sequence covers days 0, 3, 7, 10, 20, 30 with correct copy per stage
- [ ] Win-back campaign targeting customers 60-90 days post-churn
- [ ] NPS survey triggered at day 30 and day 90 with detractor follow-up workflow
