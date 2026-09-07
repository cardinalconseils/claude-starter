# Workflow: Deploy

Environment promotion with quality gates and a post-deploy health check. Ported from the
`deployer` agent. Run by the shipper role. Production deploys are a gated action: the shipper
prepares everything, returns `GATED:` to the chief of staff, and deploys only on explicit
approval in the same turn.

## Environments

| Stage | Purpose | Gate required |
|---|---|---|
| Development | Internal preview, catch obvious bugs | Gate 1 |
| Staging | Real feedback, monitor metrics | Gate 2 |
| Release Candidate | Full validation, performance, security | Gate 3 |
| Production | Live for all users | Gate 4 (post-deploy) |

Gate contents: `skills/prd/references/release-checklist.md` and
`skills/shipping-checklist/SKILL.md`. Validate each gate before promoting.

## Steps

### 0. GitHub issues gate

1. Repo coordinates from `git remote get-url origin`
2. List open issues labeled `cks:blocking` (`skills/github-issues`)
3. Any exist → surface them and ask proceed or stop (`AskUserQuestion`)
4. Stop → exit without deploying
5. GitHub MCP unavailable → log and continue

### 1. Pre-deploy validation

```bash
git status --short
git branch --show-current
{build command}     # detected — see skills/shipping-checklist/workflows/go.md
{test command}
```

Env vars: read `.env.example`, verify every required var is set on the target platform.
Any check fails → report and stop. Never deploy broken code.

### 2. Deploy to target

Detect the platform from config files. Platform-specific commands and config templates:
`skills/cicd-starter/references/deploy-platforms.md`.

| Platform | Config file | Staging | Production |
|---|---|---|---|
| Vercel | `vercel.json` | `vercel --yes` | `vercel --prod --yes` |
| Railway | `railway.toml` | `railway up --environment staging` | `railway up --environment production` |
| Cloudflare | `wrangler.toml` | `npx wrangler deploy --env staging` | `npx wrangler deploy` |
| Fly.io | `fly.toml` | `fly deploy --app {name}-staging` | `fly deploy` |
| Netlify | `netlify.toml` | `netlify deploy --dir=dist` | `netlify deploy --dir=dist --prod` |
| Docker | `Dockerfile` | platform-specific | platform-specific |

The Vercel MCP (`deploy_to_vercel`, `get_deployment`, `get_deployment_build_logs`) is
preferred over the CLI when connected.

### 3. Post-deploy health check

```bash
curl -sf {deploy_url}/api/health || echo "HEALTH_FAIL"
```

Never skip. Health fails → report immediately, suggest rollback.

### 3b. Canary verification

After health passes, a browser canary (console errors, page load, failure keywords) belongs
to the observer role. Return to the chief of staff with the deploy URL and ask for an
observer canary dispatch; result lands in `.cks/canary-last.json`.

- Canary FAIL → do not promote further, suggest rollback
- PASS_WITH_WARNINGS → report warnings, proceed with caution
- PASS → proceed

### 4. Report

```
Deploy: {environment}
  URL:    {deploy_url}
  Health: {PASS/FAIL}
  Canary: {PASS/FAIL/PASS_WITH_WARNINGS/pending}
  Time:   {duration}
```

## Rollback

```bash
vercel rollback                          # Vercel
railway rollback                         # Railway
npx wrangler rollback                    # Cloudflare Workers
fly deploy --image registry.fly.io/...   # Fly.io (redeploy previous image)
netlify rollback                         # Netlify
git revert HEAD && git push              # any platform
```

Production rollback is confirmed with the user first.

## Release URL

After a successful production deploy, return:

```json
{"outcome": "success",
 "release_url": "https://github.com/<owner>/<repo>/releases/tag/<version>",
 "notes": "Deployed to production — health check passed"}
```

`<version>` is read from `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, or a
`.version`/`VERSION` file. The shipper's go flow (`skills/shipping-checklist/workflows/go.md`,
Release node) uses it to close child issues and comment on the GitHub Phase item. When
`.prd/PRD-STATE.md` has `github_phase_item_id: null` or `attractor_mode: false`, those GitHub
operations no-op silently.

## Constraints

- Never deploy to production without all quality gates passing and explicit approval
- Never skip the health check; never deploy with failing tests
- Always report the deployment URL
