> Attribution: Adapted from [impeccable](https://github.com/pbakaus/impeccable) by Peter Bakaus, Apache-2.0.

# Motion Reference

Signals covered: `bounce-easing`, `layout-transition`, `animation-overuse`

## Duration Budget

Match duration to the weight of the change:

| Duration | Use Case | Examples |
|----------|----------|---------|
| 100–150ms | Instant feedback (micro) | Button press, toggle, color change, badge update |
| 200–300ms | State changes (standard) | Menu open, tooltip appear, hover state |
| 300–500ms | Layout changes | Accordion expand, drawer, panel slide |
| 500ms+ | Entrance animations | Page load, hero reveal, modal open |

**Exit animations are ~75% of enter duration.** Elements leave faster than they arrive — they are no longer the focus.

## Easing

Never use bare `ease` — it is a compromise, rarely optimal.

| Curve | Use For | CSS |
|-------|---------|-----|
| `ease-out` | Elements entering | `cubic-bezier(0.16, 1, 0.3, 1)` |
| `ease-in` | Elements leaving | `cubic-bezier(0.7, 0, 0.84, 0)` |
| `ease-in-out` | State toggles (open ↔ close) | `cubic-bezier(0.65, 0, 0.35, 1)` |

**For micro-interactions, use exponential out curves:**

```css
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);    /* smooth, refined */
--ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);    /* slightly dramatic */
--ease-out-expo:  cubic-bezier(0.16, 1, 0.3, 1);     /* snappy, confident */
```

**`bounce-easing` signal fires on:** `cubic-bezier` values with overshoot (control points outside 0–1 on Y axis), spring physics libraries producing bounce, or `animation-timing-function: bounce`.

Bounce and elastic easing were trendy in 2015. Real objects decelerate smoothly. Overshoot draws attention to the animation, not the content.

## What to Animate

Safe properties (GPU-accelerated, no layout recalculation):
- `transform` (translate, scale, rotate)
- `opacity`
- `filter` (blur, brightness — bounded to small areas)
- `clip-path` (for reveals and wipes)
- `backdrop-filter` (for glass effects — verify performance)

**`layout-transition` signal fires on:** animating `width`, `height`, `padding`, `margin`, `top`, `left` casually. These trigger layout recalculation on every frame.

Exception for height: use `grid-template-rows: 0fr` → `1fr` for smooth height animation without animating `height` directly.

## Staggered Animations

Use CSS custom properties for clean stagger:

```css
.item {
  animation: slide-up 300ms var(--ease-out-quart);
  animation-delay: calc(var(--i, 0) * 50ms);
}
```

Set `style="--i: 0"`, `--i: 1`, `--i: 2` on each item.

**Cap total stagger time:** 10 items × 50ms = 500ms total. For many items, reduce per-item delay or cap staggered count at 5–8.

## Reduced Motion (Required)

Vestibular disorders affect ~35% of adults over 40. `prefers-reduced-motion` is not optional.

```css
/* Define animations normally */
.panel {
  animation: slide-in 400ms var(--ease-out-expo);
}

/* Substitute for reduced-motion users */
@media (prefers-reduced-motion: reduce) {
  .panel {
    animation: fade-in 200ms ease-out;  /* crossfade instead of motion */
  }
}

/* Or disable entirely */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

Crossfades are acceptable under reduced-motion. Total stillness is acceptable. Motion is not.

## Premium Motion Materials

Transform + opacity is the reliable baseline. Premium interfaces also use:
- **Blur/filter reveals**: focus pulls, atmospheric transitions, softened entrances
- **Clip-path wipes**: editorial cropping, product-like transitions
- **Shadow bloom**: energy, affordance, active state
- **Variable font axes**: weight or width animation on keyframes

The hard rule is not "transform and opacity only." The hard rule: avoid layout-driving properties casually, keep expensive effects bounded to small areas, verify smooth on target viewports.

## Verification

- [ ] No `ease` used bare — specific curves assigned
- [ ] No bounce or elastic easing
- [ ] No layout property animation (`width`, `height`, `padding`, `margin`)
- [ ] `prefers-reduced-motion` handled for every animation
- [ ] Exit durations ~75% of enter durations
- [ ] Stagger total time ≤500ms
