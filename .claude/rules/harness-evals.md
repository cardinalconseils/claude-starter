# Harness Eval Rules

## Mandatory Behavior

Rules governing the `cks:harness-eval-runner` agent and the `.harness-evals/` corpus.

## File Scope Constraint

The harness-eval-runner agent MUST NOT write any file outside `.harness-evals/`. Any attempt to edit files under `hooks/`, `agents/`, `commands/`, `skills/`, or `.claude/` is a violation — those directories are READ-ONLY for this agent.

## Routing Constraint

Harness evals MUST NOT be routed through `cks:evals-runner`. They are a separate system:
- `cks:evals-runner` — tests LLM output quality (memory, API, tool-use, safety)
- `cks:harness-eval-runner` — tests hook handler behavior (exit codes, output patterns)

Separate agent, separate skill (`harness-evals`), separate directory (`.harness-evals/`).

## Golden Case Content Rules

Golden cases MUST use synthetic or sanitized inputs only:
- No real file paths that exist on the developer's machine
- No real command arguments that could cause side effects if run outside the fixture
- No raw secrets, API keys, or credentials in `tool_input`
- Use `/tmp/test` or similarly safe paths in command values

## Results Are Per-Dev Artifacts

Files in `.harness-evals/results/` are gitignored — never committed to the repo. They are per-developer validation artifacts. Golden cases in `.harness-evals/golden/` ARE committed.

## Golden Case Verification Before Commit

Before saving `expected.json`, manually verify the case:

```bash
printf '%s' "$(cat input.json)" | bash hooks/handlers/{hook-name}.sh
echo "exit: $?"
```

Confirm the actual exit code matches what you intend to record in `expected.json`. A wrong `expected.json` produces a permanently failing case that blocks G2 validation.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write the expected.json from memory — I know what the hook does" | Run the fixture, confirm the exit code. Memory-based expected values cause silent false failures. |
| "Harness eval results should be committed for audit trail" | Results are per-dev artifacts. They change every run. Commit only golden cases (inputs + expected). |
| "I can use /cks:evals for this hook test" | Wrong runner. Harness evals use `cks:harness-eval-runner`. Routing to `evals-runner` will produce incorrect results or errors. |
