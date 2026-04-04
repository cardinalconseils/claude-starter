---
description: "Deploy project to configured Railway environment with health checks"
allowed-tools:
  - Agent
---

# /deploy

## What It Does
Deploys [PROJECT_NAME] to the configured Railway environment. Validates
environment variables, runs the build, triggers deployment, and confirms
the service is healthy post-deploy.

## Usage
```
/deploy [--env production|staging] [--dry-run]
```

## Arguments
| Argument | Required | Description |
|----------|----------|-------------|
| `--env` | No | Target environment (default: production) |
| `--dry-run` | No | Validate config without deploying |

## Dispatch

```
Agent(subagent_type="deployer", prompt="Deploy the project. Read .prd/PRD-STATE.md for context. Validate environment variables, run the build, trigger deployment, and confirm health. Args: $ARGUMENTS")
```

## Output
Deployment status, service URL if successful, error log if failed.

## Example
```
/deploy --env staging
```
Deploys to staging, validates env vars, confirms health check passes.

## Constraints
- Never deploy with missing required environment variables
- Always run health check — never report success without it
- Production deploys require explicit `--env production` flag
