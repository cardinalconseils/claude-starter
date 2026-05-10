---
description: "Manage the Feature → Phase → Task hierarchy — new, move, close, activate, list"
argument-hint: "new|move|close|activate|list [--type ...] [--title ...] [--parent ID] [--to ID]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:work — Work Hierarchy

Thin dispatcher for hierarchy mutations. All real work happens in the `work-hierarchy-manager` agent (sole writer of `.prd/work-hierarchy.md`).

## Subcommands

- `new --type {feature|phase|task} --title "X" [--parent ID]` — create a node
- `move <ID> --to <PARENT_ID>` — reparent a Phase or Task; IDs preserved
- `close <ID>` — mark node done (rejected if open children exist)
- `activate <ID>` — set the active Feature or Phase
- `list [--type T] [--status S] [--parent ID]` — read-only flat enumeration

## Steps

1. Parse the first positional token as the subcommand (one of: `new`, `move`, `close`, `activate`, `list`).
2. If the subcommand is missing or unknown → use `AskUserQuestion` to ask the vibecoder which action to take. Never guess.
3. Dispatch the manager agent with the full argument string:

```
Agent(
  subagent_type="cks:work-hierarchy-manager",
  prompt="Subcommand: {sub}. Args: {args}. Read .prd/work-hierarchy.md (create empty if absent), validate, mutate, write atomically, then mirror active pointers into .prd/PRD-STATE.md if they changed."
)
```

4. Display the agent's result block verbatim. Do not add commentary, do not duplicate the report.

## Quick Reference

```
/cks:work new --type feature --title "Checkout v2"
/cks:work new --type phase --parent F-01 --title "Cart redesign"
/cks:work new --type task  --parent P-01 --title "Wire up empty state"
/cks:work move P-02 --to F-03
/cks:work close F-01
/cks:work activate P-01
/cks:work list --type task --status todo
```

## Rules

1. Read-only here; mutations belong to the agent.
2. If `.prd/work-hierarchy.md` is missing, the agent creates it on the first mutation. Do not pre-create from this command.
3. Close-blocking is enforced by the agent — no `--force` flag in this phase.
