---
name: mckinsey-strategy-os
description: McKinsey-style strategy OS — routes strategic analysis requests to the right module skill. Activate when PMC asks for strategic analysis, consulting-style frameworks, or structured business thinking. Covers: situation diagnosis, market mapping, strategic options, operating models, KPIs and risk, and executive communication.
allowed-tools: Read
---

# McKinsey Strategy OS

A routing and behavior spec for strategic analysis work. Maps 6 modules to 12 CKS skills (6 new + 6 existing). When activated, load the right module skill based on trigger phrases — don't blend modules.

## Module → Skill Routing Table

| Module | Skill to Load | Trigger Phrases |
|---|---|---|
| M01 Diagnosis & Framing | `situation-assessment` | "what's going on with", "frame this problem", "why isn't X working", "growth barriers", "wrong assumptions", "situation assessment" |
| M02 Market & Competitive | `market-mapping` | "map the market", "who are the competitors", "who should I target", "where's the money", "profit pool", "competitive landscape", "who's winning" |
| M02 Competitive Intel (SEO) | `competitor-alternatives` | "alternatives page", "vs page", "competitor comparison" |
| M02 Customer Segments | `customer-research` | "customer research", "ICP", "user interviews", "win/loss" |
| M03 Strategic Options | `strategic-options` | "strategic options", "should I do X or Y", "business case", "financial model", "ROI", "portfolio review", "where to play" |
| M03 Pricing | `pricing-strategy` | "pricing", "pricing tiers", "freemium", "packaging", "willingness to pay" |
| M04 Operating Model | `operating-model` | "how do I run this", "operating model", "prioritize initiatives", "90-day plan", "what to cut", "sequence this" |
| M04 Launch Roadmap | `launch-strategy` | "launch plan", "go-to-market", "Product Hunt", "press strategy" |
| M05 KPIs & Risk | `kpi-architect` | "KPIs for X", "what metrics matter", "war game", "what could kill this", "RAID", "governance", "value realization" |
| M05 Deep Stress-Test | `grill-me` | "grill me on this", "interrogate my plan", "challenge every assumption" |
| M06 Decision Memo | `decision-memo` | "decision memo", "exec brief", "pyramid this", "how do I present to", "stakeholder alignment", "narrative for X", "make this persuasive" |
| M06 Pitch/One-Pager | `sales-enablement` | "pitch deck", "one-pager", "sales deck", "objection handling" |

## Multi-Module Composition Rules

Complete one module's output before moving to the next. Output from each module is the input to the next.

Common multi-module sequences:

**"Should I launch X in this market?"**
`market-mapping` → `strategic-options`

**"I want to go faster — what do I cut?"**
`operating-model` → `kpi-architect`

**"Build the case and write the exec memo"**
`strategic-options` → `decision-memo`

**"Full strategy review for X"**
`situation-assessment` → `market-mapping` → `strategic-options` → `operating-model`

Rule: when running multi-module, complete one output before starting the next. PMC can redirect at each handoff — the handoff is a checkpoint, not an automatic continuation.

## Quality Bar

Mandatory before delivering any strategic output:

- [ ] Led with a position, not a framework recap
- [ ] Exactly ONE recommended path (not "it depends")
- [ ] Answers: what do I do next, and what would make me wrong?
- [ ] Under 90 seconds to read (if not, cut)
- [ ] Single most dangerous assumption flagged

## What This Skill Is NOT

- Not a general business Q&A router — for open-ended business research, use `deep-research`
- Not a writing skill — for marketing copy, use `copywriting`
- Not a brainstorm trigger — for divergence and idea generation, use `ideation`
- Not a security or compliance risk tool — for that, use `ciso`

This skill routes to structured consulting logic. Output is always position + next action. Never a menu of options with no recommendation.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just ask Claude directly without loading a module" | Direct asks produce generic outputs. Module routing produces structured outputs with McKinsey discipline baked in. |
| "The modules overlap — I'll blend them" | Blending produces hybrid outputs that satisfy neither question. Complete one module, then move. The handoff is the point where context resets cleanly. |
| "This is overkill for a simple question" | Simple questions answered with module discipline take 2 extra minutes. The output quality difference is 10×. |
| "I'll skip the quality bar — the output looks good" | The quality bar is 5 checks. Run them. "Looks good" is not evidence. |
