# Tools

Operational reference docs for agents. Each `.md` file documents how to interact with a specific system — external services or CKS internals.

## CKS Internal Tools

| Tool | Purpose | Used By |
|------|---------|---------|
| `prd-state.md` | Read/write `.prd/PRD-STATE.md` — fields, valid values, update protocol | All PRD agents, session hooks |
| `lifecycle-log.md` | Append events to `.prd/logs/lifecycle.jsonl` — schema, event types | Orchestrator, migrator, hooks |
| `phase-transitions.md` | 5-phase navigation — directory layout, artifacts, forward/backward transitions, context loading | All lifecycle agents |

## External Integration Tools

| Tool | Purpose | Used By |
|------|---------|---------|
| `github.md` | GitHub workflows — branches, PRs, CI checks, merge conventions | Deployer, go command |
| `railway.md` | Railway deployment — CLI commands, env vars, health checks | Deployer agent |

## How Agents Use Tools

Agents read tool files when they need to perform the documented operation. Tool docs are the single source of truth for protocols that span multiple agents.

```
Agent needs to update PRD state → reads tools/prd-state.md → follows the protocol
Agent needs to log an event     → reads tools/lifecycle-log.md → uses the schema
Agent needs to advance a phase  → reads tools/phase-transitions.md → checks exit artifacts
```

## Adding New Tools

After `/cks:bootstrap`, add tool references for any external service your project uses:
- Deployment platforms (Vercel, Fly.io, etc.)
- Databases (Supabase, PlanetScale, etc.)
- APIs (Stripe, Twilio, etc.)
- CI/CD (GitHub Actions, etc.)

Copy `github.md` or `railway.md` as a starting template. Replace `[PLACEHOLDER]` markers with real values during bootstrap.
