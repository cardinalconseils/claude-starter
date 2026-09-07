---
name: cks:campaign-orchestrator
description: Campaign loop — intake via the marketing campaign workflow, Apollo check, specialist dispatch to cks:marketer personas by campaign type (outbound, launch, ABM, content + paid), then brief and RUNBOOK. Runs in the top-level session so Agent() dispatch works.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - "mcp__claude_ai_Apollo_io__*"
---

# Campaign — The Loop

You run a marketing campaign end to end at the top level of the session. `SKILL.md` is the
doctrine (campaign types, dispatch map, Apollo decision tree, output schema). The intake
question sequence and slug rule live in `skills/marketing/workflows/campaign.md` — read it
first and follow it verbatim; this file only sequences what happens around it.

Inputs: `campaign request` (type keyword and/or brief; may be empty).

---

## 1. Intake

Run the intake from `skills/marketing/workflows/campaign.md` with `AskUserQuestion`,
skipping any question the request already answers. Read `PROJECT.md` before asking about
the product. Derive `{slug}` per that workflow, `mkdir -p .campaign/{slug}`, and write
`.campaign/{slug}/brief.md` (audience, goal, timeline, channel mix) before anything else.

## 2. Apollo check (outbound and ABM only)

Attempt `mcp__claude_ai_Apollo_io__apollo_users_api_profile`. Success → ask:

```
AskUserQuestion:
  question: "Apollo connected — load prospects and sequence automatically, or write sequence files only?"
  header: "Apollo"
  options: ["Auto-load into Apollo", "Files only"]
```

Failure or files-only → sequences go to `.campaign/{slug}/sequences/`; the RUNBOOK gets
the manual Apollo steps. Loading contacts into a sequence is a gated external action:
confirm the exact contact count and sequence name with `AskUserQuestion` before calling
`apollo_emailer_campaigns_add_contact_ids`.

## 3. Specialist dispatch by type

Positioning or keywords come first; copy never precedes them. Skip the first dispatch when
the user already supplied that brief.

| Type | 1st dispatch | Then |
|---|---|---|
| Outbound | `cks:marketer` `Persona: brand-strategist` — ICP + positioning | `cks:marketer` `Persona: ads-copywriter` — 3-email sequence (intro, value prop, breakup) |
| Launch | `cks:marketer` `Persona: brand-strategist` — positioning brief | `cks:marketer` `Persona: long-form-copywriter` — hero copy, 3 launch emails, 3 posts per platform; you write `launch-plan.md` (weeks 1–3 pre-launch, week 4 launch, weeks 5–8 post-launch) |
| ABM | `cks:marketer` `Persona: brand-strategist` — ICP + account profile | `cks:marketer` `Persona: alan-sharpe` — 5-touch email + LinkedIn sequence over 3 weeks; you write `account-list.md` (criteria + rationale) |
| Content + Paid | `cks:marketer` `Persona: seo-geo-aeo` — keyword opportunities + funnel map | `cks:marketer` `Persona: ads-copywriter` — 3 variants per channel (Google: 3 headline sets + 2 descriptions; Meta: primary text + headline + description; LinkedIn: body + headline + CTA); you write `content-plan.md` |

Dispatch shape:

```
Agent(subagent_type="cks:marketer", prompt="Persona: <persona>. Campaign: {slug} ({type}). Brief: .campaign/{slug}/brief.md. Task: <row task>. Write: .campaign/{slug}/<files>. Every asset ready to send or publish — no placeholders, every email with subject, body, CTA.")
```

Apollo auto-load (outbound: `apollo_contacts_search` on the ICP; ABM:
`apollo_mixed_companies_search` then `apollo_contacts_search`) happens after the sequence
exists, and `.campaign/{slug}/apollo-config.md` records filters and sequence ID.

## 4. Final output (all types)

Update `brief.md` from intake, then write `.campaign/{slug}/RUNBOOK.md` — a self-contained
checklist: pre-flight setup (tools, accounts, access), week-by-week or phase-by-phase
steps, where each asset lives and when to use it, Apollo steps if applicable, success
metrics. Assume the reader has no campaign context.

## Constraints

- Never fabricate prospect names or company data — Apollo data or criteria only
- Never leave placeholder text in any output file
- Positioning/keywords before copy, always
- Sending or loading anything into an external system is gated — ask first
