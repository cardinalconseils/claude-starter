---
name: mcp-server-authoring
description: >
  Scaffold, build, and deploy MCP (Model Context Protocol) servers in TypeScript.
  MCP is the modern pattern for extending AI tools — your server exposes tools
  that Claude Code, Hermes, and other MCP clients can call. Use when the project
  needs custom AI tool integrations, or when the user says "I need an MCP server."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
---

# MCP Server Authoring for Vibe Coders

MCP (Model Context Protocol) is the universal interface for AI tool integration.
Your MCP server exposes tools that ANY MCP-compatible client can call —
Claude Code, Hermes Agent, Cursor, and 50+ other tools.

## When to Build an MCP Server vs Direct API Calls

| Scenario | Use MCP Server | Use Direct API |
|----------|----------------|----------------|
| One AI agent needs one API call | — | ✅ Simpler |
| Multiple AI agents need the same tool | ✅ Define once, use everywhere | ❌ Duplicate code |
| You want to share tools across projects | ✅ Installable server | ❌ Per-project setup |
| The API has complex auth | ✅ Abstract auth into the server | ❌ Every agent re-auths |
| You're building for an ecosystem | ✅ Others can use your tools | ❌ Locked to your project |

## Project Structure

```
mcp-server/
├── src/
│   ├── index.ts              ← Server entry + transport setup
│   ├── tools/
│   │   ├── index.ts          ← Tool registry
│   │   ├── search.ts         ← Example: web search
│   │   ├── db.ts             ← Example: Supabase query
│   │   └── custom.ts         ← Your custom tool
│   ├── handlers/
│   │   └── prompts.ts        ← Optional: prompt templates
│   └── types.ts
├── package.json
├── tsconfig.json
├── .env.example
├── AGENTS.md
├── CLAUDE.md
├── README.md
└── Dockerfile                ← For Railway/Fly.io deploy
```

## Scaffold Template — MCP Server

### package.json
```json
{
  "name": "mcp-server",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "npx @modelcontextprotocol/inspector tsx src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "deploy:railway": "railway up",
    "deploy:fly": "fly deploy"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0",
    "dotenv": "^16.4.0"
  },
  "devDependencies": {
    "typescript": "^5.5.0",
    "@types/node": "^20.0.0",
    "tsx": "^4.0.0"
  }
}
```

### src/index.ts
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { setupToolHandlers } from "./tools/index.js";
import "dotenv/config";

const server = new Server(
  { name: "mcp-server", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

setupToolHandlers(server);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("MCP server running on stdio");
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
```

### src/tools/index.ts
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { z } from "zod"; // or define inline types

// Register all tools here
export function setupToolHandlers(server: Server) {
  // Example tool: hello
  server.setRequestHandler(
    {
      method: "tools/call",
      params: {
        name: "hello",
        arguments: { name: "World" }
      }
    },
    async (request) => {
      const name = request.params.arguments?.name || "World";
      return {
        content: [{ type: "text", text: `Hello, ${name}!` }]
      };
    }
  );
}

// Tool definitions for client discovery
export const TOOL_DEFINITIONS = [
  {
    name: "hello",
    description: "Say hello to someone",
    inputSchema: {
      type: "object",
      properties: {
        name: { type: "string", description: "Name to greet" }
      }
    }
  }
];
```

### Transport Options

| Transport | When to Use | Config |
|-----------|-------------|--------|
| `StdioServerTransport` | Local development, Claude Code plugin | Default, no config |
| `SSEServerTransport` | Remote server, accessed over HTTP | Needs a web server |
| HTTP (custom) | Railway/Fly.io deployment | Webhook-based |

### .env.example
```
# Set these in Railway/Fly.io secrets, never commit
OPENROUTER_API_KEY=sk-or-...
SUPABASE_URL=https://...
SUPABASE_SERVICE_KEY=...
```

## Deployment Targets

| Platform | Cost | Notes |
|----------|------|-------|
| Railway | $5-20/mo | `railway up`, auto-deploy from GitHub, good for stdio + HTTP |
| Fly.io | $2-20/mo | `fly deploy`, low-latency global, good for SSE |
| Cloudflare Workers | Free-$5 | Good for lightweight HTTP endpoints, no stdio |
| Local/Dev only | Free | Stdio transport, Claude Code discovers from plugin dir |

## Connecting to Clients

### Claude Code
```json
// In CLAUDE.md or Claude Code config
// MCP servers are configured via claude_code_config
{"mcpServers": {"my-server": {"command": "node", "args": ["dist/index.js"]}}}
```

### Hermes Agent
```yaml
# In .hermes/config.yaml
mcp_servers:
  - package: local
    args:
      command: node
      args:
        - dist/index.js
```

### n8n
Use the MCP node in n8n to connect to your MCP server's HTTP endpoint.

## Development Workflow

```bash
# Dev with MCP Inspector UI
npm run dev
# → Opens http://localhost:5173 — test tools visually

# Or test via CLI
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"search","arguments":{"query":"test"}}}' | npx tsx src/index.ts
```

## Common Tools to Build First

| Tool | Purpose | API Needed |
|------|---------|------------|
| `web-search` | Search the web | Tavily, SerpAPI, or Perplexity |
| `db-query` | Query Supabase | Supabase service key |
| `kb-search` | Knowledge base retrieval | Supabase pgvector |
| `n8n-trigger` | Trigger n8n workflow | n8n webhook URL |
| `email-send` | Send email | Resend API key |
| `crm-lookup` | CRM customer lookup | API key (varies) |

## Verification

- [ ] `npm install && npm run build` succeeds
- [ ] Server starts without errors
- [ ] MCP Inspector shows all tool definitions
- [ ] At least one tool call returns valid response
- [ ] .env.example has all required env vars (no real keys)
- [ ] Deployment config (Dockerfile or railway.toml) exists
- [ ] Client config documented (Claude Code / Hermes / n8n)