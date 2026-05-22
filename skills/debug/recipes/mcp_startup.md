# Recipe: mcp_startup

## Trigger
MCP server connection refused, handshake timeout, tool not available, ECONNREFUSED.

## Severity
`degraded` — Auto-recoverable: Yes (retry once, then skip)

## Steps

1. Check the MCP server config — is the server URL and port correct?
2. Retry the connection once (MCP servers sometimes start slowly).
3. If still failing: check if the server process is running (`ps aux | grep mcp` or equivalent).
4. If process not running: surface the start command to the user.
5. If process running but refusing connections: check port binding and firewall rules.
6. If MCP is non-critical for the current task: skip it and continue with a warning in the output.

## Auto-Fix: Retry once, then degrade gracefully
MCP startup failures should not block the session. Retry, then proceed without the tool if still failing.

## Escalation Message
> MCP server unreachable after one retry. If the tool is required for this task, the user must start the server manually before proceeding.
