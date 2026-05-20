---
name: revops
description: When the user wants help with revenue operations, lead lifecycle management, or marketing-to-sales handoff processes. Also use when the user mentions 'RevOps,' 'revenue operations,' 'MQL to SQL,' 'lead scoring,' 'funnel alignment,' or 'pipeline management.'
allowed-tools: Read, Write, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Revenue Operations (RevOps)

Expert knowledge for aligning marketing, sales, and customer success around a unified lead lifecycle, accurate attribution, and scalable revenue processes.

## What RevOps Is

Revenue Operations (RevOps) is the organizational function that aligns marketing, sales, and customer success under shared data, shared definitions, and shared accountability for revenue outcomes.

RevOps answers: "Why is our pipeline number different from what marketing reports? Why are leads being ignored? Why can't we forecast accurately?"

## Lead Lifecycle Stages

Define lifecycle stages before building any scoring, automation, or reporting. Shared definitions prevent the "we sent 100 MQLs, they only worked 10" argument.

**Standard lifecycle stages:**

| Stage | Definition | Owner |
|---|---|---|
| Subscriber | Opted in to marketing but no further intent signals | Marketing |
| Lead | Provided contact info; some profile or activity data | Marketing |
| MQL (Marketing Qualified Lead) | Met threshold score; ready for sales contact | Marketing → Sales handoff |
| SAL (Sales Accepted Lead) | Sales confirmed it meets their criteria | Sales |
| SQL (Sales Qualified Lead) | Sales has engaged and confirmed a real opportunity | Sales |
| Opportunity | Active deal in pipeline | Sales |
| Customer | Closed/won | Sales → CS |
| Churned | Customer who has left | CS |
| Disqualified | Explicitly not a fit | Sales |

**Critical: SAL stage.** If marketing sends MQLs and sales can reject them without recording why, you have no feedback loop. The SAL stage (where sales accepts or rejects with a reason) is the handoff accountability mechanism.

## MQL Criteria Design

An MQL is a lead that marketing has qualified to the point where sales engagement is appropriate.

**MQL threshold approach:**

**Demographic fit (who they are):**
- Job title match (e.g., VP Marketing, Head of Revenue, Marketing Manager)
- Company size match (e.g., 50-500 employees)
- Industry match
- Geography match

**Behavioral intent (what they did):**
- Requested a demo or trial
- Visited pricing page 2+ times
- Downloaded a bottom-of-funnel resource (ROI calculator, comparison guide)
- Attended a webinar
- Replied to an email

**Disqualifying signals (automatic exclusions):**
- Free email domain (Gmail, Yahoo) for B2B products
- Competitor domain
- Student or job seeker indicators
- Out-of-ICP company size

**MQL scoring formula example:**

| Attribute | Score |
|---|---|
| Demo request | +40 |
| Pricing page visit (2+) | +25 |
| Bottom-of-funnel content download | +20 |
| Webinar attendance | +15 |
| Top-of-funnel content download | +5 |
| ICP title match | +20 |
| ICP company size match | +15 |
| Free email domain | -50 |
| Competitor domain | -100 |

MQL threshold: Score ≥ 50 (tune based on conversion data)

## SLA Design Between Marketing and Sales

An SLA (Service Level Agreement) defines what each team commits to.

**Marketing → Sales SLA:**
- We will only send leads that meet MQL criteria [defined explicitly]
- We will send leads with complete data (name, email, company, title, lead source)
- We will include behavioral context (what they did to become an MQL)

**Sales → Marketing SLA:**
- Sales will attempt contact within [X] hours of MQL creation (typically 4-8 hours for hot leads)
- Sales will accept or reject each MQL within [Y] business days with a documented reason
- If rejected, sales will provide reason from a predefined list (not a fit, bad timing, duplicate, etc.)

**SLA reporting cadence:** Weekly review of SLA adherence in both directions. This is a shared meeting with both marketing and sales.

## Pipeline Velocity

Pipeline velocity measures how fast opportunities move through your pipeline.

**Formula:**
```
Pipeline Velocity = (Qualified Opportunities × Average Deal Value × Win Rate) / Average Sales Cycle Length
```

**Example:**
- 50 qualified opportunities
- Average deal value: $12,000
- Win rate: 25%
- Average sales cycle: 45 days
→ Pipeline velocity = (50 × $12,000 × 0.25) / 45 = $3,333/day

**Using pipeline velocity to identify problems:**

| Metric drops | Problem area |
|---|---|
| Fewer opportunities | Top-of-funnel; MQL quality or volume |
| Lower average deal size | ICP misalignment; wrong segments |
| Lower win rate | Competitive pressure; sales process; product gaps |
| Longer cycle | Evaluation friction; wrong stakeholders; missing content |

## Funnel Conversion Benchmarks

Use these as reference points, not targets (every market differs).

**B2B SaaS benchmarks:**

| Stage → Stage | Typical Rate |
|---|---|
| Lead → MQL | 20-30% |
| MQL → SAL | 70-85% (if MQL criteria are tight) |
| SAL → SQL | 60-75% |
| SQL → Opportunity | 80-90% |
| Opportunity → Closed/Won | 20-30% (enterprise), 30-50% (SMB) |

If your rates deviate significantly, investigate:
- Lead → MQL drop: Is your lead volume low quality or high intent? Review source mix.
- MQL → SAL drop: Are MQL criteria too loose? Interview sales about rejection reasons.
- Opportunity → Won drop: Competitive? Product gap? Sales skills? Check loss reasons.

## CRM Hygiene Standards

Bad CRM data produces bad decisions. Enforce hygiene at the point of entry.

**Required fields for every lead/contact:**
- First name, last name
- Business email
- Company name
- Job title
- Lead source (original source, specifically — not just "web")
- MQL date (when they crossed the threshold)

**Required fields for every opportunity:**
- Close date (realistic, not aspirational)
- Stage (with clear entry/exit criteria for each)
- Deal value
- Primary competitor
- Loss reason (mandatory on close-lost)

**CRM hygiene automation:**
- Duplicate detection on create (email match)
- Email validation on create (block free domains for B2B)
- Required field enforcement (prevent save without critical fields)
- Automated inactivity alerts (opportunities with no activity in 14+ days)

## Attribution Reporting

**Attribution models:**

| Model | Credit logic | Use for |
|---|---|---|
| First touch | 100% to first touchpoint | Understanding what creates awareness |
| Last touch | 100% to last touchpoint before conversion | Understanding what closes deals |
| Linear | Equal across all touchpoints | Understanding the full journey |
| Time decay | More credit to recent touchpoints | Mid-length sales cycles |
| W-shaped | 40% first, 40% last, 20% MQL creation point | Most balanced for marketing |
| Data-driven | Algorithm based on actual path analysis | When you have enough conversion data |

**Multi-touch attribution requirement:** Any single-touch model will under-credit content and top-of-funnel activities. Use at minimum a W-shaped or linear model for marketing reporting.

**Tools:** HubSpot, Salesforce (native), Bizible/Marketo Measure (best-in-class), Dreamdata.

## Marketing-to-Sales Handoff Process

**Handoff checklist for each MQL:**

1. Lead enriched with company data (Clearbit, Apollo enrichment)
2. MQL reason documented (which criteria triggered; what they did)
3. Lead assigned to correct rep (routing rules applied)
4. Rep notified via CRM notification + Slack alert
5. 4-hour SLA clock started
6. If not contacted in 4 hours: escalation to SDR manager

**Handoff notification template (Slack or email):**
```
New MQL: [First Name Last Name] at [Company]
Title: [Job Title]
Score: [Score]
Why MQL: [Brief — e.g., "Requested demo + pricing page 3x + VP Marketing"]
Company size: [X employees]
Key pages: [List of last 3 pages visited]
CRM record: [Link]
Suggested approach: [1-line context hint]
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Marketing and sales just have different definitions of a good lead" | That's a RevOps problem to solve, not accept. Shared definitions are the foundation. |
| "We track attribution — last touch is fine" | Last touch credits the salesperson's close, not the content that created the opportunity. You'll systematically defund top-of-funnel. |
| "The CRM is sales' responsibility" | CRM data quality is everyone's responsibility. Marketing's reporting is only as good as the data sales enters. |
| "We don't have time for SLAs — we just respond as fast as we can" | "As fast as we can" without measurement produces undocumented inconsistency. SLAs are measurable; effort is not. |
| "Lead scoring is too complicated for our stage" | A simple scoring model (fit × intent) beats no model. You don't need Marketo to implement a spreadsheet score. |

## Verification

- [ ] Lifecycle stages defined with written criteria for each stage transition
- [ ] MQL criteria documented with explicit inclusion and exclusion criteria
- [ ] Scoring model implemented and calibrated to actual conversion data
- [ ] Two-way SLA agreed between marketing and sales (written and signed off)
- [ ] SAL stage in CRM with required rejection reason field
- [ ] Weekly SLA adherence review scheduled
- [ ] Attribution model selected and implemented in reporting
- [ ] CRM required fields enforced with automation (duplicate detection, validation)
- [ ] Pipeline velocity tracked and reviewed monthly
