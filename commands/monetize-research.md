---
description: "Perplexity API market research phase"
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

# /monetize:research

<objective>Run market research phase — dispatch monetize-researcher agent for competitor pricing, market sizing, and benchmarks.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/research.md
</execution_context>

<process>
1. Validate `.monetize/context.md` exists (run discover first if missing)
2. Dispatch `monetize-researcher` agent — queries Perplexity API or WebSearch for market intelligence
3. Agent saves findings to `.monetize/research.md`
4. Validate `.monetize/research.md` was produced
5. Display: "Research complete. Run `/monetize:cost-analysis` next."
</process>
