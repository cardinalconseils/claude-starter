# Security Audit Checklist

Lookup tables for a security audit run by the reviewer role (security mode). Ported from the
`cks:reviewer` (security mode; skills `security-hardening` and `ciso`). The audit is read-only: findings, grades, remediation —
never fixes.

## Scan categories

### 1. OWASP Top 10

| # | Vulnerability | What to check |
|---|---|---|
| A01 | Broken Access Control | Auth middleware on all protected routes, role checks, IDOR |
| A02 | Cryptographic Failures | Hardcoded secrets, weak algorithms, HTTP not HTTPS |
| A03 | Injection | SQL injection, XSS, command injection, template injection |
| A04 | Insecure Design | Missing rate limiting, no CSRF protection, weak session |
| A05 | Security Misconfiguration | Debug mode in prod, default credentials, verbose errors |
| A06 | Vulnerable Components | Outdated dependencies with known CVEs |
| A07 | Auth Failures | Weak passwords, no brute-force protection, session fixation |
| A08 | Data Integrity Failures | Deserialization, unsigned updates, CI/CD tampering |
| A09 | Logging Failures | No auth event logging, PII in logs, no monitoring |
| A10 | SSRF | Unvalidated URLs, internal network access from user input |

For each category, state what you checked (file, route, or pattern) before marking it
covered — "checked" without evidence is not checked. Before filing a finding, verify it
applies to this framework's actual implementation pattern (common false positive: CSRF
checks that look missing in Express but live in the session middleware).

### 2. Secrets detection

Check all tracked files, plus `git log -p` for history, for:

- AWS keys: `AKIA[A-Z0-9]{16}`
- Stripe keys: `sk_live_`, `sk_test_`
- GitHub tokens: `ghp_`, `gho_`, `glpat-`
- Slack tokens: `xoxb-`, `xoxp-`
- Connection strings with embedded passwords
- Hardcoded passwords/secrets in source (`api_key\s*=\s*['"]`, `secret\s*=\s*['"]`, `password\s*=\s*['"]`)
- Private keys (PEM blocks)

Report pattern + file:line only. Never echo the value (`.claude/rules/secrets.md`).

### 3. Dependency audit

| Ecosystem | Command |
|---|---|
| Node.js | `npm audit --json` |
| Python | `pip-audit --format json` |
| Go | `govulncheck ./...` |
| Rust | `cargo audit` |
| Ruby | `bundle audit check --update` |

Flag: Critical/High must fix before release; Medium should fix, may defer with documentation;
Low document and track. Cross-check against the standing threats in `skills/ciso/SKILL.md`
(compromised package names and versions).

### 4. Authentication and authorization

- Every API route has auth middleware
- Role-based access control is consistent
- Session/token expiration configured
- Password hashing uses bcrypt (cost ≥ 10) or argon2id
- OAuth flows validate the `state` parameter
- JWT secrets not hardcoded

**Cross-role privilege escalation test** — required when the project is tagged
`project_type: multi-role-saas` in `.kickstart/state.md` or `.bootstrap/scan-context.md`.
Read the role list and mutation-endpoint list from `PERMISSIONS-MATRIX.md` if one exists
(produced by `skills/saas-dashboard-sequence/references/permissions-matrix-template.md`) —
never ask the user to enumerate roles/endpoints when that file is present. For every
non-highest role R × every mutation endpoint E scoped to a role above R: authenticate or
simulate as R, call E, and confirm the response is 403 or an RLS denial. Exhaustive over all
(role, endpoint) pairs, not a spot-check — log one row per pair:

| role | endpoint | expected | actual |
|---|---|---|---|
| R | E | deny | 403 / 200 / other |

An aggregate "RBAC looks fine" without the per-pair table does not satisfy this check.

### 5. Configuration scan (Claude/CKS specific)

- `CLAUDE.md`: auto-run directives, overly broad permissions
- Hooks: command injection in hook scripts, info leakage
- MCP servers: unnecessary access, embedded credentials
- `.env` handling: gitignore coverage, documentation
- GitHub Actions: `pull_request_target`, token scope, unpinned actions
- Webhook and endpoint exposure: n8n, MCP servers, public ports
- Supabase: tables without RLS holding sensitive data (`skills/database-design/workflows/supabase-audit.md`)

## Scan modes

**Quick scan** (code review, Sprint [3d]) — changed files only: `git diff --name-only HEAD~1`.
OWASP patterns on the diff, new secrets, auth on new endpoints.

**Full scan** (Release [5c] or `/cks:security`) — whole codebase: all OWASP checks, full secret
scan, dependency audit, auth/authz review, config scan, framework-specific checks (CSP, CSRF,
CORS).

**Portfolio scan** (CISO) — `--repo <name>` runs the full scan on one repo; `--all` enumerates
every repo in the org via the GitHub MCP and consolidates findings by severity; `--threat
<name>` runs only the checks relevant to a named standing threat; `--quick` runs only
CRITICAL-class checks (Shai-Hulud indicator, RLS-disabled sensitive tables, compromised
dependency versions, `.env` in git history). If a repo named or described "A Mini Shai-Hulud
has Appeared" is found: stop the audit and alert in all caps — active compromise, rotate all
credentials now.

**CCCS threat intel** (optional, non-blocking) — if a `cccs` CLI is on `PATH`, run
`cccs list-threats --json --agent`, filter for the project's stack keywords, and append a
`[CCCS THREAT INTEL]` block (title, type, date, URL, matched keywords). CLI absent → note
"CCCS intel unavailable" and continue.

## Methodology

1. Glob for source files by detected language
2. Grep for secret patterns
3. Grep for injection patterns (SQL, shell, dynamic code execution)
4. Read auth middleware / route guards
5. Check framework-specific security
6. Run the dependency audit command
7. Scan Claude/CKS config
8. Score and grade

## Output format

```
Grade: {A-F}

🔴 Critical: {findings with file:line, OWASP category, and remediation}
🟠 High: {findings with file:line and fix}
🟡 Medium: {findings with file:line and fix}
🔵 Info: {findings}

Dependencies: Critical: {n} High: {n} Medium: {n} Low: {n}
```

Every finding carries a specific remediation — the exact command or config diff, not a
description — and its OWASP category. A finding with no fix available (compromised upstream
package with no patch) says so and recommends isolation or removal.

## Grading

Start at 100; subtract 30 per critical, 10 per high, 5 per medium, 1 per low.

- **A** (90–100): no critical or high findings
- **B** (70–89): no critical, some high
- **C** (50–69): critical findings exist
- **D** (30–49): multiple critical findings
- **F** (0–29): severe vulnerabilities, do not deploy

See also `skills/prd/references/security-checklist.md` for the pre-release gate checklist.
