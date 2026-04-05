---
name: design-system
description: >
  DESIGN.md generation — creates plain-text design system documents that AI agents (Stitch, v0, Lovable, Cursor)
  read to generate consistent UI. Extracts brand identity from websites, Canva kits, or guided Q&A and produces
  a standardized 9-section DESIGN.md. Use when: "design system", "DESIGN.md", "generate design tokens",
  "brand to design system", "UI consistency", "design language", or when the user wants AI tools to produce
  visually consistent interfaces.
allowed-tools: Read, Write, WebFetch, AskUserQuestion, mcp__*
---

# DESIGN.md — Plain-Text Design Systems for AI Agents

DESIGN.md is to design agents what CLAUDE.md is to coding agents: a plain-text constitution that ensures visual consistency across AI-generated UI.

## What DESIGN.md Is

A markdown file placed at project root containing a complete design system specification. AI design tools (Google Stitch, v0, Lovable, Cursor) read it to generate consistent components, layouts, and pages without drifting from brand guidelines.

## The 9 Required Sections

Every DESIGN.md MUST contain these sections in order:

| # | Section | Purpose |
|---|---------|---------|
| 1 | Visual Theme & Atmosphere | Overall aesthetic direction, mood, metaphors |
| 2 | Color Palette & Roles | Named colors with hex values AND semantic roles (primary, surface, text, accent, status) |
| 3 | Typography Rules | Font families, weight scale, size hierarchy with px/rem, line-heights |
| 4 | Component Stylings | Buttons, cards, inputs, badges, navigation — with specific token values |
| 5 | Layout Principles | Spacing unit, grid, max-width, whitespace philosophy |
| 6 | Depth & Elevation | Shadow scale, border treatments, layering approach |
| 7 | Do's and Don'ts | Concrete guardrails — at least 8 rules per list |
| 8 | Responsive Behavior | Breakpoints, collapsing strategies, mobile-first or not |
| 9 | Agent Prompt Guide | Quick reference for AI tools: example prompts, iteration checklist |

## Quality Criteria

A good DESIGN.md:
- Uses **exact values** (hex codes, px sizes, rem units) — not vague descriptions
- Assigns **semantic roles** to colors (not just "blue" but "Primary Action", "Error State")
- Includes **component-level specifications** with padding, border-radius, shadow values
- Provides **Do's and Don'ts** that prevent common AI agent mistakes
- Ends with an **Agent Prompt Guide** with copy-paste example prompts

## Source Priority

When generating a DESIGN.md, use sources in this order:
1. `.kickstart/brand.md` — if exists, extract and expand tokens from CKS brand phase
2. Website URL — WebFetch the site, extract colors/typography/spacing from CSS
3. Canva brand kit — extract via MCP if available
4. Guided Q&A — ask user about aesthetic preferences, then generate

## Output Location

- Primary: `DESIGN.md` at project root
- The file MUST be self-contained — no external references or imports
