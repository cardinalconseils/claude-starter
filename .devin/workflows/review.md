---
description: "Phase 4 — Review: Sprint review, retrospective, and iteration decision"
---

# Review Workflow

## Purpose
Review the work, capture learnings, and decide whether to iterate or release.

## Prerequisites
- Sprint phase complete (`.phases/{feature_id}/VERIFICATION.md` exists)

## Steps

1. **Read state:** Load `.phases/PRD-STATE.json`, `SUMMARY.md`, and `VERIFICATION.md`.

2. **Sprint review:**
   - Summarize what was built
   - Compare against acceptance criteria
   - Document any deviations from plan
   - Note any technical debt incurred

3. **Retrospective:**
   - What went well?
   - What didn't go well?
   - What can we improve next time?
   - Identify patterns (not just incidents)

4. **Backlog refinement:**
   - Add any discovered work items to backlog
   - Prioritize based on impact and urgency
   - Remove items that are no longer relevant

5. **Iteration decision:** Based on verification results and review:
   - If UX issues → back to design phase
   - If logic bugs → back to sprint phase
   - If requirements changed → back to discover phase
   - If ready to release → advance to release phase

   Ask the user to confirm the decision.

6. **Generate artifact:** Write review to `.phases/{feature_id}/REVIEW.md`.

7. **Update state and auto-advance:**
   - If releasing: Set `phase_status` to "complete", `current_phase` to "release", `next_action` to "Starting release phase automatically". Then automatically continue to the release workflow.
   - If iterating: Set `phase_status` to "iterating_{phase}", update `iteration_count`. Then automatically go back to the appropriate phase workflow.

## Rules
- Every finding must have evidence
- Focus on patterns, not blame
- Iteration decision must be evidence-based
- Always ask user to confirm iteration decision
- Document learnings for future features
- **Auto-advance to release (or back to appropriate phase) after decision** — don't make the user run the next command
- **Plain English only** — no jargon, no command names, no phase numbers
