---
description: "Chief of staff — triage inbound work, cap it at three priorities, dispatch specialists, and report one brief"
argument-hint: "[inbound items or question]"
allowed-tools:
  - Read
  - Agent
---

# /cks:chief — Chief of Staff

Dispatch the **chief-of-staff** agent. It decides what deserves attention and who does
it — it never does the work itself. Use it at session start, when work is piling up, or
when it is unclear what to do next.

## Argument Parsing

| Input | What happens |
|---|---|
| `/cks:chief` | Triage everything readable — git state, PRD state, learnings, open PRs, memory |
| `/cks:chief "3 client asks + a stalled PR"` | Triage those items alongside the project's real state |
| `/cks:chief "should I take the Q3 retainer?"` | Answers as an ESCALATE with a recommendation attached |

## Dispatch

```
Agent(subagent_type="cks:chief-of-staff", prompt="Run the full chief-of-staff loop: triage, dispatch, protect, report. Inbound from the founder: $ARGUMENTS (if empty, triage whatever project state you can read). Establish real state before judging anything — never triage from memory or assertion. Default to DROP. Enforce the three-priority cap. Return one brief in your output format, and emit a REMEMBER block for anything that would change a future decision.")
```

The agent has no `Write` and no `Edit` by design. If its brief contains a REMEMBER
block, persist those items yourself — the agent cannot.

## Quick Reference

Triages inbound work into ACT / DEFER / DROP / ESCALATE, dispatches at most three
specialists in parallel, and returns a single scannable brief. Gated actions —
production deploys, external comms, pricing changes, cron edits, file removal — are
routed to you for approval, never triggered by the agent.

## Other Ways to Reach It

- **@-mention** — `@"chief-of-staff (agent)"` guarantees this specific agent runs
- **Whole session** — `claude --agent cks:chief-of-staff` makes it the main agent
- **User-level** — copy `agents/chief-of-staff.md` into `~/.claude/agents/` to reach it
  from every project without installing the plugin

## Related Commands

- `/cks:standup` — Morning recap of DEVLOG + session context (what happened)
- `/cks:chief` — What deserves attention now (what to do about it)
- `/cks:concierge` — Maps one natural-language intent to the right CKS workflow
