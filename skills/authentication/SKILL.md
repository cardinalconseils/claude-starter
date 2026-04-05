---
name: authentication
description: "Authentication and authorization patterns for production applications. Use when: adding user login, signup, password reset, social login, role-based access, session management, JWT tokens, OAuth2, MFA, or any auth-related feature. Also use when reviewing auth security."
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Authentication & Authorization

## Overview

Domain expertise for implementing authentication and authorization in production applications. Covers pattern selection, common flows, password and session security, RBAC, social login, and provider recommendations by stack.

## When to Use

- Adding user login, signup, logout, or password reset
- Implementing social login (Google, GitHub, magic links)
- Setting up JWT tokens, OAuth2, or session-based auth
- Adding role-based access control (RBAC)
- Reviewing auth-related code for security issues
- Choosing an auth provider (NextAuth, Clerk, Supabase Auth, Firebase Auth)

## When NOT to Use

- API key management for server-to-server communication (use secrets management)
- Infrastructure-level access control (IAM, network policies)
- Non-user authentication (service accounts, machine-to-machine)

## Process

### Pattern Selection

| Pattern | Best For | Trade-off |
|---------|----------|-----------|
| Session-based (cookies) | Server-rendered apps, same-domain | Requires server-side session store |
| JWT (stateless tokens) | APIs, mobile clients, microservices | Cannot revoke without blocklist |
| OAuth2 / OIDC | Third-party login, delegated auth | Complex setup, redirect flows |
| Magic links | Passwordless, low-friction signup | Depends on email delivery |

### Common Flows

1. **Signup**: validate input -> hash password (bcrypt/argon2, cost >= 10) -> store user -> send verification email -> return session/token
2. **Login**: find user by email -> compare hash -> create session/token -> set httpOnly cookie or return token
3. **Logout**: destroy session server-side -> clear cookie -> invalidate refresh token
4. **Password reset**: verify email exists -> generate time-limited token -> send reset link -> validate token -> hash new password -> invalidate all sessions
5. **Email verification**: generate signed token at signup -> send link -> verify on click -> mark user verified
6. **MFA (TOTP)**: user enables MFA -> generate secret -> user scans QR -> verify first code -> store secret -> require code on future logins

### Password Security

- Hash with **bcrypt** (cost 10+) or **argon2id** -- never MD5, SHA, or plaintext
- Minimum 8 characters, no maximum below 128, no character-type rules (NIST 800-63B)
- Check against breached password lists (Have I Been Pwned API)
- Never log passwords, even hashed

### Session Security

- Store session tokens in **httpOnly, Secure, SameSite=Lax** cookies
- Implement CSRF protection (double-submit cookie or synchronizer token)
- Rotate session tokens after login (prevent session fixation)
- Set reasonable expiry: 15-30 min for sensitive apps, 7-30 days with refresh tokens

### RBAC Basics

- Define roles (admin, editor, viewer) with explicit permissions
- Check permissions in middleware -- never in UI alone
- Default deny: no role = no access
- Add a `role` column from day one, even if you only have one role now

### Provider Recommendations

| Stack | Recommended Providers |
|-------|----------------------|
| Next.js | NextAuth.js, Clerk, Supabase Auth |
| React SPA + API | Auth0, Firebase Auth, Supabase Auth |
| Express/Node API | Passport.js, custom JWT, Clerk Backend |
| Full-stack Rails/Django | Built-in auth (Devise, django.contrib.auth) |

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We'll add auth later" | Every endpoint is public until auth exists. "Later" means users see each other's data. |
| "Basic auth is fine for now" | Basic auth sends credentials on every request in a reversible encoding. Use sessions or tokens. |
| "We don't need roles yet" | Adding roles after launch requires migrating every user. Add the role field now. |
| "We'll just use localStorage for tokens" | localStorage is accessible to any XSS. Use httpOnly cookies for session tokens. |
| "Our app is internal, we don't need auth" | Internal apps get exposed. Auth is cheaper to add now than after a breach. |

## Red Flags

- Passwords stored in plaintext or with MD5/SHA
- Tokens in localStorage instead of httpOnly cookies
- No CSRF protection on state-changing endpoints
- Missing rate limiting on login endpoint (brute force risk)
- Session tokens that never expire or rotate
- Permissions checked only in the frontend
- Password reset tokens with no expiry

## Verification

- [ ] Passwords hashed with bcrypt (cost >= 10) or argon2id
- [ ] Session tokens stored in httpOnly, Secure, SameSite cookies
- [ ] CSRF protection enabled on all state-changing routes
- [ ] Login endpoint has rate limiting
- [ ] Password reset tokens expire within 1 hour
- [ ] Session tokens rotate after successful login
- [ ] Role/permission checks happen server-side, not just UI
- [ ] No credentials logged anywhere (including error logs)
- [ ] Email verification flow implemented for signup
- [ ] Refresh token rotation implemented if using JWTs
