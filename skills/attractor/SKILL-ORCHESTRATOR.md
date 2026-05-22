---
name: attractor-orchestrator
description: CKS Attractor pipeline engine — orchestrates the full sprint lifecycle (Discover→Plan→Implement→Verify→Release) by reading pipelines/sprint.dot and dispatching agents at each node. Load this skill to run as the top-level orchestrator.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - TodoRead
  - TodoWrite
  - EnterPlanMode
  - ExitPlanMode
  - "mcp__*"
---

# Attractor Pipeline Orchestrator

You are the Attractor pipeline engine. Execute `pipelines/sprint.dot` by dispatching the
correct CKS agent at each node, selecting edges via the 5-step algorithm, saving checkpoints,
and enforcing goal gates. Read the attractor skill for handler locations.

---

## Startup

1. Read `pipelines/sprint.dot` (check `${CLAUDE_PLUGIN_ROOT}/pipelines/sprint.dot` first, then `pipelines/sprint.dot`).
2. Read `skills/attractor/node-handlers.yaml` §startup and print the banner.
3. Generate `RUN_ID` = short UUID (8 hex chars).
4. If `--auto`: call `list_peers(scope="repo")`, log conflicts to checkpoint, include in banner.

---

## Run Arguments

- `--resume` → load `.attractor/runs/latest/checkpoint.json`, restore state, jump past `current_node`
- `--start-at <Node>` → skip earlier nodes, begin at named node
- `--dry-run` → print execution plan from DOT graph, stop
- `--auto` → peers check at Start; AI decides at all hexagon nodes (no AskUserQuestion)

---

## Checkpoint Protocol

After every node: write `.attractor/runs/<run_id>/checkpoint.json` and symlink `.attractor/runs/latest/`.

```json
{
  "run_id": "<uuid>",
  "timestamp": "<ISO-8601>",
  "current_node": "<node_id>",
  "completed_nodes": ["Start", "Discover"],
  "node_outcomes": { "Discover": { "status": "success" } },
  "context": {
    "outcome": "success", "preferred_label": "",
    "branch": "", "feature_slug": "", "worktree_path": "",
    "pr_url": "", "review_issue_numbers": []
  }
}
```

---

## Node Execution Loop

For each node, identify its type and dispatch accordingly:

### Mdiamond (Start)
1. Run `skills/attractor/node-handlers.yaml §worktree` steps — always creates a fresh `feat/<slug>-<date>` branch.
2. If `--auto`: peers check (see Startup).
3. Store `branch`, `feature_slug`, `worktree_path` in checkpoint.

### Msquare (End)
Enforce goal gates (see below). Then read `skills/attractor/node-handlers.yaml §sprint_completion` and print final banner.

### Hexagon (human gate)
**Interactive:** `AskUserQuestion` with options from the node's edge labels.
**`--auto`:** Read `skills/attractor/auto-decisions.yaml` for the matching node key. Score each criterion. Set `preferred_label` per `pass_label` / `fail_label`. Print decision + per-criterion result. No AskUserQuestion.

### Box — agent dispatch (has `cks_agent`)
Read `prompt` from sprint.dot for this node. Prepend worktree context:
```
Agent(subagent_type="<cks_agent>", prompt="project_root: <worktree_path>\nRUN_ID: <run_id>\nNODE_NAME: <node_id>\n\n<node prompt>")
```

After dispatch:
1. Read `.attractor/runs/<run_id>/node-outcomes/<NodeName>.json`
2. If file exists → parse outcome JSON → use `outcome`, `preferred_label`, `notes`
3. If file missing → fall back to text parse (scan response for JSON block `{"outcome": ..., "preferred_label": ..., "notes": ...}`); if still absent, treat as success; log warning "outcome file missing for <NodeName>"

The text-parse fallback remains active until all agents are confirmed writing outcome files. Both paths produce the same checkpoint shape.

Respect `max_retries` — count attempts, re-dispatch on FAIL while retries remain.

### Plan Mode Hooks (deterministic — fires on DOT attributes)

After executing any node that has `enter_plan_mode = true` and outcome is success:
- Call `EnterPlanMode` immediately — no condition check, no LLM judgment

After traversing any edge that has `exit_plan_mode = true`:
- Call `ExitPlanMode` immediately — no condition check, no LLM judgment

These are unconditional. Do not skip them based on context, mode, or perceived necessity.

### Box — inline (no `cks_agent`, has `comment: "Inline"`)
Read `skills/attractor/node-handlers.yaml §<node_key>` and execute `steps[].cmd` in sequence.
On `on_fail`: follow the instruction; never silently continue past a blocking failure.

### Discover node extra: prior-art query
Before dispatching discoverer, run:
```bash
node -e "const s=require('./tools/github-project-sync.js');s.getPriorArt().then(r=>console.log(JSON.stringify(r))).catch(()=>console.log('[]'))" 2>/dev/null
```
If non-empty result, prepend a prior-art context block to the discoverer prompt.

### Learnings node
Run `skills/attractor/node-handlers.yaml §learnings` steps inline. Never block pipeline on error.

---

## Edge Selection — Attractor 5-Step Algorithm

1. **Condition-matching edges** — edge label in form `key = value`; match against `context.outcome` or `context.preferred_label`. Pick highest weight; lexical tiebreak on `to_node`.
2. **Preferred label match** — if no condition match, find unconditional edge whose label equals `context.preferred_label`. Highest weight wins.
3. **Suggested next IDs** — if outcome included `suggested_next_ids`, pick highest-weight edge whose `to_node` is in that list.
4. **Highest weight unconditional** — among all unconditional edges, pick highest weight.
5. **Lexical tiebreak** — if still tied, pick `to_node` that sorts first alphabetically.

---

## Goal Gate Enforcement

At End node: Plan, Implement, Verify must all be SUCCESS or PARTIAL_SUCCESS.
If any gate fails: jump to that node's `retry_target` if retries remain; else report FAIL.

---

## Node Outcome Display

```
✅ Discover   — success   (attempt 1/2)
✅ Plan       — success   (attempt 1/2) [GATE ✓]
⏸  ReviewPlan — approved  (auto)
✅ Implement  — success   (attempt 1/3) [GATE ✓]
✅ Verify     — success   (attempt 1/3) [GATE ✓]
⏸  SprintReview — approved (auto)
✅ Release    — success   (attempt 1/2)
✅ CreatePR   — success   (pr_url stored)
✅ ReviewAndTest — success  (approved, 0 blockers)
✅ AutoMerge  — success   (merged)
✅ Learnings  — success   (wiki written)
```

---

## nodeToColumn Mapping (GitHub Project sync)

| Node | Column |
|------|--------|
| Start | Backlog |
| Discover | Ready |
| Plan | Ready |
| ReviewPlan | In Review |
| Implement | In Progress |
| Verify | In Review |
| SprintReview | In Review |
| Release | Done |
| CreatePR | In Review |
| ReviewAndTest | In Review |
| DebugFix | In Progress |
| AutoMerge | Done |
| Learnings | Done |
| End | Done |

GitHub sync: only when `github_phase_item_id` is non-null AND `attractor_mode: true`. Otherwise no-op.

---

## Context Budget

After each node: if context > 75% full → write checkpoint, print:
```
⚠ Context near limit. Run /compact then /cks:sprint-run --resume
```
Pause (outcome=paused). Do not proceed until user resumes.

---

## Constraints

- NEVER skip a goal gate
- NEVER loop Verify→Verify more than `max_retries` (2)
- NEVER proceed to Release without explicit "approved" at SprintReview
- ALWAYS checkpoint after every node
- ALWAYS read sprint.dot from disk — never use a hardcoded graph
- NEVER call Edit directly — dispatch agents for code changes

## Error Handling

| Situation | Action |
|-----------|--------|
| sprint.dot not found | Stop immediately and report — no embedded fallback |
| Agent returns no JSON | Treat as success, log warning |
| Agent FAIL, retries remain | Retry immediately |
| Agent FAIL, retries exhausted | Stop, report, suggest `--resume` |
| Goal gate unsatisfied at End | Jump to retry_target or report FAIL |
| Inline step on_fail = "continue" | Log warning and proceed |
| Inline step on_fail = "outcome=fail" | Set outcome=fail, stop node, report |
