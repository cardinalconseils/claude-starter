# Railway Tool

## What It Is
Railway is the deployment platform for [PROJECT_NAME]. This tool reference
covers how to interact with Railway via CLI and the deploy script.

## Connection
- Service name: `[RAILWAY_SERVICE]`
- Project ID: `[RAILWAY_PROJECT_ID]`
- Dashboard: `https://railway.app/project/[RAILWAY_PROJECT_ID]`
- Environment: production / staging

## Key Operations

### Deploy
```bash
./deploy.sh --env production
./deploy.sh --env staging --dry-run
```

### Check status
```bash
railway status --service [RAILWAY_SERVICE]
```

### Tail logs
```bash
railway logs --service [RAILWAY_SERVICE] --tail
```

### Open dashboard
```bash
railway open
```

## Environment Variables
Set in Railway dashboard under Variables tab:
- `[ENV_VAR_NAME]` — [purpose]

Never commit env var values to the repo. Always set via Railway dashboard or CLI:
```bash
railway variables set KEY=value
```

## Health Check
Service health endpoint: `[PROJECT_URL]/health`
Expected response: `200 OK`

## Constraints
- Never run `railway down` without explicit user confirmation
- Never set sensitive env vars via shell history — use Railway dashboard
- Staging and production are separate Railway environments — confirm target before deploying
