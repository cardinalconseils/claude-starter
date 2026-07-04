# Permissions Matrix Template

This is the single source of truth for role-gated visibility in a multi-role SaaS project.
RLS policies, API middleware checks, and frontend visibility guards must all cite this file's
path in a code comment — see `.claude/rules/saas-single-app.md`.

Save the filled-in version to `PERMISSIONS-MATRIX.md` at the project root (or
`.decisions/PERMISSIONS-MATRIX.md` if the project keeps other decision artifacts there — pick
one location and keep every citation consistent).

## Role Hierarchy

List roles from highest to lowest privilege. Note inheritance if a higher role implicitly has
every lower role's permissions.

| Role | Hierarchy Level | Inherits From |
|---|---|---|
| super_admin | 0 (highest) | — |
| admin | 1 | — |
| vendor | 2 | — |

## Permissions Matrix

| Role | Permission / Capability | Scope | Visible in UI | API Endpoints Affected | RLS Policy Reference |
|---|---|---|---|---|---|
| super_admin | Manage all tenants | all | yes | `/admin/tenants/*` | `tenants_super_admin_all` |
| super_admin | Manage all users | all | yes | `/users/*` | `users_super_admin_all` |
| admin | Manage own tenant's users | team | yes | `/users` (scoped by tenant_id) | `users_admin_own_tenant` |
| admin | View tenant billing | team | yes | `/billing` | `billing_admin_own_tenant` |
| vendor | Manage own listings | own-data | yes | `/listings` (scoped by vendor_id) | `listings_vendor_own` |
| vendor | View own orders | own-data | yes | `/orders` (scoped by vendor_id) | `orders_vendor_own` |
| vendor | View other vendors' listings | — | read-only | `/listings` (public fields only) | `listings_public_read` |

Add one row per (role, permission) pair. Do not collapse multiple permissions into one row —
the point of the matrix is that every checkable fact is enumerable, not summarized.

## Scope Definitions

- **own-data** — role can only see/act on records it created or owns
- **team** — role can see/act on records within its tenant/organization
- **all** — role can see/act on records across every tenant (platform-level)

## Usage

- **RLS policies:** every policy referenced in the "RLS Policy Reference" column must exist in
  the database and must cite this matrix file's path in a SQL comment above the policy
  definition.
- **API middleware:** every endpoint in "API Endpoints Affected" must have a middleware check
  that enforces the matching scope, with a code comment citing this matrix file's path.
- **Frontend visibility guards:** every component gated by role must cite this matrix file's
  path in a comment near the guard condition.

## Example Citation (any layer)

```sql
-- Permissions: see PERMISSIONS-MATRIX.md (role: admin, scope: team)
CREATE POLICY users_admin_own_tenant ON users
  FOR ALL USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

```ts
// Permissions: see PERMISSIONS-MATRIX.md (role: vendor, scope: own-data)
if (user.role !== 'vendor' || listing.vendor_id !== user.id) {
  return res.status(403).json({ error: 'forbidden' });
}
```
