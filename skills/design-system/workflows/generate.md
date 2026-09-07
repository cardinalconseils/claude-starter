# Workflow: Generate DESIGN.html — interactive design system from brand tokens

Produce a complete `DESIGN.html` at the project root: the 9 sections from `SKILL.md`,
rendered swatches, live type specimens, styled component examples, the shared nav shell.

## 1. Source

Check in order, then confirm the source with `AskUserQuestion`:
1. `.kickstart/brand.md` — primary input when present
2. A Claude.ai/design or Google Stitch export URL
3. Any brand website URL
4. Guided Q&A about aesthetic direction, dark/light mode, references

URL sources need `WebFetch`. A role without it returns to the chief of staff with the
researcher dispatch ("fetch {URL}, extract CSS custom properties `--color-*`, `--font-*`,
`--spacing-*`, `--radius-*`, swatch hex values, typography specimens, component styles")
or asks the user to paste the tokens. Never invent brand colors.

## 2. Extract tokens

- **Colors** — every hex, with a semantic role (primary, surface, text, accent, status,
  border)
- **Typography** — families, weight scale, size hierarchy with exact px/rem and line-heights
- **Spacing** — base unit (4px or 8px) and scale
- **Components** — button styles, card treatment, inputs, radius, shadows
- **Layout** — max-width, grid, whitespace philosophy

Note the source in the header: `Imported from {Claude.ai/design | Google Stitch | URL |
brand.md | Q&A} on {date}`.

## 3. Build the file

Nav shell from `skills/prd/references/html-shell.md`, Design tab active, prefix `./`,
disable tabs whose artifacts are absent. Brand color: hex near `primary` / `brand` /
`accent` in `.kickstart/brand.md` → existing `DESIGN.html` `--color-primary` / `--accent`
→ default `#6366f1`; inject as `--accent` in `:root`.

Exact values only: hex not names, px/rem not "large". Rendered
`<div class="swatch-block" style="background:{hex}">` per color; live `<p>` specimens per
type step; real `<button>`, `<input>`, `<div class="card">` renders; ≥ 8 Do's and ≥ 8
Don'ts in two columns; an Agent Prompt Guide with copy-paste prompts for Stitch, v0,
Lovable. Dark mode first, system font stack, max-width 1200px, single column below 768px,
print-friendly. All CSS inline; no CDN, no external refs.

For "inspired by {brand}" requests read `references/design-md-examples.md`.

## 4. Quality check before writing

All 9 sections present · nav embedded · `--accent` injected · every color has a swatch
and a role · specimens carry exact sizes and weights · components are rendered HTML, not
descriptions · Do's/Don'ts ≥ 8 each · prompt guide present · fully self-contained.

## 5. Write

`DESIGN.html` at the project root. An existing `DESIGN.md` is an input, never deleted —
the HTML lives alongside it.
