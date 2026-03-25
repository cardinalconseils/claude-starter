---
description: "Discovery + context gathering phase"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, Agent, AskUserQuestion, TodoWrite]
---

# /monetize:discover

<objective>Run discovery phase only — scan codebase and gather business context.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/discover.md
</execution_context>

<process>Execute the discover workflow. Save context to `.monetize/context.md`.</process>
