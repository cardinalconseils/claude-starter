# Loop Architecture Rules

## Mandatory Behavior

When any feature description, CONTEXT.md, PLAN.md, or user message contains loop signals,
the planner MUST dispatch `cks:loop-designer` BEFORE writing PLAN.md. This is not a
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
| Sentry capture on error | If `sentry_dsn` is non-empty, `cks:loop-runner` MUST capture every unhandled exception to Sentry before writing the run's `health.jsonl` entry. No exceptions silently swallowed. |
| LangSmith trace per run | If `langsmith_project` is non-empty, `cks:loop-runner` MUST open a trace at run start and close it at run end (pass or fail). Not only on failure — every run is traced. |
| Health check scope | `cks:loop-health-checker` MUST dispatch `cks:sentry-observer` (when DSN set) and `cks:langsmith-observer` (when project set) as part of every health run. `health.jsonl` alone is insufficient. |

## Indeterministic: Left to Agent Judgment

The following are NOT enforced by this rule — agents apply judgment:

| Decision | Agent judgment applies |
|---|---|
| Loop design (six parts composition) | `cks:loop-designer` interviews user and produces LOOP-DESIGN.md |
| Triage severity scoring | `cks:loop-triage-curator` weights recency, impact, and loop-specific context |
| Health degradation detection | `cks:loop-health-checker` reads run history and flags anomalies |
| Cost estimate calibration | `cks:loop-cost-monitor` adjusts static `$-per-run` based on observed run-count patterns |
| Orchestrator sub-command routing | `cks:loop-orchestrator` decides which sub-agent to dispatch per invocation |
| Sentry tags and breadcrumbs | `cks:loop-runner` decides which loop-specific tags/context to attach (beyond the mandatory capture) |
| LangSmith trace naming | `cks:loop-runner` derives trace names from loop slug + run ID |
| Sentry alert thresholds | `cks:loop-designer` asks the user during design (error rate tolerance is loop-specific) |
| LangSmith / Sentry correlation | `cks:loop-health-checker` decides how to cross-reference trace IDs with run output |

## Required Behavior When Triggered

When a trigger pattern is matched:

1. **Do not skip, do not suggest** — invoke loop-designer directly
2. Feature-detect before dispatch:

```
if agents/loop-designer.md exists:
  Agent(
    subagent_type="cks:loop-designer",
    prompt="
      Feature being planned: {feature name and description from CONTEXT.md}
      Loop trigger detected: {matched pattern}
      Design the loop using the six-part framework (automations / worktrees / skills /
      connectors / sub-agents / memory). Produce LOOP-DESIGN.md with a hard stop
      condition and autonomy level declaration. Save to .loops/{slug}/LOOP-DESIGN.md.
    "
  )
else:
  # loop-designer not yet installed — fall back to scheduler for the automation layer
  # and surface a SUGGESTION to install /cks:loop
  surface 💡 SUGGESTION: "Loop signal detected. /cks:loop not installed. Run
  `claude /plugin add cks` to upgrade. Falling back to /cks:schedule."
  dispatch cks:scheduler with the scheduling layer of the feature
```

3. Wait for loop-designer (or scheduler fallback) to complete before writing PLAN.md
4. Reference `LOOP-DESIGN.md` path in PLAN.md Risk Notes

## Phase Placement — Design First, Planning as Fallback

Loop design SHOULD happen in **Phase 2 (Design)**, not Phase 3 (Planning).

When a feature goes through the full CKS lifecycle, the design-phase workflow detects loop
signals in CONTEXT.md and dispatches `cks:loop-designer` as step [2e] — after UX flows,
screens, and component specs are established. LOOP-DESIGN.md is produced as a design artifact,
available to prd-planner at Phase 3.

**This rule fires at step-3a as a FALLBACK only** — for cases where:
- The design phase was skipped or completed without loop signals present
- Loop signals appear only at planning time (e.g., in a PLAN.md iteration)

**Before dispatching loop-designer at step-3a, verify:**
- Does `{phase_dir}/{NN}-CONTEXT.md` exist?
- If NOT: surface a DECISION REQUIRED to start the full lifecycle before writing PLAN.md
- If YES: proceed with loop-designer dispatch as below

If loop-designer was already dispatched at Phase 2 (LOOP-DESIGN.md exists in design/):
- Do NOT re-dispatch — include existing LOOP-DESIGN.md path in prd-planner prompt
- Skip this step

## Relationship to scheduling.md

Loop signals SUPERSEDE scheduling signals. When both match:
- This rule fires; `scheduling.md` does NOT also fire for the same feature
- The loop-designer handles the automation layer (CronCreate) internally
- `scheduling.md` handles features that are ONLY scheduling (no loop architecture)

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's just a cron job, not a full loop" | If loop signals matched, it's a loop. scheduling.md handles pure crons. |
| "The loop-designer doesn't exist yet" | Feature-detect handles this. Fall back to scheduler + SUGGESTION banner. |
| "The user didn't ask for loop architecture" | Loop signals in descriptions are implicit requirements. Surface them — user can dismiss. |
| "I'll wire the stop condition later" | No LOOP-DESIGN.md without a stop condition. The scaffolder won't run without it. |
| "Level 4 autonomy is fine for a simple loop" | Autonomy level is earned, not assumed. Start at Level 1. User upgrades after one review cycle. |
