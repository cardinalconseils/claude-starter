# Release: {feature_name}

**Feature ID:** {feature_id}
**Phase:** Release
**Date:** {date}

## Rollback Plan

**How to rollback:**
{rollback_steps}

**Who to contact:**
{contacts}

**What to monitor:**
{monitoring_checks}

## Deployment History

| Environment | Deployed At | Health Check | Status |
|-------------|-------------|--------------|--------|
| Dev | {timestamp} | ✅ | Deployed |
| Staging | {timestamp} | ✅ | Deployed |
| RC | {timestamp} | ✅ | Deployed |
| Production | {timestamp} | ✅ | Deployed |

## Monitoring Configuration

- Error tracking: {configured/not_configured}
- Performance monitoring: {configured/not_configured}
- Uptime checks: {configured/not_configured}

## Post-Deploy Verification

- Feature live: ✅
- No critical errors: ✅
- Monitoring green: ✅

## Outcome

{outcome_summary}

---

**Feature Released.** Next → New feature (`/new-feature`)
