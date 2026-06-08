---
description: "Self-hosted Honcho memory layer — add theory-of-mind user representations on top of CKS file memory (augment, local-only)"
argument-hint: "[setup|status|validate]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:honcho — Self-Hosted Honcho Memory

Add a **self-hosted** Honcho memory layer that augments CKS file memory with theory-of-mind
user representations (the dialectic). File memory + the isolation guard stay the durable
local floor; Honcho is best-effort enrichment, keyed to the trusted `CKS_ACTIVE_USER` as
the Honcho peer. Data stays on your host (`localhost:8000`).

## Arguments

| Arg | Action |
|---|---|
| `setup` | Scaffold the local docker instance, pick the deriver model, register the MCP server, write the peer-id contract |
| `validate` | On-host checks — instance up, MCP registered, and whether memory truly stays local |
| `status` | Show the layer's state (keys masked) |
| (no args) | Run setup |

## Dispatch

```
Agent(
  subagent_type="cks:honcho-integrator",
  prompt="
    SUBCOMMAND: {$ARGUMENTS or 'setup'}
    Wire the SELF-HOSTED Honcho memory layer per the honcho-memory skill: augment (never
    replace) file memory, peer id = CKS_ACTIVE_USER (never message text), keep data local
    on http://localhost:8000, and validate connectivity on the host.
  "
)
```

## Quick Reference

```
/cks:honcho setup      — stand up local Honcho + register MCP + peer-id contract
/cks:honcho validate   — confirm it's up and memory stays local
/cks:honcho status     — show state (keys masked)
```

## Notes

The dialectic deriver runs an LLM — the **only** per-token cost, for memory synthesis (not
conversation, which stays on your Claude subscription). Point it at a cheap model. Full
contract: `skills/honcho-memory/SKILL.md`.
