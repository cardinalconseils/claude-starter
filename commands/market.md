---
description: "Marketing team — product positioning, brand authority, online traction, social content, AI citations, launch strategy — backed by Ahrefs + DataForSEO"
argument-hint: "[product|brand|online|social|ai|launch|flywheel] [domain]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:market — Marketing Team

Dispatch the right marketing specialist based on discipline.

## Mode Detection

Parse `$ARGUMENTS`:

| Pattern | Mode |
|---------|------|
| `product [domain]` | Product marketing — positioning, ICP, GTM, messaging |
| `brand [domain]` | Brand marketing — DR benchmark, backlinks, voice guide |
| `online [domain]` | Online marketing — keywords, funnel, content calendar, CRO |
| `social [domain]` | Social content — 30-day calendar, platform-specific posts |
| `ai [domain]` | AI marketing — AEO/GEO, llms.txt, AI citations |
| `launch [domain]` | Launch strategy — 8-week campaign plan by maturity stage |
| `flywheel [domain]` | Full flywheel — all 6 disciplines in sequence |
| No args | Ask user which discipline |

## Dispatch

**product**: `Agent(subagent_type="cks:product-marketer", prompt="Domain/brief: {$ARGUMENTS minus 'product'}. Pull Ahrefs data, define ICP, build positioning + messaging + GTM. Write .marketing/product.md.")`

**brand**: `Agent(subagent_type="cks:brand-marketer", prompt="Domain/brief: {$ARGUMENTS minus 'brand'}. Pull DR benchmark and backlink gap from Ahrefs, build brand voice guide, scan for consistency issues. Write .marketing/brand.md.")`

**online**: `Agent(subagent_type="cks:online-marketer", prompt="Domain/brief: {$ARGUMENTS minus 'online'}. Pull keyword opportunities and content gaps from Ahrefs, detect DataForSEO credentials for SERP data. Write .marketing/online.md.")`

**social**: `Agent(subagent_type="cks:social-content", prompt="Domain/brief: {$ARGUMENTS minus 'social'}. Read .marketing/product.md and .marketing/brand.md for context. Build 30-day content calendar per social-content/platforms.yaml. Write .marketing/social.md.")`

**ai**: `Agent(subagent_type="cks:ai-marketer", prompt="Domain/brief: {$ARGUMENTS minus 'ai'}. Audit AI-extraction readiness, generate llms.txt, build prompt-matched content plan, AI directory checklist. Write .marketing/ai.md.")`

**launch**: `Agent(subagent_type="cks:launch-strategist", prompt="Domain/brief: {$ARGUMENTS minus 'launch'}. Detect maturity stage from PROJECT.md. Build 8-week pre/launch/post campaign plan per launch-strategy/phases.yaml. Write .marketing/launch.md.")`

**flywheel**: Run all 6 agents in sequence: product — brand — online — social — ai — launch. Each reads prior outputs for context. After all 6 complete, synthesize `.marketing/flywheel.md` — a unified 90-day action plan with interdependencies and priority stack.

**no args**: AskUserQuestion — "Which marketing discipline?" (product / brand / online / social / ai / launch / flywheel)

## Quick Reference

```
/cks:market product payFacto.com    → Positioning + ICP + GTM + keyword map
/cks:market brand payFacto.com      → DR benchmark + backlink gap + brand voice
/cks:market online payFacto.com     → Keyword opportunities + funnel + content calendar
/cks:market social payFacto.com     → 30-day social calendar (all platforms)
/cks:market ai payFacto.com         → AEO audit + llms.txt + AI citation strategy
/cks:market launch payFacto.com     → 8-week launch campaign plan by maturity stage
/cks:market flywheel payFacto.com   → Full 6-discipline traction audit + 90-day plan
/cks:market                         → Pick discipline interactively
```

Output: `.marketing/` directory (product.md, brand.md, online.md, social.md, ai.md, launch.md, flywheel.md)
