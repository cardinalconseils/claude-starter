---
description: "Chief of staff — triage inbound work, cap it at three priorities, dispatch specialists, and report one brief"
argument-hint: "[inbound items or question] [--routine <path>]"
allowed-tools:
  - Read
  - Skill
---

# /cks:chief — Chief of Staff

Load the **chief-of-staff** brain into this session. It decides what deserves attention
and who does it — it never does the work itself. Use it at session start, when work is
piling up, or when it is unclear what to do next.

## Argument Parsing

| Input | What happens |
|---|---|
| `/cks:chief` | Triage everything readable — git state, PRD state, learnings, open PRs, memory |
| `/cks:chief "3 client asks + a stalled PR"` | Triage those items alongside the project's real state |
| `/cks:chief "should I take the Q3 retainer?"` | Answers as an ESCALATE with a recommendation attached |
| `/cks:chief "how does the sprint phase work?"` | A question is Converse — answered directly, nothing dispatched |
| `/cks:chief --routine .routines/<slug>/ROUTINE.md` | Routine mode — the profile goal is the only inbound item |

## Dispatch

This is an Orchestrator Exception command (`.claude/rules/commands.md`): the brain must
dispatch agents, and only the top-level session can, so it loads as a skill rather than
running as a sub-agent.

```
Skill(skill="cks:chief-of-staff")
```

Inbound from the founder: `$ARGUMENTS` (if empty, triage whatever project state is
readable). The skill's `SKILL-ORCHESTRATOR.md` runs the loop: read state, classify
intent, triage, open issues, dispatch at most three specialists, brief, and persist
`REMEMBER` through `cks:memory-agent`.

## Quick Reference

Triages inbound work into ACT / DEFER / DROP / ESCALATE, dispatches at most three
specialists in parallel, and returns a single scannable brief. Gated actions —
production deploys, external comms, sending mail or invoices, pricing changes, cron and
Routine changes, file removal — are routed to you for approval, never triggered.

## Other Ways to Reach It

- **Whole session** — `claude --agent cks:chief-of-staff` makes it the main agent; the
  thin `agents/chief-of-staff.md` wrapper loads this same skill
- **Channel** — a Hermes session's `CLAUDE.md` block loads it for every inbound message
  (`skills/chief-of-staff/workflows/channel-mode.md`)
- **User-level** — copy `agents/chief-of-staff.md` into `~/.claude/agents/` to reach it
  from every project without installing the plugin

## Related Commands

- `/cks:standup` — Morning recap of DEVLOG + session context (what happened)
- `/cks:chief` — What deserves attention now (what to do about it)
