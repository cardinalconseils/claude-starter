---
name: impeccable
description: >
  Designs and iterates production-grade frontend interfaces. Real working code,
  committed design choices, exceptional craft. Use when: the user wants to design,
  redesign, shape, critique, audit, polish, clarify, distill, harden, optimize, adapt,
  animate, colorize, typeset, layout, delight, or otherwise improve a frontend interface.
  Covers websites, landing pages, dashboards, product UI, app shells, components, forms,
  settings, onboarding, and empty states. NOT for backend-only or non-UI tasks.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, WebFetch, AskUserQuestion, mcp__*
---

# Impeccable — Production-Grade Frontend Design

## What This Skill Does

Turns frontend interface requests into production-grade, shipped-quality code. Handles the full lifecycle: from initial design direction to final polish pass. Every output is battle-tested with browser screenshotting and verification.

## When to Use

- Designing or redesigning any UI (websites, landing pages, dashboards, product UI)
- Shaping UX flows before writing code
- Auditing existing interfaces for quality
- Polishing, bolding, quieting, distilling, or hardening designs
- Adding animation, color, typography, or layout improvements
- Fixing UX copy, responsive issues, or performance problems
- Designing first-run flows, empty states, onboarding
- Live visual iteration in the browser

## When NOT to Use

- Backend-only tasks
- Non-UI code
- API design (use api-design skill instead)

## Commands

| Command | Category | Description |
|---|---|---|
| `craft [feature]` | Build | Shape, then build a feature end-to-end |
| `shape [feature]` | Build | Plan UX/UI before writing code |
| `init` | Build | Set up project context: PRODUCT.md, DESIGN.md |
| `document` | Build | Generate DESIGN.md from existing code |
| `extract [target]` | Build | Pull reusable tokens into design system |
| `critique [target]` | Evaluate | UX design review with heuristic scoring |
| `audit [target]` | Evaluate | Technical quality checks (a11y, perf, responsive) |
| `polish [target]` | Refine | Final quality pass before shipping |
| `bolder [target]` | Refine | Amplify safe or bland designs |
| `quieter [target]` | Refine | Tone down aggressive designs |
| `distill [target]` | Refine | Strip to essence, remove complexity |
| `harden [target]` | Refine | Production-ready: errors, i18n, edge cases |
| `onboard [target]` | Refine | Design first-run flows, empty states |
| `animate [target]` | Enhance | Add purposeful animations and motion |
| `colorize [target]` | Enhance | Add strategic color to monochromatic UIs |
| `typeset [target]` | Enhance | Improve typography hierarchy and fonts |
| `layout [target]` | Enhance | Fix spacing, rhythm, visual hierarchy |
| `delight [target]` | Enhance | Add personality and memorable touches |
| `overdrive [target]` | Enhance | Push past conventional limits |
| `clarify [target]` | Fix | Improve UX copy, labels, error messages |
| `adapt [target]` | Fix | Adapt for different devices and screen sizes |
| `optimize [target]` | Fix | Diagnose and fix UI performance |
| `live` | Iterate | Visual variant mode: pick elements in browser |

## Setup Steps (Required Before Proceeding)

1. Run `node .agents/skills/impeccable/scripts/context.mjs` once per session
2. If user invoked a sub-command, read `reference/<command>.md` next
3. Familiarize with existing design system, conventions, and components
4. Read the matching register reference (`reference/brand.md` or `reference/product.md`)
5. If platform is ios/android/adaptive, also read `reference/<platform>.md`
6. If project is brand-new (no existing tokens), run `palette.mjs` for brand seed color

## Design Guidance

### Color
- Verify contrast: body text >= 4.5:1, large text >= 3:1
- Use OKLCH for new projects
- The cream/sand/beige body bg is the saturated AI default of 2026 - avoid it
- Tinted neutrals: add 0.005-0.015 chroma toward brand hue

### Typography
- Cap body line length at 65-75ch
- Display heading ceiling: clamp() max <= 6rem (~96px)
- Display letter-spacing >= -0.04em
- Use `text-wrap: balance` on h1-h3, `text-wrap: pretty` on prose

### Layout
- Vary spacing for rhythm
- Cards are the lazy answer - use only when truly the best affordance
- Flexbox for 1D, Grid for 2D
- Build a semantic z-index scale

### Motion
- Intentional, not afterthought
- Ease out with exponential curves (ease-out-quart/quint/expo)
- Reduced motion is not optional
- Reveal animations must enhance already-visible default

### Absolute Bans
- Side-stripe borders (border-left/right > 1px as accent)
- Gradient text (background-clip: text + gradient)
- Glassmorphism as default
- The hero-metric template (big number, small label, gradient accent)
- Identical card grids
- Tiny uppercase tracked eyebrow above every section
- Numbered section markers as default scaffolding (01/02/03)
- Text that overflows its container

## AI Slop Test

If someone could look at this interface and say "AI made that" without doubt, it's failed.

## Full Reference

The complete skill content (109 supporting files including reference files for each command, register references, platform guides, and scripts) is loaded by the `skill` tool when this skill is invoked. Key references:

- `reference/init.md` - Project context setup
- `reference/craft.md` - End-to-end feature build
- `reference/shape.md` - UX/UI planning before code
- `reference/critique.md` - UX design review with scoring
- `reference/audit.md` - Technical quality checks
- `reference/polish.md` - Final quality pass
- `reference/brand.md` - Brand register (design IS the product)
- `reference/product.md` - Product register (design SERVES the product)
- `reference/hooks.md` - Design detector hook management
