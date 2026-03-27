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

1. Extract technology keywords from the feature brief or phase description
2. For each technology, check if `.context/<slug>.md` already exists
3. If not, run context research:

```
Skill(skill="context", args="\"${technology}\"")
```

**Skip this step if:**
- No technologies are mentioned in the brief
- `.context/config.md` has `auto-research: false`
- All identified technologies already have context briefs

## Success Condition

- All mentioned technologies have `.context/` briefs (or step was skipped)

## On Failure

- If context research fails for a technology: log and continue (non-blocking)
