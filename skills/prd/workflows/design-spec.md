# Workflow: Design Spec (Phase 2) — UX flows, API contract, screens, component specs

Bridge "what to build" (CONTEXT.md) and "how to code it" (sprint). Interactive by
default: `AskUserQuestion` at [2a], [2b] (if API), [2d] per screen, [2f]. Skipping a
checkpoint is a failure, not efficiency. `PHASE_MODE: auto` is the only exception.

## Inputs

`{NN}-CONTEXT.md`, `{NN}-RESEARCH.md` / `.research/*/report.md`, `.context/*.md`,
`PROJECT.md`, `CLAUDE.md`, `DESIGN.html` (fall back to `DESIGN.md`) for tokens — never
invent colors or type that conflict with it; `.learnings/gotchas.md` and
`conventions.md` for design lessons; CONTEXT.md Section 12 for the architecture tier.

## [2a] UX research

Map every user story to a screen or flow; build the information architecture
(navigation, hierarchy, data flow). Diagrams as Mermaid source + rendered SVG in
`design/diagrams/` (user flow `flowchart`, site map `flowchart`, data flow
`sequenceDiagram`; architecture topology by tier — omit when N/A):

```bash
npx -y @mermaid-js/mermaid-cli -i "{path}.mmd" -o "{path}.svg" -b transparent
```

Write `design/ux-flows.md`. Ask: "Does this flow cover all user stories?" — Approve ·
Add screens · Remove screens · Restructure.

## [2b] API contract (only with an API surface)

From CONTEXT.md Section 4 plus `CLAUDE.md` and `.kickstart/artifacts/API.md` conventions
(match MCP / CLI / library / plugin formats when the project uses them). Every endpoint:
typed request and response interfaces, required vs optional annotated, exact enum
literals, method + path + status codes (success and error), auth requirement
(`public` | `authenticated` | `owner-only` | `role:{name}`), one success and one error
example as valid JSON. Header `# API Contract — {feature} — FROZEN after user approval`.
Write `design/api-contract.md`; ask for approval before [2c]. Backward-compatibility
rules: `skills/architecture/references/api-compatibility.md`.

## [2c] Screens and diagrams

Per screen in the approved flow: a prompt from the story + criteria, injecting the
design-system block (primary, accent, font, radius, surface from `DESIGN.html`; omit the
block only when absent — say so once: "No DESIGN.html — run /cks:design-system first").
Mockups need a UI generator (Stitch MCP) or are hand-written self-contained HTML; save
`design/screens/{screen}/source.html` (+ `screenshot.png` when a browser is available).
Mockup tools are for screens only; Mermaid/Excalidraw for diagrams only. Also: state
diagrams (`stateDiagram-v2`), ERD (`erDiagram`), API sequences (`sequenceDiagram`).

## [2d] Design iteration

Per screen run the design-fluency check
(`npx impeccable detect "{source.html}" 2>/dev/null || true`; map findings to the verbs
in `skills/design-fluency/SKILL.md`; skip silently if not installed), then ask:
"Screen: {name} — how does this look?" — Approve · Edit layout · Edit content · Edit
style · Regenerate · Custom feedback. Approved screens → variants question (Mobile 375 ·
Tablet 768 · Desktop 1440 · Skip).

Design QA before handoff: every component has default, hover, focus, active, disabled,
loading, error, empty states; spacing uses tokens; contrast verified (4.5:1 body, 3:1
large/UI); touch targets ≥ 44×44 on mobile; mobile and desktop both complete; component
names match code names.

## [2e] Component specs

From approved screens: HTML structure → reusable components (atoms → molecules →
organisms) → tokens (colors, typography, spacing, breakpoints, radius, shadows,
transitions). Write `design/component-specs.md`.

## [2f] Design review

"Design phase complete. {N} screens, {N} components. Ready to proceed?" — Approve —
proceed to Sprint · Iterate — revisit screens · Restart — revisit UX flows. Write
`design/review-signoff.md` and the consolidated `{NN}-DESIGN.md`.

Branch and worktree creation for the sprint is the shipper's/builder's; return
`feat/{NN}-{slug}` as the branch to create.

## Output tree

```
.prd/phases/{NN}-{name}/
  design/ux-flows.md · api-contract.md · component-specs.md · review-signoff.md
  design/diagrams/*.mmd + *.svg
  design/screens/{screen}/source.html (+ variants/)
  {NN}-DESIGN.md
```

## Rules

Ask for every decision; show before telling; iterate willingly; component-first;
accessibility by default (semantic HTML, contrast, keyboard); mobile-first unless told
otherwise.
