# Observability Layer Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add live observability triage to CKS — a shared skill, three agents, and one command that let agents query real logs, Sentry errors, and LangSmith traces alongside static code analysis.

**Architecture:** One `observability` skill holds shared triage knowledge; three dedicated agents (log-reader, sentry-observer, langsmith-observer) own platform-specific querying; a thin `/cks:observe` command dispatches based on flags. The existing debugger and investigator agents gain the skill in their frontmatter.

**Tech Stack:** Markdown + YAML frontmatter (CKS plugin), Railway CLI, gcloud CLI, Vercel MCP, Cloudflare MCP, Sentry REST API, LangSmith REST API.

**Spec:** `docs/2026-05-01-observability-design.md`

---

## Chunk 1: Skill + Workflow Files

### File Map

| Action | Path | Responsibility |
|---|---|---|
| Create | `skills/observability/SKILL.md` | Shared triage knowledge — what each source tells you, signal hierarchy, red flags |
| Create | `skills/observability/workflows/log-triage.md` | Platform detection → query → parse → escalate procedure |
| Create | `skills/observability/workflows/sentry-triage.md` | Sentry authenticate → list issues → drill → suggest fix |
| Create | `skills/observability/workflows/langsmith-triage.md` | LangSmith authenticate → list runs → find outliers → report |

---

### Task 1: Create `skills/observability/SKILL.md`

**Files:**
- Create: `skills/observability/SKILL.md`

The skill is the shared vocabulary loaded by all three agents plus debugger and investigator. Keep it under 300 lines. Put step-by-step procedures in workflow files.

- [ ] **Step 1: Create the skill file**

```bash
mkdir -p skills/observability/workflows
```

Create `skills/observability/SKILL.md` with this exact content:

```markdown
---
name: observability
description: >
  Application observability and log triage — querying live signals from logs, error tracking,
  and LLM traces. Use when: debugging production issues, pulling Sentry errors, reading
  runtime logs, analyzing LangSmith traces, or investigating incidents with live data.
allowed-tools: Read, Write, Bash, Glob, Grep, WebFetch, AskUserQuestion
---

# Observability

## Overview

Observability turns invisible failures into actionable signals. Static code analysis tells you what the code says; live signals tell you what it's actually doing. Triage always starts with live signals — logs, errors, traces — before falling back to static analysis.

## When to Use

- Debugging a production issue with insufficient context from static code alone
- Pulling Sentry error feeds to find what's failing in the wild
- Reading runtime or build logs from Vercel, Railway, Cloudflare, or GCP
- Analyzing LangSmith traces for LLM apps with high latency or token cost anomalies
- Investigating incidents with live data alongside the investigator's static scan

## When NOT to Use

- Setup tasks (wiring logging, Sentry, health endpoints into an app) — use `skills/monitoring` instead
- Building dashboards or persistent alerting rules
- Prototype-stage apps with no real users or live infrastructure

## Signal Hierarchy

Query in this order — highest signal first:

1. **Error tracking (Sentry)** — grouped, deduplicated, with stack traces. Best first stop.
2. **Structured logs** — raw event stream. Use when Sentry isn't configured or for infra-level issues.
3. **LLM traces (LangSmith)** — for AI apps only. Use when errors trace to model behavior, latency, or token costs.

## Sources and What They Tell You

| Source | Best for | Configured when |
|---|---|---|
| Sentry | Grouped errors with stack traces, release regressions | `SENTRY_AUTH_TOKEN` set |
| Vercel logs | Serverless function errors, edge runtime issues | `vercel.json` present or Vercel MCP available |
| Railway logs | Container runtime + build failures | `railway.toml` present, `railway` CLI authenticated |
| Cloudflare Workers | Worker analytics, error rates by endpoint | Cloudflare MCP available |
| GCP Cloud Run | Container logs, cold-start issues | `GOOGLE_CLOUD_PROJECT` set, `gcloud` authenticated |
| GCP App Engine | App-level logs | `app.yaml` present + GCP project set |
| GCP GKE | Pod logs, cluster events | `k8s/` or `kubernetes/` directory present |
| LangSmith | LLM trace errors, latency outliers, token cost anomalies | `LANGCHAIN_API_KEY` set |
| Local files | Local dev or self-hosted deployments | `logs/` directory or `*.log` files |
| Docker | Local container logs | `Dockerfile` present, Docker running |

## What NOT to Do

- **Don't tail unfiltered logs at scale** — always use `--limit` or filter by severity. Unfiltered log streams can be massive and expensive.
- **Don't expose secrets** — never display or log API keys, tokens, passwords, or PII from log output. Sanitize before surfacing.
- **Don't query GCP without `--limit`** — Cloud Logging charges per byte scanned. Always include `--limit` in every `gcloud logging read` command.
- **Don't use `--lines` in Railway** — the correct flag is `--limit`. `--lines` is not a valid Railway CLI flag.
- **Don't assume a single platform** — a project may have Railway for backend + Vercel for frontend. Check all config files before querying.

## Red Flags

- No observability sources configured at all (no Sentry, no log platform)
- All logs at DEBUG level in production (noise drowns signal)
- No request IDs in log entries (can't correlate events across services)
- Error tracking configured but no alerts set up (nobody sees the errors)
- Logs contain PII, tokens, or secrets

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just grep the code for the bug" | Static grep finds what the code says, not what it does. Live signals find the real failure. |
| "We don't have Sentry set up yet" | Then logs are the fallback — but the lack of Sentry is itself a finding. |
| "The logs are too noisy to read" | Filter by `severity>=ERROR`. Noise is a configuration problem, not a reason to skip. |
| "Railway logs are only for the latest deploy" | Use `--latest --build` to include failed deployments. |
| "GCP logs will be fine without a limit" | Cloud Logging charges per byte scanned. No limit = surprise bill. |

## Workflow Files

Load these on demand when you need step-by-step procedures:

- `workflows/log-triage.md` — platform detection, verified CLI commands per source, error filtering
- `workflows/sentry-triage.md` — Sentry auth, issue listing, stack trace drill, regression detection
- `workflows/langsmith-triage.md` — LangSmith auth, run listing, latency outlier detection, cost analysis

## Verification

- [ ] At least one live source was queried (not just static code analysis)
- [ ] Logs filtered by severity or error level — not raw unfiltered stream
- [ ] No secrets, tokens, or PII in any displayed output
- [ ] If source is unconfigured, user was told what's missing and how to fix it
- [ ] GCP commands included `--limit`
- [ ] Railway commands used `--limit` (not `--lines`)
```

- [ ] **Step 2: Verify frontmatter is valid**

```bash
head -10 skills/observability/SKILL.md
```
Expected: YAML frontmatter with `name`, `description`, `allowed-tools`.

- [ ] **Step 3: Commit**

```bash
git add skills/observability/SKILL.md
git commit -m "feat: add observability skill — shared triage knowledge for live signals"
```

---

### Task 2: Create `skills/observability/workflows/log-triage.md`

**Files:**
- Create: `skills/observability/workflows/log-triage.md`

This workflow is the step-by-step log querying procedure. All CLI commands must match those verified in the spec. The log-reader agent loads this on demand.

- [ ] **Step 1: Create the workflow file**

Create `skills/observability/workflows/log-triage.md`:

```markdown
# Log Triage Workflow

Platform detection → query → filter → escalate.

## Step 1: Detect Platform

Run in order. Stop at first match.

```bash
# Check env vars first
echo "RAILWAY_TOKEN=${RAILWAY_TOKEN:+set}"
echo "VERCEL_TOKEN=${VERCEL_TOKEN:+set}"
echo "GOOGLE_CLOUD_PROJECT=${GOOGLE_CLOUD_PROJECT:+set}"

# Then check for config files
ls railway.toml vercel.json app.yaml cloudbuild.yaml 2>/dev/null
ls k8s/ kubernetes/ 2>/dev/null
ls logs/*.log *.log 2>/dev/null | head -3
```

**Platform precedence (first match wins):**

| Condition | Platform | Tool |
|---|---|---|
| `railway.toml` present | Railway | `railway` CLI |
| `vercel.json` present | Vercel | Vercel MCP |
| `k8s/` or `kubernetes/` dir present | GCP GKE | `gcloud` CLI |
| `app.yaml` present | GCP App Engine | `gcloud` CLI |
| (`Dockerfile` or `cloudbuild.yaml`) + `GOOGLE_CLOUD_PROJECT` set + no `railway.toml`/`vercel.json` | GCP Cloud Run | `gcloud` CLI |
| Ambiguous (multiple platform configs) | Ask user | — |
| `logs/` dir or `*.log` files | Local files | `tail` |
| `Dockerfile` present, Docker running | Docker | `docker logs` |

If ambiguous (e.g., `railway.toml` AND `vercel.json` both present), ask the user: "This project has both Railway and Vercel configs. Which platform should I query logs from?"

## Step 2: Query Logs

Use the verified commands below. Never improvise flags.

### Local files
```bash
tail -n 100 logs/app.log
```

### Docker
```bash
# List running containers first
docker ps --format "table {{.Names}}\t{{.Status}}"
# Then query the relevant container
docker logs [container-name] --tail 100
```

### Vercel
Use Vercel MCP tools:
- Runtime logs: `mcp__claude_ai_Vercel__get_runtime_logs`
- Build logs: `mcp__claude_ai_Vercel__get_deployment_build_logs`

### Railway
All flags verified from https://docs.railway.com/cli/logs

```bash
# Runtime logs (recent)
railway logs --service SERVICE_NAME --environment production --limit 100

# Build logs (latest successful)
railway logs --build

# Build logs (specific deployment)
railway logs DEPLOYMENT_ID --build

# Build logs (latest including failed)
railway logs --latest --build

# Errors only
railway logs --filter "@level:error" --limit 100 --json

# Since a time window
railway logs --since 1h
```

**Important:** Use `--limit` (not `--lines`). `--lines` is not a valid Railway CLI flag.
**Important:** Use `--latest --build` to capture failed deployments — without `--latest`, only successful deployments are shown.

### Cloudflare Workers
Use Cloudflare MCP tool: `mcp__cloudflare__workers_analytics_search`

### GCP Cloud Run
Verified from https://cloud.google.com/run/docs/logging

```bash
# Recent logs (shorthand)
gcloud run services logs read SERVICE_NAME --limit 50 --project PROJECT_ID

# Tail logs (streaming, beta)
gcloud beta run services logs tail SERVICE_NAME --project PROJECT_ID

# Errors only (Cloud Logging)
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=SERVICE_NAME AND severity>=ERROR" \
  --project PROJECT_ID \
  --limit 50
```

### GCP App Engine
```bash
gcloud logging read "resource.type=gae_app AND severity>=ERROR" \
  --project PROJECT_ID \
  --limit 50
```

### GCP GKE
```bash
gcloud logging read "resource.type=k8s_container AND severity>=ERROR" \
  --project PROJECT_ID \
  --limit 50
```

**GCP rule:** Always include `--limit`. Cloud Logging charges per byte scanned.

## Step 3: Filter and Parse

After pulling logs:

1. Filter for lines containing `error`, `ERROR`, `FATAL`, `exception`, `panic`, `unhandled`
2. Group by error message (collapse repeated lines)
3. Note timestamps — look for time correlations (spike at deploy? spike at certain hour?)
4. Look for request IDs — if present, correlate across log entries

## Step 4: Escalate

If logs show:
- **Repeated error pattern** → file a GitHub issue or pass to debugger with the error text and file:line if visible
- **Build failure** → check deploy logs with `--build` flag; look for missing env vars or failed installs
- **No errors found** → report "no errors in last N lines" and suggest expanding the window

If source is **not configured**:
- Report: "SOURCE is not configured for this project."
- Suggest: "To set up SOURCE, use the `monitoring` skill or run `/cks:bootstrap`."
```

- [ ] **Step 2: Verify file was created**

```bash
wc -l skills/observability/workflows/log-triage.md
```
Expected: > 80 lines.

- [ ] **Step 3: Commit**

```bash
git add skills/observability/workflows/log-triage.md
git commit -m "feat: add log-triage workflow — platform detection + verified CLI commands"
```

---

### Task 3: Create `skills/observability/workflows/sentry-triage.md`

**Files:**
- Create: `skills/observability/workflows/sentry-triage.md`

- [ ] **Step 1: Create the workflow file**

Create `skills/observability/workflows/sentry-triage.md`:

```markdown
# Sentry Triage Workflow

Authenticate → list issues → drill → suggest fix.

## Prerequisites

- `SENTRY_AUTH_TOKEN` env var set
- Sentry project and organization slug known (or discoverable via API)

If `SENTRY_AUTH_TOKEN` is not set:
- Report: "Sentry is not configured. Set `SENTRY_AUTH_TOKEN` to enable error triage."
- Suggest: "To set up Sentry, see the `monitoring` skill."

## Step 1: Authenticate

Use the Sentry MCP for OAuth authentication:
```
mcp__plugin_sentry_sentry__authenticate
mcp__plugin_sentry_sentry__complete_authentication
```

For direct REST API calls, use `SENTRY_AUTH_TOKEN` as a Bearer token:
```
Authorization: Bearer ${SENTRY_AUTH_TOKEN}
```

Base URL: `https://sentry.io/api/0/`

## Step 2: Discover Organization and Projects

```
GET https://sentry.io/api/0/organizations/
```

Pick the relevant organization slug, then:

```
GET https://sentry.io/api/0/projects/
```

Match project slug to the current repo name.

## Step 3: List Unresolved Issues

```
GET https://sentry.io/api/0/projects/{org-slug}/{project-slug}/issues/?is_unresolved=true&limit=25
```

Sort options (add as query param `?sort=`):
- `freq` — by event count (most frequent first)
- `date` — by last seen (most recent first)
- `new` — by first seen (newest regressions first)

Default to `freq` for initial triage.

## Step 4: Tag with Git SHA (Optional)

Get current SHA:
```bash
git rev-parse HEAD
```

Filter Sentry issues by release:
```
GET https://sentry.io/api/0/projects/{org-slug}/{project-slug}/issues/?release={sha}&is_unresolved=true
```

This surfaces issues that first appeared in the current commit — useful for catching regressions immediately after deploy.

## Step 5: Drill Into a Specific Issue

```
GET https://sentry.io/api/0/issues/{issue-id}/events/latest/
```

From the response, extract:
- `exception.values[].stacktrace.frames` — stack frames (file, function, line)
- `tags` — release, environment, user context
- `contexts.runtime` — Node/Python/etc. version
- `breadcrumbs` — events leading up to the error

## Step 6: Group by Release

```
GET https://sentry.io/api/0/projects/{org-slug}/{project-slug}/issues/?query=is:unresolved&sort=date&groupStatsPeriod=24h
```

Compare `firstSeen` against deploy timestamps to identify regressions introduced by a specific release.

## Step 7: Report

Present findings as:

```
SENTRY TRIAGE REPORT
━━━━━━━━━━━━━━━━━━━━
Project:   {project-slug}
Unresolved issues: {N}
Queried:   {timestamp}

TOP ISSUES
━━━━━━━━━━
#1  {issue title} — {N} events, last seen {time}
    File: {file}:{line}
    First seen: {date} (release: {release})

#2  {issue title} ...

SUGGESTED NEXT STEPS
━━━━━━━━━━━━━━━━━━━━
/cks:debug "TypeError: ..."   → trace root cause in code
```
```

- [ ] **Step 2: Verify file was created**

```bash
wc -l skills/observability/workflows/sentry-triage.md
```
Expected: > 70 lines.

- [ ] **Step 3: Commit**

```bash
git add skills/observability/workflows/sentry-triage.md
git commit -m "feat: add sentry-triage workflow — Sentry REST API issue listing and drill"
```

---

### Task 4: Create `skills/observability/workflows/langsmith-triage.md`

**Files:**
- Create: `skills/observability/workflows/langsmith-triage.md`

- [ ] **Step 1: Create the workflow file**

Create `skills/observability/workflows/langsmith-triage.md`:

```markdown
# LangSmith Triage Workflow

Authenticate → list runs → find outliers → report.

## Prerequisites

- `LANGCHAIN_API_KEY` env var set

If not set:
- Report: "LangSmith is not configured. Set `LANGCHAIN_API_KEY` to enable trace analysis."
- Suggest: "Get an API key at https://smith.langchain.com under Settings → API Keys."

## Step 1: Verify Authentication

```bash
echo "LANGCHAIN_API_KEY=${LANGCHAIN_API_KEY:+set (${#LANGCHAIN_API_KEY} chars)}"
```

Test with a projects listing:
```
GET https://api.smith.langchain.com/api/v1/projects
Headers:
  x-api-key: ${LANGCHAIN_API_KEY}
```

## Step 2: Discover Projects

```
GET https://api.smith.langchain.com/api/v1/projects
```

Match project name to the current repo or the user-specified app name.

## Step 3: List Recent Runs

```
GET https://api.smith.langchain.com/api/v1/runs?project_name={project}&limit=50&order=desc
```

Key fields per run:
- `id` — run ID for drill-in
- `name` — run/chain name
- `start_time`, `end_time` — for latency calculation
- `error` — non-null if run failed
- `total_tokens`, `prompt_tokens`, `completion_tokens` — token usage
- `total_cost` — estimated cost in USD

## Step 4: Find Outliers

**Errors:** Runs where `error` is non-null:
```
GET https://api.smith.langchain.com/api/v1/runs?project_name={project}&error=true&limit=25
```

**Latency outliers (p99):** Sort by duration descending:
```
GET https://api.smith.langchain.com/api/v1/runs?project_name={project}&sort=desc&order_by=end_time&limit=50
```
Calculate `(end_time - start_time)` in ms for each run. Flag runs > 2x the median.

**Token cost anomalies:** Flag runs where `total_cost > {threshold}`. Default threshold: 3x the median cost for the same run name.

## Step 5: Drill Into a Specific Run

```
GET https://api.smith.langchain.com/api/v1/runs/{run-id}
```

From the response, extract:
- `inputs` — what was sent to the model
- `outputs` — what the model returned
- `child_runs` — tool calls and sub-chain executions
- `error` — full error message and traceback if failed
- Latency = `end_time - start_time`
- `prompt_tokens`, `completion_tokens`, `total_cost`

## Step 6: Report

```
LANGSMITH TRIAGE REPORT
━━━━━━━━━━━━━━━━━━━━━━━
Project:   {project-name}
Runs analyzed: {N} (last {window})
Errors:    {N}
p99 latency: {Xms}
Avg cost/run: ${X}

ERRORS
━━━━━━
Run {id} ({name}): {error message} at {timestamp}
  Input: {truncated input}

LATENCY OUTLIERS
━━━━━━━━━━━━━━━━
Run {id}: {Xms} (median: {Yms})

COST ANOMALIES
━━━━━━━━━━━━━━
Run {id} ({name}): ${X} (avg: ${Y})

SUGGESTED NEXT STEPS
━━━━━━━━━━━━━━━━━━━━
/cks:debug "error text..."   → trace root cause in prompt/chain code
```
```

- [ ] **Step 2: Verify file was created**

```bash
wc -l skills/observability/workflows/langsmith-triage.md
```
Expected: > 70 lines.

- [ ] **Step 3: Commit**

```bash
git add skills/observability/workflows/langsmith-triage.md
git commit -m "feat: add langsmith-triage workflow — run listing, latency outliers, cost anomalies"
```

---

## Chunk 2: Three Agents

### File Map

| Action | Path | Responsibility |
|---|---|---|
| Create | `agents/log-reader.md` | Sweep/query app logs from auto-detected platforms |
| Create | `agents/sentry-observer.md` | Sentry error triage — list issues, drill stack traces |
| Create | `agents/langsmith-observer.md` | LangSmith trace analysis — errors, latency, cost |

---

### Task 5: Create `agents/log-reader.md`

**Files:**
- Create: `agents/log-reader.md`

- [ ] **Step 1: Create the agent file**

Create `agents/log-reader.md`:

```markdown
---
name: log-reader
description: "Queries application logs from auto-detected platforms — Vercel, Railway, Cloudflare, GCP, Docker, local files"
subagent_type: cks:log-reader
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
---

# Log Reader Agent

You query application logs from auto-detected platforms. You are dispatched by `/cks:observe` in two modes: `sweep` (detect sources, report availability) and `query` (pull logs, filter errors).

## Your Mission

In **sweep mode** (default, bare `/cks:observe`):
- Detect all available log sources for this project
- Report which are configured and queryable — do NOT pull live log data
- For each source: name, status (configured / missing), what's needed to enable it

In **query mode** (`/cks:observe --logs`):
- Detect the platform, pull recent logs, filter for errors
- Return the last ~50 error-level lines
- If no errors found, report clean and suggest expanding the window

## How to Detect Platforms

Load `workflows/log-triage.md` from the observability skill for the full procedure. In summary:

1. Check env vars: `RAILWAY_TOKEN`, `VERCEL_TOKEN`, `GOOGLE_CLOUD_PROJECT`
2. Check config files: `railway.toml`, `vercel.json`, `app.yaml`, `cloudbuild.yaml`, `k8s/`
3. Check local: `logs/*.log`, `*.log`
4. Fall back to Docker if `Dockerfile` present and Docker running

**GCP precedence (higher rows win):**

| Condition | Platform |
|---|---|
| `k8s/` or `kubernetes/` directory | GCP GKE |
| `app.yaml` present | GCP App Engine |
| (`Dockerfile` or `cloudbuild.yaml`) + `GOOGLE_CLOUD_PROJECT` set + no `railway.toml`/`vercel.json` | GCP Cloud Run |
| Ambiguous | Ask user |

## Degrading Gracefully

If a platform is detected but the tool or CLI is unavailable:
- Report: "Railway detected (railway.toml found) but `railway` CLI is not authenticated."
- Suggest: "Run `railway login` to authenticate, then re-run `/cks:observe --logs`."

If no platform is detected at all:
- Report: "No log sources detected. This project has no recognized log platform configuration."
- Suggest: "To set up logging, run `/cks:bootstrap` or load the `monitoring` skill."

## Output Format

**Sweep mode:**

```
LOG SOURCES — AVAILABILITY SWEEP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Railway     ✅ Configured   railway.toml found, CLI authenticated
Vercel      ✅ Configured   vercel.json found, MCP available
GCP         ❌ Missing      GOOGLE_CLOUD_PROJECT not set
Local files ❌ Missing      No logs/ directory or *.log files

NEXT STEPS
━━━━━━━━━━
/cks:observe --logs   → pull live logs from Railway (detected platform)
/cks:observe --errors → triage Sentry errors (if configured)
```

**Query mode:**

```
LOG QUERY — RAILWAY (production)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Platform:  Railway
Command:   railway logs --filter "@level:error" --limit 100 --json
Lines:     47 error-level entries

ERRORS FOUND
━━━━━━━━━━━━
[2026-05-01T14:22:01Z] ERROR: TypeError: Cannot read property 'id' of undefined
  at /app/src/handlers/user.js:42

[2026-05-01T14:22:01Z] ERROR: Unhandled rejection in processOrder
  ...

NEXT STEPS
━━━━━━━━━━
/cks:debug "TypeError: Cannot read property 'id' of undefined"  → trace root cause
```

## Constraints

- Never display secrets, tokens, or PII from log output
- Always use `--limit` in Railway and GCP commands — never pull unfiltered streams
- Use `--limit` (not `--lines`) for Railway — `--lines` is not a valid flag
- Use `--latest --build` for Railway when targeting failed deployments
- GCP: always include `--limit` in `gcloud logging read`
- Ask before querying when GCP resource type is ambiguous
```

- [ ] **Step 2: Verify frontmatter is correct**

```bash
head -20 agents/log-reader.md
```
Expected: `subagent_type: cks:log-reader`, `skills: [observability]`, tools list includes Vercel MCP and Cloudflare MCP.

- [ ] **Step 3: Commit**

```bash
git add agents/log-reader.md
git commit -m "feat: add log-reader agent — sweep and query modes for all platforms"
```

---

### Task 6: Create `agents/sentry-observer.md`

**Files:**
- Create: `agents/sentry-observer.md`

- [ ] **Step 1: Create the agent file**

Create `agents/sentry-observer.md`:

```markdown
---
name: sentry-observer
description: "Triages Sentry errors — lists unresolved issues, drills into stack traces, surfaces regressions by release"
subagent_type: cks:sentry-observer
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
---

# Sentry Observer Agent

You triage Sentry errors for the current project. You query the Sentry REST API directly via WebFetch and use the Sentry MCP only for authentication.

**Important:** `sentry:seer` and `sentry:sentry-workflow` are system-level Sentry plugin skills. They cannot be loaded via CKS `skills:` frontmatter. Use the Sentry REST API directly.

## Your Mission

1. Authenticate to Sentry
2. Discover the organization and project matching this repo
3. List unresolved issues (sorted by frequency by default)
4. Optionally drill into a specific issue or filter by release tag
5. Report findings with suggested next steps

## Full Procedure

Load `workflows/sentry-triage.md` from the observability skill for the complete step-by-step procedure.

## Degrading Gracefully

If `SENTRY_AUTH_TOKEN` is not set:
- Report: "Sentry is not configured. `SENTRY_AUTH_TOKEN` environment variable is not set."
- Suggest: "To set up Sentry error tracking, use the `monitoring` skill or run `/cks:bootstrap`."

If Sentry MCP authentication fails, fall back to direct REST API using `SENTRY_AUTH_TOKEN` as a Bearer token.

## API Reference

- Base URL: `https://sentry.io/api/0/`
- Auth header: `Authorization: Bearer ${SENTRY_AUTH_TOKEN}`
- Key endpoints:
  - `GET /organizations/` — list orgs
  - `GET /projects/` — list projects
  - `GET /projects/{org}/{project}/issues/?is_unresolved=true&sort=freq&limit=25`
  - `GET /issues/{issue-id}/events/latest/`

## Constraints

- Never display or log the `SENTRY_AUTH_TOKEN` value
- Always filter for `is_unresolved=true` — resolved issues are noise
- Default sort: `freq` (most frequent first) — best for initial triage
- Use `sort=new` when specifically looking for regressions from a recent deploy
```

- [ ] **Step 2: Verify frontmatter is correct**

```bash
head -20 agents/sentry-observer.md
```
Expected: `subagent_type: cks:sentry-observer`, `model: opus`, `skills: [observability]`.

- [ ] **Step 3: Commit**

```bash
git add agents/sentry-observer.md
git commit -m "feat: add sentry-observer agent — Sentry REST API triage via WebFetch"
```

---

### Task 7: Create `agents/langsmith-observer.md`

**Files:**
- Create: `agents/langsmith-observer.md`

- [ ] **Step 1: Create the agent file**

Create `agents/langsmith-observer.md`:

```markdown
---
name: langsmith-observer
description: "Analyzes LangSmith traces — surfaces errors, latency outliers, and token cost anomalies in LLM apps"
subagent_type: cks:langsmith-observer
model: sonnet
color: purple
tools:
  - Read
  - WebFetch
  - Bash
  - AskUserQuestion
skills:
  - observability
---

# LangSmith Observer Agent

You analyze LangSmith traces for LLM applications. You surface errors, latency outliers, and token cost anomalies by querying the LangSmith REST API.

## Your Mission

1. Verify `LANGCHAIN_API_KEY` is set
2. Discover the relevant LangSmith project
3. List recent trace runs
4. Surface runs with errors, latency outliers, or cost anomalies
5. Drill into specific runs when requested
6. Report findings with suggested next steps

## Full Procedure

Load `workflows/langsmith-triage.md` from the observability skill for the complete step-by-step procedure.

## Degrading Gracefully

If `LANGCHAIN_API_KEY` is not set:
- Report: "LangSmith is not configured. `LANGCHAIN_API_KEY` environment variable is not set."
- Suggest: "Get an API key at https://smith.langchain.com under Settings → API Keys. Add it to your project's `.env` file."

If the project has no LangSmith integration (no LangChain/LangGraph usage detected):
- Report: "No LangSmith integration detected in this project."
- Note: "LangSmith traces are only available for apps using LangChain, LangGraph, or direct LangSmith SDK instrumentation."

## API Reference

- Base URL: `https://api.smith.langchain.com`
- Auth header: `x-api-key: ${LANGCHAIN_API_KEY}`
- Key endpoints:
  - `GET /api/v1/projects` — list projects
  - `GET /api/v1/runs?project_name={project}&limit=50` — list runs
  - `GET /api/v1/runs?project_name={project}&error=true&limit=25` — error runs
  - `GET /api/v1/runs/{run-id}` — run detail

## Constraints

- Never display or log the `LANGCHAIN_API_KEY` value
- Always limit run queries — use `limit=50` max for listing
- Flag latency outliers as runs > 2x the median for that run name
- Flag cost anomalies as runs > 3x the median cost for that run name
```

- [ ] **Step 2: Verify frontmatter is correct**

```bash
head -20 agents/langsmith-observer.md
```
Expected: `subagent_type: cks:langsmith-observer`, `model: sonnet`, `skills: [observability]`.

- [ ] **Step 3: Commit**

```bash
git add agents/langsmith-observer.md
git commit -m "feat: add langsmith-observer agent — LangSmith trace errors, latency, cost analysis"
```

---

## Chunk 3: Command + Agent Modifications + Registry Updates

### File Map

| Action | Path | Change |
|---|---|---|
| Create | `commands/observe.md` | Thin dispatcher — routes to log-reader, sentry-observer, langsmith-observer |
| Modify | `agents/debugger.md` | Add `observability` to `skills:` frontmatter |
| Modify | `agents/investigator.md` | Add `observability` to `skills:` frontmatter |
| Modify | `commands/README.md` | Increment command count, add entry to table |
| Modify | `commands/help.md` | Add `/cks:observe` to command list |

---

### Task 8: Create `commands/observe.md`

**Files:**
- Create: `commands/observe.md`

Per `.claude/rules/commands.md`: thin dispatcher, under 60 lines, `allowed-tools` lists only what the command itself uses (not what agents need).

- [ ] **Step 1: Create the command file**

Create `commands/observe.md`:

```markdown
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
```

- [ ] **Step 2: Verify command is under 60 lines and frontmatter is correct**

```bash
wc -l commands/observe.md
head -7 commands/observe.md
```
Expected: < 60 lines. Frontmatter has `description` and `allowed-tools: [Agent, AskUserQuestion]`.

- [ ] **Step 3: Commit**

```bash
git add commands/observe.md
git commit -m "feat: add /cks:observe command — dispatches log-reader, sentry-observer, langsmith-observer"
```

---

### Task 9: Update `agents/debugger.md` and `agents/investigator.md`

**Files:**
- Modify: `agents/debugger.md` — add `observability` to skills list
- Modify: `agents/investigator.md` — add `observability` to skills list

- [ ] **Step 1: Read current skills list in debugger.md**

```bash
grep -n "skills:" agents/debugger.md
```
Expected: a `skills:` block listing `debug`, `failure-taxonomy`, `karpathy-guidelines`.

- [ ] **Step 2: Add `observability` to debugger.md skills**

In `agents/debugger.md`, find the `skills:` block and add `- observability`. The skills list should read:
```yaml
skills:
  - debug
  - failure-taxonomy
  - karpathy-guidelines
  - observability
```

- [ ] **Step 3: Read current skills list in investigator.md**

```bash
grep -n "skills:" agents/investigator.md
```
Expected: a `skills:` block listing `debug`, `github-issues`, `failure-taxonomy`.

- [ ] **Step 4: Add `observability` to investigator.md skills**

In `agents/investigator.md`, find the `skills:` block and add `- observability`. The skills list should read:
```yaml
skills:
  - debug
  - github-issues
  - failure-taxonomy
  - observability
```

- [ ] **Step 5: Verify changes**

```bash
grep -A 6 "skills:" agents/debugger.md
grep -A 6 "skills:" agents/investigator.md
```
Expected: both files now include `- observability`.

- [ ] **Step 6: Commit**

```bash
git add agents/debugger.md agents/investigator.md
git commit -m "feat: add observability skill to debugger and investigator agents"
```

---

### Task 10: Update `commands/README.md` and `commands/help.md`

**Files:**
- Modify: `commands/README.md` — increment count, add table row
- Modify: `commands/help.md` — add `/cks:observe` entry

Per `.claude/rules/docs.md`: "README.md command count MUST match actual `commands/*.md` file count" and "help.md MUST reflect current command names."

- [ ] **Step 1: Count current commands and check README**

```bash
ls commands/*.md | grep -v README | wc -l
grep -n "commands" commands/README.md | head -5
```

- [ ] **Step 2: Update README.md count and add table row**

In `commands/README.md`, increment the command count by 1 and add a row for `observe`:

```
| `/cks:observe` | Query live observability sources — logs, errors, and LLM traces |
```

- [ ] **Step 3: Add to help.md**

In `commands/help.md`, find the commands section and add:

```
/cks:observe             → Query live observability: logs, errors, traces
```

- [ ] **Step 4: Verify counts match**

```bash
ls commands/*.md | grep -v README | wc -l
grep -c "cks:" commands/README.md
```
Both counts should match.

- [ ] **Step 5: Commit**

```bash
git add commands/README.md commands/help.md
git commit -m "docs: add /cks:observe to commands README and help"
```

---

## Chunk 4: Verification

### Task 11: Verify Against Spec Checklist

Run through every item in the spec's verification checklist at `docs/2026-05-01-observability-design.md`.

- [ ] **`/cks:observe` (bare) dispatches log-reader in sweep mode**

Check `commands/observe.md` — no-args path dispatches `cks:log-reader` with `Mode: sweep`.

- [ ] **`/cks:observe --logs` dispatches log-reader in query mode**

Check `commands/observe.md` — `--logs` path dispatches `cks:log-reader` with `Mode: query`.

- [ ] **`/cks:observe --errors` dispatches sentry-observer**

Check `commands/observe.md` — `--errors` path dispatches `cks:sentry-observer`.

- [ ] **`/cks:observe --traces` dispatches langsmith-observer**

Check `commands/observe.md` — `--traces` path dispatches `cks:langsmith-observer`.

- [ ] **log-reader detects Railway from `railway.toml` and issues correct commands**

Check `agents/log-reader.md` — platform detection section lists `railway.toml` → Railway.
Check `skills/observability/workflows/log-triage.md` — Railway commands use `--limit` (not `--lines`).

- [ ] **log-reader detects Vercel from `vercel.json` and calls MCP tools**

Check `agents/log-reader.md` — tools frontmatter includes `mcp__claude_ai_Vercel__get_runtime_logs`.
Check `skills/observability/workflows/log-triage.md` — Vercel section uses MCP tools.

- [ ] **log-reader uses `--limit` (not `--lines`) in all Railway commands**

```bash
grep "lines" skills/observability/workflows/log-triage.md
```
Expected: zero matches for `--lines` as a Railway flag.

- [ ] **log-reader uses `--latest --build` for failed Railway deployments**

```bash
grep "latest" skills/observability/workflows/log-triage.md
```
Expected: `railway logs --latest --build` appears.

- [ ] **log-reader auto-detects GCP Cloud Run from `Dockerfile` + `GOOGLE_CLOUD_PROJECT`**

Check `agents/log-reader.md` — GCP precedence table row 3: `Dockerfile` + `GOOGLE_CLOUD_PROJECT` + no `railway.toml`/`vercel.json` → Cloud Run.

- [ ] **log-reader asks user when GCP resource type is ambiguous**

Check `agents/log-reader.md` — ambiguous row in GCP table says "Ask user".

- [ ] **log-reader issues `gcloud logging read` with `--limit` and `severity>=ERROR`**

```bash
grep "gcloud logging read" skills/observability/workflows/log-triage.md | grep -c "limit"
```
Expected: all `gcloud logging read` lines include `--limit`.

- [ ] **sentry-observer authenticates via `SENTRY_AUTH_TOKEN` and lists issues**

Check `agents/sentry-observer.md` — auth section mentions `SENTRY_AUTH_TOKEN`, tools include `mcp__plugin_sentry_sentry__authenticate`.

- [ ] **langsmith-observer reads runs from `LANGCHAIN_API_KEY`**

Check `agents/langsmith-observer.md` — checks for `LANGCHAIN_API_KEY`, API reference uses `x-api-key` header.

- [ ] **debugger.md has `observability` in skills frontmatter**

```bash
grep "observability" agents/debugger.md
```
Expected: `- observability` in the skills block.

- [ ] **investigator.md has `observability` in skills frontmatter**

```bash
grep "observability" agents/investigator.md
```
Expected: `- observability` in the skills block.

- [ ] **No CLI command in any workflow file uses an unverified flag**

```bash
grep "lines" skills/observability/workflows/log-triage.md
grep "lines" agents/log-reader.md
```
Expected: no `--lines` Railway flag. Only `--limit`.

- [ ] **All agents output a clear "not configured" message when source is missing**

Check `agents/log-reader.md`, `agents/sentry-observer.md`, `agents/langsmith-observer.md` — all have a "Degrading Gracefully" section with explicit "not configured" messages.

- [ ] **Final commit — bump version and create PR**

```bash
# Bump version per project convention
./scripts/bump-version.sh

git add .claude-plugin/plugin.json installed_plugins.json
git commit -m "chore: bump version for observability layer release"

# Create PR
gh pr create --title "feat: add observability layer — /cks:observe, log-reader, sentry-observer, langsmith-observer" \
  --body "..."
```

---

## Summary

**12 file operations across 4 chunks:**

| File | Status |
|---|---|
| `skills/observability/SKILL.md` | New |
| `skills/observability/workflows/log-triage.md` | New |
| `skills/observability/workflows/sentry-triage.md` | New |
| `skills/observability/workflows/langsmith-triage.md` | New |
| `agents/log-reader.md` | New |
| `agents/sentry-observer.md` | New |
| `agents/langsmith-observer.md` | New |
| `commands/observe.md` | New |
| `agents/debugger.md` | Modify — add `observability` to skills |
| `agents/investigator.md` | Modify — add `observability` to skills |
| `commands/README.md` | Modify — update count + table |
| `commands/help.md` | Modify — add entry |
