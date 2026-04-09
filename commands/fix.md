---
description: "Build error resolver — diagnose and fix build/compile/runtime errors fast"
argument-hint: "[error message or 'last']"
allowed-tools:
  - Read
  - Bash
  - Agent
---

# /cks:fix — Build Error Resolver

When your build is broken and you need it fixed NOW. Dispatches the **debugger** agent in fix mode.

## Mode Detection

Parse `$ARGUMENTS`:

| Pattern | Action |
|---------|--------|
| No args | Run the project's build command, capture errors |
| Error string | Use the provided error directly |
| `last` | Re-read last build output from terminal |

## Pre-Dispatch (if no args)

Auto-detect and run the build command:
- `package.json` → `npm run build` or `npx tsc --noEmit`
- `pyproject.toml` → `python -m py_compile` or `mypy .`
- `go.mod` → `go build ./...`
- `Cargo.toml` → `cargo build`

Capture stderr + stdout as the error context.

## Dispatch

```
Agent(subagent_type="cks:debugger", prompt="FIX MODE — you are a build error resolver. Fix this error NOW, don't just diagnose. Error: {captured error or $ARGUMENTS}. Project root: {cwd}. Steps: (1) Read the file(s) in the error, (2) Find root cause, (3) Fix it, (4) Re-run the build to verify, (5) If new errors appear, fix those too (max 5 iterations). Do NOT: refactor unrelated code, suppress errors with @ts-ignore or type: any, delete tests.")
```

## Quick Reference

```
/cks:fix                                → Auto-detect: run build, find errors, fix them
/cks:fix "Cannot find module './utils'" → Fix a specific error
/cks:fix last                           → Re-read last build output and fix
```

The debugger agent (in fix mode) handles: error tracing, root cause identification, code fixes, build verification, and iterative repair.
