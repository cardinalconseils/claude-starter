# Mode 1: App Error-Driven Debug Workflow

You received an error message or stack trace. Follow these steps in order.

## Step 1: Parse the Error

Extract from the error:
- Error type (e.g., TypeError, NullPointerException, ImportError)
- Error message (the human-readable description)
- File path and line number where the error was thrown
- Stack frames (the full call chain from top to bottom)

## Step 2: Read the Crash Site

Read the file at the reported line. Read 30 lines of surrounding context above and below the error line. Understand what the code is trying to do at that point.

## Step 3: Trace Backward Through the Call Chain

Starting from the bottom of the stack trace (the crash site), follow each frame upward:
- Read each file and function referenced in the stack frames
- Note what data is passed between functions
- Note where state is read or written

## Step 4: Identify the Root Cause

The root cause is where the bad data or bad state was **INTRODUCED**, not where it was **DETECTED**. The crash site is where it was detected. Go upstream.

Ask: "Where was this value set or this state created?" Keep tracing until you find the origin.

## Step 5: Check for Known Patterns

Match the failure against these common patterns:

- **Null/undefined passed where value expected** → trace who passed it; find where null was allowed to propagate
- **Type mismatch** → trace where the wrong type originated; look for implicit conversions or missing validation
- **Missing import/module** → check the file exists, check the export name, check the import path
- **State inconsistency** → trace all mutations to the state; look for missing updates or concurrent writes
- **Race condition** → look for async operations missing `await`, or callbacks executed out of order
- **Off-by-one / boundary** → check loop conditions, array index assumptions, zero-vs-one indexing

## Step 6: Collect Evidence

For each link in the causal chain, record:
- `file:line` — what it shows (e.g., the bad assignment, the missing check, the wrong type)

Minimum 2 evidence points. Maximum: however many it takes to show the full chain.

## Step 7: Rate Confidence

- **High** — you have a clear, unambiguous chain from origin to crash with file:line evidence at each step
- **Medium** — the chain is probable but you could not confirm one link by reading code alone
- **Low** — you have a hypothesis but multiple links are inferred, not confirmed

## Strategic Logging (when static analysis is not enough)

If the code path is dynamic, conditional, or too complex to trace from source alone:

1. Identify 3–5 key decision points in the code path — where the value changes hands or a condition branches
2. Suggest `console.log` / `print` / `fmt.Println` statements at those points
3. Tell the user exactly what command to run and what to look for in the output

Use this format:

```
📍 Suggested instrumentation:
  1. {file}:{line} — log {variable} to confirm {hypothesis}
  2. {file}:{line} — log {variable} to check {condition}

Run: {command to trigger the code path}
Look for: {what the output tells us about the root cause}
```
