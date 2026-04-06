# Workflow: Trade-Off Surfacing

<purpose>
When an agent skips a quality step, it must explicitly surface the trade-off
to the user. No silent omissions. Every skip is logged with justification.
</purpose>

## When to Surface

Surface a trade-off when:
- Skipping a quality gate due to maturity stage
- Choosing speed over thoroughness
- Using a simpler approach when a more robust one exists
- Deferring work to a later phase
- Accepting a known limitation

## Protocol

### Step 1: Detect the Skip

The agent recognizes it is about to skip or downgrade a quality step.
Common triggers:
- Maturity stage is Prototype → skipping E2E tests
- Maturity stage is Prototype → skipping security audit
- Time pressure → skipping design phase
- Simple feature → skipping full discovery

### Step 2: Surface to User

Display inline (not a separate report):
```
TRADE-OFF: Skipping {what}
  Reason: {why — maturity stage, scope, etc.}
  Risk: {what could go wrong}
  Override: Run {command} to add this step back
```

### Step 3: Log the Trade-Off

Append to `.prd/logs/decisions.jsonl`:
```json
{
  "timestamp": "{ISO-8601}",
  "event": "trade_off.surfaced",
  "agent": "{agent-name}",
  "phase": "{current-phase}",
  "feature_id": "{NN}-{name}",
  "decision": "Skip {quality step}",
  "rationale": "{maturity stage / scope / time}",
  "alternatives": ["Run {step} anyway"],
  "trade_off": "{risk accepted}",
  "reversible": true
}
```

### Step 4: Track for Audit

The audit workflow counts trade-off entries per feature.
- 0 entries + all gates pass → score 3 (no trade-offs needed)
- 0 entries + gates missing → score 0 (silent omission)
- N entries with rationale → score 2 (honest trade-offs)
- N entries with weak rationale ("too slow") → score 1

## Maturity-Based Defaults

| Quality Step | Prototype | Pilot | Candidate | Production |
|-------------|-----------|-------|-----------|------------|
| Unit tests | Skip (surface) | Required | Required | Required |
| E2E tests | Skip (surface) | Skip (surface) | Required | Required |
| Security audit | Skip (surface) | Required | Required | Required |
| Performance check | Skip (surface) | Skip (surface) | Required | Required |
| Accessibility | Skip (surface) | Skip (surface) | Skip (surface) | Required |
| Monitoring | Skip (surface) | Skip (surface) | Required | Required |

"Skip (surface)" means: skip the step but surface the trade-off explicitly.

## Anti-Pattern: Silent Omission

NEVER do this:
```
# Bad — silent skip
# (agent simply doesn't run security audit, no mention anywhere)
```

ALWAYS do this:
```
# Good — explicit trade-off
TRADE-OFF: Skipping security audit
  Reason: Maturity stage is Prototype
  Risk: Potential vulnerabilities undetected until Pilot stage
  Override: Run /cks:security to add security audit now
```
