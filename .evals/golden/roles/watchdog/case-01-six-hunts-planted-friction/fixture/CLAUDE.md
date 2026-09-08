# Mapleboard

## Rules
- Every PR must pass `npm test` before merge.
- All database migrations must be rollback-tested on staging before they ship.
- Secrets never leave `.env.local`.
