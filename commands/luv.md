---
description: "Luv Marketing agency — dispatch the marketing director to frame the task and route it through the marketer's persona bench"
argument-hint: "[task or goal]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:luv — Luv Marketing Agency

One prompt, one marketer. The `cks:marketer` role carries the whole Luv bench as personas
(`skills/marketing/personas/`); the marketing-director persona sets the strategic frame,
picks the specialist voices, and reports outcomes. Engineering asks are returned to you
with the role to dispatch (`cks:builder`, `cks:shipper`) — the marketer never writes code.

## Quick Reference

```
/cks:luv Write a launch campaign for our new product
/cks:luv Position our product against Salesforce
/cks:luv Generate 5 product hero images in Peter Belanger style
/cks:luv Create a 15-second TikTok ad using Kling
/cks:luv Write a whitepaper in the Apple/TBWA storytelling style
/cks:luv Set up a Meta Ads campaign targeting SaaS founders
```

## Persona bench

```
marketing-director (ex-CEO)  → strategic frame, approvals, budget > $5K escalation
└── campaign-lead (ex-CMO)   → routes to: brand-strategist, strategist, growth-revenue-strategist,
                               ads-copywriter, alan-sharpe, long-form-copywriter, photo-creator,
                               video-creator, video-producer, paid-media-manager, meta-ads-specialist,
                               linkedin-ads-specialist, seo-geo-aeo, designer, data-scientist,
                               claims-compliance, brand-security, outbound-prospector
```

## Dispatch

**with args:**
```
Agent(subagent_type="cks:marketer", prompt="Persona: marketing-director. Task: {$ARGUMENTS}. Set the strategic frame (audience, objective, budget, timeline, success metrics), then work the task through the persona bench in sequence — positioning before copy, copy before creative. Write artifacts to .marketing/ or .campaign/. Anything that needs code, deployment, or spend approval comes back as a hand-off line naming the role.")
```

**no args:** AskUserQuestion — "What should the Luv Marketing agency work on?" with
options: Launch campaign / Brand positioning / Creative assets (photo/video) / Long-form
content / Paid ads / Engineering task (→ `/cks:marketing-dev`)
