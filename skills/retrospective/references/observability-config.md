# Observability Configuration

Configure which deployment and monitoring sources the retro checks after shipping.
Edit `.learnings/observability.md` frontmatter to enable/disable sources and set thresholds.

## Default Configuration

```yaml
---
sources:
  - type: vercel
    enabled: true           # Uses Vercel MCP: get_runtime_logs, get_deployment
    window: 15m             # Check logs from deploy time + 15 minutes
    error-threshold: 5      # Flag if more than N errors in window

  - type: railway
    enabled: true           # Uses Railway CLI: railway logs
    window: 15m
    error-threshold: 5

  - type: cloudflare
    enabled: false          # Uses Cloudflare MCP: workers_analytics_search
    window: 15m

  - type: supabase
    enabled: false          # Uses Supabase MCP: get_logs, get_advisors
    window: 15m

  - type: langsmith
    enabled: false
    api-url: "https://api.smith.langchain.com"
    window: 30m
    check:
      - trace-errors
      - latency-p99
      - token-usage

  - type: webhook
    enabled: false
    url: ""
    method: GET
    headers:
      Authorization: "Bearer ${LOG_API_KEY}"
    jq-filter: ".errors | length"
    error-threshold: 0

auto-detect: true
skip-if-unavailable: true
---
```

## How It Works

After each ship, the retro:
1. Detects which platform the code was deployed to
2. Waits for the deploy to propagate (reads deployment status)
3. Pulls logs from the configured window (default: 15 min post-deploy)
4. Scans for errors, latency spikes, and anomalies
5. Includes findings in the retro session-log entry
6. Flags recurring post-deploy issues as GOTCHAs

## Available Source Types

| Type | MCP/Tool Used | What It Checks |
|------|---------------|----------------|
| vercel | Vercel MCP | Build logs, runtime logs, deployment status |
| railway | Railway CLI | Service logs, deploy status |
| cloudflare | Cloudflare MCP | Worker analytics, error rates |
| supabase | Supabase MCP | Database logs, advisor warnings |
| langsmith | WebFetch to API | LLM trace errors, latency, token costs |
| webhook | WebFetch to URL | Any custom monitoring endpoint |
