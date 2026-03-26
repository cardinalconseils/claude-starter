---
description: "Run all 5 phases autonomously — discover → design → sprint → review → release. No interruption."
argument-hint: "[--from N] [--skip-design] [--skip-review]"
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
  - Skill
  - AskUserQuestion
  - TodoRead
  - TodoWrite
  - "mcp__*"
---

# /cks:autonomous — Full Autonomous 5-Phase Cycle

<objective>
Execute all remaining phases autonomously. For each incomplete feature: discover → design → sprint → review → release. Pauses only for true blockers. The iteration loop in Phase 4 auto-decides based on verification results.
</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/autonomous.md
</execution_context>

<process>
Execute the autonomous workflow from `${CLAUDE_PLUGIN_ROOT}/skills/prd/workflows/autonomous.md` end-to-end.

Runs through all 5 phases per feature:
1. Discover (autonomous — infer from codebase, no questions)
2. Design (autonomous — generate screens, auto-approve)
3. Sprint (plan → implement → review → QA → merge)
4. Review (auto-decide: if all criteria pass → release, else → iterate once)
5. Release (Dev → Staging → RC → Production)

Preserves all quality gates and progress display.
</process>

## Argument Handling

- No args: Run all remaining phases with full cycle
- `--from N`: Start from phase N (skip earlier phases)
- `--skip-design`: Skip Phase 2 (for backend-only features)
- `--skip-review`: Skip Phase 4 (auto-advance to release after sprint)
