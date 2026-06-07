# Architecture Pattern Rules

## Mandatory Behavior

When any feature description, CONTEXT.md, PLAN.md, or code diff contains a distributed pattern signal, the planner MUST dispatch `cks:architecture-generator` (Mode 3) before writing PLAN.md. This is not a suggestion — it fires deterministically on pattern match.

Structural analog: `.claude/rules/scheduling.md` (keyword match → mandatory dispatch) and `.claude/rules/evals.md` (lifecycle-gate-keyed trigger). This rule follows the same model applied to distributed resilience patterns.

## Trigger Patterns

Match is case-insensitive. Any single match is sufficient to trigger.

**Dead Letter Queue**
- `dead letter`, `DLQ`, `failed message store`, `undeliverable`, `poison queue`

**Saga**
- `compensating transaction`, `rollback step`, `multi-step workflow`, `saga`

**Circuit Breaker**
- `circuit breaker`, `circuit_breaker`, `open/half-open`, `failure threshold`

**Idempotency**
- `idempotency key`, `idempotent`, `duplicate request`, `exactly-once`

**Retry / Backoff**
- `retry on failure`, `exponential backoff`, `max_retries`, `retry with delay`

**Fan-out / Fan-in**
- `fan-out`, `fan-in`, `parallel workers`, `broadcast job`, `scatter-gather`

**Health-aware Routing**
- `health check routing`, `health-aware`, `route around failures`

**CQRS**
- `CQRS`, `command query separation`, `read model`, `write model`, `projection`

**Event Sourcing**
- `event sourcing`, `event log`, `event store`, `append-only log`, `replay events`

**Outbox Pattern**
- `outbox pattern`, `transactional outbox`, `inbox outbox`, `at-least-once delivery`

**Bulkhead**
- `bulkhead`, `thread pool isolation`, `resource partition`, `blast radius isolation`

**Service Mesh**
- `service mesh`, `sidecar proxy`, `Istio`, `Linkerd`, `Envoy`, `mTLS between services`

## Required Behavior by Lifecycle Gate

### Planning Gate [3a] — MANDATORY before writing PLAN.md

1. Scan CONTEXT.md feature description and acceptance criteria for all trigger patterns above
2. Collect all matched patterns (dedup — "retry queue" → {Retry/Backoff, DLQ})
3. **If any match found:**
   - Dispatch `cks:architecture-generator` ONCE with all matched patterns:

```
Agent(
  subagent_type="cks:architecture-generator",
  prompt="
    Mode: pattern-adr
    Feature: {feature name from CONTEXT.md}
    Phase: {NN}
    Detected patterns: {comma-separated list}
    Read skills/architecture/references/distributed-patterns.md for guidance per pattern.
    Write one ADR per pattern (or one combined ADR if patterns are closely related).
    Save to .decisions/ADR-NNN.md. Report ADR path(s) when done.
  "
)
```

   - Wait for architecture-generator to complete
   - Surface an `▶ ACTION REQUIRED` block listing matched patterns + ADR file path(s)
   - Reference ADR path(s) in PLAN.md Risk Notes
   - Do NOT write PLAN.md until architecture-generator completes
4. **If no match found:** proceed to writing PLAN.md

### Sprint Gate [3c] — Non-blocking catch

After SUMMARY.md is written but before declaring build complete:

1. Scan SUMMARY.md + changed file contents for pattern signals not caught at [3a]
2. If new match found (pattern not already covered by an ADR from [3a]):
   - Dispatch `cks:architecture-generator` Mode 3 with the newly matched patterns
   - Surface `▶ ACTION REQUIRED` block
   - Non-blocking on architecture-generator failure — log the failure, continue sprint

### Review Gate [4a] — Diff scan, non-blocking

After SUMMARY.md exists and before PR review:

1. Run `git diff main...HEAD` on changed files
2. Scan diff for signals: new external HTTP calls (fetch/axios/requests/got), new queue/stream clients, new DB write paths, new third-party API integrations, new payment calls
3. For each signal, check if a matching pattern from this file is already handled in the changed files (try/catch + retry logic, idempotency key, DLQ sink, circuit state check)
4. If missing pattern found — surface `❓ DECISION REQUIRED` block:

```
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
Distributed pattern scan found {N} signal(s) not covered by existing resilience patterns.

  1. Add pattern now — returns to sprint [3c] to implement before merge
  2. Defer with ADR — creates .decisions/ADR-NNN-DEFERRED.md and continues review
  3. Dismiss with reason — records dismissal in .prd/phases/{NN}/DISMISSED-PATTERNS.md

Top findings (capped at 3 by severity):
  - [MISSING] {pattern}: {evidence — file:line} — severity: {High|Med|Low}

Recommended: 2 (Defer with ADR) — keeps merge unblocked while preserving the gap.

Reply with the number or describe what you want.
─────────────────────────────────────────────────
```

5. MUST NOT block merge — the user's choice governs
6. Record all dismissals in `.prd/phases/{NN}/DISMISSED-PATTERNS.md` — never re-prompt for the same finding

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The pattern might not be needed yet" | Pattern matched = it's needed. Defer only if user explicitly says so after being prompted. |
| "I'll mention it as a suggestion" | The rule mandates dispatch, not a suggestion. Dispatch `architecture-generator`. |
| "It's early, patterns can come later" | Later never comes. Wire patterns before PLAN.md when context is fresh. |
| "The user didn't ask for a circuit breaker" | Distributed signals in feature descriptions are implicit requirements. Surface them now. |
