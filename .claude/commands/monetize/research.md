---
name: monetize:research
description: "Perplexity API market research phase"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, Agent, TodoWrite]
---

# /monetize:research

<objective>Run research phase only — query Perplexity API for market intelligence.</objective>

<execution_context>
@.claude/skills/monetize/SKILL.md
@.claude/skills/monetize/workflows/research.md
</execution_context>

<process>Validate prerequisites, execute Perplexity queries, save to `.monetize/research.md`.</process>
