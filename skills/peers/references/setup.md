# Peer Setup Guide

## Prerequisites

- **Bun runtime**: Required to run the MCP server and broker
  ```bash
  curl -fsSL https://bun.sh/install | bash
  ```
- **Claude Code v2.1.80+**: Channel push notifications require this version or later
- **Web-based Claude login**: Channel protocol requires web auth (API key login is insufficient)

## Installation

### Step 1: Clone the repository
```bash
git clone https://github.com/louislva/claude-peers-mcp.git ~/.claude-peers-mcp
```

### Step 2: Install dependencies
```bash
cd ~/.claude-peers-mcp && bun install
```

### Step 3: Register MCP server with Claude Code
```bash
claude mcp add --scope user --transport stdio claude-peers -- bun ~/.claude-peers-mcp/server.ts
```

The `--scope user` flag registers the server globally, not per-project.

### Step 4: Verify
Restart Claude Code, then run:
```bash
bun ~/.claude-peers-mcp/cli.ts status
```

Expected: broker health check passes, your session appears as a peer.

## Configuration

### Environment Variables (optional)

| Variable | Default | Purpose |
|----------|---------|---------|
| `CLAUDE_PEERS_PORT` | `7899` | Broker HTTP port |
| `CLAUDE_PEERS_DB` | `~/.claude-peers.db` | SQLite database path |
| `OPENAI_API_KEY` | (none) | Auto-summary via gpt-5.4-nano (optional) |

CKS does not require `OPENAI_API_KEY`. Agents call `set_summary` explicitly.

## Broker Lifecycle

The broker daemon starts automatically when the first MCP server connects. You do NOT need to manage it manually.

- **Start**: Automatic on first Claude Code session with peers configured
- **Stop**: `bun ~/.claude-peers-mcp/cli.ts kill-broker`
- **Cleanup**: Stale peers are auto-removed every 30 seconds via process liveness checks

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| `list_peers` returns empty | Broker not running | Start a Claude Code session — broker auto-launches |
| `ECONNREFUSED` on port 7899 | Broker crashed or not started | Restart Claude Code or run `bun ~/.claude-peers-mcp/broker.ts` manually |
| Port 7899 in use | Another service on the port | Set `CLAUDE_PEERS_PORT=7900` in your shell profile |
| MCP server not found | Not registered | Re-run `claude mcp add` command from Step 3 |
| Channel push not working | API key login | Log in via web at claude.ai, not via API key |
| Stale peers shown | Process died without cleanup | Broker auto-cleans every 30s; wait or restart broker |

## Uninstalling

```bash
claude mcp remove claude-peers
rm -rf ~/.claude-peers-mcp ~/.claude-peers.db
```
