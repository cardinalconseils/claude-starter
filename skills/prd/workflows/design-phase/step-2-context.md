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
- `.brand/guidelines.md` — Brand guidelines (if exists — pre-fills design tokens, colors, typography, voice)
- Existing design specs in `.prd/phases/{NN}-{name}/design/` (if any)

Extract from CONTEXT.md:
- User stories → screens to design
- Acceptance criteria → UI behaviors to support
- Constraints → design limitations

**If `.brand/guidelines.md` exists:**
- Use the color palette directly for design tokens — do not ask the user to choose colors
- Use the typography choices for font selections
- Use the UI preferences (component library, design direction, border radius, spacing) as defaults
- Use the brand voice for button labels, error messages, and empty states
- Note "Brand: applied from .brand/guidelines.md" in the design output
