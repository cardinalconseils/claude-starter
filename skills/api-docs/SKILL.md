---
name: api-docs
description: >
  Auto-generates API documentation from codebase analysis. Detects endpoints, schemas,
  authentication patterns, and produces OpenAPI specs or markdown docs. Runs post-sprint
  or pre-release. Use when: "generate API docs", "document endpoints", "create OpenAPI spec",
  "API documentation", "document this API", "swagger docs", or when the project has API
  endpoints that need documentation.
---

# API Documentation Generator

Scans the codebase for API endpoints and generates structured documentation.

## When to Use

- After Sprint Phase 3 [3c] when new endpoints are implemented
- Before Release Phase 5 as part of documentation checklist
- When user explicitly requests API documentation
- When onboarding new developers who need endpoint reference

## Capabilities

### 1. Endpoint Detection

Automatically detect API routes from common patterns:

| Framework | Detection Pattern |
|-----------|-----------------|
| Express | `app.get/post/put/delete()`, `router.get/post/put/delete()` |
| Next.js App Router | `app/api/**/route.ts` — export GET/POST/PUT/DELETE |
| Next.js Pages Router | `pages/api/**/*.ts` |
| FastAPI | `@app.get/post/put/delete()` decorators |
| Django REST | `urlpatterns`, ViewSet classes |
| Flask | `@app.route()` decorators |
| Hono | `app.get/post/put/delete()` |
| tRPC | `router.query/mutation()` |

### 2. Schema Extraction

For each endpoint, extract:
- Request parameters (path, query, body)
- Request body schema (from TypeScript types, Zod schemas, Pydantic models)
- Response schema (from return types)
- Authentication requirements
- Error responses

### 3. Output Formats

#### Markdown (default)

```markdown
## POST /api/invoices

Create a new invoice.

**Authentication:** Bearer token required

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| clientId | string | Yes | Client UUID |
| items | InvoiceItem[] | Yes | Line items |

**Response (201):**
| Field | Type | Description |
|-------|------|-------------|
| id | string | Invoice UUID |
| total | number | Calculated total |

**Error Responses:**
| Status | Code | Description |
|--------|------|-------------|
| 400 | VALIDATION_ERROR | Missing required fields |
| 401 | UNAUTHORIZED | Invalid or missing token |
```

#### OpenAPI 3.0

Generate `docs/api/openapi.yaml` — machine-readable spec for Swagger UI, Postman, etc.

## How It Works

### Step 0: Load Project-Level API Contract

Check if `.kickstart/artifacts/API.md` exists. If it does:
- Read it as the **baseline contract** — this defines intended endpoints, conventions, auth patterns
- Compare discovered endpoints against API.md to flag: implemented, missing, or undocumented extras
- Use API.md conventions (error format, pagination, status codes) as the documentation standard

If API.md does not exist, proceed with codebase-only detection.

### Step 1: Detect Framework

```bash
# Check for framework signals
ls package.json pyproject.toml requirements.txt go.mod Cargo.toml 2>/dev/null
```

Read package.json or equivalent to identify the API framework.

### Step 2: Scan for Endpoints

Use Glob + Grep to find all route definitions:

```
Glob: app/api/**/route.{ts,js}     # Next.js App Router
Glob: pages/api/**/*.{ts,js}        # Next.js Pages Router
Grep: "router\.(get|post|put|delete)" # Express
Grep: "@app\.(get|post|put|delete)"   # FastAPI/Flask
```

### Step 3: Extract Schema Info

For each endpoint file:
1. Read the file
2. Parse request types (TypeScript interfaces, Zod schemas, Pydantic models)
3. Parse response types
4. Identify auth middleware
5. Extract JSDoc/docstring comments

### Step 4: Generate Documentation

Write to `docs/api/`:
- `README.md` — API overview with authentication guide
- `endpoints/` — One file per resource group
- `openapi.yaml` — OpenAPI 3.0 spec (if requested)

### Step 5: Validate

- Check all endpoints are documented
- Verify schema completeness
- Flag undocumented endpoints

## Integration with Lifecycle

### Post-Sprint Hook
After Sprint Phase 3 completes, check if new API endpoints were added:
```bash
# Check if any api/ route files were modified
git diff --name-only HEAD~1 | grep -E "(api/|routes/|endpoints/)"
```
If yes → suggest running API docs generation.

### Pre-Release Gate
In Release Phase 5, verify:
- All endpoints documented
- Documentation matches current code
- No stale docs for removed endpoints

## Commands

```
/cks:api-docs              # Generate docs for all endpoints
/cks:api-docs --openapi    # Generate OpenAPI 3.0 spec
/cks:api-docs --diff       # Only document new/changed endpoints
```

## Output

```
docs/api/
├── README.md              — API overview, auth guide, base URL
├── endpoints/
│   ├── auth.md            — Authentication endpoints
│   ├── invoices.md        — Invoice CRUD
│   └── users.md           — User management
└── openapi.yaml           — OpenAPI 3.0 spec (optional)
```
