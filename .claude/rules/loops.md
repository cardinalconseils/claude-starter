# Loop Architecture Rules

## Mandatory Behavior

When any feature description, CONTEXT.md, PLAN.md, or user message contains loop signals,
the planner MUST dispatch `cks:architect` with `skills/loop/workflows/design.md` BEFORE writing PLAN.md. This is not a
suggestion — it fires deterministically on pattern match.

Structural analog: `.claude/rules/scheduling.md` (keyword match → mandatory dispatch).
This rule fires FIRST when both loop and scheduling signals are present — loops subsume
schedules, not the other way around.

## Trigger Patterns

Match is case-insensitive. Any single match is sufficient to trigger.

**Explicit loop language**
- `agentic loop`, `agent loop`, `loop architecture`, `/cks:loop`
- `recurring agent`, `continuous agent`, `autonomous loop`
- `keep/discard loop`, `evaluator-optimizer`
- `PROGRESS.md`, `STATE.md` (when used as agent memory across runs)

**Operational intent**
- `runs overnight`, `runs nightly`, `runs unattended`, `fire-and-forget`
- `agent checks in`, `agent picks up where it left off`
- `loop runs until`, `loop exits when`, `stop condition`
- `triage inbox`, `loop output`, `loop health`, `loop cost`

**Memory and state survival**
- `agent forgets`, `file does not forget`, `state survives between runs`
- `per-run output`, `run log`, `iteration log`

**Autonomy ladder language**
- `autonomy ladder`, `level one suggests`, `apply with approval`, `apply automatically`
- `human review checkpoint`, `unattended`, `supervised run`, `unsupervised run`

## Deterministic: Rule Fires Here

The following decisions are NOT left to agent judgment — they are enforced by this rule:

| Decision | Enforced behavior |
|---|---|
| Schema versioning | `schema_version: int` MUST appear on every `.loops/**/*.jsonl` line. Reader rejects missing. |
| Migration path | `/cks:loop migrate` MUST ship in the same PR as `/cks:loop`. No deferred migration. |
| Cost monitor mode | v1 ships degraded (run-count × static estimate) with "estimate, not measured" banner. No Layer 2 dependency. |
| Stop condition | Every loop MUST declare a hard stop condition in `LOOP-DESIGN.md` before scaffolding. |
| Autonomy level | Every loop starts at Level 1 or 2 (suggest / draft). Level 3+ requires explicit user upgrade after one review cycle. |
| Sentry DSN | `state.json` MUST include a `sentry_dsn` field before loop reaches Level 2+. Empty string = explicit opt-out. Absent field = scaffolding incomplete. |
| LangSmith project | If `LOOP-DESIGN.md` declares LLM calls, `state.json` MUST include `langsmith_project`. Absent = scaffolding incomplete for LLM loops. |
| Sentry capture on error | If `sentry_dsn` is non-empty, `cks:builder` (`Mode: loop-run`) MUST capture every unhandled exception to Sentry before writing the run's `health.jsonl` entry. No exceptions silently swallowed. |
| LangSmith trace per run | If `langsmith_project` is non-empty, `cks:builder` (`Mode: loop-run`) MUST open a trace at run start and close it at run end (pass or fail). Not only on failure — every run is traced. |
| Health check scope | `skills/loop/SKILL-ORCHESTRATOR.md` MUST dispatch `cks:observer` for Sentry (when DSN set) and for LangSmith (when project set) alongside `cks:watchdog` on every health run. `health.jsonl` alone is insufficient. |

## Indeterministic: Left to Agent Judgment

The following are NOT enforced by this rule — agents apply judgment:

| Decision | Agent judgment applies |
|---|---|
| Loop design (six parts composition) | `cks:architect` (`workflows/design.md`) interviews user and produces LOOP-DESIGN.md |
| Triage severity scoring | `cks:historian` (`workflows/triage.md`) weights recency, impact, and loop-specific context |
| Health degradation detection | `cks:watchdog` (`workflows/health.md`) reads run history and flags anomalies |
| Cost estimate calibration | `cks:watchdog` (`workflows/cost.md`, with `cks:finops` for the ledger) adjusts static `$-per-run` based on observed run-count patterns |
| Orchestrator sub-command routing | `skills/loop/SKILL-ORCHESTRATOR.md` (loaded via `Skill(skill="cks:loop")`) decides which role to dispatch per invocation |
| Sentry tags and breadcrumbs | `cks:builder` decides which loop-specific tags/context to attach (beyond the mandatory capture) |
| LangSmith trace naming | `cks:builder` derives trace names from loop slug + run ID |
| Sentry alert thresholds | `cks:architect` asks the user during design (error rate tolerance is loop-specific) |
| LangSmith / Sentry correlation | `cks:watchdog` decides how to cross-reference trace IDs with run output |

## Required Behavior When Triggered

When a trigger pattern is matched:

1. **Do not skip, do not suggest** — dispatch the architect directly
2. Dispatch the architect with the loop design workflow:

```
Agent(
  subagent_type="cks:architect",
  prompt="
    Mode: loop design — read skills/loop/workflows/design.md first.
    Feature being planned: {feature name and description from CONTEXT.md}
    Loop trigger detected: {matched pattern}
    Design the loop using the six-part framework (automations / worktrees / skills /
    connectors / sub-agents / memory). Produce LOOP-DESIGN.md with a hard stop
    condition and autonomy level declaration. Save to .loops/{slug}/LOOP-DESIGN.md.
    Scheduling is registered later as a Routine by the chief of staff (skills/routines),
    never by this dispatch.
  "
)
```

3. Wait for the architect to complete before writing PLAN.md
4. Reference `LOOP-DESIGN.md` path in PLAN.md Risk Notes

## Phase Placement — Design First, Planning as Fallback

Loop design SHOULD happen in **Phase 2 (Design)**, not Phase 3 (Planning).

When a feature goes through the full CKS lifecycle, the design-phase workflow detects loop
signals in CONTEXT.md and dispatches `cks:architect` (loop design) as step [2e] — after UX flows,
screens, and component specs are established. LOOP-DESIGN.md is produced as a design artifact,
available to the architect's plan mode at Phase 3.

**This rule fires at step-3a as a FALLBACK only** — for cases where:
- The design phase was skipped or completed without loop signals present
- Loop signals appear only at planning time (e.g., in a PLAN.md iteration)

**Before dispatching the architect for loop design at step-3a, verify:**
- Does `{phase_dir}/{NN}-CONTEXT.md` exist?
- If NOT: surface a DECISION REQUIRED to start the full lifecycle before writing PLAN.md
- If YES: proceed with the architect dispatch as below

If loop design already ran at Phase 2 (LOOP-DESIGN.md exists in design/):
- Do NOT re-dispatch — include existing LOOP-DESIGN.md path in the architect's plan-mode prompt
- Skip this step

## Relationship to scheduling.md

Loop signals SUPERSEDE scheduling signals. When both match:
- This rule fires; `scheduling.md` does NOT also fire for the same feature
- The chief of staff registers the automation layer as a Routine (`skills/routines`) after design
- `scheduling.md` handles features that are ONLY scheduling (no loop architecture)

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's just a cron job, not a full loop" | If loop signals matched, it's a loop. scheduling.md handles pure crons. |
| "Loop design can wait for the sprint" | The architect writes LOOP-DESIGN.md before PLAN.md; a plan without a stop condition is not a plan. |
| "The user didn't ask for loop architecture" | Loop signals in descriptions are implicit requirements. Surface them — user can dismiss. |
| "I'll wire the stop condition later" | No LOOP-DESIGN.md without a stop condition. The scaffolder won't run without it. |
| "Level 4 autonomy is fine for a simple loop" | Autonomy level is earned, not assumed. Start at Level 1. User upgrades after one review cycle. |
