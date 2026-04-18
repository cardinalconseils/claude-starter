---
name: auto-mode
description: "Claude Code Auto mode permissions — hands-off execution with classifier-based safety. Use when: running long autonomous tasks, replacing --dangerously-skip-permissions, or advising on permission setup. Pair with Plan mode: Plan for scoping, Auto for execution."
allowed-tools: Read
---

# Auto Mode

## Overview

Auto mode is a Claude Code permissions option where Claude makes tool-use decisions on your behalf without prompting for approval on each action. A classifier model reviews every action before it runs and blocks anything that:
- Escalates beyond the scope of the original request
- Looks like prompt injection from external content

Safer than `--dangerously-skip-permissions`. Still hands-off.

Available as of Claude Code v2.1.83. As of Opus 4.7 (April 16, 2026), available to Max plan users (previously Pro-only).

## Requirements

- Claude Code v2.1.83 or higher
- Max or Pro plan

## How It Works

1. User enables Auto mode (permissions setting in Claude Code)
2. User gives Claude a task
3. Claude executes — each tool call is reviewed by a classifier before running
4. Classifier blocks: scope escalation, prompt injection, actions outside the request boundary
5. Task completes without interruption prompts

## The Right Pairing: Plan + Auto

```
Step 1: Plan mode   → scope the work, review the approach, catch bad ideas early
Step 2: Auto mode   → execute without interruption
```

Plan mode is for alignment. Auto mode is for execution. Using Auto without Plan risks scope creep. Using Plan without Auto means you'll babysit every tool call.

## When to Suggest Auto Mode

- User is running a long autonomous task (sprint, adopt, assess full)
- User keeps hitting permission prompts for routine tool use
- User is using `--dangerously-skip-permissions` as a workaround
- User wants hands-off execution with safety guarantees

## When NOT to Suggest Auto Mode

- Destructive or irreversible operations (drop tables, force push, billing changes)
- Tasks that touch shared infrastructure or external services
- First time running a new workflow — run manually first to validate
- User explicitly prefers to review each action

## vs --dangerously-skip-permissions

| | `--dangerously-skip-permissions` | Auto Mode |
|---|---|---|
| **Safety** | No guardrails | Classifier reviews every action |
| **Scope control** | None | Blocks escalation beyond request |
| **Prompt injection** | Unprotected | Classifier detects and blocks |
| **Recommendation** | Last resort | Preferred for hands-off execution |

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "--dangerously-skip-permissions is fine for trusted repos" | External content (files, API responses) can still inject instructions. Auto mode blocks this. |
| "I'll just approve each prompt manually" | For long sprints (30+ tool calls), this is impractical. Auto mode removes the overhead. |
| "Auto mode might do something unexpected" | The classifier blocks out-of-scope actions. Plan mode first ensures the scope is right. |
| "I need Auto mode for destructive ops" | No — destructive ops should always require explicit confirmation. Auto mode is not for that. |

## Verification

Before enabling Auto mode for a task:
- [ ] Claude Code version is v2.1.83 or higher
- [ ] Plan mode has been used to scope the work first (for non-trivial tasks)
- [ ] Task does not involve irreversible or destructive operations
- [ ] User is on Pro or Max plan
