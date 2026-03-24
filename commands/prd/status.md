---
name: prd:status
description: Quick roadmap overview — what's done, what's next
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# /prd:status — Project Status Dashboard

## What This Does

Scans the actual `.prd/` directory to build a **live status** from artifacts on disk — not just what STATE.md claims. This is the ground truth.

## Steps

### Step 1: Scan Phase Directories

```bash
# List all phase folders
ls .prd/phases/

# For each phase, check which artifacts exist
for dir in .prd/phases/*/; do
  phase=$(basename "$dir")
  nn=$(echo "$phase" | grep -oE '^[0-9]+')
  has_context=$(ls "$dir"*-CONTEXT.md 2>/dev/null | wc -l)
  has_plan=$(ls "$dir"*-PLAN.md 2>/dev/null | wc -l)
  has_summary=$(ls "$dir"*-SUMMARY.md 2>/dev/null | wc -l)
  has_verification=$(ls "$dir"*-VERIFICATION.md 2>/dev/null | wc -l)
done
```

### Step 2: Determine Phase Status from Artifacts

For each phase, derive status from what files exist:

| Artifacts Present | Status |
|---|---|
| None | Not started |
| CONTEXT only | Discussed |
| CONTEXT + PLAN | Planned |
| CONTEXT + PLAN + SUMMARY | Executed |
| CONTEXT + PLAN + SUMMARY + VERIFICATION | Verified — check PASS/FAIL |
| VERIFICATION contains "PASS" | Complete |
| VERIFICATION contains "FAIL" | Failed verification |

### Step 3: Read Additional Context

- Read `.prd/PRD-STATE.md` for active phase and session history
- Read `.prd/PRD-ROADMAP.md` for PRD groupings (which phases belong to which PRD)
- Read `docs/prds/` for PRD names

### Step 4: Display Dashboard

Use `AskUserQuestion` to present the status with an action choice:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 PRD-001: Process Evaluator                    ✓ COMPLETE
   [✓] 01 Completeness Checker + Question Flow
   [✓] 02 Full Card Generator
   [✓] 03 Enriched Flow Chart Generation
   [✓] 04 Smart ChatBot Integration

 PRD-002: Interactive Flowchart Editor         ► ACTIVE
   [✓] 05 Interactive Canvas & Core Editing
   [✓] 06 Node Palette & New Node Types
   [✓] 07 Undo/Redo & Auto-Save
   [►] 08 Icon Picker & Edge Labels            ← YOU ARE HERE

 Progress: 7/8 phases complete (87%)
 Active: Phase 08 — Icon Picker & Edge Labels
 Status: {derived from artifacts}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then ask what to do next:

```
AskUserQuestion({
  questions: [{
    question: "What would you like to do with Phase 08?",
    header: "Next",
    multiSelect: false,
    options: [
      { label: "Execute phase (Recommended)", description: "Run /prd:execute 8 — implement Icon Picker & Edge Labels" },
      { label: "Discuss first", description: "Run /prd:discuss 8 — review/refine requirements before executing" },
      { label: "View phase details", description: "Show the CONTEXT and PLAN for Phase 08" },
      { label: "Nothing for now", description: "Just wanted to check status" }
    ]
  }]
})
```

### Step 5: Route Based on Choice

- **Execute** → `Skill(skill="prd:execute", args="8")`
- **Discuss** → `Skill(skill="prd:discuss", args="8")`
- **View details** → Read and display `08-CONTEXT.md` and `08-PLAN.md`
- **Nothing** → Done

## Key Principle

**Scan the filesystem, don't trust state files.** STATE.md can be stale. The artifacts on disk are the ground truth. If STATE.md disagrees with what's on disk, update STATE.md to match reality.
