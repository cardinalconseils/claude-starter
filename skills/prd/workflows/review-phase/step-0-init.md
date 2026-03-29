# Step 0: Initialize Review

<context>
Phase: Review (Phase 4)
Requires: Sprint completed (phase_status = "sprinted")
Produces: Phase mode set, progress banner displayed
</context>

## Load Phase Mode

Read `.prd/prd-config.json` — extract `phases.review.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps as written. Use AskUserQuestion for all decisions.
- `auto` → Execute all steps without pausing. Select recommended options for review decisions.
- `gated` → Execute steps like auto, but after the final step, pause and ask: "Review complete. Proceed to release, iterate, or stop? (Release / Iterate / Stop)"

## Display Progress Banner

Display the progress banner from `_shared.md`.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.review.started" "{NN}-{name}" "Review phase started"`
