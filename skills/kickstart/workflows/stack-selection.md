# Workflow: Stack & Platform Selection (Phase 1c)

## Overview
Explicit technology stack and deployment platform discussion with the user. Produces
`.kickstart/stack.md` with concrete decisions that feed Design (Phase 5) and Handoff (Phase 6).

## Input
- `.kickstart/context.md` (required — from Intake)
- `.kickstart/manifest.md` (required — from Compose)
- `.kickstart/research.md` (optional — stack recommendations if research was run)

## Steps

### Step 1: Check for Existing Stack File

Read `.kickstart/stack.md` if it exists.
- If complete → ask: "Stack already decided. Re-do or skip?"
- If partial → resume from where it left off
- If not found → fresh stack selection

### Step 2: Platform Selection

Ask using AskUserQuestion:

```
AskUserQuestion:
  question: "What's your PRIMARY deployment platform?"
  options:
    - "Web browser (website or web app)"
    - "Mobile (iOS / Android / React Native / Flutter)"
    - "Desktop (Electron / Tauri / native)"
    - "Server / API only (no UI)"
    - "CLI tool"
    - "Multiple platforms (describe)"
```

Follow-up if "Multiple platforms":
```
AskUserQuestion:
  question: "Which platforms? (select all that apply)"
  options:
    - "Web + Mobile"
    - "Web + Desktop"
    - "Web + API for third parties"
    - "Mobile + API"
    - "Other combination (describe)"
```

### Step 3: Frontend Framework

Skip if platform is "Server / API only" or "CLI tool".

Read `.kickstart/context.md` for project type and `.kickstart/research.md` for recommendations (if exists).

```
AskUserQuestion:
  question: "Frontend framework preference?"
  options:
    - "Next.js (React, full-stack)"
    - "React (SPA or with separate backend)"
    - "Vue / Nuxt"
    - "Svelte / SvelteKit"
    - "Astro (content-heavy, static-first)"
    - "React Native / Expo (mobile)"
    - "Flutter (mobile/desktop)"
    - "No framework (vanilla HTML/CSS/JS)"
    - "Let Claude recommend based on requirements"
    - "Other (describe)"
```

### Step 4: Backend Framework

Skip if context shows "Static website / landing page" with no API needs.

```
AskUserQuestion:
  question: "Backend framework preference?"
  options:
    - "Node.js / Express"
    - "Node.js / Fastify"
    - "Next.js API routes (serverless)"
    - "Python / FastAPI"
    - "Python / Django"
    - "Go (standard library or Gin/Echo)"
    - "Rust (Actix / Axum)"
    - "Ruby on Rails"
    - "Serverless functions only (AWS Lambda / Vercel / Cloudflare Workers)"
    - "Let Claude recommend"
    - "Other (describe)"
```

### Step 5: Database

```
AskUserQuestion:
  question: "Database preference?"
  options:
    - "PostgreSQL"
    - "MySQL / MariaDB"
    - "SQLite (local / embedded)"
    - "MongoDB"
    - "Supabase (PostgreSQL + auth + realtime)"
    - "Firebase / Firestore"
    - "Redis (cache / primary)"
    - "No database needed"
    - "Let Claude recommend"
    - "Other (describe)"
```

Follow-up if database selected and scale expectations are moderate+:
```
AskUserQuestion:
  question: "Do you need any of these data services?"
  options:
    - "Full-text search (Elasticsearch / Meilisearch / Algolia)"
    - "Caching layer (Redis / Memcached)"
    - "Message queue (RabbitMQ / SQS / BullMQ)"
    - "Vector database for AI (Pinecone / pgvector / Weaviate)"
    - "None of these"
    - "Not sure yet"
```

### Step 5b: AI Gateway (if project uses AI features)

Skip if no AI API calls are planned for this project.

Trigger if context shows: AI chat, AI generation, AI summarization, AI classification, model calls, LLM integration, or any mention of AI-powered features.

```
AskUserQuestion:
  question: "Does this project call AI APIs (chat, generation, summarization, etc.)?"
  options:
    - "Yes — it has AI-powered features"
    - "No — no AI API calls needed"
    - "Not sure yet"
```

If yes, trigger the OpenRouter model research workflow:
- Load `skills/openrouter/SKILL.md`
- Run `skills/openrouter/workflows/model-research.md`
- The workflow will ask about task types, fetch live model candidates, and let the user select

Record the AI gateway decision in the stack file:
```
## AI Gateway
- **Provider:** OpenRouter (or: Direct Anthropic / Direct OpenAI / TBD)
- **Models:** {task-type → selected model, from research workflow}
```

### Step 6: Hosting & Deployment

```
AskUserQuestion:
  question: "Where do you want to deploy?"
  options:
    - "Vercel (optimized for Next.js / frontend)"
    - "Railway (full-stack, easy setup)"
    - "Fly.io (containers, edge compute)"
    - "AWS (EC2 / ECS / Lambda)"
    - "Google Cloud (Cloud Run / GKE)"
    - "DigitalOcean (Droplets / App Platform)"
    - "Self-hosted / VPS"
    - "Not sure yet — decide later"
    - "Other (describe)"
```

### Step 7: CI/CD Preference

```
AskUserQuestion:
  question: "CI/CD preference?"
  options:
    - "GitHub Actions"
    - "GitLab CI"
    - "Vercel / Railway auto-deploy (from git push)"
    - "None for now — manual deploys"
    - "Other (describe)"
```

### Step 8: Synthesize & Confirm

Present a structured summary:

```
Here's your technology stack:

**Platform:**     {from Step 2}
**Frontend:**     {from Step 3 or N/A}
**Backend:**      {from Step 4 or N/A}
**Database:**     {from Step 5}
**Data Services:**{from Step 5 follow-up or None}
**Hosting:**      {from Step 6}
**CI/CD:**        {from Step 7}

Does this look right? Anything to change?
```

Wait for confirmation.

### Step 9: Save Stack File

Write to `.kickstart/stack.md`:

```markdown
# Technology Stack

**Generated:** {date}
**Project:** {name from context.md}

## Platform
- **Primary:** {platform}
- **Secondary:** {if multiple}

## Frontend
- **Framework:** {choice}
- **Rationale:** {why this fits the project}

## Backend
- **Framework:** {choice}
- **Rationale:** {why this fits}

## Database
- **Primary:** {choice}
- **Data Services:** {search, cache, queue, vector — if any}
- **Rationale:** {why this fits}

## AI Gateway
- **Provider:** {OpenRouter | Direct Anthropic | Direct OpenAI | None}
- **Models:** {task-type: model-id — e.g. fast: google/gemini-flash-2.0}
- **Rationale:** {why this fits}

## Hosting & Deployment
- **Platform:** {choice}
- **CI/CD:** {choice}
- **Rationale:** {why this fits}

## Stack Summary Table

| Layer | Technology | Version | Notes |
|-------|-----------|---------|-------|
| Frontend | {framework} | latest | {notes} |
| Backend | {framework} | latest | {notes} |
| Database | {db} | latest | {notes} |
| Hosting | {platform} | — | {notes} |
| CI/CD | {tool} | — | {notes} |
```

### Step 10: Validate & Report

**Validate:** Check that `.kickstart/stack.md` exists and contains required sections:
- `## Platform`
- `## Frontend` (or confirmed N/A)
- `## Backend` (or confirmed N/A)
- `## Database`
- `## Hosting & Deployment`

**Update state:**
```
Update .kickstart/state.md:
  Phase 1c (Stack Selection) → status: done, completed: {date}
  last_phase: 1c
  last_phase_status: done
```

**Report:**
```
  [1c] Stack Selection  ✅ done
       Output: .kickstart/stack.md
       Stack: {frontend} + {backend} + {db} on {hosting}
```

## Post-Conditions
- `.kickstart/stack.md` exists with all required sections
- `.kickstart/state.md` updated with Stack Selection → done
- User has confirmed the stack choices
