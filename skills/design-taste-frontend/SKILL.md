---
name: design-taste-frontend
description: >
  Anti-slop frontend skill for landing pages, portfolios, and redesigns. Reads the
  brief, infers the right design direction, ships interfaces that do not look
  templated. Real design systems when applicable, audit-first on redesigns, strict
  pre-flight check. Use when: building landing pages, portfolios, marketing sites,
  or redesigning existing frontend surfaces. NOT for dashboards, data tables, or
  multi-step product UI.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, WebFetch, AskUserQuestion, mcp__*
---

# Design Taste Frontend (Anti-Slop)

## What This Skill Does

Prevents AI-generated visual cliches on landing pages, portfolios, and marketing sites. Enforces brief inference, dial-based design configuration, real design system selection, and a mandatory pre-flight check before shipping.

## When to Use

- Building landing pages, portfolios, marketing sites
- Redesigning existing frontend surfaces
- Any consumer-facing page where design quality matters

## When NOT to Use

- Dashboards / dense product UI / admin panels
- Data tables (use TanStack Table or AG Grid)
- Multi-step forms / wizards
- Code editors, native mobile, realtime collab UIs

## Core Methodology

1. **Brief Inference:** Read the room before touching code. Infer page kind, vibe, audience, brand assets, quiet constraints. Output a one-line "Design Read" before generating.
2. **Three Dials:** Set DESIGN_VARIANCE (1-10), MOTION_INTENSITY (1-10), VISUAL_DENSITY (1-10) based on the brief. Baseline: 8/6/4.
3. **Design System Map:** Pick the right foundation. Use official packages (Fluent, Carbon, Material, Primer, GOV.UK, USWDS, shadcn/ui) when the brief matches. Build with native CSS + Tailwind for aesthetic-only briefs.
4. **Bias Correction Directives:** Override LLM defaults proactively. Typography (avoid Inter as default, serif discipline), color (LILA rule, premium-consumer palette ban, color consistency lock), layout (anti-center bias, eyebrow restraint, hero stack discipline), content density, copy self-audit.
5. **Pre-Flight Check:** Run a mandatory checklist before declaring done. Zero em-dashes, page theme lock, color consistency, button contrast, hero fits viewport, eyebrow count, no duplicate CTA intent, real images, no AI tells.

## Key Bans

- Em-dashes (completely banned everywhere visible)
- AI purple gradients as default
- Three equal feature cards
- Generic glassmorphism on everything
- Inter as default font
- Fraunces / Instrument Serif as default serif
- Premium-consumer beige+brass+espresso palette as default
- Div-based fake screenshots
- Hand-rolled SVG icons
- Section-number eyebrows (01, 02, 03...)
- Scroll cues ("Scroll to explore")
- Decorative status dots
- More than 1 marquee per page
- More than 1 eyebrow per 3 sections

## Full Reference

The complete skill content (14 sections, appendices, pre-flight checklist) is loaded by the `skill` tool when this skill is invoked. Key sections:

- **Section 0:** Brief inference and design read
- **Section 1:** Three dials (variance, motion, density)
- **Section 2:** Design system map (when to use official packages)
- **Section 3:** Default architecture (React, Tailwind v4, Motion, fonts)
- **Section 4:** Design engineering directives (typography, color, layout, images, content)
- **Section 5:** Context-aware proactivity (glassmorphism, magnetic physics, GSAP patterns)
- **Section 6:** Performance and accessibility guardrails
- **Section 7:** Dial definitions (technical reference)
- **Section 8:** Dark mode protocol
- **Section 9:** AI tells (forbidden patterns)
- **Section 10:** Reference vocabulary (pattern names)
- **Section 11:** Redesign protocol
- **Section 12:** Block library (contract)
- **Section 13:** Out of scope
- **Section 14:** Final pre-flight check (mandatory)
