---
name: accessibility
description: >
  Web accessibility essentials (WCAG 2.1 AA) for production applications.
  Use when: building UI components, reviewing designs, adding forms, implementing
  navigation, checking color contrast, or preparing for production launch. Covers
  the 80/20 of accessibility that catches most issues.
allowed-tools: Read, Grep, Glob, Bash
---

# Accessibility

## Overview

Accessibility (a11y) ensures your application works for everyone — including the 15% of people with disabilities, keyboard power users, people with temporary injuries, and users in situational impairments (bright sunlight, one hand occupied). The 80/20 rule applies: semantic HTML and keyboard support catch most issues.

## When to Use

- Building any UI component
- Reviewing designs or mockups
- Adding forms, modals, or navigation
- Checking color contrast
- Preparing for production launch
- After receiving accessibility complaints

## When NOT to Use

- Internal CLI tools with no web interface
- Backend-only services
- Data pipelines with no user-facing output

## Process

### 1. Semantic HTML First

Use the correct elements — they provide accessibility for free.

- `<button>` not `<div onClick>` — buttons announce as clickable, handle Enter/Space
- `<nav>`, `<main>`, `<header>`, `<footer>` — landmarks for screen reader navigation
- `<h1>` through `<h6>` in order — never skip levels, never use for styling
- `<label>` with `for` attribute — links label to input for click-to-focus
- `<ul>`/`<ol>` for lists — screen readers announce "list of N items"

### 2. Keyboard Navigation

All interactive elements must be operable by keyboard alone.

- Every clickable element is focusable (native elements handle this; custom widgets need `tabindex="0"`)
- Visible focus indicators on all focusable elements (never `outline: none` without replacement)
- Logical tab order follows visual reading order
- No keyboard traps — users can always Tab away from any element
- Escape closes modals and popups

### 3. Screen Reader Support

- Meaningful alt text for images (describe the content, not "image of...")
- Decorative images get `alt=""` (empty alt, not missing alt)
- Icon buttons need `aria-label` (e.g., `aria-label="Close"`)
- Dynamic content updates use `aria-live="polite"` for non-urgent and `aria-live="assertive"` for urgent
- Hide decorative elements from screen readers with `aria-hidden="true"`

### 4. Color and Contrast

- Normal text: 4.5:1 contrast ratio minimum
- Large text (18px+ bold or 24px+ regular): 3:1 contrast ratio minimum
- Never convey information by color alone — add icons, patterns, or text labels
- Test with browser devtools color contrast checker

### 5. Forms

- Every input has a visible `<label>` (placeholder is not a label — it disappears on focus)
- Error messages are linked to inputs via `aria-describedby`
- Required fields are marked with text (not just color or asterisk without label)
- Form validation errors are announced to screen readers

### 6. ARIA — Last Resort

Use ARIA only when semantic HTML cannot express the widget. Incorrect ARIA is worse than no ARIA.

- `role` — defines what an element is (e.g., `role="dialog"`)
- `aria-label` / `aria-labelledby` — names an element
- `aria-expanded`, `aria-selected`, `aria-checked` — communicates state
- `aria-live` — announces dynamic changes

### 7. Motion and Animation

- Respect `prefers-reduced-motion` media query
- No auto-playing animations without a pause/stop control
- Avoid flashing content (3 flashes per second threshold)

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll add accessibility later" | Retrofitting a11y costs 10x more than building it in. Semantic HTML from day one is free. |
| "Our users don't need it" | 15% of people have a disability. Plus, a11y improves UX for everyone. |
| "ARIA fixes everything" | Incorrect ARIA is worse than no ARIA. Semantic HTML first, ARIA as last resort. |
| "It passes automated testing" | Automated tools catch only 30-40% of a11y issues. Manual keyboard testing is essential. |
| "We don't have time" | Using `<button>` instead of `<div onClick>` takes the same amount of time. |

## Red Flags

- `<div>` or `<span>` used as buttons or links
- `outline: none` without a replacement focus style
- Images without alt attributes (not even empty alt)
- Forms with placeholder-only labels
- Color as the only differentiator (red/green status without icons)
- Modal dialogs that cannot be closed with Escape
- No heading structure on the page

## Verification

- [ ] All interactive elements are keyboard accessible
- [ ] Visible focus indicators on every focusable element
- [ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 large)
- [ ] All images have appropriate alt text
- [ ] All form inputs have visible labels
- [ ] ARIA used only where semantic HTML is insufficient
- [ ] `prefers-reduced-motion` respected for animations
- [ ] Page navigable by screen reader with logical heading structure
