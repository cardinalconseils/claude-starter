# Peers Tool — claude-peers-mcp

## What It Is
An MCP server providing session awareness across Claude Code instances in the same repo. A broker daemon coordinates peer registration and messaging on localhost.

## Connection
- Broker endpoint: `http://127.0.0.1:7899`
- MCP server name: `claude-peers`
- Database: `~/.claude-peers.db` (SQLite, user-level)
- Transport: stdio (one MCP server per Claude Code session)

## MCP Tools

### list_peers
Discover active sessions. **Always use `scope="repo"`.**
- `scope`: `"repo"` (same git root) — the only scope CKS uses
- Returns: array of `{ id, pid, cwd, gitRoot, summary, lastSeen }`

### set_summary
Update this session's status visible to other peers.
- `summary`: structured string following the format `[activity] context — status | Doc: path`
- Called automatically by `peer-announce.sh` hook — rarely needed manually

### send_message
Send a directive to another session (arrives via channel push).
- `peerId`: target peer's ID (from `list_peers`)
- `message`: directive text (structured JSON or plain text)

## Broker HTTP API (used by hooks)

Hooks can't call MCP tools, so they use the broker directly:

```bash
# Set summary
curl -s http://127.0.0.1:7899/set-summary -X POST \
  -H "Content-Type: application/json" \
  -d '{"id":"PEER_ID","summary":"[sprint:3c] F-010 — implementing"}'

# List peers
curl -s http://127.0.0.1:7899/list-peers -X POST \
  -H "Content-Type: application/json" \
  -d '{"scope":"repo","cwd":"/path","git_root":"/path"}'
```

## Environment Variables
- `CLAUDE_PEERS_PORT`: Broker port (default: `7899`)
- `CLAUDE_PEERS_DB`: Database path (default: `~/.claude-peers.db`)

## Graceful Degradation
Peers are **100% optional**. If the broker is unreachable, all hooks exit 0 silently. No workflow is blocked by peer unavailability.

## Constraints
- Always use `scope="repo"` — never `scope="machine"` (prevents cross-repo contamination)
- Never start/stop the broker from hooks or commands — it self-manages
- Database lives at user level (`~/`), never in the project directory
