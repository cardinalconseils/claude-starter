---
name: peers
description: >
  Session awareness and deconfliction via claude-peers-mcp. Shows what all
  Claude Code sessions in a repo are doing, auto-announces status via hooks,
  detects conflicts (two sessions on same feature), and enables directives
  (stop, redirect) from a main session. Use when: checking what other sessions
  are doing, detecting conflicts, sending directives, understanding peer status.
---

# Peer Awareness & Deconfliction

## Overview

Peers provide situational awareness between autonomous Claude Code sessions in the same repo. Each session auto-announces what it's doing via lifecycle hooks. A main session can view a dashboard and send directives when conflicts arise.

**Peers are NOT for task distribution.** Use Agent Teams / subagents for that. Peers are the stand-up channel — each session is a team lead running its own work.

## How It Works

1. **Auto-announce**: Lifecycle hooks call the broker's `/set-summary` endpoint on session start, phase transitions, and session close
2. **Dashboard**: `/cks:peers` shows all repo sessions, their activity, and doc links
3. **Directives**: Main session can tell a worker to stop, redirect, or reprioritize
4. **Channel push**: Directives arrive automatically — no manual polling needed

## Summary Format

Auto-summaries follow a parseable format:
```
[{activity}] {context} — {status} | Doc: {doc_path}
```

Activity codes cover ALL session types:
- `[kickstart:step]` — project enabler flow
- `[ideate]` — brainstorming
- `[discover]` — Phase 1 requirements
- `[design]` — Phase 2 UX/API
- `[sprint:3x]` — Phase 3 sub-steps (3a planning, 3c implementing, 3d review, etc.)
- `[review]` — Phase 4 feedback
- `[release]` — Phase 5 deployment
- `[research]` — deep research
- `[debug]` — debugging
- `[tdd]` — test-driven development
- `[security]` — security audit
- `[bootstrap]` — project setup
- `[adopt]` — mid-dev CKS adoption
- `[context]` — library/API research
- `[active]` — freeform work (fallback)
- `[idle]` — no active task
- `[closing]` — session ending

## Deconfliction Rules

Flag a conflict when:
- Two peers have the same feature ID (e.g., both on F-004)
- Two peers are in the same sprint phase on the same feature
- Two peers' summaries reference overlapping file paths

When a conflict is detected:
1. Show it prominently in the dashboard: "⚠ Conflict detected"
2. Suggest: one session should stop or redirect
3. If user confirms, send a `directive_stop` to the conflicting peer

## Directive Types

See `references/directive-protocol.md` for full spec:
- `directive_stop` — stop work on specific files/feature
- `directive_redirect` — switch to a different task
- `directive_priority` — reorder work
- `status_request` — ask for detailed status
- `info` — general notification

## Receiving Directives

When your session receives a directive via channel push:
- **Stop**: Immediately cease work on specified files, announce updated status
- **Redirect**: Finish atomic operation, switch to new task
- **Status request**: Respond with current phase, feature, files changed, remaining work

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "I'll set my summary manually later" | Hooks do it automatically — don't override unless scope changed |
| "No one else is working on this repo" | Check anyway — sessions may have started since you last looked |
| "The conflict is fine, we're on different files" | If same feature, coordination is still needed — file scope can overlap |
| "I don't need to react to directives" | Channel push directives from main are like manager requests — act on them |

## Verification

- [ ] `list_peers(scope="repo")` returns only same-repo sessions
- [ ] Auto-summary updates after sprint-start, phase transitions
- [ ] Dashboard displays parsed summaries with doc links
- [ ] Conflicts flagged when two sessions share a feature
- [ ] Directives sent via `send_message` arrive via channel push
- [ ] Session close announces `[closing]` before disappearing
