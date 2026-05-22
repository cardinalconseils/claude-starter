> Attribution: Adapted from [impeccable](https://github.com/pbakaus/impeccable) by Peter Bakaus, Apache-2.0.

# Interaction Reference

Signals covered: `missing-focus-ring`, `hover-only-content`

## The Eight Interactive States

Every interactive element needs all eight states. Design them — do not leave them to browser defaults.

| State | When | Visual Treatment |
|-------|------|-----------------|
| **Default** | At rest | Base styling |
| **Hover** | Pointer over (not touch) | Subtle lift, color shift, cursor change |
| **Focus** | Keyboard/programmatic focus | Visible ring — see below |
| **Active** | Being pressed | Pressed-in feel, darker, scaled down slightly |
| **Disabled** | Not interactive | Reduced opacity, `cursor: not-allowed`, no pointer events |
| **Loading** | Processing | Spinner or skeleton — not a frozen button |
| **Error** | Invalid state | Red border, icon, accessible error message |
| **Success** | Completed | Green check, confirmation message |

**Common miss:** Designing hover without focus. Keyboard users never see hover states. They are different states and need different treatment.

## Focus Rings — Non-Negotiable

Never `outline: none` without a replacement. It is an accessibility violation and breaks keyboard navigation for millions of users.

Use `:focus-visible` to show rings only for keyboard users (not mouse/touch):

```css
/* Remove focus ring for mouse/touch */
button:focus {
  outline: none;
}

/* Show focus ring for keyboard */
button:focus-visible {
  outline: 2px solid var(--color-accent);
  outline-offset: 2px;
  border-radius: 4px; /* match element shape */
}
```

Focus ring design requirements:
- **Contrast**: 3:1 minimum against adjacent colors (WCAG 2.2)
- **Thickness**: 2–3px
- **Offset**: placed outside the element, not inside (use `outline-offset`)
- **Consistency**: same visual language across all interactive elements

**`missing-focus-ring` signal fires on:** `outline: none` or `outline: 0` without a `:focus-visible` replacement.

## Hover-Only Content

**`hover-only-content` fires when information is only accessible via hover.**

Touch users (mobile, tablets) cannot hover. Hover can be a progressive enhancement — the content must be accessible without it:
- Tooltips: must also be accessible via focus, or inline if essential
- Dropdown navigation: must also be triggered by click/tap
- Action buttons revealed on hover: must be accessible via keyboard focus

```css
/* Detect hover capability before using hover */
@media (hover: hover) {
  .card:hover .actions { opacity: 1; }
}
/* Without hover support, actions are always visible */
.card .actions { opacity: 1; }
@media (hover: hover) {
  .card .actions { opacity: 0; }
  .card:hover .actions, .card:focus-within .actions { opacity: 1; }
}
```

## Form Design

**Labels:** Always use visible `<label>` elements. Placeholders disappear on input — they are hints, not labels. `placeholder-as-label` = accessibility failure.

**Validation timing:** Validate on blur (when user leaves the field), not on every keystroke. Exception: password strength feedback is expected while typing.

**Error placement:** Below the field. Connect via `aria-describedby`:

```html
<input id="email" aria-describedby="email-error" aria-invalid="true">
<p id="email-error" role="alert">Email needs an @ symbol. Example: you@example.com</p>
```

**Required fields:** Mark required fields with `aria-required="true"`. Do not rely on color alone to indicate required state.

## Loading States

**Optimistic updates:** Show success immediately, roll back on failure. Use for low-stakes actions (likes, follows, saves). Never for payments, deletions, or irreversible actions.

**Skeleton screens over spinners:** Skeletons preview content shape and feel faster because they reduce uncertainty. Reserve spinners for indeterminate operations (file upload, long processing).

```css
/* Skeleton pulse animation */
@keyframes skeleton-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

.skeleton {
  background: var(--color-surface-2);
  border-radius: 4px;
  animation: skeleton-pulse 1.5s ease-in-out infinite;
}
```

## Modals — Use Sparingly

Modals interrupt. They are often the lazy answer. Before a modal, exhaust:
- Inline expansion (accordion, show/hide)
- Side panel or drawer
- Inline form or edit-in-place
- Contextual menu

When a modal is correct: use the `inert` attribute for focus trapping instead of complex JavaScript:

```html
<!-- When modal opens -->
<main inert><!-- background content --></main>
<dialog open><!-- modal content --></dialog>
```

`inert` prevents focus and click events on content behind the modal. Remove `inert` on close.

## Micro-Interactions

Good micro-interactions feel inevitable, not added. Apply at:
- Button press: `transform: scale(0.98)` at 100ms
- Toggle switch: smooth 200ms track + thumb transition
- Checkbox check: 150ms scale-in with ease-out
- Icon swap on state change: crossfade at 150ms

Never animate for decoration. Every animation should confirm an action or communicate a state change.

## Keyboard Navigation

All interactive elements must be reachable via Tab. Logical tab order follows DOM order — avoid creating visual order that differs from DOM order. Use `tabindex="-1"` for programmatic focus only, never to remove elements from the tab order.

## Verification

- [ ] All interactive elements have all 8 states designed
- [ ] Focus rings present and visible on all interactive elements (`:focus-visible`)
- [ ] No `outline: none` without replacement
- [ ] No hover-only content (fallback for touch/keyboard)
- [ ] Forms use visible labels, not placeholder-as-label
- [ ] Error messages connected via `aria-describedby`
- [ ] Modals use `inert` for focus trapping
- [ ] Loading states use skeletons for content-shaped operations
- [ ] Tab order matches visual reading order
