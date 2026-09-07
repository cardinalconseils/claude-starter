---
description: "Run full monetization evaluation: discover → research → cost → evaluate → report → roadmap"
argument-hint: "[path | \"description\"] (optional)"
allowed-tools:
  - Read
  - Skill
---

# /cks:monetize

Run the full monetization evaluation, one v6 role per stage, with the artifact checked on
disk between stages.

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): the stages
dispatch roles in sequence, and only the top-level session can, so it loads as a skill
rather than running as a sub-agent.

```
Skill(skill="cks:monetize")
```

arguments: `$ARGUMENTS` — empty (Mode A, self-analyze), local path (Mode B), or quoted
description (Mode C). No `stage:` → full run; the skill's `SKILL-ORCHESTRATOR.md` handles
the re-run check (archive / update / cancel) and dispatches discover (`cks:strategist`),
research (`cks:researcher`), cost research (`cks:researcher`), cost analysis (`cks:finops`),
evaluate, report, roadmap (`cks:strategist`).

## Quick Reference

```
/cks:monetize                       # self-analyze the current project
/cks:monetize ../other-project      # analyze a local codebase
/cks:monetize "B2B invoicing SaaS"  # strategy from a description, no code scan
```

Single stages: `/cks:monetize-discover`, `-research`, `-cost-analysis`, `-evaluate`,
`-report`, `-roadmap` — each loads the same skill with a `stage:` argument.

Output: `.monetize/` artifacts, `docs/monetization-assessment.md`, `docs/ROADMAP.md`.
