---
description: "Run LLM output quality evals — memory, API, tool-use, regression, safety, structured output, or role evals for an agents/<role>.md body"
argument-hint: "[--type=memory|api|tool|regression|safety|structured|role] [--tier=smoke|standard|comprehensive] [--role=<role>|all]"
allowed-tools:
  - Agent
---

# /cks:evals

Run LLM output quality evaluation suites. Dispatches `cks:tester` to execute smoke, standard, or comprehensive evals against a named feature — or, with `--type=role`, the golden briefs that score one of the eighteen role bodies. Produces structured pass/fail reports. Use before merging any AI feature PR, before releasing, and before merging a change to `agents/<role>.md`.

## Usage

```
/cks:evals [--type=TYPE] [--tier=TIER] ["feature description"]
/cks:evals --type=role --role=<role>|all
```

## Arguments

| Argument | Values | Default | Description |
|---|---|---|---|
| `--type` | `memory` `api` `tool` `regression` `safety` `structured` `role` | ask | Eval type matching the LLM feature being tested |
| `--tier` | `smoke` `standard` `comprehensive` | `standard` (`smoke` for `role`) | Eval depth tier |
| `--role` | a role name or `all` | — | With `--type=role`: which `.evals/golden/roles/<role>/` corpus to run |
| feature | free text | (from context) | Feature name or description to scope the eval run |

## Dispatch

Parses `$ARGUMENTS` and dispatches `cks:tester` with full context. `--type=role` sets `Mode: role-eval`.

```
Agent(subagent_type="cks:tester",
      prompt="Run {tier} tier {type} evals for: {feature}. Args: $ARGUMENTS")

Agent(subagent_type="cks:tester",
      prompt="Mode: role-eval. Role: {role}. Read skills/evals/workflows/role-eval.md and follow it. Args: $ARGUMENTS")
```

## Quick Reference

```bash
# Smoke evals on memory feature before commit
/cks:evals --type=memory --tier=smoke "user memory store"

# Standard API response evals before PR merge
/cks:evals --type=api --tier=standard "chat summarizer"

# Comprehensive safety evals before release
/cks:evals --type=safety --tier=comprehensive "customer support bot"

# Role evals — required before merging a change to agents/<role>.md
/cks:evals --type=role --role=debugger
/cks:evals --type=role --role=all
```

Results stored in `.evals/results/` (role results: `.evals/results/roles/<role>.json`). Golden cases in `.evals/golden/{feature}/` and `.evals/golden/roles/<role>/`.
