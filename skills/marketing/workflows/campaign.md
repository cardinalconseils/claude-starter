# Campaign Workflow

Ported from the campaign-orchestrator body. The marketer runs this under the
`campaign-lead` persona; specialist steps switch personas instead of dispatching agents.
All output goes to `.campaign/{slug}/`.

## Intake

Ask via `AskUserQuestion` in this order. Skip any question already answered in the brief.

1. **Campaign type** — outbound / launch / ABM / content+paid
2. **Product/company** — read `PROJECT.md` first; ask only if not found
3. **Target audience / ICP** — role, company size, industry
4. **Campaign goal** — meetings booked / trial signups / demo requests / revenue
5. **Timeline** — e.g. "8 weeks", "Q3"

Derive `{slug}` from campaign type + product name, lowercased and hyphenated
(`outbound-acme-q3`). Create `.campaign/{slug}/` before writing any file.

Write `.campaign/{slug}/brief.md` immediately after intake — audience, goal, timeline,
channel mix.

## Apollo check (outbound and ABM only)

Attempt `mcp__claude_ai_Apollo_io__apollo_users_api_profile`. If it succeeds, Apollo is
connected. Ask: "Apollo connected — prepare the prospect search and sequence load for
approval, or write sequence files only?"

- **Prepare for approval**: run the searches (read-only), write
  `.campaign/{slug}/apollo-config.md` with the filters, the contact IDs found, and the
  exact load call. Loading is gated — end with `GATED: load N contacts into sequence <id>`.
- **Files only / unavailable**: write sequence files to `.campaign/{slug}/sequences/`.

## Steps by campaign type

### Outbound

1. Persona `outbound-prospector`: ICP → `icp.md` (skip if the brief already carries one),
   signals → `account-list.md`, consent basis per segment
2. Build prospect criteria from the ICP
3. Persona `outbound-prospector` (or `alan-sharpe` for industrial audiences): 3-email
   sequence — intro + value prop + breakup
4. If Apollo is connected: `apollo_contacts_search` with the ICP criteria; record filters
   and IDs in `apollo-config.md`; the load stays gated
5. Write `sequences/email-1.md`, `email-2.md`, `email-3.md`

### Launch

1. Persona `brand-strategist` for the positioning brief (skip if positioning exists)
2. Build the 8-week plan:
   - Weeks 1–3: pre-launch (waitlist, teaser, media outreach)
   - Week 4: launch week (hero email, Product Hunt, social blitz)
   - Weeks 5–8: post-launch (nurture, case studies, follow-on ads)
3. Persona `long-form-copywriter` for hero copy and the 3-email launch sequence;
   persona `ads-copywriter` for social posts — 3 per platform (LinkedIn, X, Instagram)
4. Write `launch-plan.md`
5. Write assets to `assets/` — one file per channel or email

### ABM

1. Persona `outbound-prospector`: ICP and account profile → `icp.md`
2. Build target-account criteria (industry, size, signals)
3. Persona `outbound-prospector`: personalised multi-touch sequence — email + LinkedIn,
   5 touches over 3 weeks
4. If Apollo is connected: `apollo_mixed_companies_search` for accounts,
   `apollo_contacts_search` for contacts at those accounts; record in `apollo-config.md`;
   load stays gated
5. Write `account-list.md` — criteria + rationale — and `sequences/` — one file per touch

### Content + paid

1. Persona `seo-geo-aeo` for keyword opportunities and funnel mapping (aHref tools when
   connected)
2. Persona `ads-copywriter`: 3 ad-copy variants per channel —
   Google Search: 3 headline sets + 2 descriptions each;
   Meta: primary text + headline + description (3 variants);
   LinkedIn: body + headline + CTA (3 variants)
3. Write `content-plan.md` — topics, formats, publish schedule
4. Write `ads/google.md`, `ads/meta.md`, `ads/linkedin.md`

## Final output (all types)

Always write these two files last:

- `brief.md` — audience, goal, timeline, channel mix (update from intake if already written)
- `RUNBOOK.md` — step-by-step execution checklist the owner can follow without context:
  pre-flight setup (tools, accounts, access), week-by-week or phase-by-phase actions, where
  each asset lives and when to use it, Apollo steps and the gated loads awaiting approval,
  success metrics to track

## Quality gate

Under the `campaign-lead` persona, review every deliverable against `brief.md` before it
goes into `RUNBOOK.md`. Return work that misses the brief with specific revision notes and
redo it under the same persona. Persona `data-scientist` confirms tracking before any paid
step is listed as ready. Persona `marketing-director` approves before any launch with
budget above $5K or any positioning change.

## Constraints

- Never fabricate prospect names or company data — tool data or written criteria only
- Never leave placeholder text in output files — all copy is ready to send or publish
- Sequences are complete: subject line, body, CTA, unsubscribe line for every email
- `RUNBOOK.md` is self-contained — assume the reader has no campaign context
- Loads, sends, approvals, and ad spend are gated — `GATED:` lines, never tool calls
