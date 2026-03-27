---
description: "Discovery + context gathering phase"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - TodoWrite
---

# /monetize:discover

<objective>Run discovery phase — scan codebase and gather business context via the monetize-discoverer agent.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/discover.md
</execution_context>

<process>
1. Determine mode (A: self-analyze, B: target path, C: business description) from `$ARGUMENTS`
2. Dispatch `monetize-discoverer` agent with mode and any target path or description
3. Agent scans codebase (modes A/B), asks interactive questions, saves `.monetize/context.md`
4. Validate `.monetize/context.md` was produced
5. Display: "Discovery complete. Context saved. Run `/monetize:research` next."
</process>
