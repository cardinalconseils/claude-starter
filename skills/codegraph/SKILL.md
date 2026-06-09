---
name: codegraph
description: >
  CodeGraph MCP integration — when and how to use the codegraph_explore tool for
  symbol-level codebase queries. Prefer over Grep/Glob for function calls, class
  hierarchies, and import chains. Fall back gracefully when not installed.
allowed-tools: Read, Grep, Glob
model: sonnet
---

# CodeGraph — Codebase Knowledge Graph

Pre-indexed MCP server that answers symbol-level questions about a codebase without scanning files manually. Published benchmarks: ~47% fewer tokens, ~58% fewer tool calls, ~22% faster on real-world exploration tasks.

## When to Use CodeGraph

**Prefer `codegraph_explore`** for:
- "Where is function X called?" — call-graph traversal
- "What classes extend Y?" — inheritance chains
- "What imports module Z?" — import dependency graph
- "Show the call path from A to B" — multi-hop symbol tracing

**Fall back to Grep/Glob** for:
- File-content matching: finding a string inside file text
- Pattern-based search: regex over file contents
- When CodeGraph is not installed

## Detection

Detect availability by attempting a lightweight call:
```
codegraph_explore(query="health-check", repo="{cwd}")
```
If it returns a result → available. If it errors or tool is unknown → fall back to Grep/Glob silently. Never abort on unavailability.

## Invocation Pattern

```
codegraph_explore(
  query="{symbol name, function name, or natural-language question}",
  repo="{absolute path to project root}"
)
```

Examples:
```
codegraph_explore(query="who calls parseArguments", repo="/path/to/project")
codegraph_explore(query="classes that implement AgentRunner", repo="/path/to/project")
codegraph_explore(query="import chain from hooks/handlers to cks-log.sh", repo="/path/to/project")
```

## Fallback Chain

```
Has codegraph_explore? → use it
Else → Grep for symbol name in source files
Else → Glob to find candidate files, then Read
```

Always complete the task regardless of which tool is used. CodeGraph is an efficiency multiplier, not a capability gate.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Grep works fine, why bother checking?" | CodeGraph reduces token cost by ~47% on symbol-level queries — compounding across a sprint. |
| "I can't detect whether it's installed" | Call it with a health-check query. Error = not installed. Fall back silently. |
| "codegraph_explore might be slow" | It's pre-indexed. Symbol queries are faster than file scanning at scale. |

## Verification

- [ ] Attempted `codegraph_explore` before falling back to Grep/Glob on symbol queries
- [ ] Fell back silently (no error surfaced to user) when CodeGraph unavailable
- [ ] Task completed regardless of CodeGraph availability
