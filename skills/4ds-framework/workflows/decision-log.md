# Workflow: Decision Log

<purpose>
Structured protocol for agents to log significant decisions with rationale.
Enables future agents and humans to understand why choices were made.
</purpose>

## When to Log

Log a decision when ANY of these occur:
- Choosing between 2+ viable approaches
- Skipping a quality gate (with reason)
- Overriding a default behavior
- Selecting a library, pattern, or architecture
- Routing an iteration (back to which phase)
- Accepting or rejecting a trade-off

Do NOT log mechanical actions (file reads, state updates, progress banners).

## Log Format

Append one JSON line to `.prd/logs/decisions.jsonl`:

```json
{
  "timestamp": "{ISO-8601}",
  "event": "decision.logged",
  "agent": "{agent-name}",
  "phase": "{current-phase}",
  "feature_id": "{NN}-{name}",
  "decision": "{what was decided}",
  "rationale": "{why this choice}",
  "alternatives": ["{option not chosen}", "{another option}"],
  "trade_off": "{what is sacrificed by this choice}",
  "reversible": true
}
```

## Integration

### For Agent Authors

Add to any agent's system prompt:

```
## Decision Logging
When making a significant choice (see workflows/decision-log.md for criteria),
append a structured entry to `.prd/logs/decisions.jsonl`.
Include: what you decided, why, what alternatives existed, and what trade-off
was accepted. Use the JSON format from the workflow.
```

### For Audit

The audit workflow reads `decisions.jsonl` to score the Discernment dimension.
Features with no decision entries score 0 on Discernment.
Features with trade-offs explicitly logged score higher.

## Examples

**Good decision log entry:**
```json
{
  "timestamp": "2026-04-06T14:30:00Z",
  "event": "decision.logged",
  "agent": "prd-planner",
  "phase": "sprint",
  "feature_id": "03-auth",
  "decision": "Use Clerk for authentication instead of custom JWT",
  "rationale": "Maturity stage is Pilot — Clerk reduces auth surface area and ships faster",
  "alternatives": ["Custom JWT + refresh tokens", "Supabase Auth"],
  "trade_off": "Vendor lock-in, monthly cost above free tier",
  "reversible": true
}
```

**Bad (too vague):**
```json
{
  "decision": "Used Clerk",
  "rationale": "It's good"
}
```

## File Management

- Create `.prd/logs/decisions.jsonl` if it doesn't exist
- One JSON object per line (JSONL format)
- Never overwrite — always append
- No max size — old entries are valuable history
