---
description: "Create a new feature and start the 5-phase lifecycle"
---

# New Feature Workflow

## Purpose
Initialize a new feature and enter the discover phase.

## Steps

1. **Get feature name:** If not provided as argument, ask the user what feature they want to build.

2. **Initialize project state (if needed):**
   - Check if `.phases/PRD-STATE.json` exists
   - If not, create it:
     ```json
     {
       "feature_id": "F-01",
       "feature_name": "{feature_name}",
       "current_phase": "discover",
       "phase_status": "in_progress",
       "iteration_count": 0,
       "max_iterations": 3,
       "artifacts": {
         "context": null,
         "design": null,
         "plan": null,
         "summary": null,
         "verification": null,
         "review": null,
         "release": null
       },
       "last_action": "Feature created",
       "last_action_date": "{today}",
       "next_action": "Run discover workflow",
       "suggested_command": "/discover"
     }
     ```

3. **Create feature directory:** `mkdir -p .phases/F-01`

4. **Update state:** Set `current_phase` to "discover", `phase_status` to "in_progress".

5. **Enter discover phase:** Run the discover workflow.

## Rules
- Feature names should be kebab-case (lowercase, hyphens)
- Always start with discover phase
- Never skip to implementation
- State file is source of truth
