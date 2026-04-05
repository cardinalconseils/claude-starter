# Recipe: mcp_startup

## Detection Confirmation

Before applying this recipe, verify:
- Error mentions MCP, tool server, or connection failure
- This is NOT a tool execution failure (tool was invoked but returned an error — that's a different issue)
- The MCP server was expected to be available for the current workflow

## Auto-Recovery Steps

### Step 1: Identify the failing server

Parse the error for:
- Server name (e.g., "stitch", "firecrawl", "context7")
- Failure type: connection refused, timeout, auth error, config missing

### Step 2: Classify MCP failure subtype

| Subtype | Signal | Auto-Fix? |
|---------|--------|-----------|
| Connection refused | `ECONNREFUSED`, `connection refused` | Yes — retry once after 5s |
| Timeout | `timeout`, `ETIMEDOUT` | Yes — retry once with longer timeout |
| Auth error | `401`, `403`, `unauthorized` | No — needs credential update |
| Config missing | Server not in MCP config | No — needs manual setup |
| Server crashed | `SIGTERM`, `exited with code` | Yes — retry once |

### Step 3: Attempt recovery (if auto-fixable)

For connection/timeout/crash:
- Wait 5 seconds
- Retry the operation that triggered the MCP call
- If the retry succeeds → emit `recovery.succeeded`

### Step 4: Enter degraded mode (if not recoverable)

When an MCP server cannot be recovered:
1. Note which capabilities are lost (e.g., "Stitch unavailable — cannot generate screen designs")
2. Check if the current workflow can proceed without this server
3. If workflow can continue → emit `recovery.degraded` with lost capabilities
4. If workflow requires this server → emit `recovery.escalated`

## Degraded Mode Behavior

| Server | Lost Capability | Workflow Impact |
|--------|----------------|-----------------|
| Stitch | Screen generation | Design phase blocked, sprint can continue |
| Firecrawl | Web scraping | Research degraded, can use WebSearch fallback |
| Context7 | Library docs | Can use WebSearch as fallback |
| Custom MCP | Varies | Assess per-server |

## Escalation

Report to user:
```
Failure: mcp_startup ({server_name})
Subtype: {connection_refused / timeout / auth / config}
Attempted: {retry / nothing if auth/config}
Lost capability: {what this server provides}
Workaround: {fallback if available, or "none"}
Action needed: {check server status / update credentials / add config}
```
