# Observability Layer — Design Spec

**Date:** 2026-05-01
**Status:** Approved
**Scope:** New skill, three new agents, one new command, two agent modifications

---

## Problem

The debugger and investigator agents currently operate on static code only. They can read files and run `grep`, but cannot pull live signals — Sentry error feeds, runtime logs, LangSmith traces. This means they diagnose from a map rather than looking out the window. The monitoring skill covers setup but not triage.

---

## Goals

1. Give all CKS agents a shared vocabulary for querying live observability sources
2. Provide a user-facing `/cks:observe` command that is actionable at any stage — even without pre-configured sources
3. Upgrade the debugger and investigator to consume live signals alongside static analysis
4. Cover the full triage loop: structured logs, error tracking (Sentry), and LLM tracing (LangSmith)

## Non-Goals

- Replacing `skills/monitoring` (setup remains separate from triage)
- Building dashboards or persistent alerting rules
- Supporting every possible log platform (cover the CKS-detected stack: Vercel, Railway, Supabase, Cloudflare, GCP)

---

## Architecture

```
commands/observe.md                     ← /cks:observe entry point
  ├── agents/log-reader.md              ← queries app logs (all platforms)
  ├── agents/sentry-observer.md         ← Sentry error triage
  └── agents/langsmith-observer.md      ← LangSmith trace analysis

skills/observability/SKILL.md           ← shared triage knowledge
  ├── workflows/log-triage.md           ← log querying procedures per platform
  ├── workflows/sentry-triage.md        ← Sentry workflow
  └── workflows/langsmith-triage.md     ← LangSmith workflow

Modified:
  agents/debugger.md                    ← add observability to skills list
  agents/investigator.md                ← add observability to skills list
```

### Skill Boundary

| Skill | Purpose | Loaded when |
|---|---|---|
| `monitoring` | Setup — wire logging/Sentry/health endpoints into an app | Building / green-field |
| `observability` | Triage — query and act on live signals | Debugging / investigating |

They coexist. A new project loads `monitoring` to set things up; the debugger loads `observability` to query what's running.

---

## Command: `/cks:observe`

Thin dispatcher. Routes to sub-agents based on flags. Auto-detects available sources when no flag given.

| Invocation | Action |
|---|---|
| `/cks:observe` | Status sweep — detect all configured sources, show signal summary |
| `/cks:observe --logs` | Dispatch log-reader agent |
| `/cks:observe --errors` | Dispatch sentry-observer agent |
| `/cks:observe --traces` | Dispatch langsmith-observer agent |
| `/cks:observe --setup` | Dispatch monitoring agent (existing setup skill) |

**Actionable at all times:** If a source is not configured, the agent explains what's missing and offers `--setup` as the next step. No dead ends.

---

## Agent: `log-reader`

Queries application logs from auto-detected platforms. Degrades gracefully when a source is unavailable.

### Platform detection order

1. Check env vars (`RAILWAY_TOKEN`, `VERCEL_TOKEN`, `GOOGLE_CLOUD_PROJECT`, etc.)
2. Check config files (`railway.toml`, `vercel.json`, `app.yaml`, `cloudbuild.yaml`, `k8s/`)
3. Check for local log files (`logs/`, `*.log`)
4. Fall back to Docker if `Dockerfile` present

### Log sources and verified commands

| Source | Runtime logs | Build/deploy logs |
|---|---|---|
| Local files | `tail -n 100 logs/app.log` | n/a |
| Docker | `docker logs [container] --tail 100` | n/a |
| Vercel | Vercel MCP: `get_runtime_logs` | Vercel MCP: `get_deployment_build_logs` |
| Railway runtime | `railway logs --service [S] --environment production --lines 100` | — |
| Railway build | — | `railway logs [DEPLOYMENT_ID] --build` |
| Railway errors | `railway logs --filter "@level:error" --lines 100 --json` | `railway logs --latest --build` |
| Supabase | Supabase MCP: `get_logs` | — |
| Cloudflare | Cloudflare MCP: `workers_analytics_search` | — |
| GCP Cloud Run | `gcloud run services logs read SERVICE --limit 50 --project PROJECT_ID` | — |
| GCP Cloud Run tail | `gcloud beta run services logs tail SERVICE --project PROJECT_ID` | — |
| GCP Cloud Run errors | `gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=SERVICE AND severity>=ERROR" --project PROJECT_ID --limit 50` | — |
| GCP App Engine | `gcloud logging read "resource.type=gae_app AND severity>=ERROR" --project PROJECT_ID --limit 50` | — |
| GCP GKE | `gcloud logging read "resource.type=k8s_container AND severity>=ERROR" --project PROJECT_ID --limit 50` | — |

### GCP resource auto-detection

| Config file found | Assumed resource type |
|---|---|
| `app.yaml` | `gae_app` (App Engine) |
| `Dockerfile` + no `railway.toml` + GCP project set | `cloud_run_revision` (Cloud Run) |
| `k8s/` or `kubernetes/` directory | `k8s_container` (GKE) |
| Ambiguous | Ask user before querying |

---

## Agent: `sentry-observer`

Triages Sentry errors for the current project. Uses `sentry:sentry-workflow` and `sentry:seer` skills plus Sentry MCP authentication.

### Capabilities

- List unresolved issues by frequency / first-seen / last-seen
- Show stack trace and context for a specific issue
- Group issues by release tag to detect regressions
- Surface issues tagged with current git SHA
- Suggest fix direction using Sentry Seer AI

### Tools

`WebFetch` (Sentry REST API), `mcp__plugin_sentry_sentry__authenticate`, `Bash` (git SHA lookup), `AskUserQuestion`

---

## Agent: `langsmith-observer`

Analyzes LangSmith traces for LLM apps. Targets the observability-config sources already defined in `skills/retrospective/references/observability-config.md`.

### Capabilities

- List recent trace runs with latency, token usage, error status
- Drill into a specific trace (input, output, tool calls, latency breakdown)
- Surface traces with errors or p99 latency outliers
- Compare token costs across runs

### API surface (verified endpoint pattern)

Base: `https://api.smith.langchain.com`
Auth: `LANGCHAIN_API_KEY` env var
Key endpoints: `/runs` (list), `/runs/{id}` (detail), `/projects` (list)

### Tools

`WebFetch`, `AskUserQuestion`, `Bash` (env var check)

---

## Skill: `observability`

Shared triage knowledge loaded by log-reader, sentry-observer, langsmith-observer, debugger, and investigator.

### Content

- What each source tells you and when to use it
- Signal hierarchy: error tracking first, then logs, then traces
- What NOT to do (don't tail unfiltered logs at scale, don't expose secrets in queries)
- Red flags (no sources configured, all logs at DEBUG level, no request IDs)
- Common rationalizations table
- Verification checklist

### Workflow files (progressive disclosure)

- `workflows/log-triage.md` — platform detection → query → parse → escalate
- `workflows/sentry-triage.md` — authenticate → list issues → drill → suggest fix
- `workflows/langsmith-triage.md` — authenticate → list runs → find outliers → report

---

## Modified Agents

### `debugger.md`

Add `observability` to `skills:` frontmatter list. Effect: the debugger can now pull Sentry context and live logs as evidence alongside static code analysis. No other changes.

### `investigator.md`

Add `observability` to `skills:` frontmatter list. Effect: the broad scan now includes live error signals, not just static code checks. No other changes.

---

## Constraints

- All CLI commands in skill/workflow files must be sourced from official docs — no improvised flags
- Agents degrade gracefully: if a source is unavailable, explain what's missing and offer `--setup`
- Never log or display secrets, tokens, or PII pulled from log sources
- GCP queries must always include `--limit` to avoid runaway API costs
- Railway `--latest` flag required when targeting failed builds (otherwise only successful deployments are shown)

---

## Verification Checklist

- [ ] `/cks:observe` routes correctly to each sub-agent
- [ ] log-reader detects platform from config files without user input (happy path)
- [ ] log-reader asks before querying GCP when resource type is ambiguous
- [ ] sentry-observer authenticates and lists issues for a real project
- [ ] langsmith-observer reads runs from `LANGCHAIN_API_KEY`
- [ ] debugger and investigator have `observability` in their skills list
- [ ] No CLI command in any workflow file uses an unverified flag
- [ ] All agents degrade gracefully when source is unconfigured
