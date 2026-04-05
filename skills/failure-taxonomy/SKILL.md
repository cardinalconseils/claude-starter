---
name: failure-taxonomy
description: >
  Classify failures into structured categories and select recovery recipes.
  Use when: diagnosing errors, sprint failures, QA failures, build errors,
  test failures, MCP issues, branch conflicts, or any failure that needs
  classification before repair. Enables "recovery before escalation" pattern.
allowed-tools: Read, Grep, Glob, Bash
---

# Failure Taxonomy

## Purpose

Classify every failure into a structured category before attempting repair. This prevents blind retries and enables targeted recovery recipes.

**Core principle:** Recovery before escalation — attempt one automatic fix per failure type before asking the user.

## Taxonomy

| Category | Detection Pattern | Severity | Auto-Recoverable? |
|----------|------------------|----------|-------------------|
| `compile` | Build/type errors, syntax errors, missing imports | blocking | Yes — usually fixable from error output |
| `test` | Test suite failures, assertion errors | blocking | Partial — depends on cause |
| `branch_divergence` | Merge conflicts, stale branch, rebase needed | blocking | Yes — rebase or merge-forward |
| `trust_gate` | Security scan failures, secret leaks, CONFIDENCE.md gate failures | blocking | No — requires human review |
| `mcp_startup` | MCP server connection failures, handshake timeouts | degraded | Yes — retry once, then skip with warning |
| `plugin_startup` | Plugin configuration errors, missing dependencies | degraded | Partial — depends on config |
| `infra` | Deployment failures, environment issues, CI failures | blocking | No — usually requires manual intervention |
| `prompt_delivery` | Agent dispatch failures, context overflow, tool errors | degraded | Yes — reduce scope and retry |

## Classification Protocol

When encountering a failure:

1. **Extract signal** — Parse error output for keywords, file paths, exit codes
2. **Match category** — Use the detection rules below
3. **Rate severity** — `blocking` (stops progress) or `degraded` (can continue with reduced capability)
4. **Select recipe** — Load the matching recipe from `recipes/{category}.md`
5. **Attempt recovery** — Execute the recipe's auto-fix steps (ONE attempt only)
6. **Report outcome** — Emit a structured result: recovered, escalated, or skipped

## Detection Rules

### compile
```
Signals: "error TS", "SyntaxError", "Cannot find module", "does not exist",
         "expected expression", "Build failed", exit code from tsc/esbuild/webpack,
         "cargo build" failures, "rustc error", ImportError, ModuleNotFoundError
```

### test
```
Signals: "FAIL", "AssertionError", "expected X but got Y", "test failed",
         "Tests: N failed", exit code from jest/vitest/pytest/cargo test,
         "0 passing" when tests expected
```

### branch_divergence
```
Signals: "CONFLICT", "merge conflict", "diverged", "behind origin/main",
         "needs rebase", "cannot fast-forward", git status showing unmerged paths
```

### trust_gate
```
Signals: "secret detected", "API key found", "CONFIDENCE.md gate FAIL" (after 2 attempts),
         security scan findings, "vulnerability found", eslint-plugin-security warnings
```

### mcp_startup
```
Signals: "MCP server failed", "connection refused", "handshake timeout",
         "tool not available", MCP-related errors in session start output
```

### plugin_startup
```
Signals: "plugin not found", "invalid plugin.json", "missing dependency",
         "hook failed to load", plugin initialization errors
```

### infra
```
Signals: "deployment failed", "container exited", "health check failed",
         "environment variable not set", CI pipeline red, "permission denied" on deploy
```

### prompt_delivery
```
Signals: "context too long", "token limit exceeded", "agent failed to respond",
         "tool call failed", timeout on agent dispatch, empty agent response
```

## Structured Output

After classification, produce:

```json
{
  "failure_type": "compile",
  "severity": "blocking",
  "signal": "error TS2304: Cannot find name 'UserProfile'",
  "source_file": "src/auth/middleware.ts",
  "source_line": 42,
  "auto_recoverable": true,
  "recipe": "recipes/compile.md",
  "recovery_attempted": false,
  "recovery_result": null
}
```

## Integration Points

- **Debugger agent** — Classify before diagnosing. Add `failure_type` to the diagnosis report.
- **PRD executor** — Classify build/lint/type failures in Step 5. Use recipe before escalating.
- **PRD verifier** — Classify test failures. Distinguish test bugs from branch staleness.
- **Lifecycle log** — Emit `failure.classified` events with the structured output.

## Anti-Loop Rule

Each failure type gets ONE automatic recovery attempt. If recovery fails:
- Emit `recovery.escalated` event
- Report to user with classification + what was tried + why it failed
- Do NOT retry the same recipe
