---
description: "Cost analysis — research tech stack costs, build unit economics, calculate margins"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - WebSearch
  - WebFetch
  - TodoWrite
  - "mcp__*"
---

# /monetize:cost-analysis

<objective>
Research real-world operational costs for the product's tech stack and build unit economics models.
Two-agent workflow: cost-researcher gathers pricing data, then cost-analyzer builds margin models.
</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/cost-analysis.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/references/cost-categories.md
</execution_context>

<process>
1. Validate prerequisites (.monetize/context.md exists)
2. Dispatch `cost-researcher` agent — gathers raw pricing data from provider websites
3. Validate .monetize/cost-research-raw.md was produced
4. Dispatch `cost-analyzer` agent — builds unit economics from raw data
5. Validate .monetize/cost-analysis.md was produced
6. Display summary
</process>
