# Gate Workflow (Deterministic)

Validates each raw proposal against held-out tasks using the evals runner.
Pass/fail is purely numerical — same inputs always produce the same verdict.

## Inputs

- `.sleep/proposals/{skill}-{date}-raw.md` — raw proposal from replay
- `skills/{skill}/SKILL.md` — baseline (current) skill content
- `.cks/sleep-config.json` — `lift_threshold` (default: 0.05)

## Gate Logic

### 1. Baseline Score

If no baseline score exists for this skill in `.sleep/results/{date}.json`:

```
Agent(
  subagent_type="cks:evals-runner",
  prompt="Run smoke tier evals against the CURRENT (unmodified) skill: {skill}.
  Eval type: regression. Tier: smoke. Report pass rate as a decimal (0.0–1.0).
  Do NOT auto-repair. Write score to .sleep/gate-scores/{skill}-baseline.json"
)
```

Wait for result. Parse `pass_rate` from output.

### 2. Apply Proposal to Temp Copy

```bash
# Copy current skill to temp
cp skills/{skill}/SKILL.md /tmp/sleep-proposed-{skill}.md

# Apply the proposal diff
# The raw proposal contains a unified diff or full replacement section
# Parse and apply using the contract spec in references/skillopt-engine-contract.md
bash scripts/sleep-engine.sh --apply-proposal \
  --input .sleep/proposals/{skill}-{date}-raw.md \
  --target /tmp/sleep-proposed-{skill}.md
```

The temp copy is never written to `skills/` — this is the firewall.

### 3. Proposal Score

Temporarily swap the skill file (in-memory for the evals runner, or via temp path):

```
Agent(
  subagent_type="cks:evals-runner",
  prompt="Run smoke tier evals against this PROPOSED skill content at path:
  /tmp/sleep-proposed-{skill}.md. Eval type: regression. Tier: smoke.
  Do NOT auto-repair. Report pass rate as a decimal.
  Write score to .sleep/gate-scores/{skill}-proposed.json"
)
```

Wait for result. Parse `pass_rate` from output.

### 4. Gate Decision (Deterministic)

```bash
BASELINE=$(jq '.pass_rate' .sleep/gate-scores/{skill}-baseline.json)
PROPOSED=$(jq '.pass_rate' .sleep/gate-scores/{skill}-proposed.json)
THRESHOLD=$(jq '.lift_threshold // 0.05' .cks/sleep-config.json 2>/dev/null || echo 0.05)
LIFT=$(echo "$PROPOSED - $BASELINE" | bc)

# Gate: proposed must exceed baseline by at least threshold
# AND must not regress below baseline (lift must be non-negative)
if (( $(echo "$LIFT >= $THRESHOLD" | bc -l) )); then
  GATE="PASS"
else
  GATE="FAIL"
fi
```

### 5. Write Gate Result

Append to `.sleep/results/{date}.json`:

```json
{
  "skill": "prd",
  "baseline_score": 0.80,
  "proposed_score": 0.87,
  "lift": 0.07,
  "threshold": 0.05,
  "gate": "PASS"
}
```

### 6. Route by Gate Result

**PASS:** Copy proposal to `.sleep/staged/{skill}-{date}.md`

**FAIL:** Write `.sleep/blocked/{skill}-{date}.json`:
```json
{
  "skill": "prd",
  "reason": "gate_failed",
  "lift": -0.02,
  "threshold": 0.05,
  "note": "Proposed skill scored lower than baseline. Proposal discarded."
}
```

Clean up `/tmp/sleep-proposed-{skill}.md` in both cases.

## Gate Invariants

- Baseline and proposed scores use the IDENTICAL eval set (same seed)
- Gate threshold is read from config every run — never hardcoded
- A proposal that ties the baseline (lift = 0) FAILS the gate — "no regression" ≠ improvement
- Gate runs independently per skill — one FAIL does not affect other skills
- NEVER write a FAIL proposal to `.sleep/staged/`

## Output

`.sleep/staged/{skill}-{date}.md` — staged proposal (gate passed only).
`.sleep/blocked/{skill}-{date}.json` — gate failure record.
`.sleep/results/{date}.json` — updated with gate scores for each skill.
