# Proposal NNN — {Hook Name}: {One-Line Description}

Generated: {ISO timestamp}

## Evidence

**Signal source:** {telemetry | governance | harness-eval-result}
**Pattern:** {description of what was observed}
**Frequency:** {N occurrences across M sessions}

## Proposed Golden Case

**Hook:** `{hook-name}`
**Case name:** `{case-name}` (suggest: `case-NN-{short-description}`)

**`input.json`**
```json
{...}
```

**`expected.json`**
```json
{
  "exit_code": N,
  "stdout_pattern": "optional — prefix ~ for regex",
  "stderr_pattern": "optional — prefix ~ for regex"
}
```

## Validation Run

```
$ printf '%s' '{input_json}' | bash hooks/handlers/{hook-name}.sh
exit: N
stdout: {captured output if relevant}
```

Result: exit actual N = expected N ✅
Pattern match: {match result or "n/a"} ✅

## Suggested Action

1. Create directory: `.harness-evals/golden/{hook-name}/{case-name}/`
2. Write the `input.json` and `expected.json` above into that directory
3. Run `/cks:harness-eval --hook={hook-name}` to confirm the case passes
4. Commit the golden case files to the repo
