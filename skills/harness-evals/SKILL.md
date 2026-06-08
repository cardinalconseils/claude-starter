---
name: harness-evals
description: Domain knowledge for running CKS hook fixture evals — tests hook handler exit codes and output patterns, feeds G2 AHE Evolution Agent validation signal
allowed-tools:
  - Read
  - Bash
  - Glob
  - Write
---

# Harness Evals

## What Harness Evals Are

Harness evals test the CKS harness pipeline (hooks, rules) itself — specifically hook handler **behavior**: exit codes and output patterns.

They are different from `/cks:evals`, which tests LLM output quality. Harness evals are deterministic: given a known input JSON, a handler must produce a known exit code and output pattern. No LLM involved.

Primary consumer: G2 AHE Evolution Agent, which reads result JSON to validate that proposed harness mutations do not break existing hook behavior.

## Hook Fixture Anatomy

### `input.json`

A JSON object passed to the hook via stdin. Shape depends on which fields the handler reads.

Example for `destructive-op-guard` (reads `.command` at top level):
```json
{"command": "rm -rf /tmp/test"}
```

Example for hooks using the full Claude Code envelope:
```json
{
  "tool": "Bash",
  "tool_input": {"command": "rm -rf /tmp/test"},
  "tool_response": {}
}
```

Check the handler source before writing `input.json` — use `head -15 hooks/handlers/{name}.sh` to see what fields it reads from stdin.

### `expected.json`

```json
{
  "exit_code": 2,
  "stderr_pattern": "~DESTRUCTIVE|⛔",
  "stdout_pattern": "~optional-regex"
}
```

- `exit_code` — required. Must match exactly.
- `stderr_pattern` — optional. `~` prefix = regex (`grep -E`); no prefix = exact string match.
- `stdout_pattern` — optional. Same matching logic.
- Omit `stderr_pattern` or `stdout_pattern` if you don't need to assert on those streams.

## Golden Corpus Structure

```
.harness-evals/
  golden/
    {hook-name}/
      {case-name}/
        input.json
        expected.json
  results/        ← per-dev artifacts (gitignored)
    {ts}-{hook}-smoke.json
```

Hook name matches the handler filename without `.sh`:
`destructive-op-guard`, `post-tool-trace`, `session-start`, etc.

Case names: kebab-case, descriptive. Prefix with `case-NN-` for sort order.

## Scoring

- 100% pass rate = smoke green
- Any single failure = red (smoke tier is binary)
- `pass_rate = passed / total` (float 0.0–1.0)

A pass means: exit code matched AND all specified patterns matched.

## G2 Consumer Contract

Result JSON fields G2 reads: `hook`, `tier`, `pass_rate`, `passed`, `total`, `cases`.

Each case entry: `name`, `pass`, `exit_expected`, `exit_actual`, `stderr_match`, `stdout_match`.

G2 uses `pass_rate` as the mutation validation signal: a proposed rule change that drops `pass_rate` below 1.0 is rejected.

## When to Add Golden Cases

- Whenever a hook handler changes (add a case proving the new behavior)
- Before merging any hook PR
- When a new risk pattern is added to `destructive-op-guard.sh`
- When a bug is found in a handler — write the failing case first, fix, confirm it passes

Always test the case manually before saving `expected.json`:

```bash
printf '%s' "$(cat input.json)" | bash hooks/handlers/{hook-name}.sh
echo "exit: $?"
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The hook works, I tested it manually — no golden case needed" | Manual tests disappear. Golden cases persist and block regressions. Write the case. |
| "Harness evals and LLM evals are the same thing, I'll use /cks:evals" | They are different systems. `/cks:evals` tests LLM output. Harness evals test shell exit codes. Do not mix them. |
| "The golden corpus is empty, I'll add cases later" | Empty corpus = zero validation signal to G2. Add at least one case per handler that has risk patterns. |

## Verification

- [ ] Golden cases tested manually before `expected.json` committed
- [ ] `input.json` contains only synthetic/sanitized data — no real paths or secrets
- [ ] `expected.json` exit code matches observed behavior
- [ ] Results JSON written to `.harness-evals/results/` (gitignored)
- [ ] Agent wrote no files outside `.harness-evals/`
