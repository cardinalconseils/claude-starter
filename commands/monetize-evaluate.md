---
description: "Evidence-based tier evaluation + stack recommendation with assumption chains"
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

<objective>Run evaluation phase — dispatch monetize-evaluator agent to evaluate models using evidence-based tiers (Strong/Possible/Weak), build monetization stack with assumption chains and compliance gating.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/evaluate.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/references/models-catalog.md
</execution_context>

<process>
1. Validate prerequisites: `.monetize/context.md` + `.monetize/research.md` must exist
2. Check `.monetize/cost-analysis.md` — warn if missing (projections will be gross-only)
3. Dispatch `monetize-evaluator` agent — evaluates models with evidence-based tiers, builds stack with assumption chains and compliance checks
4. Agent saves to `.monetize/evaluation.md`
5. Validate `.monetize/evaluation.md` was produced
6. Display: "Evaluation complete. Run `/monetize:report` next."
</process>
