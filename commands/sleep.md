---
description: "SkillOpt-Sleep — nightly skill training loop that harvests session telemetry, replays tasks, gates improvements, and stages validated proposals for user review"
argument-hint: "[--skill=<name>] [--spike] [--status] [--adopt] [--enable] [--disable]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:sleep — Nightly Skill Training Loop

Runs SkillOpt-Sleep against CKS skill files: harvest telemetry → replay offline → gate against held-out tasks → stage proposals for review. Nothing touches `skills/*/SKILL.md` without user approval.

## Dispatch

```
ARGS="${ARGUMENTS:-}"

If ARGS is empty:
  AskUserQuestion:
    question: "What do you want to do with the sleep cycle?"
    header: "Action"
    options:
      - label: "Run cycle (Recommended)"
        description: "Run next queued sleep cycle — requires .cks/sleep-enabled flag"
      - label: "Spike mode"
        description: "Test SkillOpt lift on prd/retrospective/evals skills — no staging"
      - label: "Review staged proposals"
        description: "Inspect and adopt (or discard) pending skill proposals in .sleep/staged/"
      - label: "Enable / check status"
        description: "Enable sleep, register nightly scheduler, or check last cycle results"

Agent(
  subagent_type="cks:sleep-runner",
  prompt="$ARGS",
  isolation="worktree"
)
```

## Quick Reference

```
/cks:sleep                         — run next queued cycle (requires .cks/sleep-enabled)
/cks:sleep --skill=prd             — target single skill by name
/cks:sleep --spike                 — spike mode: 3 skills, report lift, no staging
/cks:sleep --status                — last cycle results + staged proposals + queue depth
/cks:sleep --adopt                 — review staged proposals (Decision Required per proposal)
/cks:sleep --enable                — create .cks/sleep-enabled, register nightly scheduler
/cks:sleep --disable               — remove .cks/sleep-enabled, deregister scheduler
```

## What It Produces

`.sleep/staged/{skill-name}-{date}.md` — staged proposal diff for user review.
`.sleep/results/{date}.json` — gate scores per skill (pre/post lift delta).
`.concept/skillopt-integration/spike-results.md` — spike mode lift report.

Adoption is always gated by a `❓ DECISION REQUIRED` block — proposals never auto-apply.
