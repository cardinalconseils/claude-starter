# Step 0: Initialize Sprint

<context>
Phase: Sprint (Phase 3)
Requires: PRD-STATE.md
Produces: Sprint mode detection, phase mode, progress banner
</context>

## Auto Mode Tip

```
💡 Sprint runs many operations. For uninterrupted execution, enable Auto mode (Shift+Tab → "auto")
```

## Detect Iteration Mode

Read `.prd/PRD-STATE.md`. Check `phase_status`:

- `designed` or `not_started` → **First Sprint** (iteration = 0)
- `iterating_sprint` → **Iteration Sprint** — read `iteration_count` from STATE.md
- `iterating_design` → Redirect: "Design iteration needed first. Run `/cks:design {NN}`."
- `iterating_discover` → Redirect: "Re-discovery needed first. Run `/cks:discover {NN}`."

**If Iteration Sprint:**
1. Read `iteration_count` from STATE.md (default to 1 if not set)
2. Read `.prd/phases/{NN}-{name}/{NN}-BACKLOG.md` — this is the iteration's work scope
3. Read `.prd/phases/{NN}-{name}/{NN}-REVIEW.md` — feedback that triggered this iteration
4. Set `{iteration}` = iteration_count for use in banners and artifact names

## Load Phase Mode

Read `.prd/prd-config.json` — extract `phases.sprint.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all sub-steps as written. Pause between major steps ([3a], [3c], [3d], [3e]).
- `auto` → Execute all sub-steps sequentially without pausing. Select recommended options automatically. This is the default for sprint — the plan was already approved in design.
- `gated` → Execute steps like auto, but after the final sub-step ([3f] UAT or merge), pause and ask: "Sprint complete. Review results and proceed to review? (Yes / Continue iterating)"

## Load Model Strategy

Read `.prd/prd-config.json` — extract `models` section.
Read `${SKILL_ROOT}/references/model-strategy.md` — get tier map, defaults, and **Sprint Sub-Step Model Map**.

Sprint uses mixed models per sub-step. For each `Agent()` dispatch:
1. Check `models.overrides` for the specific agent name — if found, use that model
2. Otherwise use the sub-step tier from the Sprint Sub-Step Model Map:
   - [3a] Planning → reason, [3b] Architecture → reason
   - [3c] Implementation → execute, [3c] Workers → bulk
   - [3c+] De-sloppify → execute
   - [3d] Code Review → reason
   - [3e] QA → execute, [3f] UAT → reason
   - [3g] Merge → execute, [3h] Docs → bulk
3. Resolve tier to model via `models.default[tier]`
4. If no `models` section → fall back to agent frontmatter `model:`

Pass `model="{resolved}"` to every `Agent()` call in this phase.

## Progress Banner

Display the appropriate banner from `_shared.md` (First Sprint or Iteration Sprint).
Set all sub-step statuses to `○ pending` initially.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.sprint.started" "{NN}-{name}" "Sprint phase started"`
