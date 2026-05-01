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
