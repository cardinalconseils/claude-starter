---
description: "Model scoring + stack recommendation (margin-aware)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - TodoWrite
---

# /monetize:evaluate

<objective>Run evaluation phase — dispatch monetize-evaluator agent to score models and build monetization stack with margin-aware projections.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/evaluate.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/references/models-catalog.md
</execution_context>

<process>
1. Validate prerequisites: `.monetize/context.md` + `.monetize/research.md` must exist
2. Check `.monetize/cost-analysis.md` — warn if missing (projections will be gross-only)
3. Dispatch `monetize-evaluator` agent — scores 12 models, builds stack, produces margin-aware projections
4. Agent saves to `.monetize/evaluation.md`
5. Validate `.monetize/evaluation.md` was produced
6. Display: "Evaluation complete. Run `/monetize:report` next."
</process>
