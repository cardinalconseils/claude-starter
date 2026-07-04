---
description: "Headroom — input token compression via MCP. Compress large tool payloads before they flood the context window."
allowed-tools:
  - Read
  - Bash
---

# /cks:headroom — Input Compression

Headroom compresses large *inputs* (tool stdout, file reads, Bash output, RAG chunks) before they enter the context window — 60–95% reduction with lossless retrieval. Complements caveman, which compresses *output prose*. See `.claude/rules/compression-boundary.md`.

## Setup (first time)

```bash
pip install "headroom-ai[mcp]"
headroom mcp install
# Restart Claude Code — headroom_compress / headroom_retrieve / headroom_stats now available
```

## Usage

```
/cks:headroom                   Check install status + session compression stats
/cks:headroom setup             Run install walkthrough
/cks:headroom stats             Show tokens saved this session
/cks:headroom status            Verify MCP tools are reachable
```

## When Agents Should Compress

Large payloads worth compressing before reading:
- Bash stdout > ~500 lines (build logs, grep dumps, test output)
- Full-file reads for orientation (not targeted edits)
- API responses / webhook payloads
- Sprint logs, DEVLOG, verbose retro output

Agents call `headroom_compress` on the raw payload, work with the compressed token, then call `headroom_retrieve` only when the original is needed for a precise operation.

## Dispatch

```bash
# Check headroom MCP install status
if ! command -v headroom &>/dev/null; then
  echo "headroom not installed. Run: pip install 'headroom-ai[mcp]'"
  exit 0
fi
headroom --version
echo "MCP tools: headroom_compress / headroom_retrieve / headroom_stats"
echo "Run: headroom_stats (via MCP) to see session savings"
```

## Quick Reference

| MCP Tool | What it does |
|---|---|
| `headroom_compress` | Compress a payload → returns token + key |
| `headroom_retrieve` | Recover original from key |
| `headroom_stats` | Session compression metrics |

Rule: caveman = output prose. Headroom = input payloads. Never stack both on the same content.
