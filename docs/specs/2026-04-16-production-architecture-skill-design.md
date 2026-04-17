# Design: Production Architecture Skill

**Date:** 2026-04-16
**Status:** Draft
**Branch:** feat/production-architecture-skill

---

## Problem

CKS agents build software without a shared vocabulary for production-grade reliability patterns.
When a vibecoder describes a dispatch system, a queue, or a multi-step automation, agents default
to the simplest implementation — no state machine, no failure handling, no idempotency. The result
is software that works on the happy path but collapses under real-world conditions.

The fix: embed production architecture knowledge into every phase of the CKS lifecycle so agents
always ask the right questions, plan the right structures, and verify the right compliance criteria
— without the user having to explain it each time.

---

## Goal

Every CKS lifecycle agent carries production architecture knowledge. During discovery, a dedicated
`architecture-advisor` agent surfaces the decisions that shape the system before any code is written.
During planning and sprinting, agents reference those decisions. During review, agents verify
compliance. The patterns are deterministic, named, and non-negotiable.

---

## Scope

### In scope
- New skill: `skills/production-architecture/`
- New agent: `agents/architecture-advisor.md`
- New rule: `.claude/rules/architecture.md`
- Wiring: 14 lifecycle agents updated to load the skill
- Discovery workflow: structured questions that surface architecture decisions
- Validation workflow: compliance checklist for sprint and review phases
- Quick reference: pattern lookup table

### Out of scope
- Runtime enforcement (code linting, CI checks) — future enhancement
- Project-specific architecture documents — the skill produces decisions, not final docs
- ML-based routing or inference — deterministic rules only, by design

---

## Architecture

### 11 Core Patterns (Knowledge Base)

| Pattern | What It Does | Why It Matters |
|---|---|---|
| State Machine | Rigid, deterministic job state transitions | No guessing, no LLM inference on dispatch |
| Control Plane | Orchestrates API calls, retries, transitions | The conductor — manages everything in flight |
| Message Queue | Decouples intake from processing | Jobs can arrive faster than they're processed |
| Event-Driven | Reacts to events vs. polling | Lower latency, cleaner separation |
| Saga Pattern | Multi-step rollback across services | Consistency when one step of many fails |
| Service Mesh | Retry + timeout + circuit breaker layer | Reliability between every external call |
| Circuit Breaker | Stops calling a failing API after threshold | Prevents cascading failures |
| Idempotency | Duplicate calls produce identical, safe outcomes | Duplicate triggers create duplicate side effects |
| Dead Letter Queue | Catches jobs that fail beyond max retries | Nothing loops forever; edge cases are visible |
| Health Checks | Monitors API availability before routing | Don't route to dead services |
| Fan-Out / Fan-In | Parallel worker dispatch with result aggregation | Scales processing; collects results after parallel work |

### Anti-Patterns (Enforced Prohibitions)

These apply to implementation decisions only — they are architecture constraints, not process rules.

- **Never use LLM inference for dispatch routing.** Deterministic state machine rules only.
- **Never poll external APIs without circuit breakers.** Cascading failures crash the system.
- **Never skip idempotency on job processing.** Duplicate triggers create duplicate side effects.
- **Never let failed jobs loop forever.** Dead letter queue after max retries is mandatory.
- **Never hit external APIs live at dispatch time without caching.** Use health checks first.
- **Never implement a multi-step flow without compensating rollback (saga) per step.**

---

## File Structure

```
skills/production-architecture/
  SKILL.md                           Domain knowledge, vocabulary, anti-patterns
  workflows/
    architecture-discovery.md        Structured questions for discovery phase
    architecture-validation.md       Compliance checklist for sprint/review phases
  references/
    patterns-quickref.md             Pattern → when to use → implementation hint

agents/
  architecture-advisor.md            Dedicated agent: runs discovery workflow,
                                     outputs Architecture Decisions to CONTEXT.md

.claude/rules/
  architecture.md                    Guardrail: must/must-not rules for all agents
```

---

## Lifecycle Flow

```
DISCOVERY (prd-discoverer)
  → loads production-architecture skill
  → evaluates feature scope (see Dispatch Trigger below)
  → if trigger conditions met: dispatches architecture-advisor
      Agent(subagent_type="architecture-advisor")
  → architecture-advisor runs architecture-discovery.md workflow
  → writes "## Architecture Decisions" section into CONTEXT.md:
      - applicable patterns and why
      - state machine states (if any)
      - queue schema (if any)
      - failure strategy: retries, DLQ thresholds, escalation path
      - idempotency key design
      - patterns explicitly ruled out (with reason)

DESIGN (prd-designer)
  → loads production-architecture skill
  → reads "## Architecture Decisions" from CONTEXT.md
  → aligns API contract and data model to declared state machine states and queue schema
  → surfaces conflicts between design choices and architecture decisions

PLANNING (prd-planner)
  → loads production-architecture skill
  → reads CONTEXT.md "## Architecture Decisions" section
  → embeds decisions into PRD: state diagram, queue schema, circuit breaker config
  → references patterns by name in PLAN.md implementation steps
  → if "## Architecture Decisions" section is absent: treats this as a simple feature
    with no pipeline/queue/dispatch requirements — proceeds without architecture constraints

SPRINT (sprint-runner + prd-executor + prd-executor-worker)
  → loads production-architecture skill
  → enforces patterns while building
  → before marking sprint done: runs architecture-validation.md checklist
  → if "## Architecture Decisions" section is absent in CONTEXT.md: no architecture
    blockers apply — sprint proceeds on standard completion criteria

REVIEW (prd-verifier + sprint-reviewer)
  → loads production-architecture skill
  → if "## Architecture Decisions" section is present in CONTEXT.md:
      validates implementation against declared decisions
      checks: circuit breaker wired? idempotency key present? DLQ configured?
      state machine transitions complete? health checks running?
  → if section absent: no architecture compliance checks — standard review criteria apply

ASSESSMENT (assess-runner)
  → loads production-architecture skill
  → if "## Architecture Decisions" section present: scores architecture health
    as part of overall project quality
  → if section absent: architecture health not scored

KICKSTART (kickstart-orchestrator + kickstart-intake + kickstart-handoff)
  → loads production-architecture skill
  → kickstart-intake: captures architecture signals at project start
  → kickstart-handoff: includes architecture vocabulary in handoff doc
```

### Dispatch Trigger: When `prd-discoverer` Dispatches `architecture-advisor`

Dispatch when the feature involves **any** of:
- Processing jobs, tasks, or events (queue, scheduler, cron, webhook handler)
- Routing or dispatching to multiple services, agents, or workers
- Multi-step workflows where any step can fail and must roll back
- External API calls at runtime (not just at config time)
- Real-time availability checks or assignment logic
- Systems that must handle duplicate requests safely

**Skip** dispatch when the feature is:
- A UI-only change (component, layout, copy)
- A bug fix with no architectural change
- A configuration or environment variable update
- A documentation or migration with no runtime logic

When in doubt, dispatch. A brief architecture session costs less than retrofitting
circuit breakers after launch.

### Handling Absent `## Architecture Decisions`

The presence of the `## Architecture Decisions` section in CONTEXT.md is the single signal
that architecture patterns apply to a feature:

- **Present** → downstream agents enforce the declared patterns as implementation constraints
- **Absent** → downstream agents proceed with standard criteria; no architecture blockers

This makes the system additive and non-intrusive: simple features never see architecture gates.

---

## Agent: architecture-advisor

**Role:** Architecture discovery specialist. Dispatched by `prd-discoverer` when trigger
conditions are met. Runs the `architecture-discovery.md` workflow using `AskUserQuestion`
to surface decisions. Writes the `## Architecture Decisions` section into CONTEXT.md.

**Dispatch call (in prd-discoverer agent body):**
```
Agent(subagent_type="architecture-advisor")
```

**Frontmatter:**
```yaml
name: architecture-advisor
subagent_type: architecture-advisor
description: "Architecture discovery specialist — surfaces state machine, queue, failure,
  and reliability decisions for any feature involving jobs, events, dispatch, or multi-step
  processing. Dispatched during discovery. Produces ## Architecture Decisions in CONTEXT.md."
tools:
  - Read
  - Write
  - Edit
  - AskUserQuestion
model: opus
color: yellow
skills:
  - production-architecture
```

**Cost note:** `architecture-advisor` uses `model: opus` because architecture decisions are
reasoning-heavy and shape all subsequent phases. This is an intentional cost decision:
an opus sub-agent dispatched from an opus discoverer is justified — a wrong architecture
decision costs far more than the token difference.

**Agent body must NOT:**
- Reference `${CLAUDE_PLUGIN_ROOT}` paths (use skill content only, per agent rules)
- Make dispatch routing decisions using LLM inference
- Output recommendations as plain text — always write directly to CONTEXT.md

---

## Agent Wiring

`production-architecture` added to `skills:` frontmatter of:

| Agent File | Phase | Why |
|---|---|---|
| `prd-discoverer.md` | Discovery | Dispatches architecture-advisor; evaluates trigger |
| `prd-researcher.md` | Research | Architecture-aware scoping of research |
| `prd-planner.md` | Planning | Embeds decisions into PRD + PLAN.md |
| `prd-designer.md` | Design | Aligns API/data model to architecture decisions |
| `prd-executor.md` | Sprint | Enforces patterns while building |
| `prd-executor-worker.md` | Sprint worker | Same — implementation level |
| `prd-verifier.md` | Review | Validates compliance against CONTEXT.md |
| `sprint-runner.md` | Sprint orchestrator | Pattern enforcement during sprint |
| `sprint-reviewer.md` | Sprint close | Architecture review at sprint close |
| `assess-runner.md` | Assessment | Architecture health scoring |
| `go-runner.md` | Pre-push gate | Final architecture compliance check |
| `kickstart-orchestrator.md` | Kickstart | Architecture context from project start |
| `kickstart-intake.md` | Kickstart | Captures architecture signals at intake |
| `kickstart-handoff.md` | Kickstart | Architecture section in handoff doc |

---

## Rule: `.claude/rules/architecture.md`

```
# Architecture Rules

- Agents MUST name patterns explicitly (state machine — not "the logic"; circuit breaker — not "error handling")
- Agents MUST surface architecture decisions as ASSUMPTIONS before building anything with jobs, queues, or dispatch
- Agents MUST include a failure strategy in any system that processes jobs or events
- Agents MUST NOT use LLM inference for routing decisions — deterministic rules only
- Agents MUST NOT implement a queue, dispatcher, or pipeline without circuit breakers
- Agents MUST NOT mark a sprint done if DLQ or idempotency is declared in Architecture Decisions but absent from implementation
- Agents MUST NOT reference ${CLAUDE_PLUGIN_ROOT} paths in agent body — use skill content only
- Architecture first, features second — never implement feature logic before architecture decisions are recorded
```

---

## Success Criteria

1. Every discovery of a feature matching trigger conditions produces an `## Architecture Decisions` section in CONTEXT.md covering: applicable patterns, failure strategy, idempotency approach, and patterns ruled out.
2. Every PRD for a feature with `## Architecture Decisions` includes named pattern selections, state machine diagram (if applicable), queue schema (if applicable), and circuit breaker configuration.
3. Sprint agents that find `## Architecture Decisions` in CONTEXT.md surface missing circuit breakers, DLQ, or idempotency as sprint blockers before marking done.
4. The `architecture-advisor` agent's `subagent_type: architecture-advisor` matches the dispatch call `Agent(subagent_type="architecture-advisor")` exactly — no prefix mismatch.
5. The `production-architecture` skill's `description` field contains these trigger keywords: dispatch, queue, jobs, events, routing, pipeline, multi-step, workers, availability, assignment, circuit breaker, idempotency, state machine.

---

## Vocabulary Reference (Shared Across All Agents)

| Term | Definition |
|---|---|
| State machine | Deterministic job state transitions — no LLM inference |
| Control plane | Orchestrator that manages API calls, retries, and state transitions |
| Message queue | Decoupling layer between intake and processing |
| Saga | Multi-step operation with a compensating rollback action per step |
| Circuit breaker | Trips after N failures; blocks calls during cooldown; resets on recovery |
| Idempotency key | Hash that prevents duplicate processing of the same event |
| Dead letter queue | Parking lot for jobs that exceed max retries — visible for manual review |
| Health check | Periodic API ping stored in state before routing decisions |
| Fan-out / fan-in | Parallel work distribution with result aggregation after all workers complete |
| Compensating action | The undo operation executed by a saga step on failure |
