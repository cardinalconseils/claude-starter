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
  Generate visual diagrams via Stitch MCP (user flow, site map, data flow).
  Save diagrams to: .prd/phases/{NN}-{name}/design/diagrams/
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
  - Generate visual diagrams via Stitch MCP (or Excalidraw MCP fallback, or Mermaid text):
    - User flow diagram (screen-to-screen navigation paths)
    - Site map / IA diagram (page hierarchy)
    - Data flow diagram (how data moves between screens and API)
    - Save to: .prd/phases/{NN}-{name}/design/diagrams/
  - Output: .prd/phases/{NN}-{name}/design/ux-flows.md + design/diagrams/

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
  - Check tool availability (in order): Stitch MCP → Excalidraw MCP
  - Use the first available tool for screen generation
  - If NONE available → generate text-based component specs (wireframe descriptions)
  - **Mockups**: For each key screen, generate using Stitch MCP:
    - Use natural language prompts derived from user stories
    - Reference API contract for data shapes (what fields to show, what actions are available)
    - Generate for primary device first (desktop or mobile based on project)
  - **Flowcharts**: Generate using Stitch MCP (or Excalidraw MCP):
    - User journey flowcharts (step-by-step for each critical path)
    - State transition diagrams (if feature has complex state: e.g., order status, auth flow)
    - API sequence diagrams (if API feature: request/response flow between client and server)
    - Save to: .prd/phases/{NN}-{name}/design/diagrams/
  - Output: screenshots + HTML in .prd/phases/{NN}-{name}/design/screens/ + diagrams in design/diagrams/

[2d] Design Iteration:
  - If Chrome DevTools MCP is configured: open generated HTML in browser, take screenshots at
    different viewports, inspect accessibility (contrast, focus, semantics)
  - Present generated screens to user via AskUserQuestion
  - Offer options: approve, edit (with direction), regenerate, skip
  - Generate device variants (mobile, desktop, tablet) for approved screens via Stitch MCP
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
