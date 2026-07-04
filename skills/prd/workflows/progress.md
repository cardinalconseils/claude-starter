# Workflow: Progress (5-Phase Dashboard)

## Overview
Scans `.prd/phases/` directories to derive **live status from artifacts on disk**. Displays 5-phase progress per feature. PRD-STATE.md is secondary — the filesystem is the source of truth.

## Steps

### Step 1: Scan Phase Directories

For each directory in `.prd/phases/`:

```bash
for dir in .prd/phases/*/; do
  phase=$(basename "$dir")
  nn=$(echo "$phase" | grep -oE '^[0-9]+')
  has_context=$(ls "$dir"*-CONTEXT.md 2>/dev/null | wc -l)
  has_design=$(ls "$dir"*-DESIGN.md 2>/dev/null | wc -l)
  has_plan=$(ls "$dir"*-PLAN.md 2>/dev/null | wc -l)
  has_summary=$(ls "$dir"*-SUMMARY.md 2>/dev/null | wc -l)
  has_verification=$(ls "$dir"*-VERIFICATION.md 2>/dev/null | wc -l)
  has_review=$(ls "$dir"*-REVIEW.md 2>/dev/null | wc -l)
  has_release=$(ls "$dir"*-RELEASE.md 2>/dev/null | wc -l)
  has_design_dir=$(ls -d "$dir"design/ 2>/dev/null | wc -l)
done
```

### Step 2: Derive Status Per Phase

| Artifacts on Disk | Derived Status | Phase | Icon |
|---|---|---|---|
| Empty folder | Not started | — | `[ ]` |
| CONTEXT only | Discovered | Phase 1 done | `[1]` |
| CONTEXT + DESIGN | Designed | Phase 2 done | `[2]` |
| CONTEXT + DESIGN + PLAN + SUMMARY | Sprinted | Phase 3 done | `[3]` |
| + VERIFICATION with PASS | QA Passed | Phase 3 done | `[3]` |
| + REVIEW | Reviewed | Phase 4 done | `[4]` |
| + RELEASE | Released | Phase 5 done | `[✓]` |
| phase_status = "iterating_*" | Iterating | Loop | `[↻]` |
| VERIFICATION with FAIL | Failed | Phase 3 issue | `[✗]` |

### Step 3: Group by PRD

Read `.prd/PRD-ROADMAP.md` to determine which phases belong to which PRD. Display them grouped.

### Step 4: Find Active Phase

The active phase is the **first incomplete phase** (lowest number without "released" status). Don't trust STATE.md — derive it.

### Step 5: Display Dashboard

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► PROGRESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 PRD-001: User Authentication              ✓ RELEASED
   [✓] 01 Login & Registration
   [✓] 02 OAuth Integration

 PRD-002: Invoice Builder                  ► ACTIVE
   [✓] 03 Invoice Template Engine
   [3]  04 PDF Export                       ← SPRINTING
        discover ✅ design ✅ sprint ▶ review ○ release ○
   [ ] 05 Email Delivery

 PRD-003: Dashboard Analytics              ○ PLANNED
   [ ] 06 Metrics Collection
   [ ] 07 Charts & Visualization

 Progress: 3/7 phases (43%) | 1/3 features released
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 6: Sync STATE.md

If the derived active phase differs from PRD-STATE.md, **update PRD-STATE.md** to match reality.

### Step 7: Suggest Next Action

Use `AskUserQuestion` to present what to do:

```
AskUserQuestion({
  questions: [{
    question: "Phase {NN} — {name}. Currently: {status}. What would you like to do?",
    header: "Next Action",
    multiSelect: false,
    options: [
      // Options depend on current phase in the 5-phase cycle:
      // Not started: Discover (Recommended)
      // Discovered: Design (Recommended), Re-discover
      // Designed: Sprint (Recommended), Re-design
      // Sprinted: Review (Recommended), Re-sprint
      // Reviewed: Release (Recommended), Iterate
      // Iterating: Continue iteration (Recommended), Skip to Release
      // Released: Next feature
    ]
  }]
})
```

Route based on selection to the appropriate `/cks:{command}`.
