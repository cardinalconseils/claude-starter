# Step 0: Initialize Review

<context>
Phase: Review (Phase 4)
Requires: Sprint completed (phase_status = "sprinted")
Produces: Phase mode set, progress banner displayed
</context>

## Inline Review Check

If `.prd/phases/{NN}-{name}/{NN}-REVIEW.md` already exists AND contains `Source: Inline sprint review`:
- Sprint already collected a verdict. Skip [4a] Sprint Review and go directly to [4b] Retrospective.
- This happens when the user ran `/cks:sprint` which includes an inline review at step 5.

## Load Phase Mode

Read `.prd/prd-config.json` — extract `phases.review.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps as written. Use AskUserQuestion for all decisions.
- `auto` → Execute all steps without pausing. Select recommended options for review decisions.
- `gated` → Execute steps like auto, but after the final step, pause and ask: "Review complete. Proceed to release, iterate, or stop? (Release / Iterate / Stop)"

## Load Model Strategy

Read `.prd/prd-config.json` — extract `models` section.
Read `${SKILL_ROOT}/references/model-strategy.md` — get tier map and defaults.
For each `Agent()` dispatch in this phase:
1. Check `models.overrides` for the specific agent name — if found, use that model
2. Otherwise look up the agent's tier in the reference, use `models.default[tier]`
3. If no `models` section → fall back to agent frontmatter `model:`
Pass `model="{resolved}"` to every `Agent()` call.

## Display Progress Banner

Display the progress banner from `_shared.md`.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.review.started" "{NN}-{name}" "Review phase started"`
