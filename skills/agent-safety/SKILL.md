---
name: agent-safety
description: "Leash container security for AI agents — Cedar policy generation, minimal-privilege patterns, stack-aware policy templates for sandboxing Claude Code sessions"
allowed-tools: Read, Glob, Grep, Bash, Write
model: sonnet
---

# Agent Safety — Leash Cedar Policy Generation

## Purpose

Generate minimal-privilege Cedar policy files for Leash, a container platform that sandboxes AI coding agents (Claude Code, Codex, Gemini). Policies define exactly what the agent can read, write, execute, and reach over the network.

Leash: `npm install -g @strongdm/leash` → `leash --open claude`

## Cedar Policy Anatomy

```cedar
[permit|forbid] (principal, action == Action::"PascalCase", resource)
  when { conditions };
```

- `permit` allows; `forbid` overrides conflicting permits
- Default posture: **deny everything not explicitly permitted**
- Statements evaluated top-to-bottom; first match wins
- `forbid` always beats `permit` for the same resource

## Entity Types

| Entity | Format | Notes |
|--------|--------|-------|
| `Dir::"/path/"` | Directory | Trailing `/` required for recursive match |
| `File::"/path"` | Single file | Exact path match |
| `Host::"domain"` | Hostname or IP | Supports leading `*.` wildcard only |
| `Host::"host:port"` | Host + port | Port is optional |
| `MCP::Server::"host"` | MCP server | Full hostname |
| `MCP::Tool::"name"` | MCP tool | Tool name as registered |

## Supported Actions

| Action | What It Controls |
|--------|-----------------|
| `Action::"FileOpen"` | Any file open (read or write) |
| `Action::"FileOpenReadOnly"` | Read-only file access |
| `Action::"FileOpenReadWrite"` | Write/create/truncate access |
| `Action::"ProcessExec"` | Spawning processes/commands |
| `Action::"NetworkConnect"` | Outbound network connections |
| `Action::"HttpRewrite"` | Injecting HTTP headers (auth forwarding) |
| `Action::"McpCall"` | Calling MCP tools |

## Policy Patterns by Concern

### Workspace Access
```cedar
// Allow full read/write to project workspace
permit (principal, action == Action::"FileOpenReadWrite", resource)
  when { resource in [ Dir::"/workspace/" ] };

// Block secrets files even within workspace
forbid (principal, action == Action::"FileOpen", resource)
  when { resource in [
    File::"/workspace/.env",
    File::"/workspace/.env.local",
    File::"/workspace/.env.production"
  ] };
```

### System Binaries
```cedar
// Allow standard toolchain execution
permit (principal, action == Action::"ProcessExec", resource)
  when { resource in [
    Dir::"/bin/", Dir::"/usr/bin/", Dir::"/usr/local/bin/",
    Dir::"/usr/lib/", Dir::"/nix/store/"
  ] };

// Block recon/attack tools explicitly
forbid (principal, action == Action::"ProcessExec", resource)
  when { resource in [
    File::"/usr/bin/nmap", File::"/usr/bin/netcat",
    File::"/usr/bin/curl"   // use forbid only if network-sensitive
  ] };
```

### Network Access
```cedar
// Allow only known upstream APIs
permit (principal, action == Action::"NetworkConnect", resource)
  when { resource in [
    Host::"api.github.com",
    Host::"registry.npmjs.org",
    Host::"pypi.org"
  ] };

// Block everything else on the network
forbid (principal, action == Action::"NetworkConnect", resource);
```

### MCP Tool Governance
```cedar
// Block dangerous MCP tools
forbid (principal, action == Action::"McpCall", resource)
  when { resource in [
    MCP::Tool::"execute-shell",
    MCP::Tool::"run-terminal-command"
  ] };
```

### HTTP Header Injection (auth forwarding)
```cedar
permit (principal, action == Action::"HttpRewrite",
        resource == Host::"api.example.com")
  when { context.header == "Authorization" && context.value == "Bearer ${TOKEN}" };
```

## Stack-Aware Policy Templates

### Next.js / Node.js
```cedar
// Workspace
permit (principal, action == Action::"FileOpenReadWrite", resource)
  when { resource in [ Dir::"/workspace/", Dir::"/root/.npm/" ] };
forbid (principal, action == Action::"FileOpen", resource)
  when { resource in [ File::"/workspace/.env", File::"/workspace/.env.local" ] };

// Execution
permit (principal, action == Action::"ProcessExec", resource)
  when { resource in [
    Dir::"/bin/", Dir::"/usr/bin/", Dir::"/usr/local/bin/",
    Dir::"/workspace/node_modules/.bin/"
  ] };

// Network — npm + Vercel + common AI/DB hosts
permit (principal, action == Action::"NetworkConnect", resource)
  when { resource in [
    Host::"registry.npmjs.org", Host::"api.vercel.com",
    Host::"api.openai.com", Host::"api.anthropic.com"
  ] };
forbid (principal, action == Action::"NetworkConnect", resource);
```

### Python
```cedar
permit (principal, action == Action::"FileOpenReadWrite", resource)
  when { resource in [ Dir::"/workspace/", Dir::"/root/.cache/pip/" ] };
forbid (principal, action == Action::"FileOpen", resource)
  when { resource in [ File::"/workspace/.env" ] };

permit (principal, action == Action::"ProcessExec", resource)
  when { resource in [ Dir::"/bin/", Dir::"/usr/bin/", Dir::"/usr/local/bin/" ] };

permit (principal, action == Action::"NetworkConnect", resource)
  when { resource in [
    Host::"pypi.org", Host::"files.pythonhosted.org"
  ] };
forbid (principal, action == Action::"NetworkConnect", resource);
```

### Go
```cedar
permit (principal, action == Action::"FileOpenReadWrite", resource)
  when { resource in [ Dir::"/workspace/", Dir::"/root/go/" ] };
forbid (principal, action == Action::"FileOpen", resource)
  when { resource in [ File::"/workspace/.env" ] };

permit (principal, action == Action::"ProcessExec", resource)
  when { resource in [ Dir::"/bin/", Dir::"/usr/bin/", Dir::"/usr/local/go/bin/" ] };

permit (principal, action == Action::"NetworkConnect", resource)
  when { resource in [ Host::"proxy.golang.org", Host::"sum.golang.org" ] };
forbid (principal, action == Action::"NetworkConnect", resource);
```

## Policy Generation Process

When generating a policy for a project:

1. **Detect stack** — read `package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`
2. **Detect .env files** — glob for `.env*` in root; add explicit `forbid` for each
3. **Detect external API hosts** — grep for API base URLs, SDKs, service clients
4. **Detect MCP servers in use** — read `.claude/` settings if present
5. **Start from stack template** — extend with project-specific hosts and paths
6. **Add secrets-first forbids** — always forbid .env before permitting workspace
7. **End with network deny-all** — always close with `forbid NetworkConnect` as default

## Output Location

Write the policy to `.leash/policy.cedar` in the project root.

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "I'll just allow all network access" | That defeats the entire point of sandboxing |
| "The .env block is optional if workspace is allowed" | Workspace permit does NOT protect secrets — forbid wins for specific files |
| "I'll skip MCP governance if it seems complex" | MCP tools are the highest-risk attack surface |
| "Allow /usr/ is enough for processes" | Node projects need `node_modules/.bin/` too; Go needs its own bin dir |
| "I'll put permit before forbid for readability" | Order doesn't matter for permit/forbid semantics — forbid always wins |

## Verification

After generating `.leash/policy.cedar`:
- [ ] Every `.env*` file has an explicit `forbid FileOpen`
- [ ] Network ends with a bare `forbid NetworkConnect` catch-all
- [ ] Workspace write permit precedes all specific file forbids
- [ ] No wildcards used except leading `*.` on Host entities
- [ ] All directory paths end with `/`
- [ ] File tells user: `leash --open claude` to activate
