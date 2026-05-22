> Attribution: Adapted from [impeccable](https://github.com/pbakaus/impeccable) by Peter Bakaus, Apache-2.0.

# Spatial Reference

Signals covered: `nested-cards`, `monotonous-spacing`, `cramped-padding`, `line-length`, `everything-centered`, `body-text-viewport-edge`

## Spacing System

**Use 4pt base, not 8pt.** 8pt is too coarse — you will frequently need 12px (between 8 and 16). 4pt scale:

```
4, 8, 12, 16, 24, 32, 48, 64, 96px
```

Name tokens semantically, not by value:

```css
--space-xs:  4px;
--space-sm:  8px;
--space-md:  16px;
--space-lg:  24px;
--space-xl:  48px;
--space-2xl: 96px;
```

Use `gap` instead of margins for sibling spacing — eliminates margin collapse and cleanup hacks.

## Monotonous Spacing — The Most Common Slop

**`monotonous-spacing` fires when one spacing value dominates the page.**

The fix is rhythm: tight groupings for related items, generous gaps between sections.

| Context | Spacing Level |
|---------|--------------|
| Within a card (label to value) | `--space-xs` (4px) to `--space-sm` (8px) |
| Between items in a list | `--space-sm` (8px) to `--space-md` (16px) |
| Between card components | `--space-md` (16px) to `--space-lg` (24px) |
| Between page sections | `--space-xl` (48px) to `--space-2xl` (96px) |

Same spacing everywhere = monotonous. Rhythm = intentional variation.

**Density options:**
- **Compact**: information-dense tools (admin, data tables, dev tools)
- **Comfortable**: most product UIs — enough breathing room without waste
- **Spacious**: marketing, editorial, premium brand pages

Choose a density and apply it consistently. Mixing densities within one surface is a slop tell.

## Cards — Use Sparingly

**`nested-cards` fires on cards inside cards.**

Cards are overused. Spacing and alignment create visual grouping naturally. Use cards only when:
- Content is distinct and actionable
- Items need visual comparison in a grid
- Content needs clear interaction boundaries (clickable, selectable)

**Never nest cards inside cards.** Flattening: use `border-top` dividers, spacing rhythm, or typography weight changes to create hierarchy within a card.

The alternative hierarchy tools: spacing, typography, subtle dividers, background tint — not another card shell.

## Cramped Padding

**`cramped-padding` fires when text is too close to its container edge.**

Minimum: 8px inside bordered or colored containers. Recommended: 12–16px. For cards at comfortable density: 20–24px.

**`body-text-viewport-edge` fires when body text touches the viewport edge with no container.**

Fix: wrap in a container with at least 16px (ideally 24–32px) horizontal padding, or apply `max-width` with `margin: 0 auto`.

## Line Length

**`line-length` fires when body text lines exceed ~80 characters.**

```css
.prose {
  max-width: 65ch;   /* for body text — tight, readable */
  /* or */
  max-width: 75ch;   /* for wider layouts */
}
```

`ch` units scale with the font — the limit is always relative to the type size. Beyond ~80ch, the eye loses its place tracking back to the start of the next line.

## Grid Discipline

For responsive card grids without breakpoints:

```css
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--space-lg);
}
```

Columns are at least 280px, as many as fit, leftovers stretch. For complex layouts, use named grid areas and redefine them at breakpoints.

## Centering

**`everything-centered` fires when every text element is center-aligned.**

Center only: hero sections, CTAs, modal headings, empty states.

Left-align: body text, navigation, data, form labels, card content, list items. Left-aligned text with asymmetric layouts reads as designed. All-centered reads as template.

## Hierarchy Through Multiple Dimensions

The squint test: blur your eyes (or screenshot and apply blur). Can you still identify the most important element? The second most important? Clear groupings?

Build hierarchy using 2–3 dimensions at once:
- Size + weight + space above = strong heading
- Size alone = weak heading

| Tool | Strong Hierarchy | Weak |
|------|-----------------|------|
| Size | 3:1 ratio+ | <2:1 |
| Weight | Bold vs Regular | Medium vs Regular |
| Color | High contrast | Similar tones |
| Space | Surrounded by space | Crowded |

## Touch Targets

Minimum 44×44px touch target, regardless of visual size. Use padding or pseudo-elements to expand the hit area without affecting layout:

```css
.small-button {
  padding: 12px 16px; /* ensures 44px+ height */
}
```

## Verification

- [ ] Spacing uses a defined scale (4pt base)
- [ ] No single spacing value used everywhere — rhythm varies by context
- [ ] No nested cards
- [ ] Body text has `max-width: 65–75ch`
- [ ] Container padding ≥ 12–16px inside bordered/colored containers
- [ ] Centering limited to hero, CTA, and modal contexts
- [ ] Touch targets ≥ 44×44px
