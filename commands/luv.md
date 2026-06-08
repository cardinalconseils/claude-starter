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
/cks:luv Position our product against Salesforce
/cks:luv Generate 5 product hero images in Peter Belanger style
/cks:luv Create a 15-second TikTok ad using Kling
/cks:luv Write a whitepaper in the Apple/TBWA storytelling style
/cks:luv Set up a Meta Ads campaign targeting SaaS founders
```

## How it works

```
CEO (luv:ceo)
├── CMO (luv:cmo)              → marketing tasks
│   ├── BrandStrategist        → positioning, mission/vision, community (April Dunford + Seth Godin)
│   ├── Strategist             → competitive intel, GTM, channel strategy
│   ├── AdsCopywriter          → short-form ad copy (Joel Klettke / VoC methodology)
│   ├── AlanSharpe             → B2B direct response copy (industrial, professional services)
│   ├── LongFormCopywriter     → blog, whitepaper, email sequences (TBWA\Media Arts Lab)
│   ├── PhotoCreator           → product photography via OpenAI gpt-image-1 (Peter Belanger)
│   ├── VideoCreator           → AI video via Kling API (platform-specific)
│   ├── SEO_GEO_AEO            → search + AI visibility
│   ├── DataScientist          → analytics, A/B tests
│   ├── PaidMediaManager       → Meta, Google, LinkedIn ads
│   ├── LandingPageDev         → pages + CRO
│   └── N8nAutomation          → marketing workflows
└── CTO (luv:cto)              → engineering tasks
    ├── TechLead               → roadmap, sprints
    ├── BackendDev             → API, FastAPI, MongoDB
    ├── FrontendDev            → React, PWA
    └── DevOps                 → infra, CI/CD
```

## Dispatch

**with args:** `Agent(subagent_type="luv:ceo", prompt="Task: {$ARGUMENTS}. Set the strategic frame, delegate to CMO or CTO as appropriate, and report outcomes.")`

**no args:** AskUserQuestion — "What should the Luv Marketing agency work on?" with options: Launch campaign / Brand positioning / Creative assets (photo/video) / Long-form content / Paid ads / Engineering task
