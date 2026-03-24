# Workflow: Progress

## Overview
Scans `.prd/phases/` directories to derive **live status from artifacts on disk**. PRD-STATE.md is secondary — the filesystem is the source of truth. If STATE.md disagrees with what's on disk, update STATE.md to match.

## Steps

### Step 1: Scan Phase Directories

For each directory in `.prd/phases/`:

```bash
for dir in .prd/phases/*/; do
  phase=$(basename "$dir")
  nn=$(echo "$phase" | grep -oE '^[0-9]+')
  # Check which artifacts exist
  has_context=$(ls "$dir"*-CONTEXT.md 2>/dev/null | wc -l)
  has_plan=$(ls "$dir"*-PLAN.md 2>/dev/null | wc -l)
  has_summary=$(ls "$dir"*-SUMMARY.md 2>/dev/null | wc -l)
  has_verification=$(ls "$dir"*-VERIFICATION.md 2>/dev/null | wc -l)
done
```

### Step 2: Derive Status Per Phase

| Artifacts on Disk | Derived Status | Icon |
|---|---|---|
| Empty folder | Not started | `[ ]` |
| CONTEXT only | Discussed | `[~]` |
| CONTEXT + PLAN | Planned | `[P]` |
| CONTEXT + PLAN + SUMMARY | Executed | `[E]` |
| VERIFICATION with "PASS" | Complete | `[✓]` |
| VERIFICATION with "FAIL" | Failed | `[✗]` |

If a VERIFICATION file exists, grep for "PASS" or "FAIL" verdict.

### Step 3: Group by PRD

Read `.prd/PRD-ROADMAP.md` to determine which phases belong to which PRD. Display them grouped.

### Step 4: Find Active Phase

The active phase is the **first incomplete phase** (lowest number without a passing VERIFICATION). Don't trust STATE.md — derive it.

### Step 5: Display Dashboard

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► PROGRESS
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
   [►] 08 Icon Picker & Edge Labels            ← ACTIVE

 Progress: 7/8 phases (87%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 6: Sync STATE.md

If the derived active phase differs from PRD-STATE.md, **update PRD-STATE.md** to match reality.

### Step 7: Suggest Next Action

Use `AskUserQuestion` to present what to do:

```
AskUserQuestion({
  questions: [{
    question: "Phase {NN} — {name}. What would you like to do?",
    header: "Next",
    multiSelect: false,
    options: [
      // Options depend on phase status:
      // If not started: Discuss (Recommended), Skip
      // If discussed: Plan (Recommended), Re-discuss
      // If planned: Execute (Recommended), Re-plan
      // If executed: Verify (Recommended), Re-execute
      // If failed: Fix + Re-execute (Recommended), Skip, View failures
    ]
  }]
})
```

Route based on selection to the appropriate `/prd:{command}`.
