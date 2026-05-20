---
name: design-system
description: "Design system generation — canonical DESIGN.md plus a rendered DESIGN.html view (swatches, live type specimens, mini-site nav)."
allowed-tools: Read, Write, WebFetch, AskUserQuestion, mcp__*
---

# Design System — DESIGN.md (canonical) + DESIGN.html (view)

The design system is to design agents what CLAUDE.md is to coding agents: a constitution for visual consistency. It ships as two files:

- **`DESIGN.md`** — the canonical plain-text design system. This is the **source of truth** that downstream agents (prd-designer, reviewer, sprint-reviewer, prd-executor, prd-verifier) read and parse. Generate it from `references/design-md-template.md`.
- **`DESIGN.html`** — a rendered, browser-viewable **view** of the same tokens: rendered color swatches, live type specimens, styled component examples, and the shared mini-site nav. Never a replacement for DESIGN.md.

## What DESIGN.html Is

A self-contained HTML file at project root that renders the design system from DESIGN.md so humans can see the brand come alive in a browser. It carries the same exact hex values and CSS rules as DESIGN.md.

## The 9 Required Sections

Every DESIGN.html MUST contain these sections in order:

| # | Section | HTML Rendering |
|---|---------|---------------|
| 1 | Visual Theme & Atmosphere | Prose + mood keywords as styled badges |
| 2 | Color Palette & Roles | `<div class="swatch" style="background:{hex}">` blocks — actual color rendered |
| 3 | Typography Rules | Live `<p>` specimens at each size/weight: `<p style="font-size:32px;font-weight:700">Heading 1 — The quick brown fox</p>` |
| 4 | Component Stylings | Actual rendered HTML components: `<button class="btn-primary">Primary Action</button>` styled inline |
| 5 | Layout Principles | Spacing scale as visual boxes, grid demo |
| 6 | Depth & Elevation | Shadow scale rendered as cards with the actual shadow applied |
| 7 | Do's and Don'ts | Two-column layout: green ✓ column, red ✗ column |
| 8 | Responsive Behavior | Breakpoint table, mobile/desktop toggle note |
| 9 | Agent Prompt Guide | Formatted text — copy-paste prompts for Stitch, v0, Lovable |

## HTML Structure Requirements

### Header Section
```html
<div class="ds-header">
  <h1>{project-name} Design System</h1>
  <p class="meta">Last updated: {date} · Source: {brand.md / URL / Q&A}</p>
</div>
```

### Color Swatches
```html
<div class="swatch-grid">
  <div class="swatch-item">
    <div class="swatch-block" style="background:#6366f1;"></div>
    <div class="swatch-label">
      <strong>Primary</strong>
      <code>#6366f1</code>
      <span>Primary Action, Links, Focus</span>
    </div>
  </div>
  <!-- repeat per color -->
</div>
```

### Typography Specimens (live rendering)
```html
<div class="type-scale">
  <div class="type-specimen">
    <p style="font-size:40px;font-weight:800;line-height:1.1">Display — The quick brown fox</p>
    <code>40px / 800 / 1.1lh</code>
  </div>
  <div class="type-specimen">
    <p style="font-size:32px;font-weight:700;line-height:1.2">Heading 1 — The quick brown fox</p>
    <code>32px / 700 / 1.2lh</code>
  </div>
  <!-- continue through body, caption sizes -->
</div>
```

### Component Renders (actual styled HTML)
```html
<!-- Buttons -->
<div class="component-preview">
  <button style="background:var(--accent);color:#fff;padding:10px 20px;border:none;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer">Primary Action</button>
  <button style="background:transparent;color:var(--text);padding:10px 20px;border:1px solid #333;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer">Secondary</button>
  <button style="background:transparent;color:var(--muted);padding:10px 20px;border:none;font-size:14px;cursor:pointer">Ghost</button>
</div>

<!-- Card -->
<div style="background:var(--surface);border:1px solid #2a2a2a;border-radius:12px;padding:24px;max-width:320px">
  <h3 style="font-size:16px;font-weight:600;margin-bottom:8px">Card Title</h3>
  <p style="font-size:14px;color:var(--muted)">Card body text at muted color.</p>
</div>

<!-- Input -->
<input type="text" placeholder="Input field" style="background:#111;border:1px solid #333;border-radius:8px;padding:10px 14px;color:var(--text);font-size:14px;width:280px">
```

### Do's and Don'ts (two-column)
```html
<div class="dos-donts">
  <div class="dos">
    <h3>✓ Do</h3>
    <ul>
      <li>Use primary color for the single most important action per screen</li>
      <!-- ... -->
    </ul>
  </div>
  <div class="donts">
    <h3>✗ Don't</h3>
    <ul>
      <li>Use more than 3 accent colors in one view</li>
      <!-- ... -->
    </ul>
  </div>
</div>
```

## Quality Criteria

A good DESIGN.html:
- Uses **exact values** (hex codes, px sizes, rem units) — not vague descriptions
- Assigns **semantic roles** to colors (not just "blue" but "Primary Action", "Error State")
- Renders **actual swatches** — the browser shows the real color, not a hex string
- Shows **live type specimens** at each scale step
- Renders **actual components** — not described, actually styled and visible
- Ends with an **Agent Prompt Guide** with copy-paste prompts

## Source Priority

When generating DESIGN.html, use sources in this order:
1. `.kickstart/brand.md` — if exists, extract and expand tokens from CKS brand phase
2. Website URL — WebFetch the site, extract colors/typography/spacing from CSS
3. Canva brand kit — extract via MCP if available
4. Guided Q&A — ask user about aesthetic preferences, then generate

## Output Location

- Write `DESIGN.md` at project root first — the canonical source, from `references/design-md-template.md`
- Then write `DESIGN.html` at project root — the rendered view of the same tokens
- The file MUST be self-contained: all CSS inline in `<style>` tag, no CDN
- Dark mode first: `#0d0d0d` bg, `#1a1a1a` surface, `#f1f1f1` text
- Typography: `font-family: -apple-system, system-ui, 'Segoe UI', sans-serif`
- Max-width 1200px centered content; responsive single-column below 768px
- Print-friendly: `@media print` removes nav, white background

**Brand color extraction (do this before writing):**
1. Read `.kickstart/brand.md` — find hex values near `primary`, `brand`, `accent`, `main`
2. If not found, check existing `DESIGN.html` for `--color-primary` or `--accent`
3. Default: `#6366f1`
Use extracted color as `--accent` in the `:root` block.

**Embed the shared nav shell** from `skills/prd/references/html-shell.md`:
- Set Design tab as active
- Relative paths from project root: prefix is `./`
- Check which other artifacts exist, disable missing tabs

**Keep both in sync:** DESIGN.md and DESIGN.html must carry the same tokens. DESIGN.md is authoritative; DESIGN.html is its rendered view.
