---
name: security-hardening
description: "Security hardening and OWASP Top 10 prevention for production applications. Use when: reviewing security, handling user input, managing secrets, configuring authentication, setting up HTTPS, adding CSP headers, auditing dependencies, or preparing for production deployment."
allowed-tools: Read, Grep, Glob, Bash
---

# Security Hardening

## Overview

Domain expertise for hardening production applications against the OWASP Top 10 and common security vulnerabilities. Covers injection prevention, authentication security, data exposure, access control, security headers, secrets management, CORS, input validation, and dependency auditing.

## When to Use

- Reviewing application code for security vulnerabilities
- Handling user input or form submissions
- Managing secrets, API keys, or credentials
- Configuring authentication or session management
- Setting up HTTPS, CSP, or other security headers
- Auditing dependencies for known vulnerabilities
- Preparing an application for production deployment

## When NOT to Use

- Infrastructure security (firewalls, network ACLs, VPNs)
- Compliance frameworks (SOC2, HIPAA, PCI) beyond code-level controls
- Penetration testing methodology (this is prevention, not offense)

## Process

### OWASP Top 10 Prevention

**1. Injection**
- Use parameterized queries or ORM -- never concatenate user input into SQL
- Validate and sanitize all input at system boundaries
- Apply least-privilege database users (read-only where possible)

**2. Broken Authentication**
- Hash passwords with bcrypt (cost >= 10) or argon2id
- Implement session management with httpOnly, Secure, SameSite cookies
- Offer MFA -- enforce it for admin accounts
- Rate-limit login endpoints (max 5 attempts per minute)

**3. Sensitive Data Exposure**
- HTTPS everywhere -- no exceptions, no mixed content
- Encrypt sensitive data at rest (AES-256)
- Never log PII, passwords, tokens, or credit card numbers
- Use TLS 1.2+ for all external connections

**4. XML External Entities (XXE)**
- Disable XML external entity processing in all XML parsers
- Prefer JSON over XML for API communication
- If XML is required, use a hardened parser with DTD disabled

**5. Broken Access Control**
- Check permissions on every endpoint -- server-side, not just UI
- Default deny: no permission = no access
- Verify resource ownership: user A cannot access user B's data by changing an ID
- Log access control failures for monitoring

**6. Security Misconfiguration**
- Remove default credentials and sample applications
- Disable debug mode, stack traces, and verbose errors in production
- Set security headers on all responses (see HTTP Security Headers below)
- Keep frameworks and servers updated

**7. Cross-Site Scripting (XSS)**
- Output-encode all user-generated content before rendering
- Implement Content Security Policy (CSP) headers
- Sanitize HTML if rich text is required (DOMPurify, bleach)
- Use framework auto-escaping (React JSX, Django templates)

**8. Insecure Deserialization**
- Validate and sanitize all deserialized data
- Never deserialize untrusted data with native binary serializers
- Use JSON with schema validation instead of binary serialization formats

**9. Known Vulnerabilities**
- Run `npm audit` / `pip-audit` / `bundler-audit` in CI
- Review new dependencies before adding them (check maintainers, download count, last update)
- Update dependencies monthly -- automated PRs (Dependabot, Renovate)

**10. Insufficient Logging**
- Log authentication failures, access control denials, and input validation failures
- Include timestamp, user ID, IP, action, and result in log entries
- Do NOT log sensitive data (passwords, tokens, PII)
- Send security logs to a centralized system with alerting

### Secrets Management

- Store secrets in environment variables -- never in code, config files, or git
- Use `.env.example` (with placeholder values) in the repo, never `.env`
- Rotate secrets on a schedule and after any suspected compromise
- Use a secrets manager (Vault, AWS Secrets Manager, Doppler) for production

### HTTP Security Headers

| Header | Value | Purpose |
|--------|-------|---------|
| `Content-Security-Policy` | `default-src 'self'` (minimum) | Prevents XSS, injection |
| `X-Frame-Options` | `DENY` or `SAMEORIGIN` | Prevents clickjacking |
| `X-Content-Type-Options` | `nosniff` | Prevents MIME sniffing |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Forces HTTPS |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Limits referrer leakage |
| `Permissions-Policy` | `camera=(), microphone=()` | Restricts browser features |

### CORS Configuration

- Whitelist specific origins -- never use `*` in production
- Only allow necessary HTTP methods and headers
- Set `credentials: true` only when cookies are needed cross-origin
- Validate the Origin header server-side

### Input Validation

- Validate type, length, range, and format at every system boundary
- Reject unexpected fields (allowlist, not blocklist)
- Use schema validation libraries (Zod, Joi, Pydantic)
- Validate on both client (UX) and server (security) -- server is authoritative

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We're just a small app" | Attackers don't check your user count. Automated scanners hit everything. |
| "Security can wait until production" | Security debt compounds. A breach in pilot destroys user trust permanently. |
| "That's paranoid" | Paranoid is appropriate. The OWASP Top 10 exists because these attacks are common. |
| "We trust our users" | Trust but verify. Insider threats and compromised accounts are real attack vectors. |
| "We use a framework, it handles security" | Frameworks provide tools, not guarantees. Misconfiguration defeats framework protections. |

## Red Flags

- SQL queries built with string concatenation
- Secrets committed to git (even if "removed" later -- they persist in history)
- Debug mode or stack traces enabled in production
- No CSP or security headers configured
- `CORS: *` in production configuration
- Dependencies with known CVEs (npm audit / pip-audit shows vulnerabilities)
- User input rendered without encoding or sanitization
- No rate limiting on authentication endpoints

## Verification

- [ ] All database queries use parameterized queries or ORM
- [ ] Passwords hashed with bcrypt or argon2id
- [ ] HTTPS enforced with HSTS header
- [ ] Security headers set (CSP, X-Frame-Options, X-Content-Type-Options)
- [ ] CORS whitelist uses specific origins, not wildcard
- [ ] No secrets in code, config files, or git history
- [ ] `npm audit` / `pip-audit` shows zero high/critical vulnerabilities
- [ ] Input validated at every system boundary with schema validation
- [ ] Authentication endpoints rate-limited
- [ ] Security-relevant events logged (auth failures, access denials)
- [ ] Debug mode disabled in production configuration
