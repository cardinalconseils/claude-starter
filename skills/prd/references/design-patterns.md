# Design Patterns Reference

## Component Architecture

### Atomic Design Hierarchy

```
Atoms → Molecules → Organisms → Templates → Pages
```

| Level | Definition | Examples |
|-------|-----------|----------|
| **Atoms** | Single UI elements, no children | Button, Input, Label, Icon, Badge |
| **Molecules** | Simple groups of atoms | FormField (Label + Input + Error), SearchBar, NavItem |
| **Organisms** | Complex, distinct sections | Header, Sidebar, DataTable, Form, Card |
| **Templates** | Page-level layouts (no real data) | DashboardLayout, AuthLayout, SettingsLayout |
| **Pages** | Templates with real data | Dashboard, Login, UserProfile |

### Component Naming

```
{Domain}{Variant}{Element}
```

Examples:
- `UserAvatarSmall` — domain: User, variant: Small, element: Avatar
- `InvoiceLineItem` — domain: Invoice, element: LineItem
- `DashboardMetricCard` — domain: Dashboard, element: MetricCard

### File Structure

```
components/
├── atoms/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx
│   │   └── index.ts
│   └── Input/
├── molecules/
│   └── FormField/
├── organisms/
│   └── Header/
├── templates/
│   └── DashboardLayout/
└── pages/
    └── Dashboard/
```

## Design Token Standards

### Naming Convention

```
--{category}-{property}-{variant}

Examples:
--color-primary-500
--font-size-lg
--space-4
--radius-md
--shadow-lg
```

### Color Scale

Each color gets a 50-950 scale:
```
50: lightest (backgrounds)
100-200: light (hover states, borders)
300-400: medium (secondary text)
500: base (primary use)
600-700: dark (text on light backgrounds)
800-900: darkest (headings)
950: near-black
```

### Semantic Colors

Map functional meaning to color tokens:
```
--color-success → --color-green-500
--color-error → --color-red-500
--color-warning → --color-amber-500
--color-info → --color-blue-500
```

## Responsive Design

### Mobile-First Breakpoints

```css
/* Base: mobile (< 640px) */
/* sm: 640px  — large phones, small tablets */
/* md: 768px  — tablets */
/* lg: 1024px — laptops */
/* xl: 1280px — desktops */
/* 2xl: 1536px — large screens */
```

### Layout Patterns

| Pattern | Mobile | Desktop | Use Case |
|---------|--------|---------|----------|
| Stack → Grid | Single column | 2-4 columns | Card layouts, dashboards |
| Drawer → Sidebar | Hamburger + drawer | Persistent sidebar | Navigation |
| Bottom Sheet → Modal | Bottom sheet | Centered modal | Actions, forms |
| Tab Bar → Top Nav | Bottom tabs | Top navigation | App navigation |

## Accessibility Checklist

- [ ] All images have alt text
- [ ] Form inputs have labels (visible or aria-label)
- [ ] Color is not the only indicator of state
- [ ] Contrast ratio ≥ 4.5:1 for text, ≥ 3:1 for large text
- [ ] Focus order follows visual order
- [ ] All interactive elements are keyboard-accessible
- [ ] Touch targets ≥ 44x44px
- [ ] Screen reader announces dynamic content changes (aria-live)
- [ ] Skip links for main content
- [ ] Error messages are associated with their inputs

## Stitch MCP Prompt Patterns

### Screen Generation

```
"Create a [screen type] for [app description].

The screen should:
- [requirement 1]
- [requirement 2]

Layout: [mobile-first | desktop-first]
Style: [modern minimal | data-dense | marketing | dashboard | form-heavy]
Color scheme: [from design tokens or describe]
Components needed: [list specific components]"
```

### Effective Prompts by Screen Type

| Screen Type | Key Prompt Elements |
|-------------|-------------------|
| Dashboard | Metric cards, charts, KPI layout, data density |
| Form | Field types, validation states, multi-step indicators |
| List/Table | Column definitions, sorting, filtering, pagination |
| Landing | Hero, CTA, social proof, features grid |
| Auth | Centered card, OAuth buttons, error states |
| Settings | Grouped sections, toggles, save actions |
| Empty State | Illustration, CTA, getting started guide |
