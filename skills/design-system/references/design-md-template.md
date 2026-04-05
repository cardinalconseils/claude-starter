# DESIGN.md Template

Use this template structure when generating DESIGN.md files. Replace all bracketed placeholders with actual values.

---

```markdown
# Design System: [Brand Name]

> [One-sentence design philosophy — the emotional/aesthetic DNA of this brand]

## 1. Visual Theme & Atmosphere

[Describe the overall aesthetic: is it dark-mode-native, warm editorial, clinical, playful?
Include 2-3 metaphors that capture the vibe. Example: "a literary salon reimagined as a product page"]

- **Mode**: [Dark-first / Light-first / Dual]
- **Mood**: [e.g., "Calm precision", "Bold energy", "Warm intellect"]
- **Signature Elements**: [e.g., "Organic illustrations", "Glassmorphism cards", "Monospace accents"]

## 2. Color Palette & Roles

### Core Palette
| Token | Hex | Role |
|-------|-----|------|
| `--color-primary` | #______ | Primary actions, CTAs |
| `--color-primary-hover` | #______ | Primary hover state |
| `--color-secondary` | #______ | Secondary actions |
| `--color-brand` | #______ | Brand accent (logo, highlights) |

### Surfaces
| Token | Hex | Role |
|-------|-----|------|
| `--surface-base` | #______ | Page background |
| `--surface-raised` | #______ | Cards, panels |
| `--surface-overlay` | #______ | Modals, dropdowns |

### Text
| Token | Hex | Role |
|-------|-----|------|
| `--text-primary` | #______ | Headings, body |
| `--text-secondary` | #______ | Descriptions, labels |
| `--text-tertiary` | #______ | Placeholders, hints |
| `--text-inverse` | #______ | Text on primary backgrounds |

### Status
| Token | Hex | Role |
|-------|-----|------|
| `--status-success` | #______ | Success states |
| `--status-warning` | #______ | Warning states |
| `--status-error` | #______ | Error states |
| `--status-info` | #______ | Info states |

### Borders
| Token | Hex | Role |
|-------|-----|------|
| `--border-default` | #______ | Standard borders |
| `--border-subtle` | #______ | Dividers, separators |

## 3. Typography Rules

### Font Stack
- **Primary**: [Font name], [fallback stack]
- **Monospace**: [Font name], [fallback stack]
- **Display** (optional): [Font name for headlines]

### Type Scale
| Style | Size | Weight | Line Height | Letter Spacing | Use |
|-------|------|--------|-------------|----------------|-----|
| Display XL | __px / __rem | ___ | _._  | ___em | Hero headlines |
| Display | __px / __rem | ___ | _._  | ___em | Page titles |
| H1 | __px / __rem | ___ | _._  | ___em | Section headers |
| H2 | __px / __rem | ___ | _._  | ___em | Subsection headers |
| H3 | __px / __rem | ___ | _._  | ___em | Card titles |
| Body L | __px / __rem | ___ | _._  | normal | Long-form reading |
| Body | __px / __rem | ___ | _._  | normal | Default text |
| Body S | __px / __rem | ___ | _._  | normal | Secondary text |
| Caption | __px / __rem | ___ | _._  | ___em | Labels, metadata |
| Micro | __px / __rem | ___ | _._  | ___em | Badges, tags |

### Weight System
| Weight | Value | Use |
|--------|-------|-----|
| Regular | 400 | Body text |
| Medium | 500 | Emphasis, labels |
| Semibold | 600 | Subheadings, buttons |
| Bold | 700 | Headings |

## 4. Component Stylings

### Buttons
| Variant | Background | Text | Border | Radius | Padding |
|---------|-----------|------|--------|--------|---------|
| Primary | `--color-primary` | `--text-inverse` | none | __px | __px __px |
| Secondary | transparent | `--text-primary` | 1px `--border-default` | __px | __px __px |
| Ghost | transparent | `--text-secondary` | none | __px | __px __px |
| Destructive | `--status-error` | white | none | __px | __px __px |

### Cards
- Background: `--surface-raised`
- Border: 1px solid `--border-subtle`
- Border radius: __px
- Padding: __px
- Shadow: [shadow value]

### Inputs
- Background: [value]
- Border: [value]
- Border radius: __px
- Padding: __px __px
- Focus ring: [value]
- Placeholder color: `--text-tertiary`

### Badges / Pills
- Font size: Caption scale
- Padding: __px __px
- Border radius: 9999px (pill) or __px
- Variants: [list color variants]

### Navigation
- [Describe nav component styling: sidebar, topbar, tabs]

## 5. Layout Principles

### Spacing System
- **Base unit**: __px
- **Scale**: [e.g., 4, 8, 12, 16, 24, 32, 48, 64, 96]

### Grid
- **Max width**: ____px
- **Columns**: [12-column / flexible]
- **Gutter**: __px
- **Margin**: __px (desktop), __px (mobile)

### Whitespace Philosophy
[1-2 sentences: generous vs. compact, how space is used to create hierarchy]

## 6. Depth & Elevation

### Shadow Scale
| Level | Shadow | Use |
|-------|--------|-----|
| None | none | Flat elements |
| SM | [value] | Subtle lift (cards) |
| MD | [value] | Dropdowns, popovers |
| LG | [value] | Modals, dialogs |
| XL | [value] | Floating elements |

### Border Treatment
[Describe approach: ring-based shadows vs. traditional borders, opacity values]

## 7. Do's and Don'ts

### Do
- [At least 8 specific, actionable rules]

### Don't
- [At least 8 specific things to avoid]

## 8. Responsive Behavior

### Breakpoints
| Name | Min Width | Notes |
|------|-----------|-------|
| Mobile S | < ___px | [collapsing strategy] |
| Mobile | ___px | [collapsing strategy] |
| Tablet | ___px | [collapsing strategy] |
| Desktop | ___px | Default layout |
| Desktop L | ___px+ | [max-width behavior] |

### Responsive Rules
- [Navigation collapse behavior]
- [Grid reflow behavior]
- [Typography scaling behavior]
- [Image/media behavior]

## 9. Agent Prompt Guide

### Quick Reference
When generating UI for this project:
1. Always use the color tokens defined above — never invent colors
2. Follow the type scale exactly — don't interpolate sizes
3. Use the spacing system base unit for all padding/margin
4. Apply the shadow scale for elevation — don't create custom shadows
5. Check Do's and Don'ts before finalizing any component

### Example Prompts
- "Create a pricing page using this DESIGN.md"
- "Build a dashboard layout following the grid and spacing system"
- "Design a form component using the input and button specs"

### Iteration Checklist
After generating, verify:
- [ ] Colors match the palette (no invented colors)
- [ ] Typography follows the scale (no interpolated sizes)
- [ ] Spacing uses the base unit multiples
- [ ] Components match the specified styles
- [ ] Responsive behavior follows the breakpoints
```
