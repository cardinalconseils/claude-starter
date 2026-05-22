> Attribution: Adapted from [impeccable](https://github.com/pbakaus/impeccable) by Peter Bakaus, Apache-2.0.

# Responsive Reference

Signals covered: `side-tab` (desktop-only nav on mobile), breakpoints, fluid type, container queries

## Mobile-First

Write base styles for mobile. Use `min-width` queries to add complexity for larger screens. Desktop-first (`max-width`) means mobile downloads unnecessary styles — and trains you to think of mobile as a stripped-down afterthought.

```css
/* Mobile-first */
.nav { display: flex; flex-direction: column; }

@media (min-width: 768px) {
  .nav { flex-direction: row; }
}
```

## Breakpoints

Let content drive breakpoints — not device sizes. Start narrow, stretch the viewport until the design breaks, add a breakpoint there. Three breakpoints usually suffice:

| Token | Width | Context |
|-------|-------|---------|
| `sm` | 375px | Small phones |
| `md` | 768px | Tablets, large phones landscape |
| `lg` | 1024px | Laptops, tablet landscape |
| `xl` | 1440px | Desktop, widescreen |

Use `clamp()` for fluid values without breakpoints:

```css
/* Fluid type: 16px at 375px, 20px at 1440px */
font-size: clamp(1rem, 0.5vw + 0.875rem, 1.25rem);

/* Fluid spacing */
padding: clamp(1rem, 4vw, 3rem);
```

## Detect Input Method, Not Just Screen Size

Screen size does not tell you input method. A laptop may have a touchscreen. A tablet may have a keyboard. Use pointer and hover media queries:

```css
/* Mouse or trackpad (fine pointer) */
@media (pointer: fine) {
  .button { padding: 8px 16px; }
}

/* Touch or stylus (coarse pointer) */
@media (pointer: coarse) {
  .button { padding: 12px 20px; } /* larger touch target */
}

/* Device supports hover */
@media (hover: hover) {
  .card:hover { transform: translateY(-2px); }
}

/* Touch device — no hover */
@media (hover: none) {
  .card { /* use :active instead */ }
}
```

Never rely on hover for functionality. Touch users cannot hover.

## Side-Tab on Mobile

**`side-tab` signal fires on thick colored border-left or border-right on cards.**

This pattern also represents a broader class: desktop-only navigation or interaction patterns that break on mobile.

Common mobile traps:
- Fixed sidebar navigation that collapses to nothing on mobile
- Hover-dependent dropdown menus with no touch equivalent
- Wide data tables without horizontal scroll or responsive reflow
- Side-by-side layouts that should stack vertically

Fix: design the mobile view first. The desktop view adds progressive enhancement.

## Safe Areas — Handle the Notch

Modern phones have notches, rounded corners, and home indicators. Use `env()`:

```css
body {
  padding-top: env(safe-area-inset-top);
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

/* With fallback for browsers that don't support it */
.footer {
  padding-bottom: max(1rem, env(safe-area-inset-bottom));
}
```

Enable viewport-fit in the meta tag:
```html
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
```

## Container Queries — Components, Not Pages

Viewport queries are for page layouts. Container queries are for components — the component responds to its container's size, not the viewport:

```css
.card-container {
  container-type: inline-size;
  container-name: card;
}

.card {
  display: grid;
  gap: var(--space-md);
}

@container card (min-width: 400px) {
  .card {
    grid-template-columns: 120px 1fr;
  }
}
```

A card in a narrow sidebar stays compact while the same card in a main content area expands — without viewport breakpoint hacks.

## Responsive Self-Adjusting Grids

Grid without breakpoints using `auto-fit`:

```css
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--space-lg);
}
```

Columns are at least 280px, as many as fit per row, leftovers stretch. Adjust the 280px minimum to control the column count at each viewport.

## Images

Always set `width` and `height` attributes to prevent layout shift (CLS). Use `loading="lazy"` for off-screen images. Use `srcset` for responsive image delivery:

```html
<img
  src="hero.jpg"
  srcset="hero-400.jpg 400w, hero-800.jpg 800w, hero-1200.jpg 1200w"
  sizes="(max-width: 768px) 100vw, 50vw"
  width="1200"
  height="800"
  loading="lazy"
  alt="Description"
>
```

## Verification

- [ ] Mobile-first CSS (base styles for mobile, `min-width` queries for larger)
- [ ] Content-driven breakpoints (not device-name-driven)
- [ ] Fluid values using `clamp()` where appropriate
- [ ] Input method detection (`pointer: coarse` for larger touch targets)
- [ ] No hover-only functionality
- [ ] Safe area `env()` insets applied to fixed/sticky elements
- [ ] Container queries used for component-level responsive behavior
- [ ] Images have `width`/`height` attributes and `loading="lazy"`
