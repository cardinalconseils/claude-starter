---
description: "Phase 5 — Release: Deploy through environments with quality gates"
---

# Release Workflow

## Purpose
Deploy the feature through environments with quality gates at each stage.

## Prerequisites
- Review phase complete (`.phases/{feature_id}/REVIEW.md` exists)
- Iteration decision is "ready_to_release"

## Steps

1. **Read state:** Load `.phases/PRD-STATE.json` and `REVIEW.md`.

2. **Prepare rollback plan:** Document:
   - How to rollback if something goes wrong
   - Who to contact
   - What monitoring to watch

3. **Deploy to dev:**
   - Deploy the feature to dev environment
   - Run health checks
   - If health checks fail → stop and report

4. **Deploy to staging:**
   - Deploy to staging environment
   - Run E2E tests
   - If E2E tests fail → stop and report

5. **Deploy to RC:**
   - Deploy to release candidate environment
   - Configure monitoring (errors, performance, uptime)
   - Verify monitoring is green
   - If monitoring shows issues → stop and report

6. **Deploy to production (requires confirmation):**
   - Ask user to confirm production deployment
   - Deploy to production
   - Run post-deploy health checks
   - Watch monitoring for 15 minutes
   - If issues → execute rollback plan

7. **Post-deploy verification:**
   - Verify feature is live and functional
   - Check monitoring dashboards
   - Verify no critical errors
   - Document deployment outcome

8. **Update state:** Set `phase_status` to "complete", `current_phase` to "released", `next_action` to "Feature released. Start next feature or maintenance.", `suggested_command` to "/new".

9. **Generate artifact:** Write release summary to `.phases/{feature_id}/RELEASE.md`.

10. **Final report:** Show the user a simple completion message in plain English. Say "DONE!" and tell them what was built, where to find it, and what to do next.

## Quality Gates
- Health checks must pass at each environment
- E2E tests must pass before RC
- Monitoring must be configured before production
- Rollback plan must be documented before production
- Production deployment requires explicit user confirmation

## Rules
- Safety first: never deploy without rollback plan
- Gradual rollout: dev → staging → RC → production
- Stop on any failed gate
- Always watch monitoring after production deploy
- Never auto-deploy to production without confirmation
- **Plain English only** — no jargon, no command names, no phase numbers
- **Show a clear DONE message when complete** — the user should know it's finished
