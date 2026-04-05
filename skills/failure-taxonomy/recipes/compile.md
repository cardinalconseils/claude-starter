# Recipe: compile

## Detection Confirmation

Before applying this recipe, verify:
- Build command exited non-zero
- Error output contains type errors, syntax errors, or missing module references
- This is NOT a test failure disguised as a build failure

## Auto-Recovery Steps

### Step 1: Parse error locations
Extract file:line pairs from the error output. Group by file.

### Step 2: Classify error subtype

| Subtype | Pattern | Fix Strategy |
|---------|---------|-------------|
| Missing import | `Cannot find module`, `ModuleNotFoundError` | Check if module exists elsewhere, fix import path |
| Type error | `Type X is not assignable to Y`, `error TS` | Read both types, fix the mismatch at source |
| Syntax error | `Unexpected token`, `SyntaxError` | Read the file, fix syntax |
| Missing declaration | `Cannot find name`, `not defined` | Check if it was renamed/moved, add declaration |
| Dependency missing | `Cannot resolve`, `package not found` | Check package.json, suggest install |

### Step 3: Apply targeted fix
- Read the erroring file(s)
- Apply the minimal fix for the subtype
- Re-run the build command

### Step 4: Verify
- If build passes → emit `recovery.succeeded`
- If build still fails with SAME error → emit `recovery.escalated` (do NOT retry)
- If build fails with DIFFERENT error → classify the new error (may be a different recipe)

## Escalation

Report to user:
```
Failure: compile ({subtype})
Attempted: {what was changed}
Result: Still failing — {new error summary}
Action needed: Manual review of {file paths}
```
