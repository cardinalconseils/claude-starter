# Tools

External tool and integration references. Each `.md` file documents how Claude should interact with a specific external tool or platform.

## Available Tools

| Tool | Purpose |
|------|---------|
| `railway.md` | Railway deployment platform — CLI commands, config, troubleshooting |
| `github.md` | GitHub workflows — PRs, issues, actions |

## How Tools Are Used

Tools are referenced by agents and commands when they need to interact with external services. For example, `deployer.md` reads `railway.md` to know how to deploy.

## Adding New Tools

After `/bootstrap`, add tool references for any external service your project uses:
- Deployment platforms (Vercel, Fly.io, etc.)
- Databases (Supabase, PlanetScale, etc.)
- APIs (Stripe, Twilio, etc.)
- CI/CD (GitHub Actions, etc.)
