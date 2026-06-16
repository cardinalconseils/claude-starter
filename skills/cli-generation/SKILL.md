---
name: cli-generation
description: "Domain knowledge for generating typed Go CLIs + MCP servers + Claude skills from any external API using cli-printing-press. Covers when to use it, what it produces, install prerequisites, and CKS lifecycle fit. Step-by-step flows live in workflows/."
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

# CLI Generation Skill

## What This Is

`cli-printing-press` (github.com/mvanhorn/cli-printing-press) turns any external API —
REST, GraphQL, or browser-sniffed — into three artifacts:

1. **Typed Go CLI** — an `api-name` binary with subcommands, flags, typed exit codes,
   and a `--compact` flag optimized for agent consumption
2. **MCP server** — a matching Model Context Protocol server Claude Code can register
3. **Claude skill** — a `SKILL.md` the generating agent files into the project

CKS wraps this tool via `/cks:print-cli`. The binary does the work; CKS files the output.

## When to Use

- CONTEXT.md identifies a third-party API the sprint must call
- An agent needs to call an external service and no MCP exists yet
- `prd-discoverer` surfaced a `💡 SUGGESTION` for a detected API

## What It Does NOT Do

- It does not handle authentication for you — the generated CLI has its own auth flow
- It does not guarantee the generated CLI matches undocumented API behavior
- It does not replace hand-authored MCP servers when precision is required

## Lifecycle Fit

| Phase | Use |
|---|---|
| Phase 1 — Discover | prd-discoverer surfaces suggestion when API detected in CONTEXT.md |
| Phase 2 — Design | Generated CLI/MCP becomes a named design component, not a TODO |
| Phase 3 — Sprint | Agents call the CLI binary directly; no integration sprint required |

## Output Structure (upstream)

After `printing-press print --api <name>`, artifacts live under:

```
~/printing-press/
  library/<api-name>/
    cmd/                  ← Go CLI source
    mcp/                  ← MCP server source
    SKILL.md              ← Claude skill
  manuscripts/<api-name>/ ← API schema snapshot
  .runstate/              ← Binary state (never read by CKS)
```

## CKS Filing Convention

When inside a sprint: copy the generated `SKILL.md` summary to
`.prd/phases/{NN}/integrations/<api-name>.md`.

When standalone: note the artifact paths in the agent summary; do not copy files.

## Prerequisites

See `workflows/install-printing-press.md` for the full install flow.

Summary:
- Go 1.21+ (`brew install go`)
- One-shot installer: `curl -fsSL https://raw.githubusercontent.com/mvanhorn/cli-printing-press/main/scripts/install.sh | bash`
- Installs both binary (`cli-printing-press`) and Claude Code skills in one step
- Restart Claude Code after install

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write the integration agent by hand, it's faster" | Printing-press generates a typed CLI + MCP in one command. Hand-writing takes an hour and misses compact-mode. |
| "The API isn't in the printing-press catalog, so I'll skip it" | Use `--url` sniff mode for any API not in the catalog. |
| "Go isn't installed, I'll skip this step" | Surface the ACTION REQUIRED block. Don't silently skip. |
| "I'll echo the raw binary output to the user" | Parse and summarize only. Raw stdout is not user-facing output. |

## Verification

- [ ] `go version` returns 1.21+
- [ ] `printing-press version` exits 0
- [ ] Generated SKILL.md exists under `~/printing-press/library/<api-name>/`
- [ ] Integration summary card written to `.prd/phases/{NN}/integrations/<api-name>.md` (if in sprint)
- [ ] No raw stdout or auth tokens echoed to user
