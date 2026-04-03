# Deploy Platform Reference

Multi-platform deployment config templates. The bootstrap scanner detects deploy platforms from config files in Step 2b. Use this reference to generate the correct deploy configuration.

## Platform Detection

| File Found | Platform | Config Template |
|------------|----------|----------------|
| `vercel.json` or `next.config.*` | Vercel | See Vercel section |
| `railway.toml` | Railway | See `railway-deploy.md` |
| `fly.toml` | Fly.io | See Fly.io section |
| `wrangler.toml` or `wrangler.jsonc` | Cloudflare Workers/Pages | See Cloudflare section |
| `netlify.toml` | Netlify | See Netlify section |
| `Dockerfile` or `docker-compose.yml` | Docker (generic) | See Docker section |
| None detected | Ask user | Present platform options |

If multiple detected, ask user which is primary.

---

## Vercel

### Config: `vercel.json`

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "framework": "nextjs"
}
```

Adapt `framework` and `outputDirectory` based on detected stack:
- Next.js → `"nextjs"`, `.next`
- Vite/React → `null`, `dist`
- SvelteKit → `"sveltekit"`, `.svelte-kit`

### Deploy Commands

```bash
# Preview (Dev/Staging) — auto-generates unique URL
vercel --yes

# Production
vercel --prod --yes

# Rollback
vercel rollback
```

### Environment Variables

Set via Vercel dashboard or CLI:
```bash
vercel env add SECRET_KEY production
vercel env add SECRET_KEY preview
```

### Health Check

Vercel auto-checks build success. For runtime health:
```bash
curl -sf https://{deploy_url}/api/health
```

---

## Cloudflare Workers / Pages

### Config: `wrangler.toml`

**Workers:**
```toml
name = "[PROJECT_NAME]"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
ENVIRONMENT = "production"
```

**Pages:**
```toml
name = "[PROJECT_NAME]"
pages_build_output_dir = "dist"

[build]
command = "npm run build"
```

### Deploy Commands

```bash
# Workers
npx wrangler deploy                    # Production
npx wrangler deploy --env staging      # Staging (requires [env.staging] in wrangler.toml)

# Pages
npx wrangler pages deploy dist         # Production
npx wrangler pages deploy dist --branch staging  # Preview

# Rollback
npx wrangler rollback
```

### Staging Environment (Workers)

Add to `wrangler.toml`:
```toml
[env.staging]
name = "[PROJECT_NAME]-staging"
vars = { ENVIRONMENT = "staging" }
```

---

## Fly.io

### Config: `fly.toml`

```toml
app = "[PROJECT_NAME]"
primary_region = "iad"

[build]

[http_service]
  internal_port = 3000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 256
```

### Deploy Commands

```bash
# Deploy (auto-detects Dockerfile or buildpacks)
fly deploy

# Deploy to staging (separate app)
fly deploy --app [PROJECT_NAME]-staging

# Rollback
fly releases --app [PROJECT_NAME]
fly deploy --image registry.fly.io/[PROJECT_NAME]:v{N}
```

### Health Check

```bash
fly status --app [PROJECT_NAME]
curl -sf https://[PROJECT_NAME].fly.dev/health
```

---

## Netlify

### Config: `netlify.toml`

```toml
[build]
  command = "npm run build"
  publish = "dist"

[build.environment]
  NODE_VERSION = "20"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### Deploy Commands

```bash
# Preview
netlify deploy --dir=dist

# Production
netlify deploy --dir=dist --prod

# Rollback
netlify rollback
```

---

## Docker (Generic)

### Config: `Dockerfile`

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Deploy Commands

Depends on hosting provider. Docker builds are used by Railway, Fly.io, AWS ECS, Google Cloud Run, etc.

```bash
# Build
docker build -t [PROJECT_NAME] .

# Run locally
docker run -p 3000:3000 --env-file .env.local [PROJECT_NAME]

# Push to registry
docker push registry/[PROJECT_NAME]:latest
```

---

## Bootstrap Integration

When generating CLAUDE.md (Step 4), use the detected platform to fill:

```markdown
## Stack
- **Deployment**: {platform} ({config file})
```

When generating `deploy.sh` or deploy instructions, select the matching template above.

If no platform detected and user selects one during intake, generate the config file in Step 5.

## Staging Environment Setup Guidance

Every platform above supports staging. When bootstrapping:

1. **Vercel**: Staging = any non-production deploy (automatic from PRs/branches)
2. **Railway**: Create a separate environment in Railway dashboard
3. **Cloudflare**: Add `[env.staging]` to wrangler.toml
4. **Fly.io**: Create `[PROJECT_NAME]-staging` app
5. **Netlify**: Staging = branch deploys (automatic)
6. **Docker**: Staging = separate compose profile or deployment target

Include this in the generated CLAUDE.md under "Key Workflows > Deploying".
