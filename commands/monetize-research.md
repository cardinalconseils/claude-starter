---
description: "Perplexity API market research phase"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, Agent, TodoWrite]
---

# /monetize:research

<objective>Run research phase only — query Perplexity API for market intelligence.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/research.md
</execution_context>

<process>Validate prerequisites, execute Perplexity queries, save to `.monetize/research.md`.</process>
