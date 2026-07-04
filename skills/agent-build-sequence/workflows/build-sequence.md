# Workflow: Agentic System Build Sequence (15 Stages)

## Overview

Runs 15 stages in order for an AI agent system build. Most stages dispatch to an existing
CKS agent or skill — this workflow's job is the **ordering**, not new content. Two stages
(5 and 8) produce genuinely new artifacts.

**CRITICAL: Stage 4 (State Machine) and Stage 5 (Tool Inventory) MUST both exist before
Stage 6 (Architecture) runs. Stage 6 MUST exist before Stage 14 (Schema Validation) runs.**

```
Stage 4: State Machine ─┐
                         ├─→ Stage 6: Architecture ─→ ... ─→ Stage 14: Schema Validation
Stage 5: Tool Inventory ─┘
```

This is the framework's actual value — everything else is a lookup table.

## Prerequisites

- None mandatory. Stages 1-3 are typically already done by the time this workflow is offered
  (via ideation / kickstart / PRD discover) — check for existing artifacts before re-running them.

## Stage-by-Stage

Each stage entry: what it produces, its dispatch target, and any hard prerequisite.

### Stage 1 — Idea / Problem Statement

**Produces:** Refined pitch (one-liner, problem, target user, MVP scope hint)
**Dispatch:** `cks:ideate` (standalone brainstorming skill/command)
**Prerequisite:** None
**Skip if:** A refined pitch already exists in `.ideation/*.md`

### Stage 2 — Monetization / Validation

**Produces:** `.monetize/evaluation.md`
**Dispatch:** `monetize-discoverer` → `monetize-researcher` → `monetize-evaluator` (in sequence)
**Prerequisite:** Stage 1 pitch exists
**Skip if:** User declines the monetize gate (non-blocking, per kickstart's existing gate pattern)

### Stage 3 — PRD

**Produces:** `CONTEXT.md` (11 elements)
**Dispatch:** `cks:discover` / `agents/prd-discoverer.md`
**Prerequisite:** Stage 1 pitch exists (pre-fills discovery Elements 1, 2, 9, 10)

### Stage 4 — State Machine Design

**Produces:** State list, transition table, terminal-state verification (see worked example)
**Dispatch:** `skills/orchestration/workflows/state-machine.md`
**Prerequisite:** Stage 3 CONTEXT.md exists — the state machine models the agent's actual
job lifecycle, so it needs the problem statement and scope to be fixed first.

This is the first live dispatch trigger for `state-machine.md` — it previously had no caller.
Run all 6 steps in that workflow (enumerate states → transition table → terminal states →
guards → DB enum mapping → cycle verification) before declaring this stage done.

### Stage 5 — Tool Inventory / Capability Matrix

**Produces:** A filled-in copy of `references/tool-inventory-template.md`
**Dispatch:** Net-new — no existing CKS agent owns this. Fill the template directly:
one row per tool/capability the agent system will call (internal function, external API,
MCP tool, sub-agent).
**Prerequisite:** Stage 3 CONTEXT.md exists (need to know what the agent must be able to do)

**Why this stage exists:** Architecture decisions (Stage 6) that don't know the latency,
cost, and failure profile of every tool the agent calls are guesses. This stage removes
the guessing.

### Stage 6 — Architecture Decisions

**Produces:** `ARCHITECTURE.md` update + ADR(s)
**Dispatch:** `agents/architecture-generator.md`
**Hard prerequisite:** Stage 4 (state machine) AND Stage 5 (tool inventory) artifacts must
both exist. **Do not dispatch architecture-generator for an agent system until both are
present** — see Gap Check below for what to do if this is violated.

### Stage 7 — Memory Architecture

**Produces:** A short memory-design note in `ARCHITECTURE.md` (not a new subsystem)
**Dispatch:** `agents/honcho-integrator.md` / `skills/user-memory`, `skills/conversation-state`,
`skills/honcho-memory` — pointer only. Honcho is already integrated in CKS; this stage decides
*how* the agent system uses it (session-scoped vs. cross-session, what gets summarized), not
whether to build memory from scratch.
**Prerequisite:** Stage 6 architecture exists (memory choices depend on the chosen topology)

### Stage 8 — LLM Economics

**Produces:** `.decisions/LLM-ECONOMICS.md` — thin synthesis document
**Dispatch:** Pull together, in one place:
- `skills/openrouter/workflows/model-research.md` — model pricing/selection research
- `skills/luv-model-routing/SKILL.md` — quality/budget/speed routing strategy
- `agents/cost-analyzer.md` / `agents/cost-researcher.md` — unit economics

This is not a new agent — read the outputs of the three sources above and write one summary
doc: which model(s) per call type, expected cost per agent run, and the routing rule.
**Prerequisite:** Stage 5 tool inventory exists (economics depends on per-call cost estimates
already captured there)

### Stage 9 — Observability

**Produces:** Telemetry + eval wiring confirmed for the agent system
**Dispatch:** `.claude/rules/telemetry.md` (session trace schema), `.claude/rules/harness-evals.md`
(hook-level eval scaffolding if the agent system adds hooks), `cks:observe` (cost/latency dashboard)
**Prerequisite:** Stage 6 architecture exists

### Stage 10 — Error Handling / Recovery

**Produces:** ADR(s) for any distributed resilience pattern the agent system needs
**Dispatch:** `.claude/rules/arch-patterns.md` — its existing keyword triggers (DLQ, retry,
circuit breaker, idempotency, saga) already fire `architecture-generator` Mode 3. No new
wiring needed here — just confirm the triggers fired for this feature.
**Prerequisite:** Stage 6 architecture exists

### Stage 11 — System Design

**Produces:** Screens / component specs (only if the agent system has a UI surface)
**Dispatch:** `agents/prd-designer.md`
**Skip if:** The agent system is headless (no UI) — note "N/A — headless agent system"

### Stage 12 — API Contract Design

**Produces:** `API.md` using the MCP Tool Definitions template
**Dispatch:** `skills/kickstart/workflows/design.md` § Step 5 — Contract Format table already
routes `AI agent / automation` project types to the MCP Tool Definitions template. No new
template needed; this stage just confirms that routing fires for `project_type: ai-agent-system`.
**Prerequisite:** Stage 5 tool inventory exists (tool inventory rows become MCP tool definitions)

### Stage 13 — ERD

**Produces:** `ERD.md`
**Dispatch:** `agents/db-erd.md`
**Prerequisite:** Stage 6 architecture exists

### Stage 14 — Schema Validation

**Produces:** Schema review notes / advisor findings
**Dispatch:** `agents/db-investigator.md` / `skills/database-design/SKILL.md`
**Hard prerequisite:** Stage 6 (architecture) artifact must exist before this stage runs —
see Gap Check.

### Stage 15 — Implementation Plan

**Produces:** `PLAN.md`
**Dispatch:** `agents/prd-planner.md`
**Prerequisite:** All prior stages either complete or explicitly marked N/A with a reason

## Gap Check

Run this checklist before declaring ANY stage from 6 onward complete. This is deliberately
prose-guided, not a scripted hook — per `.claude/rules/setup-philosophy.md`'s bucket test,
detecting a stage-ordering violation requires reading intent and history, which a regex
cannot do reliably.

**Before marking Stage 6 (Architecture) complete, ask:**
- Does the architecture decision reference a tool, latency budget, or cost constraint that
  isn't documented in the Stage 5 tool inventory? If yes → flag the specific decision, require
  Stage 5 be filled in (or amended) before Stage 6 proceeds.
- Does the architecture decision assume a lifecycle/state model that Stage 4's state machine
  doesn't define? If yes → flag the specific decision, require Stage 4 be revisited.

**Before marking any stage from 9-14 complete, ask:**
- Does this stage's output reference an architectural choice (a service boundary, a sync/async
  decision, a chosen datastore) that predates Stage 6, i.e. was decided before Stage 6's
  ARCHITECTURE.md/ADR existed? If yes → name the specific decision, flag as **rework risk**,
  and require Stage 6 be revisited before this stage's output is accepted.

**Output format when a gap is found:**

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
Gap Check found a stage-ordering violation.

  Decision: {the specific architecture/schema/API-contract choice}
  Predates: {Stage 4 state machine | Stage 5 tool inventory | Stage 6 architecture}
  Risk: Rework if the earlier stage's output contradicts this decision later.

  1. Revisit the earlier stage now (Recommended)
  2. Proceed anyway — document the risk in ARCHITECTURE.md "Known Gaps"
  3. Dismiss — explain why the ordering doesn't apply here

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

Never silently proceed past a detected gap — always surface the block above.

## Post-Conditions

- Each stage run has produced its named artifact at the path listed in SKILL.md's stage table
- Gap Check ran at least once before Stage 15 (Implementation Plan) was dispatched
- Any stage marked N/A has a one-line reason recorded in the calling agent's output
