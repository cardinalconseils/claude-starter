---
description: "SkillOpt-Sleep — nightly skill training loop that harvests session telemetry, replays tasks, gates improvements, and stages validated proposals for user review"
argument-hint: "[--skill=<name>] [--spike] [--status] [--adopt] [--enable] [--disable]"
allowed-tools:
  - Read
  - Skill
  - AskUserQuestion
---

# /cks:sleep — Nightly Skill Training Loop

Runs SkillOpt-Sleep against CKS skill files: harvest telemetry → replay offline → gate
against held-out tasks → stage proposals for review. Nothing touches `skills/*/SKILL.md`
without user approval.

## Dispatch

```
ARGS="${ARGUMENTS:-}"

If ARGS is empty:
  AskUserQuestion:
    question: "What do you want to do with the sleep cycle?"
    header: "Action"
    options:
      - "Run cycle (Recommended)" — next queued cycle; requires .cks/sleep-enabled
      - "Spike mode" — test lift on prd/retrospective/evals, no staging
      - "Review staged proposals" — adopt or discard pending proposals in .sleep/staged/
      - "Enable / check status" — enable sleep, register the nightly trigger, or show results

Skill(skill="cks:sleep-cycle")
```

Arguments: `$ARGS`. This is an Orchestrator Exception command (`.claude/rules/commands.md`):
the gate dispatches `cks:tester` and enable dispatches `cks:operator`, so the cycle runs
as a top-level skill. Its `SKILL-ORCHESTRATOR.md` owns the opt-in guard, the consent
block, and every mode.

## Quick Reference

```
/cks:sleep                         — run next queued cycle (requires .cks/sleep-enabled)
/cks:sleep --skill=prd             — target single skill by name
/cks:sleep --spike                 — spike mode: 3 skills, report lift, no staging
/cks:sleep --status                — last cycle results + staged proposals + queue depth
/cks:sleep --adopt                 — review staged proposals (Decision Required per proposal)
/cks:sleep --enable                — create .cks/sleep-enabled, register nightly trigger
/cks:sleep --disable               — remove .cks/sleep-enabled, deregister trigger
```

## What It Produces

`.sleep/staged/{skill-name}-{date}.md` — staged proposal diff for user review.
`.sleep/results/{date}.json` — gate scores per skill (pre/post lift delta).
`.concept/skillopt-integration/spike-results.md` — spike mode lift report.

Adoption is always gated by a `❓ DECISION REQUIRED` block — proposals never auto-apply.
