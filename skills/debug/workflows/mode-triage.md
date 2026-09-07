# Mode: Triage — scan, file, return a queue

Find every problem in an area — not only the loudest — file each to GitHub, and return a
prioritized queue. Ported from the `investigator` agent (scan and filing) and the
`triage-runner` agent (backlog classification). Run by the debugger role. Nothing is fixed in
this mode; fixing is `mode-fix.md` or `mode-multi-issue.md` on a later dispatch.

## Scope: broad

Full-project sweep.

```bash
npx tsc --noEmit 2>&1 | head -50
npx eslint . --ext .ts,.tsx 2>&1 | head -50
mypy . 2>&1 | head -50 || true
npm test -- --passWithNoTests 2>&1 | grep -E "FAIL|PASS|Error|✗|✓" | head -50 || true
npm run build 2>&1 | tail -30 || true
grep -r "TODO\|FIXME\|HACK\|XXX\|BROKEN" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" . 2>/dev/null | grep -v node_modules | head -30
grep -r "api_key\s*=\s*['\"][^'\"]\|secret\s*=\s*['\"][^'\"]\|password\s*=\s*['\"][^'\"]" --include="*.ts" --include="*.js" --include="*.py" . 2>/dev/null | grep -v node_modules | head -20
npm audit --json 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'{d[\"metadata\"][\"vulnerabilities\"][\"total\"]} vulnerabilities')" 2>/dev/null || true
cat .prd/PRD-STATE.md 2>/dev/null | head -20
```

## Scope: targeted

1. Understand the target — a file/module, a symptom, or a layer
2. Map the code path — entry point (Glob `*auth*`, `*login*`, …; Grep the component; read
   the module), follow imports and calls, note transforms, state mutations, async calls
3. Probe each file: error handling (unhandled rejections, null checks, error boundaries),
   validation (trusted input, type mismatches), security (injection, exposed secrets,
   missing auth), logic (off-by-one, wrong conditions, stale state), performance (N+1,
   missing caching, sync blocking in async)

## Findings

Each finding: title (one sentence), details (file:line, error output), severity
(`blocking` = user-facing data loss or auth bypass; `degraded` = broken with a workaround;
`tech-debt` = not user-visible), failure type from `skills/failure-taxonomy`. Only file what
you can cite with file:line — speculation is noise, not an issue. Before filing ask: does
this exist in current code, or only in my model of what could go wrong?

## Filing

Repo from `git remote get-url origin`. Labels (idempotent): `cks:auto-filed` 6B7280,
`cks:blocking` EF4444, `cks:degraded` F59E0B, `cks:tech-debt` 3B82F6, `cks:security` DC2626
(`gh label create … 2>/dev/null || true`).

Dedup: `list_issues(state="open", labels="cks:auto-filed")` once; match by title keywords
(symptom words + file/module), not by prefix. Match → skip, note "already tracked as #N".

`issue_write` per finding — title `[INV] {🔴|🟡|🔵|🔒} {summary}`; body: Summary,
Investigation (mode, area, filed by, date), Evidence, Failure Classification (type,
severity, auto-recoverable), Suggested Fix (direction, no code), Dependencies (`depends-on:`
from the open-issue list already fetched — never a second call; `file-scope:` from the cited
evidence; `root-cause: yes|no`; `symptom-of: #N` when no). Labels: `cks:auto-filed` +
severity label. GitHub MCP unavailable → list findings under `## Issues Found` and continue.

## Backlog triage (when asked to triage existing PRs, branches, issues)

Classify, do not act — merges, closes, and branch deletions are the project manager's and the
founder's, returned as recommendations:

- PR: `MERGE-READY` (approved + mergeable) / `NEEDS-REVIEW` / `BLOCKED` (changes requested
  or conflicting) / `STALE` (>14 days, unapproved) — `gh pr list --json
  number,title,author,createdAt,mergeable,reviewDecision,labels`
- Branch: `MERGED-STALE` (PR merged, branch remains) / `ORPHANED` (no PR, >30 days) /
  `ACTIVE` — `git branch -r --no-merged main --sort=-committerdate`; skip ACTIVE
- Issue: `ACTIONABLE` (assignee or non-default labels) / `STALE` (>30 days, no assignee) /
  `NEEDS-TRIAGE` — `list_issues` or `gh issue list --json number,title,labels,createdAt,assignees`

## Output

```
INVESTIGATION REPORT
━━━━━━━━━━━━━━━━━━━━
Mode:   {broad | targeted | backlog}
Area:   {area or "full project"}
Scope:  {N files scanned, N areas checked}

FINDINGS ({N} total)
#{n} 🔴 {title} — {file:line}
#{n} 🟡 {title} — {file:line}
(or "No issues found in this area ✅")

FILED TO GITHUB
{N} new · {N} already tracked · {N} skipped (MCP unavailable)

GITHUB PROJECT SYNC
Read plugin.json. If github_project.owner is set: label new issues type:bug and add them to
the board under "Backlog" via tools/github-project-sync.js. Else skip silently.

QUEUE (highest priority first)
1. #{n} — {title} — {severity} — file-scope: {files}
2. …
Recommended next dispatch: debugger mode-fix on #{n}
```
