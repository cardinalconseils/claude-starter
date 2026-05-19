---
name: cks-stack
description: "CKS production stack — 26-layer reference: design tools, build, infrastructure, security, observability, AI/LLM, payments."
allowed-tools: Read
---

# CKS Stack — Recommended Production Stack

The CKS recommended tech stack for production web applications. 26 layers covering every
production concern a vibecoder needs to own.

## Overview

What vibe coders think "full-stack" means: Frontend + Backend.
What production actually requires: every layer below, owned by you.

**Cost principle:** Free tiers are for validation only. The moment you have real users, assume
you're paying. Design to minimize what scales with usage: egress, function invocations, LLM
tokens, storage reads.

## Layer Groups

| Group | Layers | Focus |
|-------|--------|-------|
| A — Build & Design | 1–5 | Design, Frontend, APIs, Database, Auth |
| B — Infrastructure | 6–9 | Hosting, CI/CD, Cloud, API Testing |
| C — Security | 10–13 | RLS, Rate Limiting, Caching, Scaling |
| D — Observability | 14–16 | Error Tracking, AI Tracing, E2E Testing |
| E — AI & LLM | 17–20 | LLM Gateway, Providers, Fast Inference, Voice |
| F — Payments | 21 | Stripe |
| G — Communication | 22–23 | Email, Internal Comms |
| H — Automation | 24 | n8n |
| I — Sales | 25 | Apollo.io |
| J — Dev Tools | 26 | Claude Code |

## Full Reference

Read `references/stack-layers.md` for tool choices, cost notes, and consolidation decisions per layer.

## When to Use

- **Kickstart Phase 1c**: Present CKS defaults as recommended options in stack selection
- **Shipping checklist Gate 7**: Check which layers are covered for the project maturity stage
- **Cost estimation**: Reference cost notes per layer before adding a paid service
- **Architecture review**: Confirm each production concern has a designated tool

## Maturity Stage Coverage

| Maturity | Required Groups |
|----------|----------------|
| Prototype | A + B (build and deploy working) |
| Pilot | A + B + C security basics + D error tracking (Sentry) |
| Candidate | A + B + C + D + E (if AI) + F (if payments) + G email |
| Production | All relevant groups — no uncovered critical layers |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll add monitoring later" | You will not notice outages until users report them. Set up Sentry before first real user. |
| "Rate limiting can wait" | One abuse incident costs more than a year of Upstash. Wire it at Pilot. |
| "We don't need email yet" | Magic links, receipts, and password resets are day-one features. Resend takes 10 minutes. |
| "I'll figure out the LLM costs later" | Token costs are the #1 bill-spike risk. Model them before writing LLM code. |
