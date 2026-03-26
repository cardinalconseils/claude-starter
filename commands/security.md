---
description: "Security scan — audit app code AND pipeline config for vulnerabilities"
argument-hint: "[--app | --config | --full]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Agent
  - AskUserQuestion
  - TodoWrite
---

# /cks:security — Security Audit

Standalone security scanner. Audits BOTH application code AND the CKS/Claude config itself.

## Usage

```
/cks:security              → Full scan (app + config)
/cks:security --app        → App code only
/cks:security --config     → Claude/CKS config only
```

## Steps Claude Executes

### 1. App Code Scan

Dispatch the **security-auditor** agent to scan application code:

#### 1a. Secrets Detection

Search all tracked files for:
- API keys: `sk-`, `sk_live_`, `sk_test_`, `AKIA`, `ghp_`, `gho_`, `glpat-`
- Tokens: `xoxb-`, `xoxp-`, Bearer tokens
- Connection strings with passwords
- Hardcoded passwords/secrets in source (not .env)

#### 1b. OWASP Top 10 Check

| Vulnerability | What to Look For |
|---|---|
| **Injection** | Raw SQL queries, unsanitized shell commands, template injection |
| **Broken Auth** | Missing auth checks on routes, weak token validation |
| **Sensitive Data** | Secrets in logs, unencrypted storage, PII in URLs |
| **XXE** | XML parsing without disabling external entities |
| **Broken Access** | Missing authorization checks, IDOR vulnerabilities |
| **Misconfig** | Debug mode in prod, default credentials, verbose errors |
| **XSS** | Unescaped user input in HTML, `dangerouslySetInnerHTML` |
| **Deserialization** | Untrusted data deserialization (pickle, eval, JSON.parse of user input) |
| **Known Vulns** | Outdated dependencies with known CVEs |
| **Logging** | Missing audit logs, sensitive data in logs |

#### 1c. Framework-Specific Checks

- **Next.js/React**: CSP headers, SSR data leaks, client-side secret exposure
- **Django**: CSRF middleware, DEBUG setting, SECRET_KEY handling
- **Express**: Helmet.js usage, rate limiting, CORS config
- **Rails**: Strong parameters, mass assignment, SQL injection

### 2. Config Scan

#### 2a. CLAUDE.md Audit

- Auto-run directives that could be exploited
- Overly permissive tool allowances
- Missing deny patterns for destructive commands

#### 2b. Hooks Audit

- Command injection in hook scripts
- Hooks that leak sensitive info to stdout
- Missing input validation in hook handlers

#### 2c. MCP Server Audit

- Unnecessary MCP servers enabled
- MCP servers with write access that don't need it
- Credentials embedded in MCP config

#### 2d. Environment Audit

- `.env` files not in `.gitignore`
- Environment variables referenced but not documented
- Missing required env vars

### 3. Dependency Audit

Run the appropriate dependency audit:
- `npm audit` / `pnpm audit` / `yarn audit`
- `pip audit` or `safety check`
- `go vuln` check
- `cargo audit`

Report: critical/high/medium/low counts

### 4. Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CKS Security Audit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Grade: {A-F}

🔴 Critical ({count})
  - {finding} — {file:line} — {remediation}

🟠 High ({count})
  - {finding} — {file:line} — {remediation}

🟡 Medium ({count})
  - {finding} — {file:line} — {remediation}

🔵 Info ({count})
  - {finding}

Dependencies:
  Critical: {n}  High: {n}  Medium: {n}  Low: {n}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 5. Auto-Fix (if safe)

For findings with safe, reversible fixes:
- Add `.env` to `.gitignore`
- Replace hardcoded secrets with `process.env.X` references
- Add missing CSP headers

Ask user before applying fixes via AskUserQuestion.

## Constraints

- Read-only by default — never modify files without asking
- Never log or display actual secret values found
- Always include remediation advice with each finding
- Grade on a curve: A = no critical/high, B = no critical, C = critical found
