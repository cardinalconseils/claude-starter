---
name: peers
description: >
  Multi-instance Claude Code coordination via claude-peers-mcp. Enables peer
  discovery, messaging, work distribution, and status sharing across parallel
  Claude Code sessions on the same machine. Use when: dispatching parallel work
  across sessions, coordinating sprint execution with multiple agents, sharing
  context between sessions, checking peer status, or when the user says "peers",
  "other sessions", "coordinate", "send to", "check messages", "parallel sessions".
allowed-tools: Read, Grep, Glob
---

# Peer Coordination

## Overview

Claude-peers-mcp lets multiple Claude Code instances on the same machine discover and message each other in real-time. A broker daemon (localhost:7899, SQLite) manages peer registration, and each Claude Code session runs its own MCP server that connects to the broker.

This skill teaches agents WHEN and HOW to use peer coordination effectively.

## When to Use Peers

- **Multi-session sprints**: User has 2+ Claude Code terminals open and wants to split work
- **Cross-session review**: One session requests code review from another
- **Status awareness**: Check what other sessions are working on before starting
- **Task handoff**: Pass a completed subtask's context to another session
- **Broadcast updates**: Notify all sessions of a state change (merge freeze, review ready)

## When NOT to Use Peers

- **Single-session work**: No peers detected via `list_peers` — fall back to subagents
- **Subagent-scale tasks**: Work that fits within one context window — use `Agent()` instead
- **Sequential dependencies**: Tasks that must run in strict order — subagents are simpler
- **Quick lookups**: Don't message a peer for something you can grep locally

## Peers vs Subagents

| Dimension | Peers | Subagents |
|-----------|-------|-----------|
| Scope | Separate terminal sessions | Within one session |
| Context window | Independent (full context each) | Shared parent context |
| Tool access | Full tool access each | Declared in Agent() call |
| Shell access | Independent shell per session | Shared shell environment |
| Lifetime | Survives parent completion | Dies with parent task |
| Coordination | Explicit messaging | Return value |
| Best for | Large parallel workloads | Quick parallel lookups |

## MCP Tools Quick Reference

| Tool | Purpose | Key Args |
|------|---------|----------|
| `list_peers` | Find active sessions | `scope`: machine/directory/repo |
| `send_message` | Message a peer | `peerId`, `message` |
| `set_summary` | Update your status | `summary` |
| `check_messages` | Poll for messages | (none) |

## Coordination Patterns

### Fan-Out / Fan-In
Split work across N peers, collect results:
1. `list_peers` to find available sessions
2. `send_message` each peer with a task assignment (structured JSON)
3. Set own summary: "Coordinator — waiting for N peers"
4. Poll `check_messages` for results
5. Consolidate when all peers report back

### Pipeline
Sequential handoff between sessions:
1. Session A completes Phase 1, sends result summary to Session B
2. Session B picks up Phase 2 using Session A's output
3. Each session sets summary reflecting pipeline position

### Broadcast
Notify all peers of a state change:
1. `list_peers` with appropriate scope
2. `send_message` to each peer with the update
3. Use for: merge freeze, review ready, sprint complete, blocker found

## Message Protocol

All CKS workflow messages use structured JSON. See `references/message-protocol.md` for full schema.

**Always include** `type` field in messages so receiving agents can parse intent:
```json
{ "type": "task", "phase": "01-auth", "task_group": "TG-1", "files_scope": ["src/auth/"] }
```

Free-form text messages are fine for ad-hoc coordination.

## Setting Your Summary

Call `set_summary` whenever your work focus changes:
- Starting a sprint phase: `"Sprint Phase 01 — implementing auth middleware"`
- Waiting for review: `"Waiting — Phase 01 review pending"`
- Idle: `"Available — no active task"`

Do NOT rely on auto-summary (requires OpenAI). Always set explicitly.

## Availability Check Pattern

Before attempting peer coordination:
```
1. Call list_peers(scope="repo")
2. If empty → fall back to single-session / subagent mode
3. If peers exist → proceed with coordination pattern
```

Never assume peers are available. Always check and always have a fallback.

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "I'll just use subagents, peers are complex" | Peers give full context windows — worth it for large task groups |
| "The peer will figure out what to do" | Always send structured messages with explicit task scope |
| "I don't need to set my summary" | Other peers can't coordinate if they don't know what you're doing |
| "I'll check for messages later" | Check messages at natural breakpoints — don't let peers block on you |
| "One session is enough" | For 3+ task groups, multi-session is faster and uses less context |

## Verification

- [ ] `list_peers` returns at least this session (broker is running)
- [ ] `set_summary` updates without error
- [ ] `send_message` to a peer delivers (peer receives via channel push)
- [ ] Fallback works: empty `list_peers` triggers single-session mode
- [ ] Structured messages parse correctly on the receiving end
