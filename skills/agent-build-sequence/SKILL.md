---
name: agent-build-sequence
description: "Agentic System Build Sequence — 15-stage ordered methodology for building AI agent systems, autonomous agents, multi-agent orchestration, tool-calling loops. Enforces state machine and tool inventory design before architecture decisions, and architecture before schema. Use for AI agent system, autonomous agent, agent system, multi-agent, LLM economics, tool inventory, capability matrix design."
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# Agentic System Build Sequence

## Overview

Building an AI agent system out of order is the single most common cause of expensive rework:
teams pick an architecture before they know what tools the agent calls, or design a database
schema before the state machine that governs the agent's lifecycle exists. This skill is a
15-stage ordered methodology that fixes the order, not the content — most stages are dispatch
pointers to CKS agents/skills that already do the work well. The value-add is sequencing:

**State machine + tool inventory must exist before architecture. Architecture must exist before schema.**

Reversing this order is the recurring failure mode: an architecture decision made without a
tool inventory has no idea what latency/cost/failure-mode envelope the system must tolerate,
and a schema written before architecture bakes in assumptions (e.g., synchronous vs.
event-sourced) that get expensively unwound later.

## When to Use

- Building an AI agent system, autonomous agent, or multi-agent orchestration from scratch
- A feature description mentions "tool-calling loop", "agentic system", "AI agent", or similar
- `project_type: ai-agent-system` is set in `.kickstart/state.md` or `.bootstrap/scan-context.md`
- Any point where architecture, schema, or API contract decisions are being made for an agent
  system and no state machine or tool inventory exists yet

## When NOT to Use

- Simple LLM feature additions to an existing non-agentic app (a single prompt call, a
  classifier) — this is 15-stage overkill for a one-shot LLM call
- The project already has a mature state machine, tool inventory, and architecture — re-running
  the full sequence for a small feature addition inside an existing agent system is unnecessary
- `project_type` is anything other than `ai-agent-system` and no agent-system keywords matched

## The 15 Stages

Full gate-check detail (what artifact each stage produces, exact dispatch target, prerequisites)
lives in `workflows/build-sequence.md`. This table is the map — read the workflow file before
running any stage.

| # | Stage | Produces | Dispatch Target |
|---|---|---|---|
| 1 | Idea / Problem Statement | Refined pitch | `cks:ideate` |
| 2 | Monetization / Validation | `.monetize/evaluation.md` | `monetize-discoverer` → `monetize-researcher` → `monetize-evaluator` |
| 3 | PRD | `CONTEXT.md` | `cks:discover` / `agents/prd-discoverer.md` |
| 4 | State Machine Design | State/transition tables | `skills/orchestration/workflows/state-machine.md` |
| 5 | Tool Inventory / Capability Matrix | `references/tool-inventory-template.md` filled in | Net-new (this skill) |
| 6 | Architecture Decisions | `ARCHITECTURE.md` / ADRs | `agents/architecture-generator.md` (only after 4+5 exist) |
| 7 | Memory Architecture | Memory design note | `agents/honcho-integrator.md`, `skills/user-memory`, `skills/conversation-state`, `skills/honcho-memory` |
| 8 | LLM Economics | `.decisions/LLM-ECONOMICS.md` | Thin synthesis of `skills/openrouter/workflows/model-research.md`, `skills/luv-model-routing/SKILL.md`, `agents/cost-analyzer.md` / `agents/cost-researcher.md` |
| 9 | Observability | Telemetry + eval wiring | `.claude/rules/telemetry.md`, `.claude/rules/harness-evals.md`, `cks:observe` |
| 10 | Error Handling / Recovery | DLQ/retry/circuit-breaker ADRs | `.claude/rules/arch-patterns.md` |
| 11 | System Design | Screens / component specs (if any UI) | `agents/prd-designer.md` |
| 12 | API Contract Design | `API.md` (MCP tool defs) | `skills/kickstart/workflows/design.md` Contract Format table |
| 13 | ERD | `ERD.md` | `agents/db-erd.md` |
| 14 | Schema Validation | Schema review | `agents/db-investigator.md` / `skills/database-design/SKILL.md` |
| 15 | Implementation Plan | `PLAN.md` | `agents/prd-planner.md` |

## Ordering Constraint (the actual value-add)

Stages 4 and 5 (state machine, tool inventory) MUST exist before Stage 6 (architecture)
proceeds. Stage 6 must exist before Stage 14 (schema validation). This is enforced as a
**Gap Check** — a prose checklist run by the orchestrating agent before declaring any stage
complete, not a scripted hook. See `workflows/build-sequence.md` § Gap Check. Per
`.claude/rules/setup-philosophy.md`'s bucket test, detecting "was this decided before its
prerequisite existed" requires reading intent and timeline — not enumerable as a regex, so it
stays judgment-guided.

## Net-New Content

Only two pieces of this skill are genuinely new (everything else is a dispatch pointer):

- **Stage 5 — Tool Inventory template** (`references/tool-inventory-template.md`): no existing
  CKS artifact captures per-tool latency/cost/failure-mode/fallback. This is the missing piece
  the framework actually needed.
- **Stage 8 — LLM Economics synthesis**: not a new agent, just a thin doc that pulls together
  three already-existing cost/routing skills into one `.decisions/LLM-ECONOMICS.md` output.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We know the architecture already, let's skip the tool inventory" | The tool inventory is what tells you whether that architecture can survive a 3s-p95 tool call or a $0.02/call cost. Skipping it means guessing. |
| "State machine design is overkill for a simple agent loop" | Even a simple agent has states: idle, tool-calling, waiting, done, failed. Naming them now is cheaper than debugging an undefined state later. |
| "This is just a prompt change, not a new agent system" | Then this skill doesn't apply — see When NOT to Use. Don't force 15 stages onto a one-shot LLM call. |
| "Architecture-generator can figure out the tool inventory itself" | It can't — Mode 3 of `architecture-generator.md` takes tool inventory and state machine as inputs, it doesn't derive them. |
| "The Gap Check should be a hook so it can't be skipped" | Detecting a stage-ordering violation requires reading intent and history, not a regex match. This is deliberately guided, not scripted — see `.claude/rules/setup-philosophy.md`. |

## Verification

- [ ] Every stage that was run produced its named artifact at the expected path
- [ ] Stage 4 (state machine) and Stage 5 (tool inventory) artifacts exist before Stage 6 (architecture) started
- [ ] Stage 6 (architecture) artifact exists before Stage 14 (schema validation) started
- [ ] Gap Check (workflow file) was run before declaring the sequence complete
- [ ] Any stage skipped as "N/A" has a one-line reason recorded, not silently omitted
