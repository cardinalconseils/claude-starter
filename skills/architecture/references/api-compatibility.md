# Reference: API contract standards and backward-compatibility review

Companion to the API contract step in `skills/prd/workflows/design-spec.md` [2b] and the
`api-design` skill. The contract is the source of truth; implementation follows it.

## REST conventions

- Resources are nouns: `GET /v1/users/{id}`, never `/getUser`.
- Methods by semantics: GET (safe, idempotent) · POST (create) · PUT (full replace) ·
  PATCH (partial) · DELETE.
- URL shape `/v1/{resource}/{id}/{sub-resource}`; version in the URL, explicit and visible.
- Status codes used precisely: 200, 201, 204, 400, 401, 403, 404, 409, 422, 429, 500.
- Cursor pagination on every list endpoint (`next_cursor`, `limit`); standard query
  parameters for filtering and sorting.
- One error schema everywhere: `{code, message, details: []}`.
- `operationId` globally unique, camelCase: `listCampaigns`, `getCampaign`,
  `createCampaign`, `updateCampaign`, `deleteCampaign`.
- Every endpoint documents: summary + description, all parameters (location, type,
  constraints), request body with required fields and examples, every response (success
  and error), the security scheme, tags.

## GraphQL conventions

Schema-first (`schema.graphql` is the contract); imperative mutation names
(`createUser`, not `userCreate`); Relay cursor connections for pagination; document the
error strategy (typed error unions vs HTTP errors).

## Versioning lifecycle

- Each version supported ≥ 12 months after the deprecation notice; ≥ 6 months' notice.
- Breaking changes announced to consumers 4 weeks before deprecation.

## Change taxonomy

| Non-breaking (no version bump) | Breaking (version bump + migration guide) |
|---|---|
| New optional request parameters | Removing or renaming response fields |
| New response fields | Changing a field's type |
| New enum values (consumers must parse unknown values safely) | Making optional fields required |
| New endpoints | Removing endpoints, changing an endpoint's method |
| | Changing the authentication requirement |

## Review procedure

1. Diff old and new spec side by side.
2. Classify every change with the table above.
3. Breaking → reject, or require a version bump and a migration guide.
4. Non-breaking → approve with a documentation update.
5. Consumers (frontend, mobile, third parties) review a draft before the spec freezes.

## What ships with every API

Interactive docs (Swagger UI / Redoc), a getting-started guide (auth, first call, common
use cases), a complete error-code reference with resolutions, a changelog with migration
notes, per-tier rate limits, and at least a JavaScript and a Python example per endpoint.
