# Step 2: Auto-Research Technologies

<context>
Phase: Discover (Phase 1)
Requires: {NN} and {name} determined, feature brief available
Produces: .context/{slug}.md files for referenced technologies
</context>

## Inputs

- Read: Feature brief (from arguments or phase description)
- Read: `.context/config.md` (if exists — check for `auto-research: false`)
- Scan: `.context/*.md` for existing context briefs

## Instructions

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.2.started" "{NN}-{name}" "Step 2: Auto-research technologies"`

1. Extract technology keywords from the feature brief or phase description
2. **Deduplicate** the keyword list (e.g., "React" and "react" → single entry "react")
3. For each unique technology, check if `.context/<slug>.md` already exists
4. If not, run context research (one at a time, not in parallel):

```
Skill(skill="context", args="\"${technology}\"")
```

**Skip this step if:**
- No technologies are mentioned in the brief
- `.context/config.md` has `auto-research: false`
- All identified technologies already have context briefs

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "step.2.completed" "{NN}-{name}" "Step 2: Technology research complete"`

## Success Condition

- All mentioned technologies have `.context/` briefs (or step was skipped)

## On Failure

- If context research fails for a technology: log and continue (non-blocking)
