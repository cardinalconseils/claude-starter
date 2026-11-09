---
description: "Show project status dashboard — current phase, artifacts, next action"
---

# Status Workflow

## Purpose
Display the current project state and suggest next action.

## Steps

1. **Read state:** Load `.phases/PRD-STATE.json`.

2. **If no state file exists:** Report "No active feature. Run /new-feature to start."

3. **Check artifacts:** For each artifact in state, check if the file exists:
   - `.phases/{feature_id}/CONTEXT.md` → discover complete
   - `.phases/{feature_id}/DESIGN.md` → design complete
   - `.phases/{feature_id}/PLAN.md` → sprint planning complete
   - `.phases/{feature_id}/SUMMARY.md` → sprint implementation complete
   - `.phases/{feature_id}/VERIFICATION.md` → sprint verification complete
   - `.phases/{feature_id}/REVIEW.md` → review complete
   - `.phases/{feature_id}/RELEASE.md` → release complete

4. **Display dashboard:**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    FEATURE: {feature_id} — {feature_name}
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    [1] Discover    {✅ done | ▶ current | ○ pending}
    [2] Design      {✅ done | ▶ current | ○ pending}
    [3] Sprint      {✅ done | ▶ current | ○ pending}
    [4] Review      {✅ done | ▶ current | ○ pending}
    [5] Release     {✅ done | ▶ current | ○ pending}

    Iterations: {count}/{max}

    Last Action: {last_action}
    Next Action: {next_action}
    Command: {suggested_command}
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

5. **Suggest next action:** Based on current phase and status, suggest the appropriate workflow command.
