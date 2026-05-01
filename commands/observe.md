---
description: "Query live observability sources — logs, errors, and LLM traces"
argument-hint: "[--logs] [--errors] [--traces]"
allowed-tools:
  - Agent
  - AskUserQuestion
---

# /cks:observe — Live Observability

Dispatch the observability agents based on flags.

## Routing

| Invocation | Action |
|---|---|
| `/cks:observe` | Dispatch **log-reader** in `sweep` mode — detect all sources, show availability |
| `/cks:observe --logs` | Dispatch **log-reader** in `query` mode — pull and filter live logs |
| `/cks:observe --errors` | Dispatch **sentry-observer** — triage Sentry error feed |
| `/cks:observe --traces` | Dispatch **langsmith-observer** — analyze LangSmith traces |

## Dispatch

Parse `$ARGUMENTS`:

- No args or unknown flag → sweep mode (log-reader)
- `--logs` → query mode (log-reader)
- `--errors` → sentry-observer
- `--traces` → langsmith-observer

```
Agent(subagent_type="cks:log-reader", prompt="Mode: sweep. Project root: {cwd}. Detect all log sources for this project and report availability. Do not pull live log data.")
```

```
Agent(subagent_type="cks:log-reader", prompt="Mode: query. Project root: {cwd}. Detect platform, pull recent logs, filter for errors, return last ~50 error-level lines.")
```

```
Agent(subagent_type="cks:sentry-observer", prompt="Triage Sentry errors for this project. List unresolved issues sorted by frequency. Project root: {cwd}.")
```

```
Agent(subagent_type="cks:langsmith-observer", prompt="Analyze LangSmith traces for this project. Surface errors, latency outliers, and token cost anomalies. Project root: {cwd}.")
```

## Quick Reference

```
/cks:observe             → sweep: what log sources are configured?
/cks:observe --logs      → query: what errors are in the logs right now?
/cks:observe --errors    → triage: what's broken in Sentry?
/cks:observe --traces    → traces: what's slow or expensive in LangSmith?
```

If a source is not configured, the agent will explain what's missing and how to set it up.
