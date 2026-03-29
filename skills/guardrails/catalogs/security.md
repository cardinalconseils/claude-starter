# Security Guardrail Catalog

## Trigger

Generated when bootstrap detects `has_api_routes: true` OR `has_auth: true`.

## Template

Write the following to `.claude/rules/security.md`, replacing placeholders with detected values. If a value was not detected, use the default shown in parentheses.

```markdown
---
globs:
  - "**/api/**"
  - "**/auth/**"
  - "**/middleware/**"
  - "**/lib/auth*"
  - "**/server/**"
  - "**/*.server.*"
---

# Security Rules

## Secrets

- Never hardcode API keys, tokens, passwords, or connection strings in source
- Access secrets only through environment variables or a secrets manager
- Never log secret values — log the key name, not the value
- Never include secrets in error messages returned to clients

## Input Validation

- Validate all user input at the handler/controller level before processing
- Use a schema validator ({AUTH_METHOD} patterns or Zod/Yup/Joi) — never hand-roll validation
- Sanitize strings before database queries — parameterized queries only, never string interpolation
- Reject unexpected fields — use strict schemas that disallow extra properties

## Authentication

- Every API route must check authentication before processing the request
- Use {AUTH_METHOD} (default: project auth middleware) consistently — never mix auth strategies
- Verify tokens server-side on every request — never trust client-provided auth state
- Set session/token expiration — never issue tokens without a TTL

## Authorization

- Check user permissions after authentication — auth != authz
- Use role-based or attribute-based access control consistently
- Never expose internal IDs that allow users to access other users' resources (IDOR)
- Default deny — if no permission is explicitly granted, reject the request

## API Response Safety

- Never return stack traces, internal paths, or debug info in production responses
- Use consistent error response format — `{"error": "CODE", "message": "..."}`
- Set appropriate security headers (CORS, CSP, X-Frame-Options)
- Rate limit authentication endpoints — at minimum login, signup, password reset

## Database Access

- All queries must use parameterized statements — no string concatenation
- Never bypass Row Level Security (RLS) policies unless explicitly required and documented
- Use least-privilege database credentials — the app user should not be a superuser
- Wrap multi-step operations in transactions
```

## Customization Notes

- If `auth_method` is "supabase-auth": add a bullet under Authentication: "Use `supabase.auth.getUser()` server-side — never trust the JWT payload alone without server verification"
- If `auth_method` is "clerk": add a bullet: "Use `auth()` from `@clerk/nextjs/server` in server components — never check auth only on the client"
- If `auth_method` is "next-auth": add a bullet: "Use `getServerSession()` in API routes — never rely on client-side session alone"
- If `api_style` is "GraphQL": add a section "## GraphQL" with: "Limit query depth to prevent denial-of-service via nested queries" and "Disable introspection in production"
- If `api_style` is "tRPC": adjust globs to include `"**/trpc/**"` and `"**/routers/**"`
