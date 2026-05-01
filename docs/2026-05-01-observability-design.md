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
- Supporting every possible log platform (cover the CKS-detected stack: Vercel, Railway, Cloudflare, GCP)

---

## Architecture

```
commands/observe.md                     ← /cks:observe entry point
  ├── agents/log-reader.md              ← queries app logs + source sweep
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

Thin dispatcher. Routes to sub-agents based on flags.

### Frontmatter

```yaml
description: "Query live observability sources — logs, errors, and LLM traces"
argument-hint: "[--logs] [--errors] [--traces]"
allowed-tools:
  - Agent
  - AskUserQuestion
```

### Routing table

| Invocation | Action |
|---|---|
| `/cks:observe` | Dispatch log-reader in `sweep` mode (detect sources, report availability) |
| `/cks:observe --logs` | Dispatch log-reader in `query` mode |
| `/cks:observe --errors` | Dispatch sentry-observer |
| `/cks:observe --traces` | Dispatch langsmith-observer |

**Actionable at all times:** If a source is not configured, the agent explains what's missing and surfaces the monitoring skill setup path. No dead ends. (`--setup` is not a routed flag; agents include the suggestion in their output.)

---

## Skill: `observability`

### Frontmatter

```yaml
name: observability
description: >
  Application observability and log triage — querying live signals from logs, error tracking,
  and LLM traces. Use when: debugging production issues, pulling Sentry errors, reading
  runtime logs, analyzing LangSmith traces, or investigating incidents with live data.
allowed-tools: Read, Write, Bash, Glob, Grep, WebFetch, AskUserQuestion
```

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

## Agent: `log-reader`

### Frontmatter

```yaml
name: log-reader
subagent_type: cks:log-reader
description: "Queries application logs from auto-detected platforms — Vercel, Railway, Cloudflare, GCP, Docker, local files"
model: sonnet
color: cyan
tools:
  - Read
  - Bash
  - Glob
  - AskUserQuestion
  - mcp__claude_ai_Vercel__get_runtime_logs
  - mcp__claude_ai_Vercel__get_deployment_build_logs
  - mcp__cloudflare__workers_analytics_search
skills:
  - observability
```

### Modes

- **`sweep`** (default, bare `/cks:observe`) — detect all available sources, report which are configured and queryable. Does NOT pull live log data. Shows: source name, status (configured/missing), next step.
- **`query`** — pull logs from the detected platform, filter for errors, return last 50 lines.

### Platform detection order

1. Check env vars (`RAILWAY_TOKEN`, `VERCEL_TOKEN`, `GOOGLE_CLOUD_PROJECT`, etc.)
2. Check config files (`railway.toml`, `vercel.json`, `app.yaml`, `cloudbuild.yaml`, `k8s/`)
3. Check for local log files (`logs/`, `*.log`)
4. Fall back to Docker if `Dockerfile` present and Docker is running

### Log sources and verified commands

**Local files**
- `tail -n 100 logs/app.log`

**Docker**
- `docker logs [container] --tail 100`

**Vercel**
- Runtime: Vercel MCP `get_runtime_logs`
- Build: Vercel MCP `get_deployment_build_logs`

**Railway** (all flags verified from [docs.railway.com/cli/logs](https://docs.railway.com/cli/logs))
- Runtime: `railway logs --service [S] --environment production --limit 100`
- Build (latest): `railway logs --build`
- Build (specific deploy): `railway logs [DEPLOYMENT_ID] --build`
- Build (latest, including failed): `railway logs --latest --build`
- Errors only: `railway logs --filter "@level:error" --limit 100 --json`
- Since a time window: `railway logs --since 1h`

**Cloudflare**
- Analytics: Cloudflare MCP `workers_analytics_search`

**GCP Cloud Run** (verified from [cloud.google.com/run/docs/logging](https://docs.cloud.google.com/run/docs/logging))
- Shorthand: `gcloud run services logs read SERVICE --limit 50 --project PROJECT_ID`
- Tail (preview): `gcloud beta run services logs tail SERVICE --project PROJECT_ID`
- Errors only: `gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=SERVICE AND severity>=ERROR" --project PROJECT_ID --limit 50`

**GCP App Engine**
- Errors only: `gcloud logging read "resource.type=gae_app AND severity>=ERROR" --project PROJECT_ID --limit 50`

**GCP GKE**
- Errors only: `gcloud logging read "resource.type=k8s_container AND severity>=ERROR" --project PROJECT_ID --limit 50`

### GCP resource auto-detection

Precedence: higher rows win. Only reach a row if no higher-precedence match applies.

| Condition | resource.type used |
|---|---|
| `k8s/` or `kubernetes/` directory present | `k8s_container` |
| `app.yaml` present | `gae_app` |
| (`Dockerfile` or `cloudbuild.yaml`) + `GOOGLE_CLOUD_PROJECT` set + no `railway.toml` or `vercel.json` | `cloud_run_revision` |
| Any other combination (ambiguous / multiple platform configs) | Ask user before querying |

---

## Agent: `sentry-observer`

### Frontmatter

```yaml
name: sentry-observer
subagent_type: cks:sentry-observer
description: "Triages Sentry errors — lists unresolved issues, drills into stack traces, surfaces regressions by release"
model: opus
color: red
tools:
  - Read
  - WebFetch
  - Bash
  - AskUserQuestion
  - mcp__plugin_sentry_sentry__authenticate
  - mcp__plugin_sentry_sentry__complete_authentication
skills:
  - observability
```

Note: `sentry:seer` and `sentry:sentry-workflow` are system-level Sentry plugin skills. They are NOT loaded via CKS `skills:` frontmatter (no precedent for plugin-scoped skill names). The agent queries the Sentry REST API directly via WebFetch and uses the Sentry MCP only for authentication.

### Capabilities

- List unresolved issues sorted by frequency / first-seen / last-seen
- Show stack trace and context for a specific issue
- Group issues by release tag to detect regressions
- Surface issues tagged with current git SHA (`git rev-parse HEAD`)
- Query via Sentry REST API: base `https://sentry.io/api/0/`, auth `SENTRY_AUTH_TOKEN` env var

---

## Agent: `langsmith-observer`

### Frontmatter

```yaml
name: langsmith-observer
subagent_type: cks:langsmith-observer
description: "Analyzes LangSmith traces — surfaces errors, latency outliers, and token cost anomalies in LLM apps"
model: sonnet
color: purple
tools:
  - Read
  - WebFetch
  - Bash
  - AskUserQuestion
skills:
  - observability
```

### Capabilities

- List recent trace runs with latency, token usage, error status
- Drill into a specific trace (input, output, tool calls, latency breakdown)
- Surface traces with errors or p99 latency outliers
- Compare token costs across runs

### API surface

- Base: `https://api.smith.langchain.com`
- Auth: `LANGCHAIN_API_KEY` env var
- Key endpoints: `GET /runs` (list), `GET /runs/{id}` (detail), `GET /projects` (list)

---

## Modified Agents

### `debugger.md`

Add `observability` to `skills:` frontmatter list. No other changes. Effect: the debugger can now pull Sentry context and live logs as evidence alongside static code analysis.

### `investigator.md`

Add `observability` to `skills:` frontmatter list. No other changes. Effect: broad scans now include live error signals.

---

## Out of Scope (for now)

- **Supabase logs** — excluded until Supabase MCP `get_logs` tool availability is confirmed in this environment
- **`/cks:observe --setup`** — not a routed flag; monitoring setup remains in `/cks:bootstrap` and the `monitoring` skill

---

## Constraints

- All CLI commands in skill/workflow files must be sourced from official docs — no improvised flags
- Agents degrade gracefully: if a source is unavailable, explain what's missing
- Never display secrets, tokens, or PII pulled from log sources
- GCP queries must always include `--limit` to avoid runaway API costs
- Railway queries must use `--limit` (not `--lines`) — verified flag name
- Railway `--latest` flag required when targeting failed builds

---

## Verification Checklist

- [ ] `/cks:observe` (bare) dispatches log-reader in sweep mode
- [ ] `/cks:observe --logs` dispatches log-reader in query mode
- [ ] `/cks:observe --errors` dispatches sentry-observer
- [ ] `/cks:observe --traces` dispatches langsmith-observer
- [ ] log-reader detects Railway from `railway.toml` and issues correct commands
- [ ] log-reader detects Vercel from `vercel.json` and calls MCP tools
- [ ] log-reader uses `--limit` (not `--lines`) in all Railway commands
- [ ] log-reader uses `--latest --build` for failed Railway deployments
- [ ] log-reader auto-detects GCP Cloud Run from `Dockerfile` + `GOOGLE_CLOUD_PROJECT`
- [ ] log-reader asks user when GCP resource type is ambiguous
- [ ] log-reader issues `gcloud logging read` with `--limit` and `severity>=ERROR`
- [ ] sentry-observer authenticates via `SENTRY_AUTH_TOKEN` and lists issues
- [ ] langsmith-observer reads runs from `LANGCHAIN_API_KEY`
- [ ] debugger.md has `observability` in skills frontmatter
- [ ] investigator.md has `observability` in skills frontmatter
- [ ] No CLI command in any workflow file uses an unverified flag
- [ ] All agents output a clear "not configured" message when source is missing
