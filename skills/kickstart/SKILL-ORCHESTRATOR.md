---
name: cks:kickstart-orchestrator
description: Kickstart lifecycle loop — Ideate → Intake → Research → Monetize → Feature Scope → Brand → Design → Handoff → feature lifecycle, gating every phase with AskUserQuestion and dispatching v6 roles. Runs in the top-level session so Agent() dispatch works.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# Kickstart — The Loop

You sequence the kickstart lifecycle from idea to scaffolded project at the top level of
the session. `SKILL.md` is the doctrine (mandatory gates, state-file enforcement, banners);
this file is the order of operations and who does each phase. You never do a phase's work
yourself — every phase is a dispatch, every gate is an `AskUserQuestion`.

Inputs: `pitch` (may be empty), `project_root`.

---

## 0. Resume detection

Read `.kickstart/state.md` if it exists.

- Found → show the progress banner from `SKILL.md`, then ask:
  ```
  AskUserQuestion:
    question: "Previous kickstart found. How to proceed?"
    header: "Kickstart Resume"
    options:
      - "Resume from where I left off (Recommended)"
      - "Start fresh (archive existing)"
      - "Update intake answers then continue"
  ```
  Resume → continue from the first incomplete phase. Fresh → move `.kickstart/` to
  `.kickstart/archive/{date}/` and start at Phase 0. Update → re-run Phase 1, then continue
  from Phase 5.
- Not found → fresh run.

## Phase gates (every phase, no exceptions)

Before each phase below, check its artifact and ask in the `.claude/rules/phase-gates.md`
shape — recommend Run when the artifact is missing, Skip when it exists, never decide alone:

```
AskUserQuestion:
  question: "Phase {N} — {Name}: {artifact} {✅ found / ⚠️ missing}. Run or skip?"
  header: "Phase {N} Gate"
  options:
    - "Run {Name} (Recommended)"          ← artifact missing
    - "Skip — already done (Recommended)" ← artifact found
    - "Skip — not needed"
```

Write `.kickstart/state.md` after every phase and every skip (SKILL.md stop rule). Record
the `maturity_stage` from intake — it calibrates design depth and handoff quality gates
(Prototype: wireframes only, no security/CI gates; Pilot: auth + validation gates;
Candidate/Production: full design, full gates, brand strongly recommended).

## 1. Phase 0 — Ideate (`.kickstart/ideation.md`)

Only when no ideation file exists and the pitch is empty or vague, ask "clear idea, or
brainstorm first?". If brainstorm:

```
Agent(subagent_type="cks:strategist", prompt="Mode: ideate (kickstart). Run Phase 0 per the ideation protocol in the kickstart skill. Pitch: {pitch}. Write .kickstart/ideation.md. Update .kickstart/state.md.")
```

**Pitch approval gate** — after it returns, before spending research tokens:

```
AskUserQuestion:
  question: "Ideation complete. Is this the right direction to build?"
  header: "Pitch Approval"
  options: ["Proceed", "Refine pitch", "Start over"]
```
Refine → re-dispatch with the current pitch as context, re-ask. Start over → re-dispatch
fresh, re-ask.

## 2. Phase 1 + 1b + 1c — Intake, Compose, Stack (`.kickstart/context.md`, `manifest.md`, `stack.md`)

```
Agent(subagent_type="cks:strategist", prompt="Mode: intake (kickstart). Idea pitch: {pitch}. If .kickstart/ideation.md exists, read it. Run skills/kickstart/workflows/intake.md, then compose.md, then stack-selection.md. Ask the optional-phase questions (research, monetize, feature scope, brand) with AskUserQuestion and record each answer as {phase}_opted in .kickstart/state.md. Write all three artifacts. Report maturity_stage.")
```

Wait. Read `.kickstart/state.md` for the opt-in decisions and `maturity_stage`.

## 3. Phase 2 — Research (`.kickstart/research.md`, when `research_opted: true`)

```
Agent(subagent_type="cks:researcher", prompt="Mode: kickstart research. Read .kickstart/context.md. Run skills/kickstart/workflows/research.md: competitive landscape, market signals, comparable products. Save .kickstart/research.md with citations. Update .kickstart/state.md.")
```

**Stack confirmation gate** — after research (or after intake when research was skipped):

```
AskUserQuestion:
  question: "Are these stack and constraints correct before design locks them in?"
  header: "Stack Confirmation"
  options: ["Proceed", "Adjust constraints", "Change stack"]
```
Adjust / Change → collect the new constraints, re-dispatch the strategist in `Mode: intake`
(stack step only), re-ask.

## 4. Phase 3 — Monetize (`.monetize/`, when `monetize_opted: true`)

Run the stage sequence from `skills/monetize/SKILL-ORCHESTRATOR.md` here — you are already
top-level, so dispatch its roles directly in order: discover (`cks:strategist`), research
(`cks:researcher`), cost research (`cks:researcher`), cost analysis (`cks:finops`), evaluate
(`cks:strategist`), report (`cks:strategist`). Seed discover from `.kickstart/context.md`.
Skip the roadmap stage — kickstart's own roadmap comes from Design. Update
`.kickstart/state.md` when the report exists.

## 5. Phase 3.5 — Feature Scope (`.prd/FEATURES.md`, when `feature_scope_opted: true`)

```
Agent(subagent_type="cks:strategist", prompt="Mode: feature-scope (kickstart). Read .kickstart/context.md and .kickstart/state.md (plus research.md and .monetize/report.md if present). Run the feature elicitation interview and MVP scoping with AskUserQuestion. Write .prd/FEATURES.md, .prd/MVP-CUTLINE.md, .prd/OUT-OF-SCOPE.md. Update .kickstart/state.md.")
```

## 6. Phase 4 — Brand (`.kickstart/brand.md`, when `brand_opted: true`)

```
Agent(subagent_type="cks:marketer", prompt="Persona: brand-strategist. Mode: kickstart brand extraction. Read .kickstart/context.md. Run skills/kickstart/workflows/brand.md (Canva MCP, WebFetch, or manual Q&A). Save .kickstart/brand.md. Update .kickstart/state.md. If a DESIGN.html is wanted, say so in your report — do not generate it yourself.")
```

If the report asks for `DESIGN.html`, dispatch `cks:architect` with the design-system
prompt from `workflows/brand.md` before Phase 5.

## 7. Phase 5 — Design (`.kickstart/artifacts/`)

```
Agent(subagent_type="cks:architect", prompt="Mode: kickstart design. maturity_stage={maturity_stage}. Read every .kickstart/ artifact and .prd/FEATURES.md if it exists. Run skills/kickstart/workflows/design.md. If FEATURES.md exists: design artifacts for MVP-tagged features only, put V2 features in FEATURE-ROADMAP.md, omit cut features. Prototype: wireframes only, skip component specs. Candidate/Production: full screens + component specs + accessibility notes. Multi sub-project: follow the manifest layout from the kickstart skill. Write .kickstart/artifacts/. Update .kickstart/state.md.")
```

## 8. Phase 6 — Handoff (`CLAUDE.md`, `.prd/`, scaffold)

```
Agent(subagent_type="cks:operator", prompt="Mode: kickstart handoff. Read all .kickstart/ artifacts. Run skills/kickstart/workflows/handoff.md: scaffold the project, initialize .prd/ (including .prd/NORTH-STAR.md and .finops/BUDGET.md from the templates if absent — never overwrite), personalize .claude/. Apply the maturity_stage quality gates. Update .kickstart/state.md. Stop before the feature-lifecycle steps — the orchestrator runs those.")
```

## 9. Completion and auto-chain

Read `.kickstart/state.md`; verify every phase is done or skipped; print the final banner
from `SKILL.md`. Then run `workflows/auto-chain.md` exactly — it dispatches `cks:strategist`
for the first sub-project's discovery (validated, retried once) and `cks:architect` for
design. Do not stop after the scaffold; the chain is the point of kickstart.

## Constraints

- Every phase is gated by `AskUserQuestion` — including phases the user opted into at intake
- Never dispatch a phase whose prerequisite artifact (SKILL.md "Phase Prerequisites") is missing
- Never write a phase artifact yourself — only `.kickstart/state.md` and archive moves
- Pass `maturity_stage` to every dispatch after intake
- One role per dispatch; monetize stages run in order, never in one message
