> Attribution: Adapted from [impeccable](https://github.com/pbakaus/impeccable) by Peter Bakaus, Apache-2.0.

# Color (OKLCH) Reference

Signals covered: `ai-color-palette`, `gradient-text`, `dark-glow`, `low-contrast`, `gray-on-color`, `pure-black-white`

## Use OKLCH, Not HSL

`oklch(lightness chroma hue)` is perceptually uniform — equal lightness steps look equal. HSL is not: 50% lightness in yellow looks bright while 50% in blue looks dark.

```css
/* Bad — HSL */
color: hsl(250, 70%, 50%);

/* Good — OKLCH */
color: oklch(55% 0.18 250);
```

Building a shade scale: hold chroma and hue roughly constant, vary lightness. **Reduce chroma as you approach white (L→100) or black (L→0)** — high chroma at extremes looks garish.

The hue is a brand decision. Do not reach for blue (250) or warm orange (60) by reflex — those are AI-design defaults, not brand choices.

## Palette Structure

| Role | Purpose | Shades |
|------|---------|--------|
| Primary | Brand, CTAs, key actions | 3–5 shades |
| Neutral | Text, backgrounds, borders | 9–11 shade scale |
| Semantic | Success / error / warning / info | 4 colors, 2–3 shades each |
| Surface | Cards, modals, overlays | 2–3 elevation levels |

Skip secondary/tertiary until you need them. One accent color works for most UIs. More colors = more decision fatigue.

## Tinted Neutrals

Pure gray (`oklch(50% 0 0)`) feels lifeless next to a brand color. Add tiny chroma toward the brand hue:
- Chroma: 0.005–0.015 (subconscious cohesion, not obviously tinted)
- Hue: match THIS project's brand, not "warm = friendly, cool = tech"

Never default to warm orange or cool blue neutrals — that is the most saturated AI default.

## AI Color Palette Traps

**`ai-color-palette` signal fires on:**
- Purple/violet (`oklch(55% 0.18 300)` range) as the primary color
- Cyan-on-dark as the accent
- Purple-to-blue gradients anywhere

These combinations are so common in AI-generated UIs they signal "not designed by a human." Choose a distinctive, brand-motivated palette.

**`gradient-text` signal fires on:**
- `background-clip: text` with a gradient background
- `-webkit-background-clip: text`
- Tailwind: `bg-clip-text`

Gradient text is decorative, never meaningful. Use solid color text. Emphasis via weight or size, not color-clipping.

**`dark-glow` signal fires on:**
- Dark background + `box-shadow` with colored glow
- The "neon on dark" aesthetic

This is the most recognizable AI "cool" look. Use subtle, purposeful elevation shadows instead, or remove the dark theme.

## WCAG Contrast Thresholds

| Content | AA Minimum | AAA Target |
|---------|-----------|------------|
| Body text | 4.5:1 | 7:1 |
| Large text (≥18px or ≥14px bold) | 3:1 | 4.5:1 |
| UI components, icons | 3:1 | 4.5:1 |
| Decorative non-essential | none | none |

**Traps:**
- Placeholder text still needs 4.5:1 — light gray placeholder usually fails
- `gray-on-color`: gray text on any colored background looks washed out; use a darker shade of the background or near-white
- Red on green (or reverse): 8% of men can't distinguish these
- Blue on red: vibrates visually
- Yellow on white: almost always fails

Do not trust eyes. Verify with [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) or browser DevTools → Rendering → Emulate vision deficiencies.

## Pure Black/White

`#000000` and `#ffffff` don't exist in nature. Real shadows and surfaces always carry a color cast.
- Background: tint toward brand hue with chroma 0.005–0.01
- Example: `oklch(12% 0.01 250)` — dark blue-tinted near-black
- `pure-black-white` signal fires on literal `#000` backgrounds

## 60-30-10 Rule (Applied Correctly)

Visual weight, not pixel count:
- 60%: Neutral backgrounds, white space, base surfaces
- 30%: Text, borders, inactive states
- 10%: Accent — CTAs, highlights, focus states

Accent colors work because they are rare. Overuse kills their power. This is Restrained strategy only — Committed / Full Palette / Drenched designs intentionally exceed 10%.

## Light and Dark Mode

Define tokens, not literal colors:

```css
:root {
  --color-surface: oklch(98% 0.005 250);
  --color-text: oklch(15% 0.01 250);
  --color-accent: oklch(55% 0.18 250);
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-surface: oklch(12% 0.01 250);
    --color-text: oklch(92% 0.005 250);
    /* accent may need chroma adjustment for contrast */
  }
}
```

Never duplicate component styles for dark mode. Token swap is the pattern.

## Verification

- [ ] OKLCH used (not HSL)
- [ ] No purple/violet primary unless brand-motivated and intentional
- [ ] No `background-clip: text` gradient
- [ ] No colored box-shadow glows on dark backgrounds
- [ ] All text passes WCAG AA contrast ratio
- [ ] Neutrals tinted toward brand hue (chroma > 0)
- [ ] No `#000` or `#fff` without tinting
