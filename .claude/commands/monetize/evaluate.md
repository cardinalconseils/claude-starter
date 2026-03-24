---
name: monetize:evaluate
description: "Model scoring + stack recommendation"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, TodoWrite]
---

# /monetize:evaluate

<objective>Run evaluation phase only — score models and build monetization stack.</objective>

<execution_context>
@.claude/skills/monetize/SKILL.md
@.claude/skills/monetize/workflows/evaluate.md
@.claude/skills/monetize/references/models-catalog.md
</execution_context>

<process>Pre-filter models, score viable ones, build stack. Save to `.monetize/evaluation.md`.</process>
