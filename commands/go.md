---
description: "Quick action command — commit, PR, dev, build, start. PRD-aware: guides you through the lifecycle."
argument-hint: "[action: commit|pr|dev|build|start] or no arg for full flow"
allowed-tools:
  - Read
  - Agent
---

# /cks:go — One Command, Every Quick Action

Parse the action argument and dispatch the go-runner agent.

## Routing

| Invocation | Action |
|------------|--------|
| `/cks:go` | Full flow: build → commit → push → PR |
| `/cks:go commit [message]` | Stage + smart commit |
| `/cks:go pr [title]` | Commit + push + open PR |
| `/cks:go dev` | Start dev server (auto-detects language) |
| `/cks:go start` | Start production/preview server |
| `/cks:go build` | Run build (auto-detects language) |

## Dispatch

```
Agent(subagent_type="go-runner", prompt="
  action: {parsed action or 'full' if no arg}
  args: {remaining text after action keyword}
  project_root: {current directory}
")
```

## Quick Reference

```
/cks:go              → build + commit + push + PR
/cks:go dev          → npm run dev / cargo run / python main.py / ...
/cks:go start        → npm start / docker compose up / ...
/cks:go build        → npm run build / cargo build / go build / ...
/cks:go commit       → smart commit with conventional message
/cks:go pr           → commit + push + create PR
/cks:go commit fix login bug  → commit with custom message
```
