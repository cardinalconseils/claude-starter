---
name: campaign
description: "Campaign orchestration knowledge — campaign types, intake workflow, specialist dispatch map, Apollo integration decision tree, output schema for outbound, launch, ABM, and content/paid campaigns"
allowed-tools: Read, Write, AskUserQuestion
---

# Campaign Orchestration

Domain expertise for planning and executing marketing campaigns across four types: outbound email, product launch, account-based (ABM), and content + paid.

## Campaign Type Definitions

### Outbound Email
Cold prospecting sequence targeting individuals who match the ICP but have no prior relationship with the product. Typical goal: book meetings or demos. Best when: you have a defined ICP, can source contacts, and have a clear value proposition. 3-touch sequence is the minimum viable; 5-touch adds a case study and a multi-channel step (LinkedIn).

### Product Launch
Time-bounded campaign to announce and drive adoption of a new product or feature. Structured in three phases: pre-launch (build anticipation), launch week (maximize spike), post-launch (nurture and convert). Best when: there is a hard ship date, a waitlist, or a Product Hunt moment to anchor to.

### Account-Based Marketing (ABM)
Personalized multi-touch campaign targeting a defined list of high-value accounts, not individuals. Combines email and LinkedIn touches, with messaging tailored to account-level signals (industry, recent news, job postings). Best when: ACV is high, sales cycle is long, and a named account list exists or can be built.

### Content + Paid Ads
Keyword-driven content plan paired with paid ad copy across Google Search, Meta, and LinkedIn. Best when: there is search demand to capture (Google), retargetable audience (Meta), or a professional ICP reachable on LinkedIn. Requires keyword research before copy can be written.

## Intake Question Sequence

Ask in this order. Skip any question whose answer is already in the dispatch prompt or PROJECT.md.

1. **Campaign type** — outbound / launch / ABM / content+paid
2. **Product/company** — what the product does and who it's for (read PROJECT.md first)
3. **ICP** — role, company size, industry, pain state
4. **Goal** — primary conversion event (meeting booked, trial signup, demo request, revenue)
5. **Timeline** — total duration and any hard deadlines

Slug derivation: `{type}-{product-name}-{quarter}`, all lowercase, hyphens only. Example: `outbound-acme-q3`.

## Specialist Dispatch Map

| Campaign Type | Agent(s) to Dispatch | When to Skip |
|---|---|---|
| Outbound | `cks:product-marketer` | User already provided ICP + positioning brief |
| Launch | `cks:product-marketer` | User already provided launch brief |
| ABM | `cks:product-marketer` | User already provided account profile |
| Content + Paid | `cks:online-marketer` | User already provided keyword list + funnel |

Dispatch order matters: always get positioning/keywords before writing copy.

## Apollo Integration Decision Tree

```
Is campaign type outbound or ABM?
  └─ YES → Attempt mcp__claude_ai_Apollo_io__apollo_users_api_profile
      ├─ SUCCESS → Ask: "Auto-load prospects + sequence, or write files only?"
      │     ├─ AUTO-LOAD: search contacts → load sequence → write apollo-config.md
      │     └─ FILES ONLY: write sequence files, note manual Apollo steps in RUNBOOK
      └─ FAIL (no MCP / auth error) → Write sequence files only; note setup in RUNBOOK
  └─ NO (launch / content+paid) → Skip Apollo entirely
```

Apollo tools used for auto-load:
- `apollo_contacts_search` or `apollo_mixed_companies_search` — prospect/account discovery
- `apollo_emailer_campaigns_add_contact_ids` — load contacts into sequence
- Never use `apollo_emailer_campaigns_remove_or_stop_contact_ids` unless user explicitly requests it

## Output Schema

```
.campaign/{slug}/
  brief.md              — audience, goal, timeline, channel mix (all types)
  RUNBOOK.md            — execution checklist (all types)
  sequences/            — email + LinkedIn touch files (outbound, ABM)
    email-1.md
    email-2.md
    email-3.md
  launch-plan.md        — 8-week phase plan (launch)
  assets/               — hero copy, social posts, launch emails (launch)
  account-list.md       — target account criteria + rationale (ABM)
  content-plan.md       — topics, formats, publish schedule (content+paid)
  ads/                  — ad copy by channel (content+paid)
    google.md
    meta.md
    linkedin.md
  apollo-config.md      — search filters + sequence ID (outbound/ABM, Apollo only)
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I don't need Apollo — I'll just write the sequence" | Apollo auto-load saves the user hours of manual setup. Always detect and offer it for outbound and ABM. |
| "I can skip intake questions — the brief is obvious" | Brief.md must be written with explicit answers. Assumed answers produce misaligned copy. |
| "The RUNBOOK can be short — they'll figure it out" | A RUNBOOK without setup steps, file paths, and metrics leaves the user stranded. Make it self-contained. |
| "I'll dispatch the specialist later — let me write copy first" | Positioning from `cks:product-marketer` shapes all copy. Write copy before positioning = rework. |
| "ABM and outbound are basically the same" | ABM targets accounts with personalized signal-based messaging; outbound targets individuals with ICP-fit messaging. Different sequence structure and Apollo queries. |
| "Content + paid doesn't need a specialist dispatch" | `cks:online-marketer` owns keyword research. Without it, ad copy lacks search intent alignment. |

## Verification

- [ ] `brief.md` exists with: audience, goal, timeline, channel mix
- [ ] All sequence files written with subject lines, body copy, and CTA — no placeholders
- [ ] `RUNBOOK.md` is self-contained: setup steps, asset file paths, success metrics
- [ ] Apollo auto-load confirmed or explicitly skipped with notes in RUNBOOK
- [ ] Specialist dispatch completed before copy was written
- [ ] Output folder matches schema above — no missing required files for campaign type
