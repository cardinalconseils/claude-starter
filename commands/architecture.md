---
description: "Generate or refresh ARCHITECTURE.md — project topology diagram, component table, ADR index"
argument-hint: "[refresh|adr \"decision title\"]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:architecture

Dispatch the **architecture-generator** agent to maintain `ARCHITECTURE.md` and `.decisions/ADR-*.md`.

```
Agent(subagent_type="cks:architecture-generator", prompt="Mode: Full Refresh. Read all inputs (ARCHITECTURE.md if exists, all .decisions/ADR-*.md, all .prd/phases/*-TDD.md, active CONTEXT.md). Generate or refresh ARCHITECTURE.md using the architecture skill template. Rebuild Mermaid topology, Components table, Data Flow, and Decision Index. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:architecture              Refresh ARCHITECTURE.md from all TDDs + ADRs
/cks:architecture adr "title" Create a standalone ADR for a decision made outside a sprint
```

### What gets produced

- `ARCHITECTURE.md` at project root — topology diagram, components, data flows, ADR index
- `.decisions/ADR-NNN.md` — one file per significant design decision

### When to run

- After completing a sprint that changed the architecture
- When onboarding a new team member (to ensure the doc is current)
- Before a release to capture final state

### Sprint integration

Architecture is also updated automatically during sprint step [3b]. Manual `/cks:architecture` is for full rebuilds or standalone ADRs.
