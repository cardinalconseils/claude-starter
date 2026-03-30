---
description: "Security scan — audit app code AND pipeline config for vulnerabilities"
argument-hint: "[--app | --config | --full]"
allowed-tools:
  - Read
  - Agent
---

# /cks:security — Security Audit

Dispatch the **security-auditor** agent (which has `skills: prd` loaded at startup).

## Mode Detection

Parse `$ARGUMENTS`:

| Argument | Scan Mode |
|----------|-----------|
| `--app` | App code only (OWASP, secrets, dependencies) |
| `--config` | Claude/CKS config only (CLAUDE.md, hooks, MCP, .env) |
| `--full` or no args | Full scan (app + config + dependencies) |

## Dispatch

```
Agent(subagent_type="security-auditor", prompt="Run a {detected mode} security audit. Project root: {cwd}. Scan for OWASP Top 10, secrets, dependency vulnerabilities, and config issues. Present a graded report (A-F) and ask before applying any fixes. Arguments: $ARGUMENTS")
```

## Quick Reference

```
/cks:security              → Full scan (app + config + dependencies)
/cks:security --app        → App code only
/cks:security --config     → Claude/CKS config only
```

The security-auditor agent handles: OWASP scanning, secrets detection, framework-specific checks, dependency audit, config audit, graded reporting, and fix proposals with user confirmation.
