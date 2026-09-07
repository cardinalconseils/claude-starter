---
description: "Executive assistant — inbox triage, calendar review, reply drafts, meeting prep. Drafts only; nothing is sent. Dispatches the assistant role."
argument-hint: "[inbox | calendar | draft <thread or person> | prep <meeting>] [context]"
allowed-tools: [Read, Agent]
---

# /cks:assistant — Executive Assistant

Parse `$ARGUMENTS`: the first word is the mode (`inbox`, `calendar`, `draft`, `prep`);
the rest is context (a thread subject, a person, a meeting, a window like "this week").
No args → `inbox`.

```
Agent(subagent_type="cks:assistant", prompt="
  Mode: {mode}
  Context: {rest of arguments, or none}
  User: CKS_ACTIVE_USER (default local)
  Read skills/executive-assistant/SKILL.md and the workflow for this mode.
  Brain 1 tools first when present, Gmail / Google Calendar MCP second; name which were available.
  Every outbound item is a draft plus a GATED: line — send nothing.
")
```

## Quick Reference

```
/cks:assistant                       Inbox triage since last run — A/B/C tiers, drafts for A and B
/cks:assistant inbox this week       Wider window
/cks:assistant calendar              Conflicts, focus blocks, prep and travel holds, briefs due
/cks:assistant draft "Re: SOW v2"    One reply draft in the owner's voice
/cks:assistant prep "Acme kickoff"   Meeting brief: them, us, the one decision, risks
```

Reminders: `/cks:remind`. Morning brief: `/cks:standup`. State lives under the user's
guarded directory (`$CKS_HQ/users/<slug>/` or `~/.cks/user/<slug>/`).
