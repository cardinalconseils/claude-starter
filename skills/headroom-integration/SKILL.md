---
name: headroom-integration
description: >
  Integrates the headroom MCP server for input token compression. Use when compressing
  tool stdout, file reads, Bash output, RAG chunks, or any large payload entering the
  context window. Exposes headroom_compress, headroom_retrieve, headroom_stats tools.
  Complements caveman (which compresses output prose). See compression-boundary.md.
allowed-tools: Read, Bash, AskUserQuestion
---

# Headroom — Input Compression Integration

## What Headroom Does

Headroom compresses large *inputs* before they enter Claude's context window — tool stdout, file contents, API responses, grep results. It cuts 60–95% of input tokens with near-lossless reconstruction via `headroom_retrieve`.

Caveman compresses *output prose*. Headroom compresses *input payloads*. They are complementary, not redundant. See `.claude/rules/compression-boundary.md`.

## Setup (one-time per machine)

```bash
pip install "headroom-ai[mcp]"   # requires Python 3.10+
headroom mcp install              # registers the MCP server with Claude Code
```

After `headroom mcp install`, restart Claude Code. The three MCP tools become available:
- `headroom_compress` — compress a message or payload
- `headroom_retrieve` — recover original from compressed context
- `headroom_stats` — report compression metrics for the session

## When to Use

Invoke `headroom_compress` when a payload is large AND the full content is unlikely to be needed verbatim:

| High value | Lower value |
|---|---|
| Bash stdout > 500 lines | Short command output (< 20 lines) |
| Full file reads for orientation | Targeted file reads (specific function) |
| grep results across many files | Single-match grep |
| API/webhook responses | Config key lookups |
| Sprint log / DEVLOG dumps | Current phase CONTEXT.md |

## MCP Tool Reference

### `headroom_compress`

Compresses a message. Returns a compressed token with a retrieval key.

```
Input:  { "message": "<large payload string>" }
Output: { "compressed": "<token>", "key": "<uuid>", "ratio": 0.73 }
```

### `headroom_retrieve`

Recovers original content from a compressed token.

```
Input:  { "key": "<uuid from compress>" }
Output: { "original": "<full content>" }
```

### `headroom_stats`

Reports session-level compression metrics.

```
Output: { "tokens_saved": 12400, "calls": 7, "avg_ratio": 0.68 }
```

## Agent Usage Pattern

When an agent reads a large file or runs a command that produces verbose output:

```
1. Run the tool (Read / Bash / etc.) — get the raw payload
2. If payload > ~200 lines: call headroom_compress with the payload
3. Work with the compressed token — only decompress if specific content is needed
4. Call headroom_retrieve only when the original is required for a precise edit
```

## Security Constraint

Tool output compressed by headroom may contain credentials (env files, config dumps, API responses). Per `.claude/rules/secrets.md`:
- Mask any credential that surfaces in `headroom_retrieve` or `headroom_stats` output
- Never echo a raw secret from a retrieved payload
- The compression step does NOT sanitize secrets — masking is always the agent's responsibility

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll skip compression — this file isn't that big" | 200-line threshold is a guide. When in doubt, compress. Token savings compound across a sprint. |
| "headroom_compress might lose information I need" | Call `headroom_retrieve` when you need the original. Recovery is always available. |
| "Caveman already handles compression" | Caveman handles output prose only. It cannot compress a 10KB Bash stdout. These are different tools. |
| "I'll auto-compress all inputs" | Only compress when explicitly asked or when payload is clearly large. Rule 3 of compression-boundary.md: headroom requires explicit invocation. |

## Verification

- [ ] `headroom mcp install` confirms: "MCP server registered"
- [ ] `headroom_compress` tool appears in Claude Code MCP tool list
- [ ] Compress a test payload and verify ratio > 0 returned
- [ ] `headroom_retrieve` with the returned key restores original content
