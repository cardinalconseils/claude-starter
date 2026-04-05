# Step 2: Load Design Context

<context>
Phase: Design (Phase 2)
Requires: {NN}-CONTEXT.md
Produces: Design context loaded into working memory
</context>

## Instructions

Read all necessary context:
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` — Discovery output (user stories, acceptance criteria, scope)
- `.prd/PRD-PROJECT.md` — Project context
- `CLAUDE.md` — Project conventions
- `DESIGN.md` (project root) — Full design system (if exists — authoritative source for ALL visual decisions)
- `.brand/guidelines.md` — Brand guidelines (if exists and no DESIGN.md — pre-fills design tokens, colors, typography, voice)
- Existing design specs in `.prd/phases/{NN}-{name}/design/` (if any)

Extract from CONTEXT.md:
- User stories → screens to design
- Acceptance criteria → UI behaviors to support
- Constraints → design limitations

**If `DESIGN.md` exists at project root (highest priority):**
- This is the authoritative design system — it takes precedence over .brand/guidelines.md
- Use its Color Palette & Roles for all color decisions — pass hex tokens to Stitch MCP prompts
- Use its Typography Rules for all font decisions
- Use its Component Stylings for button, card, input, and badge specs
- Use its Layout Principles for spacing, grid, and max-width
- Enforce its Do's and Don'ts as hard constraints in screen generation
- Include its Agent Prompt Guide instructions in Stitch MCP prompts
- Note "Design system: applied from DESIGN.md" in the design output
- Do NOT invent new colors, typography, or spacing that conflict with DESIGN.md

**If `.brand/guidelines.md` exists (and no DESIGN.md):**
- Use the color palette directly for design tokens — do not ask the user to choose colors
- Use the typography choices for font selections
- Use the UI preferences (component library, design direction, border radius, spacing) as defaults
- Use the brand voice for button labels, error messages, and empty states
- Note "Brand: applied from .brand/guidelines.md" in the design output
