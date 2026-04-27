---
name: environment-management
description: >
  Environment separation and configuration management for production applications.
  Use when: setting up dev/staging/production environments, managing environment
  variables, configuring secrets, adding feature flags, or deploying across
  environments.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Environment Management

## Overview

Environment separation prevents development mistakes from reaching real users. Every change should pass through at least two environments before production. Configuration that varies between environments belongs in environment variables, never hardcoded.

## When to Use

- Setting up a new project's environment structure
- Adding environment variables or secrets
- Configuring feature flags for staged rollout
- Setting up deployment pipelines
- Promoting changes between environments
- Reviewing environment security

## When NOT to Use

- Throwaway scripts or one-off experiments
- Local-only tools that will never be deployed
- Prototype stage with no users (but plan for it)

## Process

### 1. Environment Separation

| Environment | Purpose | Data | Deploys |
|---|---|---|---|
| Development | Local coding and debugging | Seed/mock data | On save (hot reload) |
| Staging | Pre-production validation | Anonymized production snapshot | On PR merge |
| Production | Real users, real data | Live data | Manual trigger or release tag |

**Minimum viable:** dev + production. **Ideal:** dev + staging + production.

### 2. Environment Variables

All configuration that varies by environment goes in env vars:
- Database URLs and connection strings
- API keys and third-party credentials (e.g. `OPENROUTER_API_KEY`, `STRIPE_SECRET_KEY`)
- AI model assignments (e.g. `OPENROUTER_MODEL_FAST`, `OPENROUTER_MODEL_REASON`)
- Log levels and debug flags
- Feature flags
- Service URLs (API base URL, CDN URL)

### 3. .env File Management

- `.env.example` — Checked into repo with placeholder values. Documents every required variable.
- `.env.local` / `.env` — Gitignored. Contains real values for local development.
- Never commit `.env` with real secrets. Ever.

Verify `.gitignore` includes: `.env`, `.env.local`, `.env.*.local`

### 4. Secrets Management

| Approach | When to Use |
|---|---|
| Environment variables | Minimum viable — all platforms support them |
| Platform secrets (Vercel env, Railway secrets) | Managed hosting — encrypted at rest |
| Secrets manager (AWS SSM, HashiCorp Vault) | Enterprise — rotation, audit trails, access control |

Never store secrets in: code, git history, CI logs, client-side bundles, or Slack messages.

### 5. Per-Environment Configuration

**Development:** Verbose logging, debug mode on, local database, mock external services, hot reload.

**Staging:** Production-like config, test/anonymized data, real external services (sandbox mode), CI/CD deployed.

**Production:** Minimal logging (info+error), debug off, real database, HTTPS enforced, error tracking active.

### 6. Feature Flags

Use for staged rollout and safe deployment.

**Simple (small projects):** Boolean env var (`FEATURE_NEW_CHECKOUT=true`). Toggle per environment.

**Advanced (larger projects):** Feature flag service (LaunchDarkly, Unleash, Flipt). Percentage rollout, user targeting, kill switch.

### 7. Database Per Environment

Never share a database between environments. One wrong query in dev wipes production data.

- Dev: local database (SQLite, local Postgres)
- Staging: separate cloud database with anonymized data
- Production: isolated, backed up, access-controlled

### 8. Deploy Pipeline

Dev deploys on push (automatic). Staging deploys on PR merge (automatic). Production deploys on release tag or manual approval (deliberate).

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "One environment is fine for now" | Deploying untested changes to production is gambling with user data. |
| "I'll just use the production database for testing" | One wrong DELETE statement and you have lost real user data. |
| "Env vars are overkill" | Hardcoded config means redeploying to change a value. Env vars change without code changes. |
| "We'll add staging later" | Without staging, every deploy is a production experiment on real users. |
| "Secrets in code are fine, it's a private repo" | Private repos get forked, cloned, and shared. Secrets in code are secrets in every copy. |

## Red Flags

- Production database URL hardcoded in source code
- `.env` file committed to git with real secrets
- No `.env.example` documenting required variables
- Same database used for development and production
- No staging environment — dev ships straight to production
- Secrets visible in CI/CD logs
- Feature flags that are never cleaned up after full rollout

## Verification

- [ ] At least dev + production environments exist
- [ ] All varying config uses environment variables (not hardcoded)
- [ ] `.env.example` exists with all required variables documented
- [ ] `.env` / `.env.local` is in `.gitignore`
- [ ] No secrets in source code or git history
- [ ] Each environment has its own database
- [ ] Deploy pipeline enforces environment progression
- [ ] Feature flags have a cleanup plan after rollout
