---
description: "Run a full project health diagnostic — env vars, TODOs, tests, PRD state, git hygiene"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# /cks:doctor — Project Health Diagnostic

Run a battery of checks and report a health score for the current project.

## Checks to Run

### 1. Environment Variables

- Grep the codebase for `process.env.`, `import.meta.env.`, `os.environ`, `env(` patterns
- Compare found env var names against `.env.local`, `.env`, `.env.example`
- Report: missing vars (referenced but not defined), unused vars (defined but not referenced)

### 2. Code Health — TODOs/FIXMEs/HACKs

```bash
# Count by type across source files (exclude node_modules, .git, dist, build)
```

- Report count of `TODO`, `FIXME`, `HACK`, `XXX`, `WARN` annotations
- Flag any `FIXME` or `HACK` items as high-priority

### 3. Test Suite

- Detect test framework: look for `jest.config`, `vitest.config`, `pytest.ini`, `Cargo.toml [test]`, etc.
- If found, run the test command and report pass/fail/skip counts
- If no test framework detected, report "No test suite found"

### 4. PRD State Consistency

- If `.prd/PRD-STATE.md` exists:
  - Check if current phase is stale (last action date > 7 days ago)
  - Check if roadmap has unfinished phases
  - Verify PRD-STATE references match actual PRD files
- If no `.prd/`: skip this check

### 5. Git Hygiene

- Uncommitted changes count
- Stale local branches (merged branches not yet deleted)
- Check if current branch is behind remote

### 6. Dependencies (if applicable)

- If `package.json` exists: check for `npm audit` vulnerabilities (summary only)
- If `requirements.txt` or `pyproject.toml`: note last update date
- If `Cargo.toml`: run `cargo audit` if available

## Output Format

```
🏥 Project Health Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Environment     ✅ 12/12 vars defined
  Code Markers    ⚠️  8 TODOs, 2 FIXMEs, 1 HACK
  Tests           ✅ 47 passed, 0 failed, 3 skipped
  PRD State       ✅ Phase 3 — executing (active)
  Git Hygiene     ⚠️  3 uncommitted files, 2 stale branches
  Dependencies    ✅ No known vulnerabilities

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Health Score: 85/100  (Good)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Recommendations:
  1. Fix 2 FIXMEs and 1 HACK in src/
  2. Clean up stale branches: feature/old-auth, fix/typo
  3. Commit or stash uncommitted changes
```

## Scoring

| Check | Weight | Scoring |
|-------|--------|---------|
| Environment | 20 | -5 per missing var |
| Code Markers | 15 | -2 per FIXME/HACK, -0.5 per TODO |
| Tests | 25 | -5 per failure, 0 if no suite |
| PRD State | 15 | -5 if stale, -10 if inconsistent |
| Git Hygiene | 10 | -2 per issue |
| Dependencies | 15 | -5 per vulnerability level |

## Rules

1. **Never modify anything** — this is read-only diagnostics
2. **Don't run long tests** — use `--dry-run` or `--list` flags if available, otherwise run with a 30s timeout
3. **Be helpful** — every warning should include a specific action to fix it
4. **Skip gracefully** — if a check doesn't apply, skip it without error
