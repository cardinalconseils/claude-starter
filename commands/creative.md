---
description: "Luv creative suite — dispatch copywriters, brand strategist, photo creator, and video creator directly without going through the full agency hierarchy"
argument-hint: "[creative task]"
allowed-tools: Read, Agent, AskUserQuestion
---

# /cks:creative — Luv Creative Suite

Direct access to the creative personas of `cks:marketer`. Use instead of `/cks:luv` when
the task is purely creative — no engineering, no analytics, no media buying. One dispatch,
one named persona.

## Quick Reference

```
/cks:creative Write 5 Google Ads headlines for our B2B SaaS product
/cks:creative Alan Sharpe style email for manufacturing procurement managers
/cks:creative Brand positioning workshop for our new fintech product
/cks:creative Generate hero images for our product launch (Peter Belanger style)
/cks:creative 15-second Instagram Reels ad — Kling video
/cks:creative Write a thought leadership whitepaper for our CEO
```

## Persona selection

| Request signal | `Persona:` | Voice |
|---|---|---|
| Google / Meta / LinkedIn ad copy, headlines, CTAs | `ads-copywriter` | Joel Klettke VoC methodology |
| B2B direct response, industrial, professional services | `alan-sharpe` | Alan Sharpe precision |
| Blog, whitepaper, email sequence, case study | `long-form-copywriter` | TBWA\Media Arts Lab storytelling |
| Positioning, mission/vision, key messages, community | `brand-strategist` | April Dunford + Seth Godin |
| Product / campaign photography | `photo-creator` | Peter Belanger aesthetic, gpt-image-1 |
| Ad clips, social video, text- or image-to-video | `video-creator` | Kling, platform-specific specs |

Persona files, API call patterns, platform specs, and frameworks live in
`skills/marketing/personas/` — deterministic parts in frontmatter, voice in the body.

## Dispatch

```
Agent(subagent_type="cks:marketer", prompt="Persona: {persona from the table}. Creative brief: {$ARGUMENTS}. Read .marketing/brand.md and .marketing/product.md if present for voice and ICP. Deliver ready-to-use output (copy variants, generated asset paths, or prompts) to .marketing/creative/. No placeholders.")
```

**No args or ambiguous:** AskUserQuestion with options: Short-form ad copy / B2B direct
response copy (Alan Sharpe) / Long-form content / Brand positioning + strategy / Product
photography / Video content
