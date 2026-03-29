# Step 6: Update State

<context>
Phase: Release (Phase 5)
Requires: Post-deploy complete ([5e])
Produces: STATE.md, ROADMAP.md, PRD updated
</context>

## Instructions

**Update PRD-STATE.md:**
```yaml
phase_status: released
last_action: "Released to production"
last_action_date: {today}
next_action: "Feature complete. Run /cks:new for next feature."
```

**Update PRD-ROADMAP.md:**
- Mark phase as "Released" with date
- Move feature to "Completed" section if all phases done

**Update PRD document:**
- Set status to "Complete"
- Add release notes
