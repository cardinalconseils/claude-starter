# Hook Fixture Runner — Smoke Tier

Step-by-step mechanics for running harness eval cases.

## Case Discovery

```bash
find .harness-evals/golden -mindepth 2 -maxdepth 2 -name "input.json" | sort
```

Each path has the form `.harness-evals/golden/{hook-name}/{case-name}/input.json`.

Extract `hook-name` from the second path segment. Extract `case-name` from the third.

Filter by `--hook` arg if provided (skip cases where hook-name does not match).

## Loading a Case

```bash
input_json=$(cat .harness-evals/golden/{hook-name}/{case-name}/input.json)
expected_exit=$(jq -r '.exit_code' .harness-evals/golden/{hook-name}/{case-name}/expected.json)
expected_stderr=$(jq -r '.stderr_pattern // ""' .harness-evals/golden/{hook-name}/{case-name}/expected.json)
expected_stdout=$(jq -r '.stdout_pattern // ""' .harness-evals/golden/{hook-name}/{case-name}/expected.json)
```

## Running the Fixture

Use temp files for both streams to avoid subshell exit-code loss:

```bash
STDERR_TMP=$(mktemp /tmp/harness-stderr-XXXXXX)
STDOUT_TMP=$(mktemp /tmp/harness-stdout-XXXXXX)

printf '%s' "$input_json" | bash hooks/handlers/{hook-name}.sh >"$STDOUT_TMP" 2>"$STDERR_TMP"
EXIT_ACTUAL=$?

STDERR_ACTUAL=$(cat "$STDERR_TMP")
STDOUT_ACTUAL=$(cat "$STDOUT_TMP")

rm -f "$STDERR_TMP" "$STDOUT_TMP"
```

Why temp files: a `$(...)` subshell captures stdout but swallows the exit code. Temp files preserve `$?` in the parent shell.

## Pattern Matching

```bash
match_pattern() {
  local actual="$1"
  local pattern="$2"
  if [ -z "$pattern" ]; then
    echo "skip"
    return 0
  fi
  if [ "${pattern:0:1}" = "~" ]; then
    # regex match
    if echo "$actual" | grep -qE "${pattern:1}"; then
      echo "pass"
    else
      echo "fail"
    fi
  else
    # exact match
    if [ "$actual" = "$pattern" ]; then
      echo "pass"
    else
      echo "fail"
    fi
  fi
}

stderr_result=$(match_pattern "$STDERR_ACTUAL" "$expected_stderr")
stdout_result=$(match_pattern "$STDOUT_ACTUAL" "$expected_stdout")
```

A case passes if: `exit_actual == exit_expected` AND `stderr_result != "fail"` AND `stdout_result != "fail"`.

## Scaffold Template

When zero golden cases are found, emit these instructions:

```
No golden cases found. Scaffold the corpus:

mkdir -p .harness-evals/golden/destructive-op-guard/case-01-rm-rf-blocked
echo '{"tool":"Bash","tool_input":{"command":"rm -rf /tmp/test"},"tool_response":{}}' \
  > .harness-evals/golden/destructive-op-guard/case-01-rm-rf-blocked/input.json
echo '{"exit_code":2,"stderr_pattern":"~DESTRUCTIVE|⛔"}' \
  > .harness-evals/golden/destructive-op-guard/case-01-rm-rf-blocked/expected.json

# Verify before committing:
printf '%s' "$(cat .harness-evals/golden/destructive-op-guard/case-01-rm-rf-blocked/input.json)" \
  | bash hooks/handlers/destructive-op-guard.sh
echo "exit: $?"
```

Then re-run `/cks:harness-eval` to confirm cases pass.

## Result JSON Shape

Write to `.harness-evals/results/{ts}-{hook}-smoke.json`:

```json
{
  "ts": "2024-01-15T10:30:00Z",
  "hook": "destructive-op-guard",
  "tier": "smoke",
  "pass_rate": 1.0,
  "passed": 2,
  "total": 2,
  "cases": [
    {
      "name": "case-01-rm-rf-blocked",
      "pass": true,
      "exit_expected": 2,
      "exit_actual": 2,
      "stderr_match": true,
      "stdout_match": true
    }
  ]
}
```

When running all hooks, write one result file per hook (one hook name per file).
