# Harvest Workflow (Deterministic)

Extracts task patterns and usage signals from CKS telemetry for one or more target skills.
All steps are deterministic — no LLM involved.

## Inputs

- `.prd/logs/sessions/*.jsonl` — per-tool-call traces (see `.claude/rules/telemetry.md`)
- `.learnings/session-log.md` — retro session entries with skill mentions
- `.sleep/queue.json` — explicitly queued skills with source tags

## Steps

### 1. Identify Target Skills

```bash
# From queue
TARGET_SKILLS=$(jq -r '.queued[].skill' .sleep/queue.json 2>/dev/null)

# Or from --skill arg
# Or from spike defaults: prd retrospective evals

echo "Target skills: $TARGET_SKILLS"
```

### 2. Parse Session Telemetry per Skill

For each target skill, scan `.prd/logs/sessions/*.jsonl`:

```bash
# Map tool→skill via skill domain keywords
# prd-related: prd-orchestrator, prd-executor, prd-planner, prd-discoverer, prd-verifier
# retro-related: retrospective, retro, session-log
# evals-related: evals-runner, evals, smoke, standard, comprehensive

# Count tool-call frequency per skill domain
grep -h . .prd/logs/sessions/*.jsonl 2>/dev/null \
  | jq -r 'select(.tool != null) | "\(.tool) \(.session_id)"' \
  | sort | uniq -c | sort -rn > /tmp/tool-freq.txt
```

Map tool names to skill domains using `references/skillopt-engine-contract.md`
domain-map table. Sum frequencies per skill.

### 3. Extract Task Patterns from Session Log

```bash
# Find skill mentions in session log
grep -i "{skill_name}" .learnings/session-log.md 2>/dev/null \
  | tail -20 > /tmp/session-mentions.txt
```

Extract the surrounding context (±3 lines) for each mention as a "task example".

### 4. Write Harvest Output

For each skill, write `.sleep/harvest/{skill}-{date}.json`:

```json
{
  "skill": "prd",
  "harvested_at": "2026-06-15T02:00:00Z",
  "session_count": 12,
  "tool_call_frequency": 847,
  "task_examples": [
    "User ran /cks:sprint on authentication feature — 3 phases, 14 files",
    "Executor dispatched 5 parallel workers for database migration sprint"
  ],
  "source_queue_entry": {"source": "sprint", "queued_at": "2026-06-15T14:00"}
}
```

### 5. Validate Harvest

Minimum signal threshold: at least 3 `task_examples` OR `tool_call_frequency >= 10`.

If below threshold:
- Log: `"Low signal for skill {name} — proceeding with minimal examples"`
- Do NOT skip the skill — skillopt handles sparse input

## Output

`.sleep/harvest/{skill}-{date}.json` — one file per skill.

Harvest step is complete when all target skills have a harvest file.
