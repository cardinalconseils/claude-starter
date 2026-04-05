---
name: monitoring
description: >
  Application monitoring, logging, and observability for production applications.
  Use when: setting up error tracking, adding logging, creating health endpoints,
  configuring alerting, preparing for production, or when debugging production
  issues.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Monitoring

## Overview

Monitoring turns invisible failures into visible signals. Without it, you learn about problems when users complain — or worse, when they leave silently. The goal is not dashboards; it is knowing when something breaks before users do.

## When to Use

- Setting up a new production application
- Adding structured logging to an existing app
- Creating health and readiness endpoints
- Configuring error tracking (Sentry, LogRocket, etc.)
- Setting up alerting for production incidents
- Debugging production issues with insufficient visibility

## When NOT to Use

- Prototype stage where the app is not yet serving real users
- Local development logging (use standard debug tools instead)
- One-off scripts that run and exit

## Process

### 1. Structured Logging

Use JSON format with consistent fields across all log entries.

**Required fields:** timestamp, level, message, request_id
**Useful fields:** user_id (not PII), service_name, duration_ms, status_code

**Log levels — use them correctly:**
- `error` — Something failed and needs attention (broken request, unhandled exception)
- `warn` — Degraded state but still functioning (slow query, retry succeeded, cache miss)
- `info` — Important business events (user signup, payment processed, deploy complete)
- `debug` — Development detail (request payload, query plan) — never in production

### 2. What to Log and What NOT to Log

**Log:** Auth failures, permission denials, input validation failures, external API calls (with duration), slow queries (> threshold), startup/shutdown events, deploy markers.

**Never log:** Passwords, API keys, tokens, session secrets, full credit card numbers, PII (emails, phone numbers, addresses). Sanitize or redact before logging.

### 3. Error Tracking

Configure Sentry, LogRocket, Bugsnag, or similar. Capture stack traces, group by root cause, set up alerts on new error types. Tag errors with release version for regression detection.

### 4. Health Endpoints

**`/health`** — Basic liveness check. Returns 200 if the process is running. Used by load balancers and container orchestrators.

**`/ready`** — Readiness check. Verifies dependencies: database connection, cache availability, external API reachability. Returns 503 if any dependency is down.

### 5. Uptime Monitoring

External ping service (UptimeRobot, Pingdom, Better Stack) hits /health every 1-5 minutes from multiple regions. Alert on 2+ consecutive failures to avoid false positives.

### 6. Alerting Strategy

**Page (immediate action required):** 5xx error rate spike, health check failure, database unreachable.

**Notify (review soon):** Slow response times (p95 > threshold), high memory usage, elevated error rate.

**Avoid alert fatigue:** Fewer meaningful alerts are better than many noisy ones. Every alert should have a clear action. If you ignore an alert regularly, fix it or remove it.

### 7. Key Metrics

| Metric | What It Tells You |
|---|---|
| Response time (p50/p95/p99) | User experience and backend health |
| Error rate (5xx / total) | Reliability — target < 0.1% |
| Uptime percentage | SLA compliance — target 99.9%+ |
| Active users | Business health and load baseline |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll add monitoring when we need it" | You need it the moment a real user touches your app. Flying blind is gambling. |
| "Console.log is fine" | Console.log in production is noise. Structured logging with levels is signal. |
| "We don't have enough traffic to monitor" | Monitoring catches bugs before users report them. Traffic volume is irrelevant. |
| "Dashboards are enough" | Nobody watches dashboards at 3am. Alerts catch what dashboards miss. |
| "We'll just check the logs" | Unstructured logs at scale are unsearchable. Structure them from the start. |

## Red Flags

- Production app with no error tracking
- Console.log as the only logging mechanism
- No health endpoint for load balancers
- No uptime monitoring (learning about downtime from users)
- Logging PII, tokens, or secrets
- Alert on every warning (alert fatigue guarantees missed real alerts)
- No request ID correlation across log entries

## Verification

- [ ] Structured logging in place (JSON, consistent fields, correct levels)
- [ ] No PII, secrets, or tokens in log output
- [ ] Error tracking configured and capturing stack traces
- [ ] /health endpoint returns 200 when process is alive
- [ ] /ready endpoint checks all critical dependencies
- [ ] Uptime monitoring pinging from external service
- [ ] Alerting configured for critical failures (not noisy)
- [ ] Key metrics tracked (response time, error rate, uptime)
