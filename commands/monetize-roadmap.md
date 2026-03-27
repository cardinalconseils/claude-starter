---
description: "Generate monetization roadmap + PRD handoff"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - Skill
  - TodoWrite
---

# /monetize:roadmap

<objective>Create PRD-ready phase briefs, update roadmap, and hand off to /cks:new.</objective>

<execution_context>
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/SKILL.md
@${CLAUDE_PLUGIN_ROOT}/skills/monetize/workflows/roadmap.md
</execution_context>

<process>
1. Validate `docs/monetization-assessment.md` + `.monetize/evaluation.md` exist
2. Read evaluation stack details — phased timeline, revenue milestones, prerequisites
3. Create phase briefs at `.monetize/phases/phase-{N}-{slug}.md`
4. Update `docs/ROADMAP.md` with monetization phases
5. Display final summary with handoff to `/cks:new`
</process>
