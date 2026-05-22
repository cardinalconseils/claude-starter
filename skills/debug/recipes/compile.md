# Recipe: compile

## Trigger
TypeScript error, build failed, syntax error, missing import, unresolved module.

## Severity
`blocking` — Auto-recoverable: Yes (usually)

## Steps

1. Parse the error output for file path and line number.
2. Read the flagged file at the reported line ±10 lines.
3. Identify: missing import, wrong type, bad syntax, or unresolved module.
4. If missing import: check if the package is in `package.json`; if not, surface the install command.
5. If type error: trace to origin — is the type wrong at the call site or at the definition?
6. Apply the minimal fix (one dispatch to `cks:debugger-worker`).

## Auto-Fix: Yes
Compile errors are typically self-contained and fixable from the error output alone. Dispatch a worker with the file and the specific line to fix.

## Escalation Message
> Build still failing after fix attempt. Provide the user with the full error output and the file:line that was changed.
