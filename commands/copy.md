---
description: "Copywriter — hero copy, email sequences, ad copy, landing pages using PAS/AIDA/BAB/FAB frameworks adapted to brand voice and ICP"
argument-hint: "[hero|email|ad|landing|all] [context or domain]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:copy — Copywriter

Dispatch the copywriter agent for framework-driven copy in any format.

## Mode Detection

Parse `$ARGUMENTS`:

| Pattern | Mode |
|---------|------|
| `hero [context]` | Hero copy — headline, subheadline, above-fold CTA |
| `email [context]` | Email copy — subject line + body for cold, drip, or one-off |
| `ad [context]` | Ad copy — 3 variants per format (Google RSA, Meta) |
| `landing [context]` | Landing page — full above-fold + sections |
| `all [context]` | All formats in sequence |
| No args | Ask user which format |

## Prerequisites Check

Before dispatching, check if context files exist:

```
Read .marketing/product.md — missing? warn user
Read .marketing/brand.md — missing? warn user
```

If both missing: recommend running `/cks:market product [domain]` and `/cks:market brand [domain]` first. Proceed anyway if user confirms — agent will ask for context inline.

## Dispatch

`Agent(subagent_type="cks:copywriter", prompt="Mode: {mode}. Context: {$ARGUMENTS minus mode}. Read .marketing/product.md and .marketing/brand.md for ICP and brand voice. Apply framework from copywriting/config.yaml. Write to .marketing/copy/{mode}.md.")`

## Quick Reference

```
/cks:copy hero payFacto.com      → Hero headline (7w max) + subheadline + CTA
/cks:copy email "product launch" → Email subject + body for launch announcement
/cks:copy ad payFacto.com        → 3 ad variants (Google RSA + Meta formats)
/cks:copy landing "free trial"   → Landing page copy — above-fold + sections
/cks:copy all payFacto.com       → All formats in sequence
/cks:copy                        → Pick format interactively
```

Output: `.marketing/copy/` directory (hero.md, email.md, ads.md, landing.md)
