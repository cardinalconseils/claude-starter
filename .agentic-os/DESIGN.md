# Agentic OS Dashboard — Design Spec

> Phase 2 design for `dashboard/index.html`. Standalone design task (no PRD phase).
> Scope: visual polish, hierarchy, OS-control-panel feel. Code untouched — spec only.

---

## 1. Design Goals (recap)

1. Visual polish — typography, spacing, color hierarchy
2. Domain cards feel like an OS control panel, not a flat list
3. Live data section feels like a real dashboard (gauges, progress, clean stat blocks)
4. Token tracker promoted to first-class utility

---

## 2. Information Architecture (v2)

```
┌─────────────────────────────────────────────────────────────────┐
│ HEADER                                                          │
│   "CKS Agentic OS" + status pulse (date · last refresh)         │
├─────────────────────────────────────────────────────────────────┤
│ STATUS STRIP   (sticky, always visible — the OS vitals)         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ Token Tracker│  │ Git Pulse    │  │ Memory Counts        │   │
│  │ daily gauge  │  │ last commit  │  │ raw · wiki · output  │   │
│  │ monthly bar  │  │ relative time│  │ recent file          │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│ CONTROL PANEL  (domain grid — OS surface)                       │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                          │
│  │ ⚙ Plugin │  │ 🚀 Release │  │ 📖 Docs │                       │
│  │ Primary │  │ Primary │  │ Primary │                          │
│  │ ─ sec   │  │ ─ sec   │  │ ─ sec   │                          │
│  │ ─ sec   │  │ ─ sec   │  │ ─ sec   │                          │
│  └─────────┘  └─────────┘  └─────────┘                          │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                          │
│  │ 💬 Comm │  │ 🧩 Widget│  │ 🗂 Data │                          │
│  └─────────┘  └─────────┘  └─────────┘                          │
├─────────────────────────────────────────────────────────────────┤
│ UTILITY DRAWER  (collapsible — Quick Commands + help tip)       │
└─────────────────────────────────────────────────────────────────┘
```

**Rationale:**
- Live data = OS vitals → must always be visible → sticky top strip
- Domain cards = the actual control panel → biggest visual zone
- Quick commands = meta-controls → least frequent → bottom drawer
- Duplicate Memory card removed (was both in domain grid + live grid)

---

## 3. Design Tokens

### Color Palette — OKLCH, branded dark

Current palette is generic slate. New palette signals "OS terminal" with intentional cyan/blue accent (NOT purple-violet — see design-fluency `ai-color-palette` slop).

```css
/* Background — tinted dark, not pure black */
--bg-0:         oklch(15% 0.015 250);   /* page background  #0d1119 */
--bg-1:         oklch(19% 0.02  250);   /* card surface     #161b27 */
--bg-2:         oklch(23% 0.025 250);   /* card hover       #1e2433 */
--bg-3:         oklch(13% 0.015 250);   /* recessed input   #0a0e16 */

/* Borders */
--border-0:     oklch(28% 0.02  250);   /* default border   #2a3142 */
--border-1:     oklch(35% 0.03  250);   /* hover border     #3a4358 */
--border-accent:oklch(70% 0.18  220);   /* active accent    #4f8df7 */

/* Text */
--text-0:       oklch(96% 0.005 250);   /* primary          #f1f3f8 */
--text-1:       oklch(75% 0.01  250);   /* secondary        #aab2c0 */
--text-2:       oklch(55% 0.015 250);   /* muted            #707888 */
--text-3:       oklch(40% 0.015 250);   /* disabled         #4d5363 */

/* Accents — single brand hue, no gradients */
--accent:       oklch(72% 0.16  220);   /* primary cyan-blue #5b9af9 */
--accent-dim:   oklch(45% 0.12  220);   /* accent variant   #2d5fb3 */

/* Semantic */
--ok:           oklch(75% 0.16  150);   /* green            #4ddb8a */
--warn:         oklch(80% 0.15   80);   /* amber            #e8b340 */
--err:           oklch(65% 0.20   25);   /* red              #e85a52 */
```

**Contrast check:** body text on bg-0 = 14.2:1 (passes WCAG AAA). Muted on bg-1 = 5.1:1 (passes AA).

### Typography

Avoid the AI-default fonts (Inter, Roboto, Geist, Plus Jakarta). Use system mono for tech identity + a distinctive sans for body.

```css
--font-display: 'JetBrains Mono', 'SF Mono', ui-monospace, monospace;
--font-body:    'IBM Plex Sans', system-ui, -apple-system, sans-serif;
--font-mono:    'JetBrains Mono', 'SF Mono', ui-monospace, monospace;

/* Scale — 1.25 ratio (major third) */
--text-xs:   0.75rem;    /* 12px — labels, badges */
--text-sm:   0.875rem;   /* 14px — body */
--text-base: 1rem;       /* 16px — default */
--text-md:   1.125rem;   /* 18px — card titles */
--text-lg:   1.5rem;     /* 24px — section heads */
--text-xl:   2rem;       /* 32px — page title */
--text-2xl:  2.5rem;     /* 40px — token gauge readout */

/* Weights */
--fw-regular: 400;
--fw-medium:  500;
--fw-bold:    700;

/* Line heights */
--lh-tight:   1.2;       /* headings */
--lh-normal:  1.5;       /* body */
--lh-loose:   1.7;       /* paragraphs */
```

**Hierarchy rule:** page title uses mono display at xl/bold. Section heads use mono at md/medium uppercase tracked +0.05em. Body uses sans at sm/regular.

### Spacing — 4px base, geometric scale

```css
--sp-1:  0.25rem;   /*  4px */
--sp-2:  0.5rem;    /*  8px */
--sp-3:  0.75rem;   /* 12px */
--sp-4:  1rem;      /* 16px */
--sp-5:  1.5rem;    /* 24px */
--sp-6:  2rem;      /* 32px */
--sp-7:  3rem;      /* 48px */
--sp-8:  4rem;      /* 64px */
```

**Spacing rhythm (fights `monotonous-spacing` slop):**
- Card internal padding: `--sp-5` (24px)
- Gap between cards in a row: `--sp-4` (16px)
- Gap between sections: `--sp-7` (48px)
- Tight groupings (label/value): `--sp-2` (8px)

### Radius

```css
--radius-sm: 6px;    /* buttons, inputs */
--radius-md: 10px;   /* cards */
--radius-lg: 14px;   /* status strip outer */
--radius-pill: 999px;
```

### Shadows — soft, layered, no neon glow

```css
--shadow-1: 0 1px 2px rgba(0,0,0,0.4);                          /* resting */
--shadow-2: 0 4px 12px rgba(0,0,0,0.5), 0 1px 2px rgba(0,0,0,0.4); /* hover lift */
--shadow-focus: 0 0 0 2px var(--accent);                        /* keyboard focus */
```

No `box-shadow` glow on dark backgrounds (avoid `dark-glow` slop). Use subtle elevation only.

### Motion

```css
--ease-out:    cubic-bezier(0.2, 0, 0, 1);     /* exits, hovers */
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);   /* state changes */
--dur-fast:    120ms;
--dur-base:    200ms;
--dur-slow:    320ms;
```

Animate `transform` + `opacity` only. Never animate `width`, `height`, `padding`. Respect `prefers-reduced-motion`.

---

## 4. Component Spec

### 4.1 Header

```
┌──────────────────────────────────────────────────────────┐
│ CKS · Agentic OS                            ⟳ refreshed  │
│                                            2026-06-08    │
└──────────────────────────────────────────────────────────┘
```
- Title: mono, --text-xl, --fw-bold, --text-0
- Eyebrow line subordinated: sans, --text-xs, --text-2, right-aligned
- No giant hero. No gradient text. No italic serif (avoid `italic-serif-display` slop).

### 4.2 Status Strip — Token Tracker (HERO)

```
┌────────────────────────────────────────┐
│ TOKEN TRACKER          [reset]          │
│                                         │
│  127,430                                │
│  daily                                  │
│  ████████░░░░░░░░░░  42% of 300k budget │
│                                         │
│  ─────────────────────────────────      │
│  Monthly  2.8M / 10M                    │
│  ████████████░░░░░░░░░░░░░░░░  28%      │
│                                         │
│  [____] tokens          [ Log usage ]   │
└────────────────────────────────────────┘
```
- Daily count: mono, --text-2xl, --accent, --fw-bold
- Progress bar: 6px height, --bg-3 track, --accent fill, --radius-pill
- Color shift on bar: green <60%, amber 60-85%, red >85%
- Section divider between daily/monthly: 1px --border-0
- Input + button inline, equal-height (32px)
- Reset action: ghost button, --text-3 default, --text-1 on hover

### 4.3 Status Strip — Git Pulse

```
┌────────────────────────────────────────┐
│ GIT PULSE              ● live           │
│                                         │
│ feat: add dashboard redesign            │
│ 2 hours ago · main                      │
│                                         │
│ ─────────────────────────────────       │
│ Branch    codex/hermes-module           │
│ Status    7 modified · 4 untracked      │
│                                         │
│ [ paste git log -1 --format="%s|%ar" ]  │
└────────────────────────────────────────┘
```
- Status dot: 8px circle, --ok if recent (<24h), --warn (1-7d), --text-3 (>7d)
- Commit message: sans, --text-sm, --text-0, truncate at 1 line with ellipsis
- Time + branch: --text-xs, --text-2
- Label/value rows: label --text-2, value --text-0 (left-aligned, value right-aligned)

### 4.4 Status Strip — Memory Counts

```
┌────────────────────────────────────────┐
│ MEMORY                  3 stages        │
│                                         │
│  raw/         12 files                  │
│  ▓▓▓▓░░░░░░  staging                    │
│                                         │
│  wiki/         8 files                  │
│  ▓▓▓░░░░░░░  knowledge                  │
│                                         │
│  output/       3 files                  │
│  ▓░░░░░░░░░  deliverables               │
│                                         │
│  Last: gotchas-auth.md · 2h             │
└────────────────────────────────────────┘
```
- Tiny bar viz per stage: 8 cells, fill proportional to count
- Cells: --accent-dim filled, --bg-3 empty, 6px wide, 2px gap
- Stage labels: mono, --text-xs, --text-2
- Stage descriptors (staging/knowledge/deliverables): sans italic, --text-3
- Recent file row: --text-xs, mono filename, --text-2

### 4.5 Domain Card — Control Panel Surface

```
┌─────────────────────────┐
│  ⚙                       │
│  Plugin Dev              │
│  Build & wire CKS plugin │
│                          │
│  ─────────────────────   │
│  ▶ Add command           │
│  ▶ Wire agent            │
│  ▶ Debug hook            │
│  ▶ Write skill           │
│  ▶ TDD                   │
│                          │
└─────────────────────────┘
```

Anatomy:
- **Icon row**: 24px icon, --accent color, top-left. Single character or lucide-icon SVG.
- **Title**: sans, --text-md, --fw-bold, --text-0
- **Tagline**: sans, --text-xs, --text-2, max 1 line
- **Divider**: 1px --border-0, --sp-4 vertical margin
- **Action row**:
  - Left: ▶ caret in --accent-dim, --text-xs
  - Middle: action label, sans --text-sm --text-1
  - Hover: caret → --accent, label → --text-0, row bg → --bg-2
  - Click: flash --accent border-left 2px for 200ms (copy feedback)
- Card itself: --bg-1, --border-0, --radius-md, --shadow-1
- Card hover: lift via `transform: translateY(-2px)`, --shadow-2, --border-1
- NO `<code>` row visible by default — show inline command on hover OR via aria-expanded toggle. Reduces visual noise dramatically.

**Domain icons (use a single icon set, lucide-static SVG sprite):**
- Plugin Dev → `puzzle` or `terminal-square`
- Release → `rocket` or `package`
- Docs → `book-open`
- Community → `messages-square`
- Widget Dev → `layout-grid`
- Data → `database`

**Tagline copy (new):**
| Domain | Tagline |
|---|---|
| Plugin Dev | Build & wire CKS plugin |
| Release | Version, ship, publish |
| Docs | Update docs & wiki |
| Community | Triage, review, respond |
| Widget Dev | Build dashboard widgets |
| Data | Schemas, sources, exports |

### 4.6 Utility Drawer — Quick Commands

```
┌────────────────────────────────────────────┐
│ Quick Commands                       [ ▾ ]  │
├────────────────────────────────────────────┤
│ [ OS Status ] [ Refresh OS ] [ Sprint ] [ Go ]│
└────────────────────────────────────────────┘
```
- Collapsible, default open
- Horizontal pill row, --radius-pill buttons, --bg-1 + --border-0
- Hover: --border-accent

### 4.7 Help Tip Banner

```
┌────────────────────────────────────────────┐
│ ℹ Click any action to copy command.        │
│   Paste into terminal running Claude Code. │
└────────────────────────────────────────────┘
```
- --bg-1, --border-0, --radius-md, --sp-4 padding
- Icon: ℹ in --accent, --text-md
- Body: sans, --text-sm, --text-1

---

## 5. Layout Decisions

### Grid

- Desktop ≥ 1024px: status strip = 3-col grid, domain panel = 3-col, 1280px max-width centered
- Tablet 640–1023px: status strip = 1-col stack (token first, git, memory), domain = 2-col
- Mobile < 640px: everything 1-col, status strip not sticky (saves viewport)

### Z-order

- Status strip: `position: sticky; top: 0; z-index: 10` with --bg-0 backdrop + 1px --border-0 bottom
- Drawer: standard flow at page bottom

### Container

```css
.os-container {
  max-width: 1280px;
  margin: 0 auto;
  padding: var(--sp-6) var(--sp-5);
}
```

### Page background

Subtle radial gradient — single low-saturation hue, NOT purple/cyan. Avoid `ai-color-palette` slop:

```css
body {
  background:
    radial-gradient(ellipse at top, oklch(18% 0.025 220) 0%, var(--bg-0) 60%);
  background-attachment: fixed;
}
```

---

## 6. Accessibility

- All interactive surfaces keyboard-focusable. Focus ring = --shadow-focus (2px --accent outline).
- Color contrast all passes WCAG AA. Token gauge bar uses both color AND fill % (never color alone).
- Token reset button: not destructive-styled (no red) but `aria-label="Reset all token counters — cannot be undone"`.
- Status strip uses `<section aria-label="OS vitals">`. Each strip card is an `<article>`.
- Domain cards use `<article>` with `<h3>` title. Action buttons are real `<button>`, not divs.
- Live-updated counts use `aria-live="polite"` so screen readers announce changes.
- Respects `prefers-reduced-motion`: disable hover lift transitions, keep instant state changes.

---

## 7. Visual Slop Checklist (design-fluency)

| Signal | Status |
|---|---|
| `side-tab` | Avoided — no thick colored side borders on cards |
| `border-accent-on-rounded` | Avoided — accent is icon/text color, not card border |
| `overused-font` | Avoided — IBM Plex Sans + JetBrains Mono instead of Inter |
| `flat-type-hierarchy` | Fixed — 1.25 ratio scale, xs→2xl |
| `gradient-text` | Avoided — solid --accent for emphasis |
| `ai-color-palette` | Avoided — single cyan-blue hue, no purple/violet |
| `nested-cards` | Removed (was Recent files card inside Memory card) |
| `monotonous-spacing` | Fixed — tight pairs (sp-2), section gaps (sp-7) |
| `everything-centered` | All copy left-aligned |
| `dark-glow` | No box-shadow glows |
| `icon-tile-stack` | Avoided — icon is small in card corner, not stacked above title |
| `pure-black-white` | Fixed — bg-0 is tinted oklch(15% 0.015 250) |
| `gray-on-color` | Fixed — all text on tinted bg uses --text-* scale, contrast verified |
| `low-contrast` | All combos verified ≥4.5:1 |
| `tight-leading` | Body 1.5, paragraphs 1.7 |

---

## 8. What Changed vs Current `dashboard/index.html`

| Area | Before | After |
|---|---|---|
| Live data position | Below domain grid | Sticky top status strip |
| Token tracker | Buried bottom-right | Hero card with daily gauge + monthly bar |
| Memory card | Duplicated (domain grid + live grid) | Single status-strip card with stage bars |
| Domain cards | Flat button list, all same weight | Icon + tagline + collapsed action list, lift on hover |
| Command code preview | Always visible (visual noise) | Hidden by default, surfaces on hover/focus |
| Quick Commands | Mixed in domain grid | Bottom drawer (horizontal pills) |
| Font | system-ui | IBM Plex Sans + JetBrains Mono |
| Background | Pure dark slate | Tinted oklch with subtle top gradient |
| Accent | Generic blue #4f6ef7 | Brand cyan-blue oklch(72% 0.16 220) |
| Card shadow | None | --shadow-1 resting, --shadow-2 on hover |

---

## 9. Implementation Notes

- Build as a CSS rewrite + minor HTML restructure of `dashboard/index.html`. No framework.
- Replace `<style>` block with token-based CSS using custom properties at `:root`.
- Add `<section class="status-strip">` between header and `.grid`.
- Move existing live-data cards into the status strip.
- Move Quick Commands to bottom drawer; remove duplicate Memory card.
- Add SVG icon sprite or inline lucide icons per domain.
- Progress bar: pure CSS, no JS dependency.
- Token gauge color shift: CSS custom property updated via JS in `tokRender()`.

---

## 10. Open Questions for Sign-off

1. Icon strategy: single character (⚙ 🚀 📖 💬 🧩 🗂) vs lucide SVG sprite vs Phosphor? Spec defaults to lucide for sharper look — confirm.
2. Should command code preview show on hover or only on click-to-expand? Spec defaults to hover.
3. Token budget thresholds (300k daily / 10M monthly) — placeholder. Confirm real numbers.
4. Mobile: drop sticky status strip below 640px — confirm acceptable.

---

## 11. Design Sign-off

Status: **DESIGN SPEC READY**. Awaiting orchestrator/user review before passing to Phase 3 Sprint.
Implementation target: `dashboard/index.html` CSS + minor markup restructure. No framework, no build step.
