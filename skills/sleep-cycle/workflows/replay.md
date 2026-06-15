# Replay Workflow (Indeterministic)

Runs the SkillOpt-Sleep Python subprocess to generate skill edit proposals.
The LLM-generated outputs (task replays + edit proposals) are indeterministic by design.
The subprocess invocation, input/output paths, and seed pinning are deterministic.

## Inputs

- `.sleep/harvest/{skill}-{date}.json` — harvest output for each skill
- `skills/{skill}/SKILL.md` — current skill content (read-only in this step)
- `session_id[:8]` — seed for held-out task selection

## Steps

### 1. Prepare Input Bundle per Skill

For each skill:

```bash
# Build skillopt input JSON
cat > /tmp/skillopt-input-{skill}.json << EOF
{
  "skill_content": "$(cat skills/{skill}/SKILL.md | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')",
  "task_examples": $(jq '.task_examples' .sleep/harvest/{skill}-{date}.json),
  "seed": "${SESSION_ID:0:8}",
  "held_out_count": $(jq '.held_out_tasks // 5' .cks/sleep-config.json 2>/dev/null || echo 5)
}
EOF
```

### 2. Invoke SkillOpt

```bash
bash scripts/sleep-engine.sh \
  --input /tmp/skillopt-input-{skill}.json \
  --output .sleep/proposals/{skill}-{date}-raw.md \
  --skill {skill}
```

The script checks Python ≥3.10, verifies `skillopt==0.1.0` is installed,
and runs the subprocess. See `references/skillopt-engine-contract.md` for
the full interface spec.

### 3. Validate Raw Proposal

After each skill:

```bash
if [ ! -s ".sleep/proposals/{skill}-{date}-raw.md" ]; then
  echo "WARN: empty proposal for {skill} — skipping gate"
  continue
fi
```

A valid raw proposal contains at least one diff block (`--- a/` / `+++ b/` markers)
or a `## Proposed Changes` section.

### 4. Log Replay Outcome

Append to `.sleep/results/{date}.json` (create if absent):

```json
{
  "skill": "prd",
  "replay_status": "ok",
  "proposal_bytes": 1842,
  "held_out_seed": "a3f7b2c1"
}
```

## Indeterministic Expectations

- SkillOpt may propose different edits each run — this is expected and correct
- Two runs with the same seed will select the same held-out tasks but may produce different proposals (LLM temperature)
- The gate step (next workflow) filters out proposals that don't improve performance
- NEVER cache raw proposals across cycles — always regenerate

## Output

`.sleep/proposals/{skill}-{date}-raw.md` — raw proposal per skill, passed to gate.

If a skill fails replay (empty output, Python error, skillopt crash):
- Write `.sleep/blocked/{skill}-{date}.json` with `{"reason": "replay_failed", "error": "..."}`
- Continue processing remaining skills — one failure does not abort the cycle
