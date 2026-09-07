# Workflow: Discover Elements — the 11-element interview that produces CONTEXT.md

Gather every element with `AskUserQuestion` — research the codebase first so the options
are informed, present a recommended answer with one sentence of reasoning, and pre-fill
what artifacts already answer. Text questions are dead questions. The only exception is a
brief that literally says `AUTONOMOUS MODE`: then take the first (recommended) option.

## The 11 elements (+ tier)

1. Problem Statement & Value Proposition
2. User Stories — "As a [user], I want [action] so that [value]"
3. Scope — in / out / a different feature
4. API Surface Map — adapt to project type: web/API/mobile → endpoints (method, path,
   auth, payload); AI agent/MCP → tool definitions; CLI → commands and flags; library →
   public exports; plugin → commands/agents/hooks/skills; website → N/A
5. Acceptance Criteria — testable, per story
6. Constraints & Negative Cases — what must NOT happen
7. Test Plan — unit, integration, AND E2E
8. UAT Scenarios — Given/When/Then: happy path, error recovery, edge case
9. Definition of Done
10. Success Metrics / KPIs
11. Cross-Project Dependencies — N/A without `.prd/PROJECT-MANIFEST.md` or with one sub-project
12. System Architecture Tier — Tier 1 (single VM) · Tier 2 (app + DB, monitoring) ·
    Tier 3 (distributed) · N/A — record the tier and its implications

## Hard gate

Do not write CONTEXT.md until the user has confirmed, via `AskUserQuestion`: ≥ 3 user
stories with a "so that"; ≥ 2 testable criteria per story; a test plan with unit +
integration + E2E; ≥ 3 UAT scenarios. Fewer than 4 `AskUserQuestion` calls before writing
means the interview was skipped — go back.

## 0. Research before asking

- `.ideation/*.md` (newest) → pre-fill elements 1, 2, 9, 10 from `## Refined Pitch`; greet
  with the one-liner and confirm instead of asking cold.
- `.prd/FEATURES.md` entry for this feature tagged `mvp` → **warm mode**: elements 1–3 are
  pre-approved; ask one confirmation ("Confirmed — proceed (Recommended) / Adjust scope /
  Adjust stories") and then ask only elements 4–11. Entry tagged `v2`/`cut`, or none →
  cold mode, full flow. Verify the entry semantically matches the request — stale entries
  corrupt scope.
- Source files, `docs/prds/`, `CLAUDE.md`, `.prd/PROJECT-MANIFEST.md`, `.prd/prd-config.json`
  (`features_file`), `.prd/phases/{NN}-*/{NN}-RESEARCH.md`, `.context/*.md`, `.research/*/report.md`,
  `skills/prd/references/uat-patterns.md`, `skills/prd/references/testing-strategy.md`.
- Unfamiliar central technology, 5+ files across 3+ directories, or an undocumented
  external system → return to the chief of staff with the researcher dispatch you need
  (`codebase-research.md`) before continuing, unless RESEARCH.md already exists.
- Agent-system signals or `project_type: ai-agent-system` → surface the 15-stage offer per
  `.claude/rules/agent-build-sequence.md` (non-blocking). Multi-role signals → per
  `.claude/rules/saas-build-sequence.md`. PM-framework signals → `.claude/rules/pm-frameworks.md`.

## 1. Elements 1–3 — one call, up to three questions

Problem (single, options from research) · Users (multi) · Scope (multi, with an explicit
"defer to future feature" option).

## 2. Elements 4–5 — two calls

API surface (multi, include "N/A — no API surface"). Then, in a **separate** call,
acceptance criteria per confirmed story: `{criterion}` — "Testable: {how}", plus
"Add custom criterion".

## 3. Element 6

Constraints and negative cases (multi): "Must NOT {behavior}", "Must fail gracefully when {condition}".

## 4. Elements 7–8 — one call, two questions

Test plan (multi: `Unit: …`, `Integration: …`, `E2E: …`, "Add more tests") and UAT
scenarios (multi: happy path, error recovery, edge case, each as Given/When/Then).

## 5. Elements 9–10 — one call, two questions

DoD ("Standard DoD (Recommended)" = review + tests + UAT + staging + docs + PO approval;
add performance / security / accessibility / custom) and success metrics (adoption, error
rate, time saved, custom KPI — each with a target and how it is measured).

## 5b. Element 11 — only with a manifest of 2+ sub-projects

Consumes / Provides / Shares / No cross-project dependencies, populated from the manifest.

## 5c. Element 12

Ask the tier; record tier + implications in Section 12.

## 6. Write CONTEXT.md

Template: `skills/prd/templates/context.md`. Path:
`.prd/phases/{NN}-{name}/{NN}-CONTEXT.md` (phase-number prefix is mandatory). All sections
populated; flag any incomplete element rather than padding it. Compliance signals (PII,
payment, health, enterprise) → run `skills/compliance/workflows/surface-scan.md` before
declaring the phase done.

## 7. Confirm

"Discovery complete — 11/11 elements gathered. Proceed?" Options: Approve — proceed to
Design (Recommended) · Adjust elements · Redo discovery.

## Constraints

- 5–8 `AskUserQuestion` calls total; batch up to 4 related questions per call.
- Never write the PRD or the plan — that is the architect's.
- Never write code.
