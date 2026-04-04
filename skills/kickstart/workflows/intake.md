# Workflow: Intake (Phase 1)

## Overview
Deep guided Q&A to understand the project idea — domain, users, data model, integrations,
and constraints. Produces `.kickstart/context.md` with structured context that feeds all
downstream phases.

## Input
- `$IDEA` — optional pitch text from `/kickstart` argument
- `references/ai-glossary.md` — for inline educational explanations

## Steps

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.started" "_project" "Kickstart Phase 1: Intake" '{"phase_number":"1","phase_name":"Intake"}'`

### Step 1: Check for Existing Context

Read `.kickstart/context.md` if it exists.

- If complete context exists → ask: "Intake already done. Re-do or skip to next phase?"
- If partial context exists → resume from where it left off
- If no context → fresh intake

### Step 2: Idea Pitch

**Check for ideation output first:**
If `.kickstart/ideation.md` exists, read it. Use the `## Refined Pitch` section as
the idea context — this is the output from Phase 0 (Ideation). Acknowledge it:
"I see you've already brainstormed this idea. Here's what I'm working with: {one-liner from ideation}."
Proceed directly to Step 3 (Guided Q&A) with this context.

If `$IDEA` was provided as argument, use it directly.

If neither ideation output nor argument exists, ask:

```
What's your project idea? Pitch it to me in a few sentences.
(Don't worry about being precise — we'll refine it together.)
```

Acknowledge the pitch and summarize your understanding before proceeding to questions.

### Step 3: Guided Q&A

Ask questions **one at a time** using AskUserQuestion with selectable options where possible.
Adapt question order and skip questions where the answer is obvious from the pitch.

**Core Questions (~10, adapt based on answers):**

1. **Problem & Value**
   "What specific problem does this solve? Who has this problem today and how do they deal with it?"

2. **Target Users**
   "Who are your primary users?"
   Options: `Solo consumers` | `SMB teams (2-50)` | `Mid-market (50-500)` | `Enterprise (500+)` | `Developers` | `Agencies` | `Other (describe)`

3. **User Journey**
   "Walk me through what a user does — from first visit to getting value. What are the key steps?"

4. **Domain Entities**
   "What are the core 'things' in your system? (e.g., Users, Projects, Invoices, Products, Messages)"
   Prompt for relationships: "How do these relate to each other? (e.g., a User has many Projects, a Project has many Tasks)"
   Prompt for key fields: "For each entity, what are the most important fields? (e.g., User has email, name, role)"

5. **Data & Constraints**
   "For each entity, are there fields that must be unique? Required? Have specific types?"
   Examples:
   - "Email must be unique?"
   - "Is there financial data (needs encryption)? User content (needs moderation)? Files (needs storage)?"
   - "Any fields with specific formats? (e.g., phone numbers, URLs, currency amounts)"
   - "Any soft-delete (archived) vs hard-delete entities?"

6. **Auth Model**
   "How do users access the system?"
   Options: `Public (no login)` | `Simple login (email/password)` | `OAuth (Google, GitHub, etc.)` | `Role-based (admin/user/viewer)` | `Multi-tenant (orgs with members)` | `API keys`

7. **Integrations**
   "What external systems does this connect to?"
   Options: `Payment (Stripe, etc.)` | `Email (SendGrid, etc.)` | `Storage (S3, etc.)` | `AI/LLM APIs` | `Calendar` | `CRM` | `Custom APIs` | `None yet`

8. **Scale & Constraints**
   "What's your expected scale at launch and at 12 months?"
   Also ask: "Any hard constraints? (budget, timeline, compliance, platform requirements)"

9. **API Strategy**
   "Will this project expose APIs? Who consumes them?"
   Options: `Web frontend only (internal API)` | `Mobile + web (internal API)` | `Public API for third parties` | `Both internal + public API` | `No API (static site / CLI)` | `Not sure yet`

   If any API option selected, follow up:
   "What API style fits your needs?"
   Options: `REST (standard, widely understood)` | `GraphQL (flexible queries, multiple consumers)` | `tRPC (type-safe, TypeScript end-to-end)` | `Let Claude recommend based on stack` | `Not sure yet`

10. **Existing Assets**
   "Do you have anything built already? (code, designs, wireframes, competitor notes, domain name)"
   Options: `Starting from zero` | `Have designs/wireframes` | `Have a prototype` | `Have a partial codebase` | `Migrating from existing product`

11. **What Are You Building?**
    "What are you building?"
    Options: `Web application (interactive, needs backend)` | `Website (content-focused, mostly static)` | `Mobile app (iOS / Android)` | `Backend API / microservice` | `CLI tool` | `Desktop application` | `AI agent / automation` | `Library / SDK` | `Other (describe)`

12. **Where Will Users Access It?**
    "Where will users primarily interact with this?"
    Options: `Web browser` | `Mobile app (App Store / Play Store)` | `Desktop app` | `Terminal / CLI` | `API only (no direct user interface)` | `Multiple platforms (describe)` | `Not sure yet`

13. **Business Stage** (monetization context)
    "What stage is your business or project?"
    Options: `Just exploring / side project` | `Pre-revenue startup` | `Early revenue` | `Growth stage` | `Profitable / established` | `Internal tool (no revenue goal)`

14. **Revenue Model** (monetization context)
    "How do you plan to make money? (or N/A for internal tools)"
    Options: `Freemium (free tier + paid upgrades)` | `Subscription (SaaS)` | `One-time purchase` | `Marketplace / transaction fees` | `Ad-supported` | `Open source + services` | `Not sure yet` | `N/A — internal tool`

### Step 4: Educational Inline

During Q&A, when answers touch on glossary concepts, briefly explain them inline.

**When to surface a definition:**
- User mentions "RAG" or "vector database" → explain the concept
- User describes an agent workflow → explain ReAct, tool calling
- User mentions "fine-tuning" or "embeddings" → explain the distinction
- Architecture involves AI → explain inference, context window, grounding

**Format:**
```
> **RAG (Retrieval Augmented Generation)** — Fetch real documents, inject them into the
> prompt so AI answers from facts, not memory. This is likely what you want for {their use case}.
```

Read `references/ai-glossary.md` for definitions. Don't force explanations — only when natural.

### Step 5: Synthesize & Confirm

After all questions, present a structured summary:

```
Here's what I understand about your project:

**Name:** {inferred or given}
**One-liner:** {synthesized from pitch + answers}
**Problem:** {from Q1}
**Users:** {from Q2}

**Domain Model:**
| Entity | Key Fields | Constraints | Notes |
|--------|-----------|-------------|-------|
| {Entity 1} | {field1}, {field2} | {unique, required, etc.} | {special handling} |
| {Entity 2} | {field1}, {field2} | {constraints} | {notes} |

**Relationships:**
- {Entity 1} 1:N {Entity 2} (a {E1} has many {E2})
- {Entity 2} N:M {Entity 3} (via join table)

**Key User Journey:**
1. {step 1}
2. {step 2}
3. ...

**Auth:** {from Q6}
**Integrations:** {from Q7}
**Scale:** {from Q8}
**API:** {from Q9 — consumers + style}
**Building:** {from Q11}
**Platform:** {from Q12}
**Business Stage:** {from Q13}
**Revenue Model:** {from Q14}

Does this look right? Anything to add or correct?
```

Wait for confirmation before saving.

### Step 6: Save Context

Create `.kickstart/` directory:
```bash
mkdir -p .kickstart
```

Write structured context to `.kickstart/context.md`:

```markdown
# Kickstart Context

**Generated:** {date}
**Project:** {name}
**One-liner:** {description}

## Problem Statement
{What problem this solves, who has it, current alternatives}

## Target Users
- **Primary ICP:** {from Q2}
- **User persona:** {synthesized description}
- **Expected scale:** {from Q8}

## User Journey
1. {step 1}
2. {step 2}
3. ...

## Domain Model

### Entities
| Entity | Key Fields | Type Hints | Constraints | Notes |
|--------|-----------|------------|-------------|-------|
| {Entity 1} | {field1} | {string/uuid/int/etc.} | {PK, unique, required, indexed} | {special handling} |
| {Entity 1} | {field2} | {type} | {constraints} | {notes} |
| {Entity 2} | {field1} | {type} | {constraints} | {notes} |

### Relationships
- {Entity 1} 1:N {Entity 2} — {description}
- {Entity 2} N:M {Entity 3} — via {join_table}

### Data Rules
- **Soft delete:** {which entities use soft delete, if any}
- **Encryption:** {which fields need encryption, if any}
- **Audit trail:** {which entities need created_at/updated_at/deleted_at}

## Authentication & Authorization
- **Model:** {from Q6}
- **Roles:** {if applicable}
- **Special requirements:** {multi-tenant, API keys, etc.}

## Integrations
| System | Purpose | Priority |
|--------|---------|----------|
| {integration 1} | {why} | {must-have / nice-to-have} |

## API Strategy
- **Consumers:** {from Q9 — who calls the API: web, mobile, third parties}
- **Style:** {from Q9 — REST, GraphQL, tRPC, or "TBD"}
- **Public API:** {yes/no — does this expose a public API for third parties?}
- **Versioning:** {if public API: URL (/v1/), header, or "TBD"}

## Constraints
- **Budget:** {from Q8}
- **Timeline:** {from Q8}
- **Compliance:** {from Q8}
- **Platform:** {from Q8}

## Existing Assets
{from Q10}

## What Are You Building
- **Type:** {from Q11 — e.g., Web application, Mobile app, CLI tool}
- **Platform:** {from Q12 — where users access it}
- **Module structure:** {inferred — monorepo, single module, multi-service}

## Business & Monetization
- **Stage:** {from Q13 — e.g., Pre-revenue startup, Growth stage}
- **Revenue Model:** {from Q14 — e.g., Freemium, Subscription, N/A}
- **ICP notes:** {any ICP or willingness-to-pay signals from Q1/Q2}

## AI Concepts Discussed
{List any glossary terms that came up during Q&A with their relevance to this project}
```

### Step 7: Validate & Report

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "kickstart.phase.completed" "_project" "Kickstart Phase 1 complete" '{"phase_number":"1"}'`

**Validate:** Check that `.kickstart/context.md` exists and contains the required sections:
- `## Problem Statement`
- `## Target Users`
- `## Domain Model`
- `## Authentication & Authorization`
- `## API Strategy`

If any section is missing, the intake is incomplete — loop back to the missing question.

**Update state:**
```
Update .kickstart/state.md:
  Phase 1 (Intake) → status: done, completed: {date}
  last_phase: 1
  last_phase_status: done
```

**Report:**
```
  [1] Intake          ✅ done
      Output: .kickstart/context.md
      Entities: {N} identified | Auth: {model} | Integrations: {N}
```

## Post-Conditions
- `.kickstart/context.md` exists with all required sections
- `.kickstart/state.md` updated with Intake → done
- User has confirmed the synthesis is accurate
