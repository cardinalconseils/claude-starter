# Workflow: Compose (Phase 1b — Project Composition)

## Overview
Identifies all sub-projects, shared concerns, and infrastructure a project needs.
Maps dependencies between them and determines build order. Produces `.kickstart/manifest.md`
that drives per-sub-project design artifacts, handoff, and feature lifecycles.

## Input
- `.kickstart/context.md` — intake output (REQUIRED — must exist before compose runs)
- `skills/prd/templates/manifest.md` — output template

## Pre-Conditions
- `.kickstart/context.md` exists with `## Problem Statement` and `## Domain Model` sections
- If missing, redirect to Intake phase

## Steps

### Step 1: Check for Existing Manifest

Read `.kickstart/manifest.md` if it exists.

- If complete manifest exists → ask: "Composition already done. Re-do or skip to next phase?"
- If partial manifest exists → resume from where it left off
- If no manifest → fresh composition

### Step 2: Analyze Intake Context

Read `.kickstart/context.md` and extract:
- Domain entities and their relationships
- Auth model and user types
- API strategy and consumers
- Integrations and external systems
- Scale expectations

Use this to **pre-populate suggested sub-projects** — don't ask from scratch, propose based on what you know.

### Step 3: Identify Deployment Targets

Based on intake analysis, present suggested sub-projects:

```
AskUserQuestion({
  questions: [{
    question: "Based on your project, I think you need these deployment targets. Select all that apply:",
    header: "Targets",
    multiSelect: true,
    options: [
      // Dynamically generated from intake context. Examples:
      { label: "Backend API (Recommended)", description: "Core API serving all clients — your domain model needs a server" },
      { label: "Web Frontend", description: "Customer-facing web application" },
      { label: "Admin Panel", description: "Internal operations dashboard for managing {entities}" },
      { label: "Marketing / Landing Site", description: "Public-facing marketing pages, pricing, docs" }
      // Add mobile, CLI, worker based on intake signals
    ]
  }]
})
```

**Intelligence rules:**
- If intake mentions "mobile" → suggest Mobile App
- If intake has admin-type users/roles → suggest Admin Panel
- If intake mentions "public API" → suggest API as standalone target
- If intake mentions "landing page" or "marketing" → suggest Marketing Site
- If intake has background jobs or queue → suggest Worker Service
- Always suggest Backend API if there are domain entities + auth

### Step 4: Identify Shared Concerns

```
AskUserQuestion({
  questions: [{
    question: "Which cross-cutting concerns need shared design? These will be built once and used by multiple sub-projects:",
    header: "Shared",
    multiSelect: true,
    options: [
      // Dynamically generated from intake. Examples:
      { label: "Authentication & SSO (Recommended)", description: "Single auth system for all sub-projects — {auth model from intake}" },
      { label: "Payments / Billing", description: "Shared payment processing — {integration from intake}" },
      { label: "Notifications", description: "Email, push, in-app notifications across sub-projects" },
      { label: "File Storage", description: "Shared file upload/storage service" }
      // Add search, messaging, analytics based on intake signals
    ]
  }]
})
```

**Intelligence rules:**
- If intake auth model isn't "Public" → always suggest Auth
- If intake mentions Stripe/payment → suggest Payments
- If intake has file/upload entities → suggest File Storage
- If intake mentions search or full-text → suggest Search

### Step 5: Identify Infrastructure

```
AskUserQuestion({
  questions: [{
    question: "What infrastructure does this project need?",
    header: "Infra",
    multiSelect: true,
    options: [
      { label: "Database (Recommended)", description: "Primary data store — {suggest based on stack prefs}" },
      { label: "Queue / Workers", description: "Background job processing for async tasks" },
      { label: "CDN / Edge", description: "Static asset delivery and edge caching" },
      { label: "Monitoring / Logging", description: "Observability stack for all sub-projects" }
      // Add cache, search engine, etc. based on intake signals
    ]
  }]
})
```

### Step 6: Capture Details per Sub-Project

For each selected sub-project, ask ONE focused question to refine it:

```
AskUserQuestion({
  questions: [
    // Up to 4 questions per call, batch sub-projects
    {
      question: "For the Backend API — what's the core responsibility?",
      header: "SP-01",
      multiSelect: false,
      options: [
        { label: "Full domain logic + API (Recommended)", description: "All business logic lives here, frontends are thin clients" },
        { label: "API gateway + microservices", description: "Route to domain-specific services" },
        { label: "BFF pattern", description: "Backend-for-Frontend, tailored API per client type" }
      ]
    },
    {
      question: "For the Admin Panel — what's the primary audience?",
      header: "SP-02",
      multiSelect: false,
      options: [
        { label: "Internal team only", description: "Your ops team managing the platform" },
        { label: "Customer admins", description: "Tenant admins managing their org's data" },
        { label: "Both", description: "Internal super-admin + tenant admin views" }
      ]
    }
  ]
})
```

Adapt questions per sub-project type. Skip obvious answers (e.g., don't ask "what does the database do").

### Step 7: Build Dependency Graph

Automatically determine dependencies based on:
- Backend API depends on Database and Auth
- Frontend/Admin/Marketing depend on Backend API
- All authenticated sub-projects depend on Auth
- Payment-related sub-projects depend on Payments shared concern
- Sub-projects with file uploads depend on File Storage

Present the dependency graph for confirmation:

```
AskUserQuestion({
  questions: [{
    question: "Here's the dependency graph I've worked out. Does this look right?",
    header: "Dependencies",
    multiSelect: false,
    options: [
      { label: "Looks correct (Recommended)", description: "Proceed with this dependency structure" },
      { label: "Needs adjustment", description: "I'll describe what to change" }
    ]
  }]
})
```

Display the Mermaid graph inline before the question so the user can see it.

### Step 8: Determine Build Order

From the dependency graph, compute build order:
1. **Foundation:** Infrastructure + shared concerns (no dependencies)
2. **Core:** Sub-projects that others depend on (highest fan-out)
3. **Parallel:** Sub-projects at the same dependency depth (can be built concurrently)
4. **Final:** Leaf sub-projects (most dependencies, fewest dependents)

### Step 9: Generate Cross-Project Contracts

Based on dependencies, generate the contracts table:
- API contracts: which sub-project exposes what endpoints, consumed by whom
- Auth contracts: token format, session management, shared across which sub-projects
- Data contracts: shared schema conventions, naming, soft deletes
- Event contracts: if any sub-project publishes events others consume

### Step 10: Write Manifest

Read template from `skills/prd/templates/manifest.md`.

Create `.kickstart/` directory if needed:
```bash
mkdir -p .kickstart
```

Write to `.kickstart/manifest.md` filling all sections:
- Sub-Projects (with SP-{NN} IDs)
- Shared Concerns (with SC-{NN} IDs)
- Infrastructure (with INFRA-{NN} IDs)
- Dependency Graph (Mermaid)
- Build Order (priority groups)
- Cross-Project Contracts

### Step 11: Confirm with User

Present a summary:

```
Project Composition Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sub-Projects:     {N}
Shared Concerns:  {N}
Infrastructure:   {N}

Build Order:
  1. {Foundation items}
  2. {Core items}
  3. {Parallel items}
  4. {Final items}

Contracts: {N} cross-project agreements defined
```

```
AskUserQuestion({
  questions: [{
    question: "Project composition complete. Proceed to research phase?",
    header: "Confirm",
    multiSelect: false,
    options: [
      { label: "Approve — proceed (Recommended)", description: "Move to Phase 2: Research" },
      { label: "Adjust sub-projects", description: "Add, remove, or modify sub-projects" },
      { label: "Redo composition", description: "Start over" }
    ]
  }]
})
```

### Step 12: Validate & Report

**Validate:** Check that `.kickstart/manifest.md` exists and contains:
- `## Sub-Projects` with at least 1 SP-{NN} entry
- `## Dependency Graph` with a mermaid block
- `## Build Order` with at least 1 priority group

If any section is missing, loop back to the relevant step.

**Update state:**
```
Update .kickstart/state.md:
  Phase 1b (Compose) → status: done, completed: {date}
  last_phase: 1b
  last_phase_status: done
  sub_projects: {count}
```

**Report:**
```
  [1b] Compose        ✅ done
       Output: .kickstart/manifest.md
       Sub-Projects: {N} | Shared: {N} | Infra: {N} | Build Groups: {N}
```

## Single Sub-Project Fallback

If during Step 3 the user selects only ONE deployment target and no shared concerns:
- Still generate the manifest (with 1 SP entry)
- Skip Steps 7-9 (dependency graph, build order, contracts are trivial)
- Mark shared concerns and infrastructure as minimal
- The manifest exists but is lightweight — downstream phases handle it normally

This ensures the compose phase doesn't add overhead for simple projects while keeping
the manifest as a consistent interface for all downstream workflows.

## Post-Conditions
- `.kickstart/manifest.md` exists with all required sections
- `.kickstart/state.md` updated with Compose → done
- User has confirmed the composition is accurate
