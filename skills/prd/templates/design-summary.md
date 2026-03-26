# {NN}-DESIGN.md — Design Summary

> Phase 2: Design output for Phase {NN}: {phase_name}
> Generated: {date}

## Screen Inventory

| Screen | Description | Device | Screenshot | Status |
|--------|-------------|--------|------------|--------|
| {screen-name} | {what it shows} | Desktop | `design/screens/{name}/screenshot.png` | Approved |
| {screen-name} | {what it shows} | Mobile | `design/screens/{name}/variants/mobile.html` | Approved |

## Component Hierarchy

### Atoms (Base Elements)
- `Button` — primary, secondary, ghost variants
- `Input` — text, email, password, search
- `Label` — form labels, section headers
- `Icon` — icon set reference

### Molecules (Composed Components)
- `FormField` — Label + Input + validation message
- `Card` — container with header, body, footer
- `NavItem` — Icon + Label + active state

### Organisms (Complex Components)
- `Header` — Logo + Navigation + UserMenu
- `Form` — multiple FormFields + submit action
- `DataTable` — sortable, filterable table

### Templates (Page Layouts)
- `AuthLayout` — centered card on background
- `DashboardLayout` — sidebar + header + content area
- `PublicLayout` — header + hero + content + footer

## Design Tokens

### Colors
```
--color-primary: {value}
--color-secondary: {value}
--color-accent: {value}
--color-background: {value}
--color-surface: {value}
--color-text: {value}
--color-text-muted: {value}
--color-error: {value}
--color-success: {value}
--color-warning: {value}
```

### Typography
```
--font-family-sans: {value}
--font-family-mono: {value}
--font-size-xs: {value}
--font-size-sm: {value}
--font-size-base: {value}
--font-size-lg: {value}
--font-size-xl: {value}
--font-size-2xl: {value}
--font-weight-normal: 400
--font-weight-medium: 500
--font-weight-bold: 700
--line-height-tight: 1.25
--line-height-normal: 1.5
--line-height-relaxed: 1.75
```

### Spacing
```
--space-1: 0.25rem
--space-2: 0.5rem
--space-3: 0.75rem
--space-4: 1rem
--space-6: 1.5rem
--space-8: 2rem
--space-12: 3rem
--space-16: 4rem
```

### Breakpoints
```
--breakpoint-sm: 640px
--breakpoint-md: 768px
--breakpoint-lg: 1024px
--breakpoint-xl: 1280px
```

### Other
```
--border-radius-sm: {value}
--border-radius-md: {value}
--border-radius-lg: {value}
--shadow-sm: {value}
--shadow-md: {value}
--shadow-lg: {value}
--transition-fast: 150ms ease
--transition-normal: 300ms ease
```

## UX Flows

Reference: `design/ux-flows.md`

### Primary User Journey
```
{Entry Point} → {Screen 1} → {Screen 2} → {Success State}
```

### Error Flows
```
{Action} → {Error State} → {Recovery Path}
```

## Accessibility Notes

- Minimum contrast ratio: 4.5:1 (WCAG AA)
- Focus indicators: visible on all interactive elements
- Keyboard navigation: all actions reachable via keyboard
- Screen reader: semantic HTML, ARIA labels where needed
- Touch targets: minimum 44x44px

## Design Review Sign-off

- **Reviewed by**: {stakeholder}
- **Date**: {date}
- **Decision**: Approved / Approved with notes / Rejected
- **Notes**: {any conditions or follow-ups}
