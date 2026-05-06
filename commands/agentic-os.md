---
description: "Scaffold and manage an Agentic OS — architecture + memory + observability — inside any project"
argument-hint: "[init|status|add-domain <name>]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:agentic-os — Agentic OS

Scaffold and manage the three-layer Agentic OS structure inside the current project.

## Mode Detection

Parse `$ARGUMENTS`:

| Pattern | Mode |
|---------|------|
| `init` | Full scaffold — architecture + memory + observability layers |
| `status` | Terminal dashboard — domains, recent memory changes, skill shortcuts |
| `add-domain <name>` | Add a new domain + skill stub to an existing Agentic OS |
| No args | Ask user which mode |

## Dispatch

**init**: `Agent(subagent_type="cks:agentic-os-builder", prompt="Mode: init. Interview the user for project domains and tasks, then scaffold the full Agentic OS (architecture + memory + observability) in the current project directory.")`

**status**: `Agent(subagent_type="cks:agentic-os-builder", prompt="Mode: status. Read .agentic-os/domains.md and memory/ to render a terminal dashboard showing active domains, recent memory changes, and available skill shortcuts.")`

**add-domain**: `Agent(subagent_type="cks:agentic-os-builder", prompt="Mode: add-domain. Domain name: {$ARGUMENTS minus 'add-domain'}. Add this domain to .agentic-os/domains.md, create its skill stub in .agentic-os/skills/, and update memory/index.md.")`

**no args**: AskUserQuestion — "What do you want to do?" (init / status / add-domain)

## Quick Reference

```
/cks:agentic-os init              → Full scaffold: interview + three-layer OS setup
/cks:agentic-os status            → Terminal dashboard: domains, memory, shortcuts
/cks:agentic-os add-domain Sales  → Add a new domain to an existing OS
```

Output: `.agentic-os/` (domains + skills), `memory/` (raw/wiki/output), `dashboard/index.html`
