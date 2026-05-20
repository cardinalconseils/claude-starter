---
description: "Luv Marketing agency — dispatch the CEO to orchestrate the full AI-powered marketing team"
argument-hint: "[task or goal]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:luv — Luv Marketing Agency

Dispatches the Luv Marketing CEO. The CEO delegates to CMO (marketing) or CTO (engineering), who delegate to their specialist teams. Fully agentic org chart — one prompt fans out through the hierarchy.

## Usage

```
/cks:luv Write a launch campaign for our new product
/cks:luv Audit our SEO and fix the top 3 issues
/cks:luv Build a landing page for our webinar with tracking
/cks:luv Set up a Meta Ads campaign targeting SaaS founders
```

## How it works

```
CEO (luv:ceo)
├── CMO (luv:cmo)          → marketing tasks
│   ├── Strategist         → positioning, ICP, GTM
│   ├── AdsCopywriter      → short-form ad copy
│   ├── LongFormCopywriter → blog, email, case studies
│   ├── SEO_GEO_AEO        → search + AI visibility
│   ├── DataScientist      → analytics, A/B tests
│   ├── PaidMediaManager   → Meta, Google, LinkedIn ads
│   ├── LandingPageDev     → pages + CRO
│   └── N8nAutomation      → marketing workflows
└── CTO (luv:cto)          → engineering tasks
    ├── TechLead           → roadmap, sprints
    ├── BackendDev         → API, FastAPI, MongoDB
    ├── FrontendDev        → React, PWA
    └── DevOps             → infra, CI/CD
```

## Dispatch

**with args:** `Agent(subagent_type="luv:ceo", prompt="Task: {$ARGUMENTS}. Set the strategic frame, delegate to CMO or CTO as appropriate, and report outcomes.")`

**no args:** AskUserQuestion — "What should the Luv Marketing agency work on?" with options: Launch campaign / SEO audit / Landing page / Paid ads campaign / Content strategy / Engineering task
