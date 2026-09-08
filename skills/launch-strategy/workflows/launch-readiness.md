# Workflow: Launch Readiness — pre-launch gate check by maturity stage

Run the shipping checklist against the current project and report blocking issues by
severity. Gates adapt to the maturity stage (Prototype → Pilot → Candidate → Production).
Report only — the role running this never fixes.

## Inputs

- `stage`: `prototype` | `pilot` | `candidate` | `production` — auto-detect from
  `.prd/PRD-STATE.md` or `PROJECT.md`; if unspecified, infer from test infra (no tests →
  Prototype; tests + CI → Pilot+) and say so.
- `focus`: optional — `security` | `performance` | `accessibility` | `all` (default).

## Gate checks

Run actual commands (build, test, grep) — never assume from file presence.

**All stages**
- Build succeeds (`npm run build` or the detected build command)
- No hardcoded secrets in code (grep for API keys, passwords, tokens)

**Pilot+**
- Authentication working
- Input validation on user-facing forms
- Environment variables configured, not hardcoded
- Error pages exist (404, 500)

**Candidate+**
- Tests pass (`npm test` or the detected test command)
- No TODO/FIXME in shipping code
- No `console.log` in production code
- Health endpoint responding (`/health` or `/api/health`)
- Core Web Vitals measured (web apps)
- Keyboard navigation works for key flows

**Production**
- `npm audit` clean (no high/critical)
- Security headers configured (CSP, HSTS)
- Error tracking configured (Sentry or similar)
- Monitoring/alerting in place
- Database backup procedure documented
- Rollback procedure documented
- README and changelog current

## Report

```
## Launch Readiness Report
Stage: {detected stage} ({how it was detected})

### BLOCKING (must fix before deploy)
- {issue} — {file:line or command output} — fix: {recommended fix}

### WARNING (should fix, not blocking)
- {issue} — {evidence} — {recommendation}

### PASSED
- {check}

### Verdict: READY / NOT READY
{blocking count} blocking, {warning count} warnings
```

## Rules

1. Adapt gates to the stage — never demand production gates of a prototype.
2. Be specific: "CSRF protection missing on `/api/users` POST", not "security issues found".
3. Every blocking issue carries a recommended fix.
4. If the stage is genuinely unknown, say which stage you assumed and why.
