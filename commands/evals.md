---
description: "Run LLM output quality evals — memory, API, tool-use, regression, safety, or structured output"
argument-hint: "[--type=memory|api|tool|regression|safety] [--tier=smoke|standard|comprehensive]"
allowed-tools:
  - Agent
---

# /cks:evals

Run LLM output quality evaluation suites. Dispatches the evals-runner agent to execute smoke, standard, or comprehensive evals against a named feature. Produces structured pass/fail reports. Use before merging any AI feature PR or before releasing.

## Usage

```
/cks:evals [--type=TYPE] [--tier=TIER] ["feature description"]
```

## Arguments

| Argument | Values | Default | Description |
|---|---|---|---|
| `--type` | `memory` `api` `tool` `regression` `safety` `structured` | ask | Eval type matching the LLM feature being tested |
| `--tier` | `smoke` `standard` `comprehensive` | `standard` | Eval depth tier |
| feature | free text | (from context) | Feature name or description to scope the eval run |

## Dispatch

Parses `$ARGUMENTS` and dispatches `cks:evals-runner` with full context.

```
Agent(subagent_type="cks:evals-runner",
      prompt="Run {tier} tier {type} evals for: {feature}. Args: $ARGUMENTS")
```

## Quick Reference

```bash
# Smoke evals on memory feature before commit
/cks:evals --type=memory --tier=smoke "user memory store"

# Standard API response evals before PR merge
/cks:evals --type=api --tier=standard "chat summarizer"

# Tool-use regression check after prompt edit
/cks:evals --type=tool --tier=standard "calendar booking agent"

# Comprehensive safety evals before release
/cks:evals --type=safety --tier=comprehensive "customer support bot"

# Prompt regression after any prompt change
/cks:evals --type=regression "search feature"

# Structured output validation
/cks:evals --type=structured --tier=standard "product extraction API"
```

Results stored in `.evals/results/`. Golden cases in `.evals/golden/{feature}/`.
