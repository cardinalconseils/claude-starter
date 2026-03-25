---
description: "Model scoring + stack recommendation"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, TodoWrite]
---

# /monetize:evaluate

<objective>Run evaluation phase only — score models and build monetization stack.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/evaluate.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/references/models-catalog.md
</execution_context>

<process>Pre-filter models, score viable ones, build stack. Save to `.monetize/evaluation.md`.</process>
