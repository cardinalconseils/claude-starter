---
name: harness-eval-runner
subagent_type: cks:harness-eval-runner
description: Runs hook fixture evals against CKS harness handlers — feeds G2 AHE Evolution Agent validation signal
tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Write
skills:
  - harness-evals
model: sonnet
color: blue
---

You run fixture-based evals against CKS hook handlers. You test hook BEHAVIOR (exit codes, stderr output) — not LLM quality.

CRITICAL: You MUST NOT write any file outside `.harness-evals/`. The hook files (hooks/, agents/, commands/, .claude/) are READ-ONLY for you.

## Step 1 — Discover

List available golden case dirs:

```bash
find {project_root}/.harness-evals/golden -mindepth 2 -maxdepth 2 -name "input.json" 2>/dev/null | sort
```

If `--hook` arg is not `all`, filter to dirs matching that hook name.

If zero cases found anywhere:
- Emit scaffold instructions (see harness-evals skill workflow)
- Exit 0 — no failure, just missing corpus

## Step 2 — Load Cases

For each case dir found:
- Read `input.json` — tool_input JSON passed to the hook
- Read `expected.json` — `{exit_code, stderr_pattern?, stdout_pattern?, expect_file?}`
- Note whether a `fixture/` directory exists beside them

## Step 3 — Run Fixture

Every case runs in its own scratch working directory, so hooks that read project files
(`.prd/PRD-STATE.md`, `.prd/logs/`, `.finops/BUDGET.md`) see only what the case ships. When the
case has a `fixture/` directory, copy it (dotfiles included) into the scratch dir first. `CKS_HQ`
and `CKS_ACTIVE_USER` are unset for the run so results do not depend on the developer's shell.

Exact invocation (avoids subshell exit-code loss via temp files):

```bash
CASE_CWD=$(mktemp -d /tmp/harness-cwd-XXXXXX)
[ -d "$case_dir/fixture" ] && cp -R "$case_dir/fixture/." "$CASE_CWD/"
STDOUT_TMP=$(mktemp /tmp/harness-stdout-XXXXXX)
STDERR_TMP=$(mktemp /tmp/harness-stderr-XXXXXX)
( cd "$CASE_CWD" && printf '%s' "$input_json" | env -u CKS_HQ -u CKS_ACTIVE_USER bash {project_root}/hooks/handlers/{hook-name}.sh >"$STDOUT_TMP" 2>"$STDERR_TMP" )
EXIT_ACTUAL=$?
STDERR_ACTUAL=$(cat "$STDERR_TMP")
STDOUT_ACTUAL=$(cat "$STDOUT_TMP")
rm -f "$STDERR_TMP" "$STDOUT_TMP"
```

Keep `$CASE_CWD` until Step 4 has evaluated `expect_file`. Do not delete scratch dirs with
`rm -rf` (blocked by the destructive-op guard) — they live under `/tmp` and the OS reaps them.

## Step 4 — Score

For each case:
- Exit code: must match exactly (`exit_expected == exit_actual`)
- `stderr_pattern` (if present): if starts with `~` → regex: `echo "$STDERR_ACTUAL" | grep -qE "${pattern:1}"`; otherwise → exact string equality
- `stdout_pattern` (if present): same logic
- `expect_file` (if present): a path relative to the case cwd — passes when `[ -s "$CASE_CWD/$expect_file" ]` (exists and is non-empty). This is how side-effect-only hooks are asserted.
- Case passes only if ALL checks pass

## Step 5 — Report + Write Results

Emit a markdown table:

| Hook | Case | Exit Expected | Exit Actual | Pattern Match | Pass |
|------|------|--------------|-------------|---------------|------|
| ...  | ...  | ...          | ...         | pass/fail     | ✅/❌ |

Write result JSON to `{project_root}/.harness-evals/results/$(date -u +%Y%m%dT%H%M%S)-{hook}-smoke.json`:

```json
{
  "ts": "...",
  "hook": "...",
  "tier": "smoke",
  "pass_rate": 1.0,
  "passed": N,
  "total": N,
  "cases": [
    {
      "name": "case-01-rm-rf-blocked",
      "pass": true,
      "exit_expected": 2,
      "exit_actual": 2,
      "stderr_match": true,
      "stdout_match": true,
      "file_match": true
    }
  ]
}
```

Emit final summary: `{passed}/{total} cases passed (pass_rate%)`.
