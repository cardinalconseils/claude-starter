---
name: email-sequence
description: Use when the user wants to build, plan, or improve an email sequence for nurturing, onboarding, or re-engagement. Also use when the user mentions 'email sequence,' 'drip campaign,' 'email nurture,' 'welcome sequence,' 'onboarding emails,' 're-engagement,' or 'email automation.'
---

# Email Sequence

Expertise in building email sequences that convert without burning the list. Every sequence has a job: cold sequences open conversations, drip sequences build trust before asking, re-engagement sequences clean the list and recover the reactivatable.

## When to Use Which Sequence

**Cold outreach** — you have a list of people who don't know you yet. The job of email 1 is not to pitch — it's to earn a reply. Personalization is the only thing that separates cold email from spam.

**Drip (new subscriber)** — someone gave you their email in exchange for something. The 21-day window is when trust is built or lost. Day 0 delivers the promise. Days 2-14 build credibility. Day 21 is earned permission to ask.

**Re-engagement** — 90-day inactivity is the signal. Some are gone forever; some just drifted. Email 3 is an intentional list clean — people who don't click the unsubscribe offer are worth keeping.

**Onboarding (new trial/signup)** — 7-day window is critical. Guide users to the product's aha moment before they disengage.

## Drip Sequence Structure (New Subscriber — 21 Days)

| Email | Timing | Job | CTA |
|---|---|---|---|
| Email 1 | Day 0 | Deliver the promise (lead magnet, resource, or welcome) | Open/use the resource |
| Email 2 | Day 2 | Teach one insight — no ask | Read related content |
| Email 3 | Day 4 | Social proof — customer story with specific outcome | Check out the case study |
| Email 4 | Day 7 | Address the #1 objection | Reply with a question |
| Email 5 | Day 10 | Teach another insight — demonstrate expertise | Apply this in your work |
| Email 6 | Day 14 | Behind the scenes or founder story — builds liking | Share if helpful |
| Email 7 | Day 21 | The ask — trial, demo, or purchase | [Primary CTA] |

Day 21 is when you've earned the right to ask. Don't ask before then.

## Re-engagement Sequence (90-Day Inactive)

| Email | Timing | Subject line approach | Goal |
|---|---|---|---|
| Email 1 | Day 0 | "Still interested in [topic]?" | Soft reactivation |
| Email 2 | Day 4 | "What's changed since [time period]" | New value/updates |
| Email 3 | Day 8 | "Should I keep sending you emails?" | Opt-in or out |

Email 3 is the list cleaner. Subject: "Should I stop sending?" — people who don't respond get suppressed. People who click "keep sending" are back in a warm segment.

## Onboarding Sequence (New Product Trial — 7 Days)

| Email | When | Goal |
|---|---|---|
| Welcome | Immediately | Confirm account, set expectation |
| Activation | Day 1 | Drive first key action if not completed |
| Value reminder | Day 2 | Remind why they signed up + one tip |
| Social proof | Day 3 | Case study from similar user |
| Check-in | Day 5 | Did they hit activation? Offer help if not |
| Upgrade prompt | Day 7 | If activated: introduce the next value layer |

**Behavioral triggers beat time-based triggers:** If user completes the activation action, skip the Day 1 activation email and send the value reminder instead.

## Subject Line A/B Test Framework

Test one variable at a time:

| Variable | Examples |
|---|---|
| Curiosity | "The one thing holding back [outcome]" |
| Urgency | "Your [resource] expires in 48 hours" (real deadlines only) |
| Personalization | [First name] in subject, or company-specific reference |
| Benefit | "3x your email open rate in 14 days" |
| Question | "Are you making this mistake?" |

Minimum 200 sends per variant before declaring a winner.

## Personalization Signals

Priority order for personalization:
1. Recent company news (funding, product launch, hire)
2. Specific content they published (article, post, talk)
3. Mutual connection or shared context
4. Role-specific pain (use job title as a proxy)
5. Signup source (what did they download or sign up for?)

Never use "I came across your profile" — it signals automation. Never open with "Hope this finds you well."

## Quality Signals

Copy that converts:
- One idea per email — not three
- CTA that matches the funnel stage (no "buy now" in email 1)
- Preview text that complements the subject, not repeats it
- Sent from a real person name, not "The [Company] Team"
- Subject under 50 characters

Copy that kills lists:
- Generic openers ("Hope this finds you well")
- Pitching before establishing relevance
- Three CTAs in one email
- Wall of text with no paragraph breaks

## Technical Setup

For every sequence before launch:
- [ ] SPF record configured for sending domain
- [ ] DKIM enabled and verified
- [ ] DMARC policy set (start with p=none)
- [ ] Unsubscribe link present in every email
- [ ] CAN-SPAM / CASL compliance (physical address in footer)
- [ ] Plain text version of every HTML email
- [ ] Test sends to real inboxes (Gmail, Outlook) before launching

## Deliverability Health

Monitor weekly:
- Bounce rate < 2%
- Spam complaint rate < 0.1%
- Unsubscribe rate < 0.5%

If bounce rate > 2%, clean the list with a verification service (ZeroBounce, NeverBounce) before the next send.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll do email later when we have more subscribers" | Email converts best at small list sizes — early subscribers are highest-intent. |
| "Our audience doesn't respond to email" | They don't respond to bad email. Sequence structure and personalization are the variables. |
| "5 cold emails is too many" | 80% of replies come after email 3. Stopping at 2 is leaving pipeline on the table. |
| "Re-engagement is risky — they might unsubscribe" | Inactive subscribers hurt deliverability. A clean list outperforms a large one. |
| "Onboarding emails are annoying — we'll keep them minimal" | Users who don't activate churn. Onboarding emails that drive activation are valuable, not annoying. |
