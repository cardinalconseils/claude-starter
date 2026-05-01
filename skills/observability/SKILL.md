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
