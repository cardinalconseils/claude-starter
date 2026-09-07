---
name: design-fluency
description: >
  Design vocabulary and visual-slop detection for UI output. Use when: generating screens,
  reviewing design adherence, running visual polish passes, detecting AI-generated visual clichés
  (overused fonts, gradient text, nested cards, monotonous spacing, ai-color-palette). Provides
  design verbs (bolder, quieter, distill, polish, clarify, animate, harden) and 7 domain references.
allowed-tools: Read, Bash
---

# Design Fluency

Design vocabulary, visual-slop detection, and reference pointers for agents producing or reviewing UI.

> Attribution: Adapted from [impeccable](https://github.com/pbakaus/impeccable) by Peter Bakaus, Apache-2.0.

## Design Verbs

Apply these to any UI improvement instruction:

| Verb | When to Use | Effect |
|------|-------------|--------|
| `bolder` | Design feels safe, bland, or invisible | Increase visual weight and contrast — bigger type, stronger color, bolder hierarchy |
| `quieter` | Design is noisy, cluttered, or overwhelming | Reduce visual noise — mute colors, tighten spacing, cut decorative elements |
| `distill` | Design has excess — too many cards, sections, labels | Strip until nothing left to cut — one idea per section, fewest elements possible |
| `polish` | Design is structurally sound but unrefined | Refine micro-details — spacing rhythm, type kerning, hover states, alignment |
| `clarify` | Design is hard to scan or understand | Improve legibility and hierarchy — stronger size contrast, better labels, fix line length |
| `animate` | Design needs life or feedback cues | Add purposeful motion — enter/exit transitions, micro-interactions, loading states |
| `harden` | Design works for happy path only | Add structure for edge cases — error states, empty states, overflow, i18n, dark mode |

## Visual Slop Signals

Run `npx impeccable detect <target>` to detect these automatically.

Each signal maps to a design verb fix:

### AI Slop Category

| Signal | What It Looks Like | Fix Verb |
|--------|-------------------|----------|
| `side-tab` | Thick colored border on one side of a card — the most recognizable AI-generated UI tell | `distill` — remove or replace with full border or background tint |
| `border-accent-on-rounded` | Thick accent border on a rounded card — border clashes with radius | `distill` — remove the border or the radius |
| `overused-font` | Inter, Roboto, Geist, Fraunces, Plus Jakarta Sans, Space Grotesk — all converged-on AI defaults | `bolder` — choose a face with genuine personality |
| `single-font` | One font for everything — no typographic contrast | `clarify` — pair a display face with a body face |
| `flat-type-hierarchy` | Font sizes too close together, no visual hierarchy | `clarify` — fewer sizes, at least 1.25 ratio between steps |
| `gradient-text` | `background-clip: text` with gradient — decorative, never meaningful | `distill` — solid color text only |
| `ai-color-palette` | Purple/violet gradients, cyan-on-dark — most recognizable AI palette | `bolder` with a distinctive intentional palette |
| `nested-cards` | Cards inside cards — visual noise, excessive depth | `distill` — flatten; use spacing, typography, dividers |
| `monotonous-spacing` | Same spacing value everywhere — no rhythm | `polish` — tight groupings for related items, generous gaps between sections |
| `everything-centered` | Every text element center-aligned | `clarify` — left-align body; center only hero and CTA |
| `bounce-easing` | Bounce or elastic CSS easing | `animate` — use ease-out-quart/quint/expo instead |
| `dark-glow` | Dark background with colored box-shadow glows | `quieter` — subtle lighting or remove dark theme |
| `icon-tile-stack` | Rounded-square icon above heading — universal AI feature card | `distill` — side-by-side icon+heading or inline icon |
| `italic-serif-display` | Oversized italic serif (Fraunces, Recoleta) as hero headline | `bolder` — set roman, or use a non-serif display face |
| `hero-eyebrow-chip` | Tiny uppercase tracked label above hero headline or as pill chip | `distill` — drop the eyebrow; integrate into headline |
| `repeated-section-kickers` | Repeated tiny uppercase labels above every section | `distill` — replace with stronger structure or imagery |

### Quality Category

| Signal | What It Looks Like | Fix Verb |
|--------|-------------------|----------|
| `pure-black-white` | Pure `#000000` background | `polish` — tint toward brand hue: `oklch(12% 0.01 250)` |
| `gray-on-color` | Gray text on a colored background | `clarify` — use darker shade of background color |
| `low-contrast` | Text failing WCAG AA (4.5:1 body, 3:1 large) | `harden` — increase contrast |
| `layout-transition` | Animating `width`, `height`, `padding`, `margin` | `animate` — use `transform`/`opacity` instead |
| `line-length` | Body text wider than ~80 characters | `clarify` — add `max-width: 65ch` to text containers |
| `cramped-padding` | Text too close to container edge | `polish` — add at least 8px (ideally 12–16px) padding |
| `body-text-viewport-edge` | Body text flush against viewport edge | `harden` — wrap in container with 16–32px horizontal padding |
| `tight-leading` | Line height below 1.3× font size | `clarify` — use 1.5–1.7 for body text |
| `skipped-heading` | Heading levels skip (h1 then h3) | `harden` — fix document outline for screen reader navigation |
| `justified-text` | Justified text without hyphenation | `clarify` — use `text-align: left` for body |
| `tiny-text` | Body text below 12px | `harden` — minimum 14px body, 16px preferred |
| `all-caps-body` | Long body passages in uppercase | `clarify` — reserve uppercase for short labels only |
| `wide-tracking` | Letter spacing above 0.05em on body text | `polish` — reserve wide tracking for uppercase labels |

## Reference Files

| Domain | File | Key Signals Covered |
|--------|------|---------------------|
| Typography | `references/typography.md` | `overused-font`, `flat-type-hierarchy`, `single-font`, `italic-serif-display` |
| Color (OKLCH) | `references/color-oklch.md` | `ai-color-palette`, `gradient-text`, `dark-glow`, `low-contrast`, `gray-on-color` |
| Motion | `references/motion.md` | `bounce-easing`, `layout-transition`, `animate` verb |
| Spatial | `references/spatial.md` | `nested-cards`, `monotonous-spacing`, `cramped-padding`, `line-length` |
| Interaction | `references/interaction.md` | `missing-focus-ring`, `hover-only-content`, all 8 interactive states |
| Responsive | `references/responsive.md` | `side-tab` (mobile nav), breakpoints, container queries |
| UX Writing | `references/ux-writing.md` | `placeholder-as-label`, `vague-cta`, error message patterns |

## Running the Linter

No install needed. Run against any file path or directory:

```bash
npx impeccable detect <target>
```

Examples:
```bash
npx impeccable detect src/components/Card.tsx
npx impeccable detect src/
npx impeccable detect dist/index.html
```

Parse output: each finding has `id` (the signal name above), `file`, `line`, and `message`. Map `id` to the signal table above for the fix verb.

## Workflows

- `workflows/review.md` — lint, map findings to verbs and references, apply the maturity gate (advisory vs blocking), findings table

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Inter is fine — everyone uses it" | That is the problem. Every AI-generated UI uses it. It signals default choice, not design intent. |
| "Gradient text looks premium" | It reads as AI-generated. Solid color with weight contrast is more premium. |
| "Nested cards add structure" | Nested cards add noise. Spacing and type hierarchy add structure. |
| "The linter is too strict" | Each rule maps to a documented AI-slop tell or accessibility standard. Challenge the rule with evidence, not vibes. |
| "We can fix slop after MVP" | Slop trains users to expect low-quality. First impressions are product. Fix during design, not after launch. |
| "This design is intentional" | Intentional means you can explain the trade-off. If you can't, it's accidental. |

## Verification

- [ ] `npx impeccable detect` ran and output parsed
- [ ] All `slop` category findings addressed (or explicitly accepted with rationale)
- [ ] `quality` findings at critical severity addressed
- [ ] Design verbs applied: each change maps to a verb and a signal
- [ ] Typography reference consulted for font choices
- [ ] Color reference consulted for palette decisions
- [ ] Motion reference consulted before adding any animation
