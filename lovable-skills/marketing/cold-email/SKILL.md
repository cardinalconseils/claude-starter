---
name: cold-email
description: Use when the user wants to write B2B cold outreach emails or follow-up sequences. Also use when the user mentions 'cold email,' 'prospecting email,' 'outbound email,' 'SDR sequence,' 'sales email,' or 'cold outreach.'
---

# Cold Email

Expert knowledge for writing B2B cold emails and sequences that get replies, book meetings, and start conversations at scale.

## Core Principle

Cold email is a relevance game, not a volume game. One highly relevant email to 50 prospects outperforms one generic email to 500. Personalization is the variable that matters most.

## The Anatomy of a High-Reply Cold Email

**Structure:**
1. Subject line (open)
2. Opening line (personalized hook — earns the next sentence)
3. Bridge (connect their situation to your solution)
4. Value prop (one sentence — specific outcome, not feature list)
5. Proof point (one concrete example or number)
6. CTA (one ask — low friction)

Total length: 3-5 sentences for the body. Under 150 words.

## Subject Line Formulas

Subject lines determine open rate. Keep them:
- Specific (not clever)
- Under 50 characters
- Relevant to their role/problem

**Formulas that work:**
- "[Company name] + [your product area]" — e.g., "Acme Corp + their onboarding drop-off"
- "Quick question about [their specific initiative]"
- "[Mutual connection] suggested I reach out"
- "Idea for [their team/problem]"
- "[Peer company] is doing this — are you?"
- "[Specific number] [outcome] for [their industry]"

**Avoid:**
- "Following up" (signals a previous cold email chain)
- "Checking in"
- ALL CAPS or excessive punctuation
- Generic: "Grow your revenue," "Increase conversions"

## Opening Line Formulas

The opening line must make the prospect feel you actually know them — not that you merged their name from a CSV.

**Tier 1 — Company-specific (highest effort, highest reply rate):**
- "[Company] just raised a Series B — congratulations. Scaling [function] after a raise is..."
- "Saw your post about [topic] last week. You mentioned [specific point] — we've seen that a lot with [their type of company]."
- "I noticed [company] recently launched [product/feature]. Companies at this stage often struggle with..."

**Tier 2 — Role/trigger-specific (medium effort, good reply rate):**
- "As a [their title], you're probably spending a lot of time on [painful task]."
- "[Job posting for role X] tells me you're building out [function] — that usually means..."
- "I saw [company] is hiring [10+] salespeople. Growth at that pace usually creates [specific problem]."

**Tier 3 — Industry-specific (lower effort, scalable):**
- "Most [role] at [industry] companies we talk to are dealing with [specific problem]."

## Value Prop Compression

Compress your value prop to one sentence. If you can't, you don't understand it yet.

**Formula:** "[Product] helps [ICP] [achieve outcome] without [common sacrifice]."

**Examples:**
- "We help B2B SaaS companies reduce onboarding drop-off by 40% without hiring more CSMs."
- "We give growth teams one dashboard for all their paid channels so they stop spending 3 hours/week in spreadsheets."

## Proof Point Selection

One specific, credible data point is worth more than three vague claims.

**Good proof points:**
- "We did this for [similar company type] — they went from 12% to 19% activation in 6 weeks."
- "[X] companies in [their industry] use us."
- "Reduced [specific metric] by [%] for [company type]."

**Bad proof points:**
- "Our customers love us."
- "We've helped hundreds of companies."
- "Industry-leading results."

Match the proof point to the prospect's likely concern:
- Early-stage prospects: speed of results
- Enterprise: risk reduction and security
- Volume-sensitive: scale and reliability

## CTA Design

One ask. Specific. Low friction.

**Best CTAs:**
- "Would it be worth a 15-minute call to see if this applies to [Company]?" (Yes/No question)
- "Can I send you a 2-minute video showing exactly how this works?"
- "Are you the right person to talk to about this, or would you recommend someone else?"

**CTA principles:**
- Yes/No questions outperform open-ended questions
- Specific time commitment ("15 minutes" not "a quick call")
- Make the "no" easy — some of the best replies are "not us, but talk to [person]"

## Follow-Up Sequence Architecture

Most replies come from follow-ups, not the first email. Each follow-up must add value, not just nag.

**5-touch sequence:**

| Touch | Timing | Content |
|---|---|---|
| Email 1 | Day 0 | Full pitch — problem + value + proof + CTA |
| Email 2 | Day 3 | New angle — different pain, different outcome framing |
| Email 3 | Day 7 | Social proof — case study, testimonial, or relevant stat |
| Email 4 | Day 14 | Content offer — relevant article, checklist, or resource |
| Email 5 | Day 21 | Break-up email — "I don't want to keep bugging you..." |

**Break-up email formula:**
"I've sent a few notes and haven't heard back — I'll assume the timing isn't right. If [problem] ever becomes a priority, we're at [email]. Rooting for [Company]."

Break-up emails often get replies because they remove pressure.

## Personalization at Scale

**Tier 1 (10% of list):** Fully custom opening line for high-value accounts. Spend 5-10 minutes per prospect.

**Tier 2 (30% of list):** Trigger-based personalization. Use signals (job post, funding, product launch) to auto-populate opening line templates.

**Tier 3 (60% of list):** Segment personalization. One version per segment (industry, role, company size).

**Signal sources:**
- LinkedIn activity (posts, job changes, company announcements)
- Job postings (what they're hiring for reveals their priorities)
- Funding announcements (Crunchbase, TechCrunch)
- Recent news mentions

## Deliverability: Technical Foundation

- [ ] SPF record configured for sending domain
- [ ] DKIM enabled and verified
- [ ] DMARC policy set (start with p=none, move to p=quarantine)
- [ ] Custom tracking domain (not shared with other senders)
- [ ] Dedicated sending subdomain (e.g., outreach.company.com, not company.com)

**Warm-up protocol for new domains:**
- Week 1: 10-20 emails/day
- Week 2: 30-50 emails/day
- Week 3: 75-100 emails/day
- Week 4+: Scale to target volume

**Reputation signals to monitor:**
- Bounce rate < 2% (clean your list with ZeroBounce or NeverBounce)
- Spam complaint rate < 0.1%
- Unsubscribe rate < 0.5%

## Reply Rate Benchmarks

| Scenario | Expected Reply Rate |
|---|---|
| Generic mass email | < 1% |
| Segment-personalized | 2-5% |
| Trigger-based personalization | 5-10% |
| Full 1:1 personalization | 10-20% |
| Warm intro (referral) | 40-70% |

If reply rate is below 2%, fix the list quality or personalization before scaling volume.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We need to send more emails to get more replies" | Volume amplifies a broken message. Fix reply rate first, then scale. |
| "Our product is complex — we need to explain it fully in email 1" | Nobody reads a wall of text from a stranger. Earn the right to explain more on a call. |
| "The follow-up emails should remind them what email 1 said" | Each email must stand alone and add new value. Reminders are annoying; new angles get replies. |
| "We'll personalize later when we have more resources" | Generic outreach at any scale has 0-1% reply rates. Personalization is a prerequisite, not a luxury. |
| "Deliverability is IT's problem" | Landing in spam = 0% reach. Sending domain setup is a marketing responsibility. |

## Verification

- [ ] SPF, DKIM, DMARC configured for sending domain
- [ ] New domain warm-up protocol followed before full volume
- [ ] List verified with bounce-check tool (bounce rate < 2%)
- [ ] Opening line is prospect-specific (not just a merged first name)
- [ ] Value prop is one sentence with specific outcome
- [ ] CTA is a Yes/No question with specific time commitment
- [ ] Follow-up sequence covers 5 touches with different angles
- [ ] Reply rate tracked weekly (target > 5% for personalized campaigns)
