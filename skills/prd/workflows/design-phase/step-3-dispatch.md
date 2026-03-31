# Step 3: Dispatch Designer Agent (or Agent Team)

<context>
Phase: Design (Phase 2)
Requires: Design context loaded (Step 2)
Produces: Design artifacts via prd-designer agent
</context>

## Decision: Single Designer vs. Agent Team

Check CONTEXT.md for API Surface Map (Element 4):
- **No API surface (N/A)** → single prd-designer agent (below)
- **API surface exists** → use Agent Team to parallelize [2a] UX Research and [2b] API Contract

## Agent Team Design (when feature has both UI + API)

When the feature has both a UI layer and an API layer, parallelize the independent research:

```
Create an agent team for Phase {NN}: {phase_name} design.

Team lead coordinates UX and API design, then drives screen generation.

Spawn 2 teammates (use Sonnet):
- Teammate "ux-researcher": Map user flows from each user story in CONTEXT.md.
  Create information architecture. Identify key screens needed.
  Generate technical diagrams: write Mermaid .mmd files then render to SVG:
    npx -y @mermaid-js/mermaid-cli -i "{path}.mmd" -o "{path}.svg" -b transparent
  Diagram types: user flow (flowchart), site map (flowchart), data flow (sequenceDiagram), ERD (erDiagram).
  Use Excalidraw create_view for freeform architecture diagrams (renders inline).
  Save .mmd + .svg to: .prd/phases/{NN}-{name}/design/diagrams/
  Write text output to: .prd/phases/{NN}-{name}/design/ux-flows.md
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

## Single Designer (default — no API, or simple feature)

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
2. Work through ALL sub-steps in order:

[2a] UX Research:
  - Map user flows from each user story
  - Create information architecture
  - Identify key screens needed
  - Generate technical diagrams as RENDERED SVG FILES:
    - For each diagram: write Mermaid source to .mmd file, then render to .svg:
      npx -y @mermaid-js/mermaid-cli -i "{path}.mmd" -o "{path}.svg" -b transparent
    - User flow diagram — Mermaid flowchart (screen-to-screen navigation)
    - Site map / IA diagram — Mermaid flowchart (page hierarchy)
    - Data flow diagram — Mermaid sequence diagram (data between screens and API)
    - ERD — Mermaid erDiagram (entity relationships)
    - Architecture — Excalidraw create_view (freeform, renders inline in Claude Code)
    - Use Excalidraw create_view to show diagrams inline for immediate user review
    - Save both .mmd (source) and .svg (rendered) to: .prd/phases/{NN}-{name}/design/diagrams/
  - Output: .prd/phases/{NN}-{name}/design/ux-flows.md + design/diagrams/*.svg

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

[2c] Screen Generation (Mockups + Diagrams):
  - **Mockups** (Stitch MCP — if configured):
    - For each key screen, generate using Stitch MCP with natural language prompts from user stories
    - Reference API contract for data shapes (what fields to show, what actions are available)
    - Generate for primary device first (desktop or mobile based on project)
    - If Stitch MCP not available → write text-based wireframe descriptions + component specs
  - **Technical Diagrams** (Mermaid → mmdc SVG rendering; Excalidraw → inline freeform):
    - User journey flowcharts — Mermaid flowchart (step-by-step for each critical path)
    - State transition diagrams — Mermaid stateDiagram (complex state: order status, auth flow)
    - ERD — Mermaid erDiagram (entity relationships)
    - API sequence diagrams — Mermaid sequenceDiagram (request/response flow)
    - Architecture diagrams — Excalidraw create_view (freeform system topology)
    - ALL Mermaid diagrams MUST be rendered to SVG:
      Write .mmd file → run: npx -y @mermaid-js/mermaid-cli -i "{path}.mmd" -o "{path}.svg" -b transparent
    - Save both .mmd + .svg to: .prd/phases/{NN}-{name}/design/diagrams/
  - Output: screenshots + HTML in .prd/phases/{NN}-{name}/design/screens/ + diagrams in design/diagrams/

[2d] Design Iteration:
  - If Chrome DevTools MCP is configured: open generated HTML in browser, take screenshots at
    different viewports, inspect accessibility (contrast, focus, semantics)
  - Present generated screens to user via AskUserQuestion
  - Offer options: approve, edit (with direction), regenerate, skip
  - Generate device variants (mobile, desktop, tablet) for approved screens via Stitch MCP (if available)
  - Review diagrams from [2a]/[2c]: ask user to approve or revise flowcharts and user journeys

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

## Sub-step Status Updates

Update sub-step status as each completes:
```
  [2a] UX Research            ✅ {N} flows mapped, {N} diagrams generated
  [2b] API Contract           ✅ {N} endpoints defined | ⏭ N/A
  [2c] Screen Generation      ✅ {N} screens generated
  [2d] Design Iteration       ▶ reviewing...
  [2e] Component Specs        ○ pending
  [2f] Design Review          ○ pending
```
