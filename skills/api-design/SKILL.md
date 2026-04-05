---
name: api-design
description: "REST API and interface design conventions for production applications. Use when: designing API endpoints, creating route handlers, defining request/response schemas, handling API errors, adding pagination, versioning APIs, or reviewing API architecture."
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# API Design

## Overview

Domain expertise for designing consistent, predictable REST APIs. Covers resource naming, HTTP verbs, status codes, error formats, pagination, filtering, versioning, rate limiting, validation, and documentation.

## When to Use

- Designing new API endpoints or route handlers
- Defining request/response schemas
- Implementing error handling, pagination, or filtering
- Adding API versioning or rate limiting
- Reviewing existing API architecture for consistency
- Generating or updating OpenAPI/Swagger specs

## When NOT to Use

- GraphQL API design (different conventions apply)
- WebSocket or real-time protocol design
- Internal function interfaces (this is for HTTP APIs)

## Process

### Resource Naming

- Use **nouns**, not verbs: `/users` not `/getUsers`
- Use **plural** resource names: `/users`, `/orders`, `/products`
- Nest for relationships: `/users/:id/orders` (orders belonging to a user)
- Keep URLs lowercase with hyphens: `/order-items` not `/orderItems`
- Maximum 2 levels of nesting -- deeper means a new top-level resource

### HTTP Verbs

| Verb | Purpose | Idempotent | Request Body |
|------|---------|------------|--------------|
| GET | Read resource(s) | Yes | No |
| POST | Create resource | No | Yes |
| PUT | Replace resource entirely | Yes | Yes |
| PATCH | Update resource partially | Yes | Yes |
| DELETE | Remove resource | Yes | No |

### Status Codes

| Code | When to Use |
|------|-------------|
| 200 OK | Successful GET, PUT, PATCH, or DELETE |
| 201 Created | Successful POST that creates a resource |
| 204 No Content | Successful DELETE with no response body |
| 400 Bad Request | Malformed request syntax |
| 401 Unauthorized | Missing or invalid authentication |
| 403 Forbidden | Authenticated but insufficient permissions |
| 404 Not Found | Resource does not exist |
| 409 Conflict | Resource state conflict (duplicate email, version mismatch) |
| 422 Unprocessable Entity | Valid syntax but semantic validation failed |
| 429 Too Many Requests | Rate limit exceeded |
| 500 Internal Server Error | Unhandled server error |

### Error Format

Use a consistent envelope for all errors:

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "message": "Email is required" },
      { "field": "age", "message": "Must be a positive integer" }
    ]
  }
}
```

- `code`: machine-readable, UPPER_SNAKE_CASE
- `message`: human-readable summary
- `details`: array of field-level errors (optional)

### Pagination

- **Cursor-based** (preferred): `?cursor=abc123&limit=20` -- stable under inserts/deletes
- **Offset-based** (acceptable): `?page=2&limit=20` -- simpler but drifts with mutations
- Always return: `{ data: [...], pagination: { hasMore, nextCursor, total } }`

### Filtering and Sorting

- Filter via query params: `?status=active&role=admin`
- Sort via query param: `?sort=created_at:desc`
- Use consistent naming across all endpoints

### Versioning

- **URL prefix** (preferred for simplicity): `/v1/users`, `/v2/users`
- Increment major version only for breaking changes
- Support previous version for minimum 6 months after deprecation

### Rate Limiting

- Apply per-user and per-endpoint limits
- Return `429` with `Retry-After` header (seconds until reset)
- Include rate limit headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

### Request Validation

- Validate at the boundary (controller/handler layer), not deep in business logic
- Fail fast: return all validation errors at once, not one at a time
- Use schema validation libraries (Zod, Joi, Pydantic) -- not manual if-checks

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "We can clean up the API later" | API contracts are promises to consumers. Breaking changes after launch require versioning. |
| "Let's just use POST for everything" | HTTP verbs communicate intent. GET for reads, POST for creates, PUT/PATCH for updates, DELETE for deletes. |
| "Error messages don't matter" | Vague errors waste debugging time. "Invalid request" vs "email field is required" -- which helps? |
| "We don't need pagination yet" | Unpaginated list endpoints will time out or OOM as data grows. Add pagination from the start. |
| "Versioning is over-engineering" | One breaking change without versioning breaks every consumer simultaneously. |

## Red Flags

- Verbs in URL paths (`/getUser`, `/deleteOrder`)
- All endpoints return 200 with error in body
- Different error formats across endpoints
- List endpoints with no pagination
- No input validation at API boundary
- Sensitive data (passwords, tokens) in query params or URL paths
- Missing Content-Type headers on responses

## Verification

- [ ] All endpoints use nouns, plural resources, proper HTTP verbs
- [ ] Status codes match semantics (201 for create, 204 for delete, etc.)
- [ ] Error responses use consistent format with code, message, details
- [ ] All list endpoints have pagination (cursor or offset)
- [ ] Request validation at boundary with schema library
- [ ] Rate limiting configured with proper 429 response and Retry-After
- [ ] API versioned with URL prefix (/v1/)
- [ ] No sensitive data in URLs or query parameters
- [ ] OpenAPI/Swagger spec exists and matches implementation
