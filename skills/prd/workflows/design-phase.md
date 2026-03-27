# Workflow: Design Phase (Phase 2)

## Overview
Creates UX/UI designs for a discovered feature using Stitch SDK for screen generation and Chrome DevTools MCP for review. Produces design specs that guide Sprint implementation. Uses the **prd-designer** agent. All user interactions MUST use `AskUserQuestion` with selectable options.

## Pre-Conditions
- `.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` exists (if not, redirect to `/cks:discover`)
- `.prd/` state files exist

## Steps

### Step 0: Progress Banner

Display the lifecycle progress banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► DESIGN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ▶ current
     [2a] UX Research            ○ pending
     [2b] API Contract           ○ pending
     [2c] Screen Generation      ○ pending
     [2d] Design Iteration       ○ pending
     [2e] Component Specs        ○ pending
     [2f] Design Review          ○ pending
 [3] Sprint      ○ pending
 [4] Review      ○ pending
 [5] Release     ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 1: Determine Target Phase

Read `.prd/PRD-STATE.md` to find the active phase, or use the phase number argument.

Verify that {NN}-CONTEXT.md exists:
```
Read .prd/phases/{NN}-{name}/{NN}-CONTEXT.md
```

If no {NN}-CONTEXT.md → tell the user: "No discovery found. Run `/cks:discover {NN}` first."

### Step 2: Load Design Context

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

### Step 3: Dispatch Designer Agent (or Agent Team)

**Decision: Single designer vs. Agent Team**

Check CONTEXT.md for API Surface Map (Element 4):
- **No API surface (N/A)** → single prd-designer agent (below)
- **API surface exists** → use Agent Team to parallelize [2a] UX Research and [2b] API Contract

#### Agent Team Design (when feature has both UI + API)

When the feature has both a UI layer and an API layer, parallelize the independent research:

```
Create an agent team for Phase {NN}: {phase_name} design.

Team lead coordinates UX and API design, then drives screen generation.

Spawn 2 teammates (use Sonnet):
- Teammate "ux-researcher": Map user flows from each user story in CONTEXT.md.
  Create information architecture. Identify key screens needed.
  Write output to: .prd/phases/{NN}-{name}/design/ux-flows.md
  Use AskUserQuestion for flow validation.

- Teammate "api-designer": Read the API Surface Map from CONTEXT.md Section 4.
  Read project-level API conventions from CLAUDE.md and .kickstart/artifacts/API.md (if exists).
  Check existing endpoints in API.md to avoid conflicts and match conventions.
  Define full request/response schemas, auth requirements, example pairs.
  Write output to: .prd/phases/{NN}-{name}/design/api-contract.md
  Use AskUserQuestion for contract approval.

Team lead:
- Wait for both teammates to complete [2a] and [2b]
- Merge UX flows + API contract into unified design context
- Drive [2c] Screen Generation using both outputs (screens reference API data shapes)
- Continue through [2d] Design Iteration, [2e] Component Specs, [2f] Design Review
- Use AskUserQuestion for ALL remaining design decisions
```

After the team completes [2a]+[2b] in parallel, the lead continues sequentially through [2c]-[2f] since those require user interaction.

#### Single Designer (default — no API, or simple feature)

Dispatch the **prd-designer** agent with:

```
Agent(
  subagent_type="prd-designer",
  prompt="
    Project root: {project_root}
    Phase: {phase_number} — {phase_name}

    Read these files (lazy — do not embed contents):
    - .prd/phases/{NN}-{name}/{NN}-CONTEXT.md — discovery output
    - .prd/PRD-PROJECT.md — project context
    - CLAUDE.md — conventions

    Your job: Follow your agent instructions to produce designs for this phase.

CRITICAL RULES:
1. Use AskUserQuestion for ALL design decisions — present visual options, never assume
2. Work through ALL 5 sub-steps in order:

[2a] UX Research:
  - Map user flows from each user story
  - Create information architecture
  - Identify key screens needed
  - Output: .prd/phases/{NN}-{name}/design/ux-flows.md

[2b] API Contract (if feature has API surface from Discovery Element 4):
  - Read the API Surface Map from {NN}-CONTEXT.md Section 4
  - Read project-level API conventions from CLAUDE.md and .kickstart/artifacts/API.md (primary) or .kickstart/artifacts/ARCHITECTURE.md (fallback)
  - Check existing endpoints in API.md to avoid conflicts and ensure consistent naming
  - For each endpoint in the surface map, define:
    - Full request schema (typed parameters, body fields, validation rules)
    - Full response schema (success + error responses)
    - Authentication requirements
    - Example request/response pairs
  - Write to: .prd/phases/{NN}-{name}/design/api-contract.md
  - If OpenAPI is the project standard, also generate a partial openapi.yaml
  - Present contract to user via AskUserQuestion for approval before screen generation
  - This enables frontend screens to be designed against a defined contract
  - If no API surface (N/A in Discovery) → skip this sub-step

[2c] Screen Generation (Stitch SDK):
  - For each key screen, generate via Stitch SDK
  - Use natural language prompts derived from user stories
  - Reference API contract for data shapes (what fields to show, what actions are available)
  - Generate for primary device first (desktop or mobile based on project)
  - Output: screenshots + HTML in .prd/phases/{NN}-{name}/design/screens/

[2d] Design Iteration:
  - Present generated screens to user via AskUserQuestion
  - Offer options: approve, edit (with direction), regenerate, skip
  - Generate device variants (mobile, desktop, tablet) for approved screens
  - Use Chrome DevTools MCP to review in browser if available

[2e] Component Specs:
  - Extract HTML from approved screens
  - Map to component hierarchy (atoms → molecules → organisms)
  - Define design tokens: colors, spacing, typography, breakpoints
  - Output: .prd/phases/{NN}-{name}/design/component-specs.md

[2f] Design Review:
  - Present final design summary to user (including API contract if applicable)
  - AskUserQuestion for sign-off:
    - "Approve — proceed to Sprint"
    - "Iterate — go back to screen generation"
    - "Restart — go back to UX research"
    - "Revise API contract" (if API feature)
  - Output: .prd/phases/{NN}-{name}/design/review-signoff.md
```

Update sub-step status as each completes:
```
  [2a] UX Research            ✅ {N} flows mapped
  [2b] API Contract           ✅ {N} endpoints defined | ⏭ N/A
  [2c] Screen Generation      ✅ {N} screens generated
  [2d] Design Iteration       ▶ reviewing...
  [2e] Component Specs        ○ pending
  [2f] Design Review          ○ pending
```

### Step 4: Validate Output

**Check that design artifacts exist:**
- `.prd/phases/{NN}-{name}/design/ux-flows.md` exists
- `.prd/phases/{NN}-{name}/design/api-contract.md` exists (if feature has API surface from CONTEXT.md)
- `.prd/phases/{NN}-{name}/design/screens/` directory has at least one screen
- `.prd/phases/{NN}-{name}/design/component-specs.md` exists
- `.prd/phases/{NN}-{name}/design/review-signoff.md` exists with approval

**If validation fails:**
```
  [2] Design      ✗ validation failed
      Missing: {what's missing}
      Retrying design for missing artifacts...
```
Re-dispatch the designer agent for missing sub-steps. If it fails again, ask the user.

### Step 5: Create Design Summary

Write `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` consolidating:
- API contract summary (endpoints, schemas — if applicable)
- Screen inventory (name, description, screenshot path)
- Component hierarchy
- Design tokens
- Device variants generated
- Stakeholder sign-off status

### Step 6: Update State

After validation passes:

**Update PRD-STATE.md:**
```yaml
active_phase: {NN}
phase_name: {name}
phase_status: designed
last_action: "Design complete — {N} screens, {N} components"
last_action_date: {today}
next_action: "Run /cks:sprint to start implementation"
```

**Update PRD-ROADMAP.md:**
- Set the phase status to "Designed"

### Step 7: Completion Banner

```
  [2] Design      ✅ done
      Output: .prd/phases/{NN}-{name}/{NN}-DESIGN.md
      Screens: {N} generated, {N} approved
      Components: {N} specified
      Design tokens: defined
      Next: /cks:sprint {NN}
```

### Step 8: Context Reset & Compaction

All state is persisted to disk. Suggest compaction before sprint:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Design complete. Specs saved to {NN}-DESIGN.md and design/ directory.
Run /compact before sprint to maximize implementation context.

  ✅ DESIGN.md       — design summary
  ✅ design/         — screens, flows, component specs
  ✅ PRD-STATE.md    — phase tracking
  ✅ Working Notes   — session context (auto-captured)

  /compact
  /cks:next

Nothing is lost.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here.

## Post-Conditions
- `.prd/phases/{NN}-{name}/design/` directory with UX flows, screens, component specs
- `.prd/phases/{NN}-{name}/{NN}-DESIGN.md` summary exists
- PRD-STATE.md updated
- PRD-ROADMAP.md updated

## Stitch SDK Integration

The designer agent uses Stitch SDK via MCP or direct API:

**Screen generation prompt pattern:**
```
"Create a {screen_type} screen for {app_name}.
{user_story_description}
Requirements:
- {acceptance_criterion_1}
- {acceptance_criterion_2}
Style: {project_design_system_or_preferences}"
```

**Screen editing prompt pattern:**
```
"Edit this screen: {edit_instruction_from_user_feedback}"
```

**Variant generation:**
```
"Generate a mobile variant of this screen"
"Generate a tablet variant of this screen"
```

If Stitch SDK MCP is not configured, fall back to:
1. `frontend-design:frontend-design` skill for HTML/CSS generation
2. Excalidraw MCP for wireframe diagrams
3. Manual design spec writing (text-based component descriptions)
