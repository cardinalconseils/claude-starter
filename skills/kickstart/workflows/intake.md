# Workflow: Intake (Phase 1)

## Overview
Deep guided Q&A to understand the project idea — domain, users, data model, integrations,
and constraints. Produces `.kickstart/context.md` with structured context that feeds all
downstream phases.

## Input
- `$IDEA` — optional pitch text from `/kickstart` argument
- `references/ai-glossary.md` — for inline educational explanations

## Steps

### Step 1: Check for Existing Context

Read `.kickstart/context.md` if it exists.

- If complete context exists → ask: "Intake already done. Re-do or skip to next phase?"
- If partial context exists → resume from where it left off
- If no context → fresh intake

### Step 2: Idea Pitch

If `$IDEA` was provided as argument, use it directly.

If no argument, ask:

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

5. **Data & Relationships**
   "For each entity, what are the key properties? Any that need special handling?"
   Examples: "Is there financial data (needs encryption)? User content (needs moderation)? Files (needs storage)?"

6. **Auth Model**
   "How do users access the system?"
   Options: `Public (no login)` | `Simple login (email/password)` | `OAuth (Google, GitHub, etc.)` | `Role-based (admin/user/viewer)` | `Multi-tenant (orgs with members)` | `API keys`

7. **Integrations**
   "What external systems does this connect to?"
   Options: `Payment (Stripe, etc.)` | `Email (SendGrid, etc.)` | `Storage (S3, etc.)` | `AI/LLM APIs` | `Calendar` | `CRM` | `Custom APIs` | `None yet`

8. **Scale & Constraints**
   "What's your expected scale at launch and at 12 months?"
   Also ask: "Any hard constraints? (budget, timeline, compliance, platform requirements)"

9. **Existing Assets**
   "Do you have anything built already? (code, designs, wireframes, competitor notes, domain name)"
   Options: `Starting from zero` | `Have designs/wireframes` | `Have a prototype` | `Have a partial codebase` | `Migrating from existing product`

10. **Project Type**
    "What type of project is this?"
    Options: `Full-stack web app` | `Backend API / microservice` | `Frontend SPA` | `Static website / landing page` | `CLI tool` | `Mobile app (React Native / Flutter)` | `AI agent / automation` | `Library / SDK` | `Other (describe)`

11. **Stack Preferences**
    "Any technology preferences or requirements?"
    Options: `Let Claude recommend` | `I have specific preferences (list them)` | `Must match existing team skills`

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

**Core Entities:**
- {Entity 1} → has many {Entity 2}
- {Entity 2} → belongs to {Entity 1}, has many {Entity 3}
- ...

**Key User Journey:**
1. {step 1}
2. {step 2}
3. ...

**Auth:** {from Q6}
**Integrations:** {from Q7}
**Scale:** {from Q8}
**Project Type:** {from Q10}
**Stack:** {from Q11 or recommendation}

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
| Entity | Key Properties | Notes |
|--------|---------------|-------|
| {Entity 1} | {props} | {special handling} |
| {Entity 2} | {props} | {special handling} |

### Relationships
- {Entity 1} 1:N {Entity 2}
- {Entity 2} N:M {Entity 3}
- ...

## Authentication & Authorization
- **Model:** {from Q6}
- **Roles:** {if applicable}
- **Special requirements:** {multi-tenant, API keys, etc.}

## Integrations
| System | Purpose | Priority |
|--------|---------|----------|
| {integration 1} | {why} | {must-have / nice-to-have} |

## Constraints
- **Budget:** {from Q8}
- **Timeline:** {from Q8}
- **Compliance:** {from Q8}
- **Platform:** {from Q8}

## Existing Assets
{from Q9}

## Project Type
- **Type:** {from Q10 — e.g., Full-stack web app, Backend API, CLI tool}
- **Module structure:** {inferred — monorepo, single module, multi-service}

## Stack Preferences
{from Q11 — or "Claude to recommend based on requirements"}

## AI Concepts Discussed
{List any glossary terms that came up during Q&A with their relevance to this project}
```

### Step 7: Validate & Report

**Validate:** Check that `.kickstart/context.md` exists and contains the required sections:
- `## Problem Statement`
- `## Target Users`
- `## Domain Model`
- `## Authentication & Authorization`

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
