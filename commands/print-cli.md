---
description: "Generate a CLI + MCP server + Claude skill for any external API using cli-printing-press"
argument-hint: "[--api <name|url>]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:print-cli — API → CLI + MCP + Skill Generator

Turn any external API into an agent-callable CLI + MCP server + Claude Code skill in one shot.
Wraps [cli-printing-press](https://github.com/mvanhorn/cli-printing-press) — the tool runs
locally; CKS files the generated artifacts into your project.

## Arguments

| Arg | Action |
|---|---|
| `--api <name>` | Generate from a known API name (`linear`, `notion`, `espn`, etc.) |
| `--url <url>` | Sniff schema from a website URL, then generate |
| (no args) | Prompts for API name or URL |

## Dispatch

```
Agent(
  subagent_type="cks:printing-press-runner",
  prompt="
    MODE: {--api <name> → named | --url <url> → sniff | no args → ask}
    ARG: {$ARGUMENTS}
    Check Go runtime, run cli-printing-press, parse output, file generated
    skill + MCP config into the project. Surface ACTION REQUIRED if Go is
    absent. Follow cli-generation skill for all steps.
  "
)
```

## Quick Reference

```
/cks:print-cli --api linear       — generate Linear CLI + MCP + skill
/cks:print-cli --api notion       — generate Notion CLI + MCP + skill
/cks:print-cli --url https://...  — sniff schema from URL, then generate
/cks:print-cli                    — prompts for API name or URL
```

## When to Use

- When CONTEXT.md identifies an external API dependency
- When an agent needs to call a third-party API and no MCP exists yet
- After seeing a `💡 SUGGESTION` from prd-discoverer about a detected API
