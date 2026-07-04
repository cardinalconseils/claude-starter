# Step 6: Update State

<context>
Phase: Release (Phase 5)
Requires: Post-deploy complete ([5e])
Produces: {NN}-RELEASE.md, STATE.md, ROADMAP.md, PRD updated
</context>

## Instructions

**Write `{NN}-RELEASE.md` to the phase directory:**

```
.prd/phases/{NN}-{name}/{NN}-RELEASE.md
```

Minimal content:
```markdown
# Release — {NN} {name}

Released: {today}
Environment: production
```

This is the Phase 5 terminal artifact. The progress dashboard detects `*-RELEASE.md` on disk to show `[✓]` — write this file before updating STATE.md so the two stay in sync.

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
