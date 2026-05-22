# Recipe: infra

## Trigger
Deployment failure, container exit, CI pipeline red, environment variable missing, permission denied on deploy.

## Severity
`blocking` — Auto-recoverable: No

## Steps

1. Read the deployment log or CI output to identify the failing step.
2. Check environment variables — missing vars are the most common cause.
3. Check container exit code if applicable (`docker ps -a`, `kubectl describe pod`).
4. Check health check endpoint if deployment completed but health check failed.
5. If permission denied: check IAM roles, service account bindings, or SSH keys.
6. Escalate to user with: failing step, error message, and suspected cause.

## Auto-Fix: None
Infrastructure failures require access to deployment targets that the agent cannot reach. Provide diagnosis only.

## Escalation Message
> Infra failure detected. Provide the user with the exact failing step, the error message, and which environment variable or permission is likely missing.
