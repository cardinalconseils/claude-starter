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

## Steps Claude Executes

1. Validate all required environment variables are set
2. Run `./deploy.sh --env [environment]` (or `--dry-run` if flagged)
3. Monitor deployment output and tail logs
4. Run health check against service URL
5. Report: success with URL, or failure with error details

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
