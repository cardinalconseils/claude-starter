---
description: "Self-improvement loop — analyze session patterns and propose rule/persona/workflow improvements"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:improve — Self-Improvement Loop

Parse `$ARGUMENTS`:
- `--analyze` → analyze patterns and generate new proposals
- `--list` → show pending proposals (default if no args)
- `--apply <id>` → apply a specific proposal
- `--reject <id>` → reject a specific proposal

Gate: if `.cks/control-plane/config.yaml` does not exist, output:
> Control plane not initialized. Run `/cks:control-plane init` first.
Then stop.

Ensure dirs exist:
```bash
mkdir -p .cks/control-plane/improvements/pending
mkdir -p .cks/control-plane/improvements/accepted
mkdir -p .cks/control-plane/improvements/rejected
```

Dispatch:

```
Agent(
  subagent_type="cks:improvement-agent",
  prompt="
    Mode: {analyze | list | apply | reject}
    Proposal-ID: {id from --apply or --reject, or empty}
    Improvements base: .cks/control-plane/improvements/
  "
)
```

## Quick Reference

```
/cks:improve                    List pending proposals
/cks:improve --analyze          Scan all sources, generate new proposals
/cks:improve --list             Show pending proposals table
/cks:improve --apply 2026-05-20-001    Apply proposal 001
/cks:improve --reject 2026-05-20-002   Reject proposal 002
```
