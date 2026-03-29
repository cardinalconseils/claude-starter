---
description: "Generate monetization assessment report with cost analysis"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - TodoWrite
---

# /monetize:report

<objective>Generate the full business case report — dispatch monetize-reporter agent to combine all artifacts into docs/monetization-assessment.md.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/report.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/references/report-template.md
</execution_context>

<process>
1. Validate `.monetize/evaluation.md` exists (run evaluate first if missing)
2. Dispatch `monetize-reporter` agent — combines context, research, cost analysis, and evaluation
3. Agent saves to `docs/monetization-assessment.md`
4. Validate report was produced
5. Display summary with recommended stack and projected net revenue
6. Display: "Report complete. Run `/monetize:roadmap` next."
</process>
