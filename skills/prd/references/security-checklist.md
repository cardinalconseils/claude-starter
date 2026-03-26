# Security Checklist Reference

## Pre-Release Security Gate

This checklist is used by the security-scanner agent and during Release Phase 5 [5c].

### Authentication

- [ ] All protected routes require authentication
- [ ] Authentication middleware applied consistently
- [ ] Session/token expiration configured (max 24h for sessions, 1h for JWTs)
- [ ] Password hashing uses strong algorithm (bcrypt rounds >= 10, or argon2)
- [ ] Password minimum requirements enforced (>= 8 chars, complexity rules)
- [ ] Brute-force protection (rate limiting on auth endpoints)
- [ ] Account lockout after failed attempts
- [ ] Secure password reset flow (time-limited tokens, one-use)

### Authorization

- [ ] Role-based access control (RBAC) consistent across all endpoints
- [ ] Users cannot access other users' data (IDOR protection)
- [ ] Admin endpoints restricted to admin role
- [ ] API keys have appropriate scope limitations
- [ ] OAuth scopes are minimal (principle of least privilege)

### Data Protection

- [ ] HTTPS enforced (HSTS header set)
- [ ] Sensitive data encrypted at rest
- [ ] PII not logged (passwords, tokens, SSN, credit cards)
- [ ] Database connections use TLS
- [ ] Backups encrypted
- [ ] Data retention policy implemented

### Input Validation

- [ ] All user input validated on the server (not just client)
- [ ] SQL queries use parameterized queries / ORM
- [ ] No raw HTML rendering of user input (XSS prevention)
- [ ] File uploads validate type, size, and content
- [ ] URL parameters validated before use
- [ ] JSON/XML parsers configured against XXE attacks
- [ ] No dynamic code execution with user input

### Security Headers

- [ ] Content-Security-Policy (CSP) configured
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY (or SAMEORIGIN)
- [ ] Strict-Transport-Security (HSTS)
- [ ] Referrer-Policy: strict-origin-when-cross-origin
- [ ] Permissions-Policy restricting unnecessary APIs
- [ ] CORS configured (not wildcard in production)

### Secrets Management

- [ ] No hardcoded secrets in source code
- [ ] .env files in .gitignore
- [ ] Secrets stored in environment variables or secret manager
- [ ] API keys rotated regularly
- [ ] Different keys for dev/staging/production
- [ ] No secrets in client-side JavaScript

### Dependencies

- [ ] npm audit / pip-audit shows no critical vulnerabilities
- [ ] Dependencies pinned to specific versions (lock file committed)
- [ ] No unnecessary dependencies
- [ ] New dependencies reviewed for security
- [ ] No dependencies with known supply chain attacks

### Error Handling

- [ ] Production errors do not expose stack traces
- [ ] Error messages do not reveal system internals
- [ ] 500 errors return generic message to client
- [ ] Errors logged server-side with context (but no PII)
- [ ] Error monitoring configured (Sentry, etc.)

### API Security

- [ ] Rate limiting on all public endpoints
- [ ] Request size limits configured
- [ ] CSRF protection on state-changing requests
- [ ] API versioning strategy defined
- [ ] Deprecation notices on old endpoints
- [ ] No sensitive data in URL parameters (use body/headers)

### Infrastructure

- [ ] Database not publicly accessible
- [ ] SSH keys (not passwords) for server access
- [ ] Firewall rules restrict unnecessary ports
- [ ] Regular security updates applied
- [ ] Logging and monitoring active
- [ ] Incident response plan documented

## Severity Classification

| Severity | Definition | Action Required |
|----------|-----------|----------------|
| Critical | Active exploitation possible, data breach risk | BLOCK release, fix immediately |
| High | Exploitable with effort, significant impact | Fix before production, can ship to staging |
| Medium | Exploitable in specific conditions, moderate impact | Document, fix within 1 sprint |
| Low | Theoretical risk, minimal impact | Track, fix when convenient |

## Quick Security Check Patterns

For fast pre-commit security validation, the security-scanner agent checks for:

1. Hardcoded credentials (password/secret/key/token assignments)
2. Dangerous code patterns (dynamic code execution, raw HTML injection)
3. Hardcoded production URLs
4. Missing input validation on new endpoints
5. New dependencies without security review
