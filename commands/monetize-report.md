---
description: "Generate monetization assessment report"
allowed-tools: [Read, Write, Edit, Glob, TodoWrite]
---

# /monetize:report

<objective>Generate the full business case report from evaluation data.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/report.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/references/report-template.md
</execution_context>

<process>Load all artifacts, fill report template, save to `docs/monetization-assessment.md`.</process>
