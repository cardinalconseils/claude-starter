# Sub-step [3h]: Documentation Check

<context>
Phase: Sprint (Phase 3)
Requires: Code merged ([3g])
Produces: Updated API docs (if needed)
</context>

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3h.started" "{NN}-{name}" "Sprint: documentation check started"`

## Instructions

**Auto-detect if documentation needs updating.**

Check if the sprint touched API routes or architecture-affecting files:

```bash
# Check for API route changes in the files listed in SUMMARY.md
git diff --name-only HEAD~1 | grep -E "(api/|routes/|endpoints/|controllers/)" || true
```

If API routes were added or changed:
```
━━━ Doc Check ━━━
New or modified API endpoints detected.
Suggesting documentation update...
━━━━━━━━━━━━━━━━━
```

Run a quick doc refresh scoped to changed files:
```
Agent(subagent_type="cks:doc-generator", model="{resolved_model_bulk}", prompt={
  scope: "api",
  diff_only: true,
  project_root: {project_root}
})
```

If no API changes detected, check for architecture-level changes (new directories, new service layers, major refactors):
```bash
git diff --name-only HEAD~1 | grep -E "(src/lib/|src/services/|src/infrastructure/)" || true
```

If architecture changes found → suggest `/cks:docs arch` but don't auto-run.

If no documentation-relevant changes → skip silently.

```
  [3h] Documentation Check     ✅ {api docs updated | no doc changes needed}
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.3h.completed" "{NN}-{name}" "Sprint: documentation check complete"`
