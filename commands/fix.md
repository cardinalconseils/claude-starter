---
description: "Build error resolver — diagnose and fix build/compile/runtime errors fast"
argument-hint: "[error message or 'last']"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - TodoWrite
---

# /cks:fix — Build Error Resolver

When your build is broken and you need it fixed NOW. Standalone — works anytime, no phase required.

## Usage

```
/cks:fix                    → Auto-detect: run build, find errors, fix them
/cks:fix "Cannot find module './utils'"  → Fix a specific error
/cks:fix last               → Re-read last build output and fix
```

## Steps Claude Executes

### 1. Identify the Error

**If no argument:** Run the project's build/compile command:
- `package.json` → `npm run build` / `npm run typecheck`
- `tsconfig.json` → `npx tsc --noEmit`
- `pyproject.toml` → `python -m py_compile` or `mypy .`
- `go.mod` → `go build ./...`
- `Cargo.toml` → `cargo build`
- `Makefile` → `make`

Capture stderr + stdout.

**If argument given:** Parse the error message directly.

### 2. Classify the Error

| Category | Indicators | Approach |
|----------|-----------|----------|
| **Import/Module** | "Cannot find module", "ModuleNotFoundError" | Check paths, install deps, fix exports |
| **Type Error** | "Type X not assignable", "has no attribute" | Fix types, add declarations |
| **Syntax** | "Unexpected token", "SyntaxError" | Fix syntax at reported line |
| **Dependency** | "peer dep", "version conflict", lockfile | Reinstall, update, resolve conflicts |
| **Runtime** | "undefined is not a function", "NoneType" | Trace the value, add null checks |
| **Config** | "Invalid configuration", env vars | Fix config files, check .env |
| **Permission** | "EACCES", "Permission denied" | Fix file permissions, ownership |

### 3. Diagnose

Use the **build-resolver** agent:

```
Agent(subagent_type="general-purpose", prompt="""
You are a build error resolver. Your ONLY job is to fix this error:

Error: {error_output}
Project root: {cwd}

Steps:
1. Read the file(s) mentioned in the error
2. Understand the root cause (not just the symptom)
3. Fix the root cause
4. If the fix requires installing a dependency, do it
5. Re-run the build command to verify the fix
6. If new errors appear, fix those too (max 5 iterations)

Do NOT:
- Refactor unrelated code
- Add features
- Change test files (unless the test itself is the build target)
- Suppress errors with @ts-ignore or type: any (fix properly)
""")
```

### 4. Verify

Re-run the original build command. If it passes:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Build fixed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Error:    {original error summary}
Cause:    {root cause}
Fix:      {what was changed}
Files:    {modified files}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If it fails with a NEW error, loop (max 5 iterations). If still failing after 5:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠ Build partially fixed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fixed:      {count} error(s)
Remaining:  {count} error(s)
Next error: {description}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Constraints

- Fix the ROOT CAUSE, not the symptom
- Never use `// @ts-ignore`, `# type: ignore`, `any` type as fixes
- Never delete tests to make builds pass
- Never downgrade dependencies unless no alternative exists
- If a fix requires a breaking change, ask the user first via AskUserQuestion
