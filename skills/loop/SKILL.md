---
name: loop
description: "Loop architecture domain expertise — six-part composition (automations/worktrees/skills/connectors/sub-agents/memory), autonomy ladder, triage-inbox-first UX, stop condition rules, health.jsonl schema, cost monitoring"
allowed-tools:
  - Read
  - Write
  - Bash
---

# Loop Architecture

Domain expertise for designing, running, and operating agentic loops in CKS.

## Six-Part Composition

Every loop is composed of up to six parts. Not all are required — include what the use case needs.

| Part | What it is | When to include |
|---|---|---|
| **Automations** | Cron schedule or event trigger that fires the loop | Always — every loop needs a trigger |
| **Worktrees** | Isolated git worktrees for each run | When loop writes code or modifies files (deferred to V2) |
| **Skills** | Domain expertise files loaded by the runner | When the loop needs specialized knowledge |
| **Connectors** | External integrations (APIs, DBs, webhooks, Slack, Telegram) | When loop reads/writes external systems |
| **Sub-agents** | Specialist agents dispatched within a run | When tasks require delegation or parallel work |
| **Memory** | `STATE.md` or `PROGRESS.md` — survives between runs | When the loop builds on prior context |

### Memory Pattern

`STATE.md` (or `PROGRESS.md`) lives at `.loops/{slug}/STATE.md`. Keep it short (under 50 lines). Contents:

- What run N completed
- What run N+1 should focus on
- Any items deferred from previous runs
- Current iteration count

The runner reads it at start, writes an update at end. This is the only cross-run memory.

## Autonomy Ladder

Every loop declares an autonomy level in `LOOP-DESIGN.md`. Default is Level 1 or 2.

| Level | Behavior | When to use |
|---|---|---|
| **Level 1 — Suggest** | Loop writes suggestions to output files. Applies nothing. | Default for new loops. Human reviews every output. |
| **Level 2 — Draft** | Loop writes drafts (PRs, docs, emails) but does not send/merge. | After one review cycle confirms quality. |
| **Level 3 — Apply** | Loop applies changes, shows them before committing. | Explicit user upgrade required after Level 2 cycle. |
| **Level 4 — Autonomous** | Loop applies and commits with audit log only. | Explicit user upgrade from Level 3. High trust. |

**Default:** Level 1 for all new loops. Never start at Level 3 or 4 without explicit user upgrade in `LOOP-DESIGN.md`.

**Upgrade path:** User confirms upgrade via `AskUserQuestion` in the designer. Each level requires at least one review cycle at the previous level.

## Stop Condition Rules

Every loop MUST declare a hard stop condition. Rules:

1. Stop condition MUST be checkable by something other than the agent's own claim
2. Must include a maximum iteration backstop (e.g., "after 100 runs, pause and report")
3. Examples of valid stop conditions:
   - "Stop when `.loops/{slug}/STOP` file exists"
   - "Stop after 50 iterations"
   - "Stop when error rate in health.jsonl exceeds 20% over last 10 runs"
   - "Stop when no new items found for 3 consecutive runs"
4. Loop designer MUST refuse to produce `LOOP-DESIGN.md` until stop condition is stated

**Why:** Without a hard stop, loops run until they exhaust budget or hit infrastructure limits. The stop condition is the circuit breaker.

## Triage-Inbox-First UX

Primary output is `.triage/{slug}/{YYYY-MM-DD}.md` — NOT a status console.

**Why:** Vibecoders don't monitor loops proactively. Findings must surface to them (triage inbox, Slack/Telegram notification on failure). Confirmed in V1 user interviews.

Key behaviors:
- Triage curator writes a dated report every run cycle
- Reports show HIGH / MEDIUM / LOW findings — severity-scored, deduplicated
- "No findings" is still a valid report — always write the file
- `/cks:loop status` is secondary UX — always mention triage as primary

## Health.jsonl Schema

See `docs/schemas/loop-events-v1.md` for full spec. Summary:

```json
{"schema_version":1,"loop_slug":"<slug>","run_id":"<uuid>","ts":"<ISO8601>","outcome":"pass|fail","summary":"<what happened>","iteration":<n>}
```

- `schema_version` MUST be `1` on every line
- Reader MUST reject entries where `schema_version` is absent
- File is append-only

## Evaluator-Optimizer Pattern

When a loop improves output over iterations (e.g., refines a document, optimizes a metric):

- **Writer agent**: produces the output (draft, code, analysis)
- **Checker agent**: evaluates against an objective gate (test pass/fail, score threshold, metric value)
- Gate must be objective — not "looks good", but "passes lint" or "score ≥ 0.85"
- Loop exits when gate passes OR max iterations reached

## Cost Monitor Approach

V1 cost monitoring uses run-count × static estimate:
- Static estimate: $0.01 per run (Sonnet model, ~50k tokens per iteration)
- This is a rough estimate — actual cost varies by loop complexity
- **Always show "estimate, not measured" banner** — Layer 2 telemetry (duration_ms, cost_usd) not shipped
- Never claim exact cost — always frame as estimate

## Sentry and LangSmith Integration

`state.json` MUST include these fields before loop reaches Level 2+:
- `sentry_dsn`: Sentry Data Source Name. Empty string = explicit opt-out (must be stated).
- `langsmith_project`: LangSmith project name. Required when loop has LLM calls. Empty string = explicit opt-out.

Absent field (not empty string, but missing) = scaffolding incomplete.

**Loop runner MUST:**
- Capture every unhandled exception to Sentry when `sentry_dsn` is non-empty (before writing health entry)
- Open LangSmith trace at run start and close at run end (every run, not just failures) when `langsmith_project` is non-empty

**Loop health checker MUST:**
- Dispatch `cks:sentry-observer` when `sentry_dsn` is non-empty
- Dispatch `cks:langsmith-observer` when `langsmith_project` is non-empty
- `health.jsonl` alone is NOT sufficient — observer checks are mandatory

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll add the stop condition later" | No LOOP-DESIGN.md without a stop condition. The runner refuses to run without it. |
| "Level 3 is fine, the loop is simple" | Every loop starts at Level 1. User upgrades after one review cycle. No exceptions. |
| "health.jsonl alone is enough for health check" | Both observers must be dispatched when configured. health.jsonl is internal; observers check external signals. |
| "I'll skip the triage report when nothing happened" | Always write the triage file. "No findings" is information. |
| "The cost estimate is close enough to call it accurate" | Always show the "estimate, not measured" banner. Layer 2 telemetry not shipped. |
| "sentry_dsn can stay absent if not needed" | Absent field = incomplete scaffolding. Empty string = explicit opt-out. There is a difference. |

## Verification

- [ ] `LOOP-DESIGN.md` exists with stop condition declared
- [ ] Autonomy level is Level 1 or 2 (never Level 3+ on first scaffold)
- [ ] `state.json` has `sentry_dsn` and `langsmith_project` fields (even if empty strings)
- [ ] `health.jsonl` entries include `schema_version: 1`
- [ ] Triage report written to `.triage/{slug}/{date}.md`
- [ ] "estimate, not measured" banner shown on cost output
