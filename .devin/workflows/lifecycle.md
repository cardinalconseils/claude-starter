---
description: "Run the full 5-phase lifecycle autonomously — discover through release"
---

# Full Lifecycle Workflow

## Purpose
Run all 5 phases in sequence with minimal user intervention.

## Steps

1. **Initialize:** Read or create `.phases/PRD-STATE.json`.

2. **Phase 1 — Discover:** Run the discover workflow.
   - Gather all 11 elements
   - Generate CONTEXT.md
   - Ask user to confirm before advancing

3. **Phase 2 — Design:** Run the design workflow.
   - Create UX flows, screens, components
   - Generate DESIGN.md
   - Ask user to confirm before advancing

4. **Phase 3 — Sprint:** Run the sprint workflow.
   - Plan → Implement → Verify
   - Convergence loop (max 3 iterations)
   - Generate PLAN.md, SUMMARY.md, VERIFICATION.md
   - Create PR
   - Ask user to confirm before advancing

5. **Phase 4 — Review:** Run the review workflow.
   - Sprint review + retrospective
   - Iteration decision
   - If iterate → loop back to appropriate phase (max 1 iteration)
   - If release → continue
   - Generate REVIEW.md

6. **Phase 5 — Release:** Run the release workflow.
   - Dev → Staging → RC → Production
   - Quality gates at each stage
   - Require explicit confirmation for production
   - Generate RELEASE.md

7. **Final report:**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    LIFECYCLE COMPLETE
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Feature: {feature_id} — {feature_name}
    Phases: 5/5 ✅
    PR: #{number}
    Production: {url}
    discover ✅ → design ✅ → sprint ✅ → review ✅ → release ✅
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

## Rules
- Ask for confirmation at each phase transition
- Max 1 iteration in autonomous mode
- Never skip quality gates
- Stop on critical failures
- State file is source of truth
- Always update state after each phase
