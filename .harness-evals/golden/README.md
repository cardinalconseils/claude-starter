# Harness Evals — Golden Corpus

Fixture-based evals for CKS hook handlers. Each case provides a known input and asserts a known exit code + output pattern.

## Directory Structure

```
.harness-evals/
  golden/
    {hook-name}/
      {case-name}/
        input.json    ← tool_input JSON passed to the hook via stdin
        expected.json ← exit code + optional stderr/stdout patterns + optional expect_file
        fixture/      ← optional: files copied into the case's scratch cwd before the hook runs
  results/            ← per-dev run results (gitignored)
```

Every case runs in its own scratch working directory (`mktemp -d`), with `CKS_HQ` and
`CKS_ACTIVE_USER` unset. Hooks that read project state (`session-start` reads `.prd/PRD-STATE.md`,
`subagent-stop-trace` needs `.prd/logs/`) get that state from `fixture/` — ship the minimal files
the hook needs, nothing that exists on a real machine. Use `.gitkeep` to commit an empty directory.

`hook-name` matches the handler filename without `.sh`:
`destructive-op-guard`, `post-tool-trace`, `session-start`, etc.

`case-name` convention: `case-NN-description` (kebab-case, NN for sort order).

## Fixture Anatomy

### `input.json`

For hooks that extract `.command` from the top-level input (e.g. `destructive-op-guard`):

```json
{"command": "rm -rf /tmp/test"}
```

For hooks that use the full Claude Code hook envelope (`tool`, `tool_input`, `tool_response`):

```json
{
  "tool": "Bash",
  "tool_input": {"command": "rm -rf /tmp/test"},
  "tool_response": {}
}
```

Check the handler source to confirm which fields it reads from stdin.

### `expected.json`

```json
{
  "exit_code": 2,
  "stderr_pattern": "~DESTRUCTIVE|⛔"
}
```

- `exit_code` — required
- `stderr_pattern` — optional; `~` prefix = regex, no prefix = exact match
- `stdout_pattern` — optional; same matching logic
- `expect_file` — optional; path relative to the case cwd that must exist and be non-empty after
  the run. Use it for hooks whose only observable effect is a file write (e.g. `subagent-stop-trace`
  appends to `.prd/logs/agents/<role>.jsonl` and prints nothing).
- Omit pattern fields if you don't need to assert on those streams

Verify a fixture case by hand the same way the runner does — from a copy of `fixture/`:
```bash
D=$(mktemp -d) && cp -R fixture/. "$D/" && (cd "$D" && printf '%s' "$(cat "$OLDPWD/input.json")" | env -u CKS_HQ bash "$PLUGIN/hooks/handlers/{hook-name}.sh"); echo "exit: $?"
```

## Worked Example: destructive-op-guard

### case-01-rm-rf-blocked

Tests that `rm -rf` is blocked (exit 2).

**input.json:**
```json
{"command": "rm -rf /tmp/test"}
```

**expected.json:**
```json
{
  "exit_code": 2,
  "stdout_pattern": "~CRITICAL|⛔|IRREVERSIBLE"
}
```

Note: `destructive-op-guard.sh` reads `.command` from the top-level JSON and writes its warning block to stdout. Use `stdout_pattern`, not `stderr_pattern`.

Verify before committing:
```bash
printf '%s\n' '{"command":"rm -rf /tmp/test"}' \
  | bash hooks/handlers/destructive-op-guard.sh
echo "exit: $?"
```

Should print the warning block and exit 2.

### case-02-safe-command

Tests that a safe command passes through (exit 0).

**input.json:**
```json
{"command": "echo hello"}
```

**expected.json:**
```json
{
  "exit_code": 0
}
```

Verify:
```bash
printf '%s\n' '{"command":"echo hello"}' \
  | bash hooks/handlers/destructive-op-guard.sh
echo "exit: $?"
```

Should exit 0 with no output.

## Running Evals

```bash
/cks:harness-eval                              # all hooks, smoke tier
/cks:harness-eval --hook=destructive-op-guard  # one hook
```

Results written to `.harness-evals/results/` (gitignored).
