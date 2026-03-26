---
description: "Upgrade existing CKS projects from 6-step to 5-phase lifecycle — non-destructive, preserves all artifacts"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# /cks:upgrade — Upgrade to 5-Phase Lifecycle

Upgrades an existing CKS project from the old 6-step workflow (discuss → plan → execute → verify → ship → retro) to the new 5-phase lifecycle (discover → design → sprint → review → release).

**Non-destructive.** No artifacts are deleted. Only STATE.md is updated and missing Phase 2/4 markers are added.

## Step 1: Assess Current State

Read existing state:

```
Read .prd/PRD-STATE.md
Read .prd/PRD-ROADMAP.md
```

If no `.prd/` → "Nothing to upgrade. Run `/cks:new` to start fresh with the 5-phase lifecycle."

Scan all phase directories:

```bash
for dir in .prd/phases/*/; do
  phase=$(basename "$dir")
  echo "=== $phase ==="
  ls "$dir" 2>/dev/null
done
```

Report findings:

```
CKS Upgrade Assessment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current workflow: 6-step (discuss → plan → execute → verify → ship)
Target workflow:  5-phase (discover → design → sprint → review → release)

Phases found: {N}
  Phase 01: {name} — has: CONTEXT ✓ PLAN ✓ SUMMARY ✓ VERIFICATION ✓
  Phase 02: {name} — has: CONTEXT ✓ PLAN ✓
  Phase 03: {name} — has: CONTEXT ✓

STATE.md status: {old status}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Step 2: Confirm Upgrade

```
AskUserQuestion({
  questions: [{
    question: "Ready to upgrade to the 5-phase lifecycle?",
    header: "Upgrade Confirmation",
    multiSelect: false,
    options: [
      { label: "Upgrade (Recommended)", description: "Map old statuses to new, add Phase 2/4 markers, preserve all artifacts" },
      { label: "Preview only", description: "Show what would change without modifying anything" },
      { label: "Cancel", description: "Keep the old workflow" }
    ]
  }]
})
```

## Step 3: Map Phase Statuses

For each phase directory, determine current status from artifacts on disk and map to new status:

### Status Mapping

| Old Artifacts | Old Status | New Status | Reason |
|---|---|---|---|
| Empty directory | `not_started` | `not_started` | No change |
| CONTEXT only | `discussed` | `discovered` | Phase 1 done |
| CONTEXT + PLAN | `planned` | `designed` | Phase 1 done, Phase 2 skipped (design didn't exist), treat as ready for sprint |
| CONTEXT + PLAN + SUMMARY | `executed` | `sprinted` | Phase 3 done (implementation complete) |
| CONTEXT + PLAN + SUMMARY + VERIFICATION (PASS) | `verified` | `sprinted` | QA is now inside sprint — treated as sprint complete |
| CONTEXT + PLAN + SUMMARY + VERIFICATION (FAIL) | `verification_failed` | `sprinting` | Needs re-sprint |
| Status = `shipped` | `shipped` | `released` | Direct mapping |

### Phase 2 (Design) Handling

For completed phases that never had a Design phase:

Create a minimal `{NN}-DESIGN.md` marker:

```markdown
# {NN}-DESIGN.md — Design Summary

> Phase 2: Design — SKIPPED (pre-5-phase lifecycle)
> Upgraded: {today}

## Status

This phase was completed before the 5-phase lifecycle was introduced.
Design was not a separate phase in the original workflow.
No design artifacts exist — implementation was based directly on discovery.

## Retroactive Notes

{If the phase has UI components, note that no formal design specs exist.
Future iterations of this feature should include Phase 2: Design.}
```

### Phase 4 (Review) Handling

For shipped phases that never had a Review phase:

Create a minimal `{NN}-REVIEW.md` marker:

```markdown
# {NN}-REVIEW.md — Sprint Review & Retrospective

> Phase 4: Review — SKIPPED (pre-5-phase lifecycle)
> Upgraded: {today}

## Status

This phase was shipped before the 5-phase lifecycle was introduced.
No formal sprint review or retrospective was conducted.

## Iteration Decision

Decision: Release (retroactive — feature was already shipped)
```

## Step 4: Update STATE.md

Map the current status to the new status system:

```yaml
# Old format preserved in notes, new status applied
active_phase: {NN}
phase_name: {name}
phase_status: {new mapped status}
last_action: "Upgraded to 5-phase lifecycle"
last_action_date: {today}
next_action: {derived from new status}
```

Add new fields that didn't exist before:

```yaml
iteration_count: 1
iteration_reason: "N/A"
```

## Step 5: Update ROADMAP.md

For each phase entry in ROADMAP.md, update the status label:

| Old Label | New Label |
|---|---|
| "Discussed" | "Discovered" |
| "Planned" | "Designed (Design skipped)" |
| "Executed" | "Sprinted" |
| "Verified" | "Sprinted" |
| "Complete" | "Released" |
| "Shipped" | "Released" |

## Step 6: Report

```
CKS Upgrade Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Upgraded: {N} phases

Phase Status Changes:
  Phase 01: {name} — shipped → released
  Phase 02: {name} — verified → sprinted
  Phase 03: {name} — discussed → discovered

Markers Added:
  Phase 01: {NN}-DESIGN.md (skipped), {NN}-REVIEW.md (skipped)
  Phase 02: {NN}-DESIGN.md (skipped), {NN}-REVIEW.md (skipped)

STATE.md: updated to 5-phase format
ROADMAP.md: updated labels

No artifacts were deleted or modified (only new markers added).

Next steps:
  /cks:progress    → see your project in the new 5-phase view
  /cks:next        → continue where you left off
  /cks:new "brief" → start a new feature with the full 5-phase cycle
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

1. **Never delete existing artifacts** — only add new markers
2. **Never modify CONTEXT.md, PLAN.md, SUMMARY.md, VERIFICATION.md** — they're historical records
3. **STATE.md is the only file that gets its content changed** — status mapping
4. **ROADMAP.md labels get updated** — cosmetic, not structural
5. **Design/Review markers are clearly labeled as "SKIPPED"** — no fake artifacts
6. **AskUserQuestion for confirmation** — never auto-upgrade
7. **Idempotent** — safe to run multiple times (skips already-upgraded phases)
