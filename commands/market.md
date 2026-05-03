---
description: "Marketing team — product positioning, brand authority, online traction, AI citations — backed by Ahrefs + DataForSEO"
argument-hint: "[product|brand|online|ai|flywheel] [domain]"
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
| `ai [domain]` | AI marketing — AEO/GEO, llms.txt, AI citations |
| `flywheel [domain]` | Full flywheel — all 4 disciplines in sequence |
| No args | Ask user which discipline |

## Dispatch

**product**: `Agent(subagent_type="cks:product-marketer", prompt="Domain/brief: {$ARGUMENTS minus 'product'}. Pull Ahrefs data, define ICP, build positioning + messaging + GTM. Write .marketing/product.md.")`

**brand**: `Agent(subagent_type="cks:brand-marketer", prompt="Domain/brief: {$ARGUMENTS minus 'brand'}. Pull DR benchmark and backlink gap from Ahrefs, build brand voice guide, scan for consistency issues. Write .marketing/brand.md.")`

**online**: `Agent(subagent_type="cks:online-marketer", prompt="Domain/brief: {$ARGUMENTS minus 'online'}. Pull keyword opportunities and content gaps from Ahrefs, detect DataForSEO credentials for SERP data. Write .marketing/online.md.")`

**ai**: `Agent(subagent_type="cks:ai-marketer", prompt="Domain/brief: {$ARGUMENTS minus 'ai'}. Audit AI-extraction readiness, generate llms.txt, build prompt-matched content plan, AI directory checklist. Write .marketing/ai.md.")`

**flywheel**: Run all 4 agents in sequence, passing domain to each. After all 4 complete, synthesize `.marketing/flywheel.md` — a unified 90-day action plan with interdependencies and priority stack.

**no args**: AskUserQuestion — "Which marketing discipline?" (product / brand / online / ai / flywheel)

## Quick Reference

```
/cks:market product payFacto.com    → Positioning + ICP + GTM + keyword map
/cks:market brand payFacto.com      → DR benchmark + backlink gap + brand voice
/cks:market online payFacto.com     → Keyword opportunities + funnel + content calendar
/cks:market ai payFacto.com         → AEO audit + llms.txt + AI citation strategy
/cks:market flywheel payFacto.com   → Full 4-discipline traction audit + 90-day plan
/cks:market                         → Pick discipline interactively
```

Output: `.marketing/` directory (product.md, brand.md, online.md, ai.md, flywheel.md)
