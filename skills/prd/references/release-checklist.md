# Release Checklist Reference

## Quality Gates by Environment

### Gate 1: Dev → Staging

**Must pass:**
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] Build succeeds without warnings
- [ ] No lint errors
- [ ] No TypeScript/type errors
- [ ] Acceptance criteria met (from VERIFICATION.md)
- [ ] Code review completed (no blocking issues)
- [ ] No hardcoded secrets or credentials
- [ ] Environment variables documented

**Should check:**
- [ ] No console.log/print statements left in production code
- [ ] No TODO/FIXME on critical paths
- [ ] Error handling covers expected failure modes
- [ ] Database migrations tested (up and down)

### Gate 2: Staging → Release Candidate

**Must pass:**
- [ ] All Gate 1 criteria met
- [ ] Real user feedback collected (minimum: 1 stakeholder review)
- [ ] Error rate < {threshold}% over 24h
- [ ] No critical/blocker bugs open
- [ ] API response times within SLA
- [ ] Memory/CPU usage stable (no leaks)
- [ ] All known bugs triaged (critical = fixed, high = scheduled)

**Should check:**
- [ ] Documentation updated (README, API docs, changelog)
- [ ] Feature flags configured correctly
- [ ] Monitoring dashboards show expected metrics
- [ ] Rollback procedure tested on staging

### Gate 3: RC → Production

**Must pass:**
- [ ] All Gate 1 + Gate 2 criteria met
- [ ] **E2E regression suite passes** — ALL critical paths, not just new feature
- [ ] Performance targets met (p95 response time, throughput)
- [ ] Security review complete (see security-checklist.md)
- [ ] Load testing passed (if applicable)
- [ ] Rollback plan documented and tested
- [ ] Database migration rollback tested
- [ ] Feature flags ready for kill-switch

**Must confirm:**
- [ ] Monitoring and alerting configured for new endpoints/features
- [ ] On-call team notified of release
- [ ] Incident response plan reviewed

### Gate 4: Post-Production

**Immediate (first 15 minutes):**
- [ ] Smoke test passes on production
- [ ] E2E critical paths verified on production
- [ ] No error spikes in monitoring
- [ ] API endpoints responding correctly
- [ ] Database queries executing normally

**First hour:**
- [ ] Error rate stable or improved
- [ ] Performance within SLA
- [ ] No user-reported issues
- [ ] Logs show expected behavior

**First 24 hours:**
- [ ] Success metrics tracking active
- [ ] No degradation from baseline
- [ ] Changelog published
- [ ] CLAUDE.md updated with new patterns/deps

## Rollback Procedures

### Instant Rollback (< 5 minutes)
```bash
# Revert to previous deployment
vercel rollback                      # Vercel
railway rollback                     # Railway
git revert HEAD && git push          # Git-based
```

### Feature Flag Rollback (< 1 minute)
```
Disable feature flag → feature hidden immediately
No deployment needed
```

### Database Rollback
```bash
# Run down migration
npm run migrate:down                 # or equivalent
# Verify data integrity
npm run db:check
```

**WARNING**: Database rollbacks may cause data loss if the migration was destructive. Always verify:
1. Is the down migration non-destructive?
2. Was any new data written that depends on the new schema?
3. Do other services depend on the new schema?

## Release Types

| Type | Gate Required | When |
|------|--------------|------|
| **Hotfix** | Gate 1 + Gate 4 only | Critical production bug |
| **Patch** | Gates 1-2 + Gate 4 | Bug fixes, minor improvements |
| **Minor** | All gates | New features |
| **Major** | All gates + extended staging | Breaking changes, large features |

## Semantic Versioning

```
MAJOR.MINOR.PATCH

MAJOR: Breaking changes (API, schema, behavior)
MINOR: New features, backwards-compatible
PATCH: Bug fixes, backwards-compatible
```

## Communication Checklist

- [ ] Changelog entry written
- [ ] Release notes for stakeholders (if user-facing changes)
- [ ] API documentation updated (if endpoints changed)
- [ ] Internal team notified (Slack/email)
- [ ] External users notified (if breaking changes)
