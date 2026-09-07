# Workflow: Project Health Check — scored diagnostic, read-only

Run a battery of quick checks and produce a scored report. Diagnose, never fix.

## Checks

### 1. Git hygiene
```bash
git status --short
git stash list
git branch -vv | grep -v "^\*" | head -10
```
Uncommitted changes? Stale stashes? Orphaned local branches?

### 2. Build health
Detect the project type, run the build command, capture the exit code.
Report passing / failing / no build command detected.

### 3. Test health
Detect the test command, run it. Report `X/Y passing` or no tests detected.

### 4. Dependency health
```bash
npm audit --json 2>/dev/null | head -5
npm outdated 2>/dev/null | head -10
pip check 2>/dev/null
cargo audit 2>/dev/null | head -10
```

### 5. Environment variables
- `.env.example` present?
- `.env` missing while `.env.example` exists → warn
- Hardcoded secrets in source (grep `sk_live_`, `AKIA`, password patterns) — report the
  file and line only, never the value (`.claude/rules/secrets.md`)

### 6. Code quality
```bash
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --include="*.rs" --include="*.go" . 2>/dev/null | wc -l
```

### 7. PRD state
`.prd/` exists? `PRD-STATE.md` valid? Age of the last action? Phases started but never
completed?

### 8. Branch freshness
```bash
git fetch origin main 2>/dev/null
git rev-list HEAD..origin/main --count 2>/dev/null
```
fresh (0) · slightly stale (1–5) · stale (6+)

## Report

```
Project Health — {date}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Check              Status    Details
  ─────────────────────────────────────
  Git hygiene        {✓|⚠|✗}  {summary}
  Build              {✓|⚠|✗}  {summary}
  Tests              {✓|⚠|✗}  {X/Y passing}
  Dependencies       {✓|⚠|✗}  {N vulnerabilities}
  Environment        {✓|⚠|✗}  {summary}
  Code quality       {✓|⚠|✗}  {N TODOs, N FIXMEs}
  PRD state          {✓|⚠|✗}  {phase + staleness}
  Branch freshness   {✓|⚠|✗}  {N commits behind}

  Score: {passed}/{total} ({percent}%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

1. Read-only — diagnose, never fix.
2. Fast — quick heuristics, not deep scans.
3. A check that fails to run or does not apply is `N/A`, not a failure.
