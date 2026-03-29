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
     [2b] Screen Generation      ○ pending
     [2c] Design Iteration       ○ pending
     [2d] Component Specs        ○ pending
     [2e] Design Review          ○ pending
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
- Existing design specs in `.prd/phases/{NN}-{name}/design/` (if any)

Extract from CONTEXT.md:
- User stories → screens to design
- Acceptance criteria → UI behaviors to support
- Constraints → design limitations

### Step 3: Dispatch Designer Agent

Dispatch the **prd-designer** agent with:

```
Agent prompt:
- Project root: {project_root}
- Phase: {phase_number} — {phase_name}
- Discovery context: {CONTEXT.md content}
- Project context: {PROJECT.md content}
- Conventions: {CLAUDE.md content}

Your job: Follow your agent instructions to produce designs for this phase.

CRITICAL RULES:
1. Use AskUserQuestion for ALL design decisions — present visual options, never assume
2. Work through ALL 5 sub-steps in order:

[2a] UX Research:
  - Map user flows from each user story
  - Create information architecture
  - Identify key screens needed
  - Output: .prd/phases/{NN}-{name}/design/ux-flows.md

[2b] Screen Generation:
  - Check tool availability (in order): Stitch SDK MCP → frontend-design skill → Excalidraw MCP
  - Use the first available tool for screen generation
  - If NONE available → generate text-based component specs (wireframe descriptions)
  - For each key screen, generate using selected tool
  - Use natural language prompts derived from user stories
  - Generate for primary device first (desktop or mobile based on project)
  - Output: screenshots + HTML in .prd/phases/{NN}-{name}/design/screens/ (or .md specs if text-only)

[2c] Design Iteration:
  - Present generated screens to user via AskUserQuestion
  - Offer options: approve, edit (with direction), regenerate, skip
  - Generate device variants (mobile, desktop, tablet) for approved screens
  - Use Chrome DevTools MCP to review in browser if available

[2d] Component Specs:
  - Extract HTML from approved screens
  - Map to component hierarchy (atoms → molecules → organisms)
  - Define design tokens: colors, spacing, typography, breakpoints
  - Output: .prd/phases/{NN}-{name}/design/component-specs.md

[2e] Design Review:
  - Present final design summary to user
  - AskUserQuestion for sign-off:
    - "Approve — proceed to Sprint"
    - "Iterate — go back to screen generation"
    - "Restart — go back to UX research"
  - Output: .prd/phases/{NN}-{name}/design/review-signoff.md
```

Update sub-step status as each completes:
```
  [2a] UX Research            ✅ {N} flows mapped
  [2b] Screen Generation      ✅ {N} screens generated
  [2c] Design Iteration       ▶ reviewing...
  [2d] Component Specs        ○ pending
  [2e] Design Review          ○ pending
```

### Step 4: Validate Output

**Check that design artifacts exist:**
- `.prd/phases/{NN}-{name}/design/ux-flows.md` exists
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
