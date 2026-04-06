# Peers Tool — claude-peers-mcp

## What It Is
An MCP server enabling peer discovery and messaging between Claude Code instances on the same machine. A shared broker daemon coordinates all communication via localhost.

## Connection
- Broker endpoint: `http://127.0.0.1:7899`
- MCP server name: `claude-peers`
- Database: `~/.claude-peers.db` (SQLite, user-level)
- Transport: stdio (one MCP server per Claude Code session)

## MCP Tools

### list_peers
Discover active Claude Code sessions.
- `scope`: `"machine"` (all) | `"directory"` (same cwd) | `"repo"` (same git root)
- Returns: array of `{ id, pid, cwd, gitRoot, summary, lastSeen }`

### send_message
Send a message to a specific peer.
- `peerId`: target peer's ID (from `list_peers`)
- `message`: text content (use structured JSON for CKS workflows)

### set_summary
Update this session's work summary visible to other peers.
- `summary`: 1-2 sentence description of current work

### check_messages
Poll for incoming messages (fallback — messages also arrive via channel push).
- Returns: array of `{ from, message, timestamp }`

## CLI Commands
```bash
bun cli.ts status         # Broker health + all peers
bun cli.ts peers          # List active peers
bun cli.ts send <id> <msg>  # Send message to peer
bun cli.ts kill-broker    # Stop broker daemon
```

## Environment Variables
- `CLAUDE_PEERS_PORT`: Broker port (default: `7899`)
- `CLAUDE_PEERS_DB`: Database path (default: `~/.claude-peers.db`)
- `OPENAI_API_KEY`: Optional — enables auto-summary via gpt-5.4-nano

## Health Check
```bash
curl -s http://127.0.0.1:7899/health
```
Expected: `200 OK`

## Graceful Degradation
Peers are **100% optional**. If the MCP server is not configured or the broker is not running, all CKS workflows continue in single-session mode. No workflow depends on peer availability.

## Constraints
- Never start/stop the broker from CKS hooks or commands — broker self-manages
- Never rely on auto-summary — agents should call `set_summary` explicitly
- Database lives at user level (`~/`), never in the project directory
