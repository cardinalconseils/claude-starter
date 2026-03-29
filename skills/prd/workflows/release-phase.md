# Workflow: Release Phase (Phase 5)

## Overview
Environment promotion from Development through Production with quality gates at each stage. Includes E2E regression, health checks, changelog, and post-deploy monitoring. All user interactions MUST use `AskUserQuestion` with selectable options.

## Pre-Conditions
- Phase has been reviewed (phase_status = "reviewed")
- PR exists from Sprint [3g]
- Git has a remote configured

## Steps

### Load phase mode
Read `.prd/prd-config.json` — extract `phases.release.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps as written. Pause at each environment gate ([5a] Dev, [5b] Staging, [5c] RC, [5d] Prod).
- `auto` → Execute all environment promotions without pausing. Only stop on deployment failures.
- `gated` → Execute steps like auto, but pause after [5d] Production deploy and ask: "Production deploy complete. Verify and finalize? (Yes / Rollback)"

### Step 0: Auto Mode Tip

```
💡 Release runs many permission-triggering operations. Enable Auto mode (Shift+Tab → "auto")
```

### Step 0b: Progress Banner

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► RELEASE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ✅ done (PR #{number})
 [4] Review      ✅ done — approved for release
 [5] Release     ▶ current
     [5a] Dev Deploy             ○ pending
     [5b] Staging Deploy         ○ pending
     [5c] RC Deploy + E2E        ○ pending
     [5d] Production Deploy      ○ pending
     [5e] Post-Deploy            ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.release.started" "{NN}-{name}" "Release phase started"`

### Step 1: Preflight Checks

**1a. Project Health:**
```
Skill(skill="doctor")
```
If health score < 50 → warn and ask whether to proceed.
Skip if `--skip-doctor` flag.

**1b. Verification status:**
Read VERIFICATION.md — confirm PASS verdict.

**1c. Working tree:**
```bash
git status --short
```

**1d. Dependencies:**
```bash
if [ -f "package.json" ]; then
  npm install && npm run build
elif [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
fi
```
If build fails → stop.

**1e. Remote + gh CLI:**
```bash
git remote -v | head -2
which gh && gh auth status 2>&1
```

---

### Sub-step [5a]: Dev Deploy + Internal Validation

**Quality Gate: Dev → Staging**

1. Ensure code is on a feature branch (create if on main)
2. Push to remote
3. Deploy to development/preview environment:
   - Vercel: PR auto-generates preview URL
   - Railway: deploy to dev environment
   - Other: `Skill(skill="deploy")` if available

4. Internal validation:
```
AskUserQuestion({
  questions: [{
    question: "Dev deployment ready at {preview_url}. Internal validation:",
    header: "Dev → Staging Gate",
    multiSelect: false,
    options: [
      { label: "Validated — promote to Staging", description: "No major bugs, acceptance criteria met, data flow verified" },
      { label: "Issues found", description: "Bugs or problems discovered — go back to Sprint" },
      { label: "Skip to Staging", description: "Already validated externally" }
    ]
  }]
})
```

If "Issues found" → update STATE.md to `iterating_sprint`, exit release.

```
  [5a] Dev Deploy             ✅ {url} — validated
```

---

### Sub-step [5b]: Staging Deploy + Feedback

**Quality Gate: Staging → RC**

1. Deploy to staging environment
2. Notify limited external testers (if applicable)
3. Monitor:
   - Error rates
   - Performance metrics
   - User feedback

```
AskUserQuestion({
  questions: [{
    question: "Staging deployment live. Collect feedback and validate:",
    header: "Staging → RC Gate",
    multiSelect: false,
    options: [
      { label: "Feedback positive — promote to RC", description: "Error rate acceptable, metrics trending right" },
      { label: "Issues found — fix first", description: "Go back to Sprint for fixes" },
      { label: "Design issues — revisit design", description: "Go back to Phase 2" },
      { label: "Skip staging", description: "Move directly to RC (small change or hotfix)" }
    ]
  }]
})
```

If routing back → update STATE.md, exit release.

```
  [5b] Staging Deploy         ✅ Feedback positive
```

---

### Sub-step [5c]: RC Deploy + E2E Regression Suite

**Quality Gate: RC → Production**

1. Deploy to release candidate / pre-production environment

2. Run full guardrail adherence audit:

```
Skill(skill="cks:review-rules", args="--full")
```

This scans the entire codebase against all `.claude/rules/*.md` files.

- If overall grade is **D or F**: block promotion to production. Report violations and require fixes.
- If grade is **A-C**: include findings in the quality gate report. Proceed to E2E validation.
- If no `.claude/rules/` exists: skip and proceed.

3. Run validation suite. **Decision: Sequential vs. Agent Team**

Check what validation is needed:
- **Backend-only feature** → sequential test run (below)
- **Full-stack feature (frontend + backend + performance)** → use Agent Team for parallel validation

#### Agent Team RC Validation (full-stack features)

When the feature spans frontend + backend, run all validation in parallel:

```
Create an agent team to validate RC deployment for Phase {NN}: {phase_name}.

Team lead consolidates all gate results into a promotion decision.

Spawn 3 teammates (use Sonnet):
- Teammate "e2e-new-feature": Run E2E tests for NEW feature acceptance criteria.
  Navigate to {app_url}. Execute:
  {for each AC from CONTEXT.md translated to browser/API action}
  Take screenshots. Report PASS/FAIL per criterion.

- Teammate "e2e-regression": Run REGRESSION tests for existing features.
  Navigate to {app_url}. Verify critical paths still work:
  - User can log in
  - Core navigation works
  - Existing features unbroken
  Take screenshots. Report PASS/FAIL per path.

- Teammate "perf-security": Run performance + security validation.
  Performance: Lighthouse audit on {app_url}, check load times, bundle size.
  Security: Check for exposed secrets, OWASP basics, auth bypass.
  Report: performance score, security findings.

- Teammate "api-contract" (only if Newman collection exists at testing/newman/):
  Run: npx newman run api-contract.postman_collection.json --environment env-rc.postman_environment.json
  Validate all API endpoints against contract: status codes, response schemas, auth.
  Report PASS/FAIL per endpoint with contract violation details.

Team lead:
- Collect all PASS/FAIL results
- Merge into gate decision: E2E {pass}/{total}, perf score, security status
- Present consolidated results to user via AskUserQuestion
```

#### Sequential Validation (backend-only or simple features)

**If frontend feature detected:**
```
Skill(skill="browse", args="Navigate to {app_url}. Execute full E2E regression:

NEW FEATURE tests (from this phase):
- {AC-1 translated to browser action}
- {AC-2 translated to browser action}

REGRESSION tests (existing features):
- {critical path 1 — e.g., user can log in}
- {critical path 2 — e.g., user can navigate to dashboard}
- {critical path 3 — e.g., existing features still work}

Take screenshot after each test. Report PASS/FAIL.")
```

**If backend/API:**
```bash
# Run full test suite
npm test          # or pytest, cargo test, go test, etc.

# Run E2E if available
npm run test:e2e  # or equivalent

# Run API contract tests via Newman (if collection exists)
if [ -f ".prd/phases/{NN}-{name}/testing/newman/api-contract.postman_collection.json" ]; then
  npx newman run .prd/phases/{NN}-{name}/testing/newman/api-contract.postman_collection.json \
    --environment .prd/phases/{NN}-{name}/testing/newman/env-rc.postman_environment.json \
    --reporters cli,json \
    --reporter-json-export newman-rc-results.json
fi
```

3. Performance validation (if not handled by team above):
```bash
# Basic performance check
if command -v lighthouse &> /dev/null; then
  lighthouse {app_url} --output json --quiet
fi
```

4. Gate decision:
```
AskUserQuestion({
  questions: [{
    question: "RC validation complete. E2E: {pass}/{total}. Promote to Production?",
    header: "RC → Production Gate",
    multiSelect: false,
    options: [
      { label: "Promote to Production", description: "All gates passed — deploy to prod" },
      { label: "E2E failures — fix first", description: "Regression found — go back to Sprint" },
      { label: "Performance issues", description: "Doesn't meet SLA — optimize first" },
      { label: "Security concern", description: "Block until security review complete" }
    ]
  }]
})
```

```
  [5c] RC Deploy + E2E        ✅ E2E: {pass}/{total} — all gates passed {team ? "— parallel validation" : ""}
```

---

### Sub-step [5d]: Production Deploy + Smoke Test

1. Deploy to production:
```
Skill(skill="deploy")
```
Or platform-specific:
```
Skill(skill="vercel:deploy")
```

2. Post-deploy smoke test:
```
Skill(skill="browse", args="Navigate to {production_url}. Smoke test:
- App loads without errors
- Key user journey works end-to-end
- No console errors
- API responds correctly
Take screenshot of each step.")
```

3. E2E validation on production:
```
Skill(skill="browse", args="Navigate to {production_url}. Validate critical user journeys:
- {critical path 1}
- {critical path 2}
Report PASS/FAIL with screenshots.")
```

```
  [5d] Production Deploy      ✅ {platform} — smoke test passed
```

---

### Sub-step [5e]: Post-Deploy

1. **Changelog:**
```
Skill(skill="changelog")
```
Commit if updated.

2. **Documentation refresh + staleness check:**

Run a full documentation refresh and staleness audit:
```
Agent(subagent_type="doc-generator", prompt={
  scope: "all",
  diff_only: false,
  project_root: {project_root},
  staleness_check: true
})
```

Report findings:
```
━━━ Documentation Audit ━━━
 API docs:        {N} endpoints — {ok|M undocumented}
 Architecture:    {current|stale (last updated N days ago)}
 Components:      {N} modules — {ok|M undocumented}
 Onboarding:      {current|references removed feature X}
 Stale docs:      {N} files reference deleted code
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If stale or undocumented items found → warn but do NOT block release. Log findings in the completion report. Commit doc updates if any were generated.

3. **CLAUDE.md update:**
Scan for changes introduced by the shipped feature:
- New dependencies → Stack section
- New env vars → Environment Variables section
- New conventions → Rules section
- New workflows → Key Workflows section

```
Skill(skill="claude-md-management:revise-claude-md")
```
Or update directly. Commit if changed.

4. **Monitoring confirmation:**
```
AskUserQuestion({
  questions: [{
    question: "Production deploy complete. Confirm monitoring:",
    header: "Post-Deploy Checklist",
    multiSelect: true,
    options: [
      { label: "Error monitoring active", description: "Sentry, LogRocket, etc." },
      { label: "Performance monitoring active", description: "Dashboards, alerting" },
      { label: "Success metrics tracking", description: "KPIs from Discovery being measured" },
      { label: "Rollback plan confirmed", description: "Know how to revert if needed" },
      { label: "Skip monitoring", description: "Not applicable for this project" }
    ]
  }]
})
```

5. **Auto-retrospective:**
```
Skill(skill="retro", args="--auto")
```

```
  [5e] Post-Deploy            ✅ Changelog + Docs + CLAUDE.md + monitoring
```

---

### Step 2: Update State

**Update PRD-STATE.md:**
```yaml
phase_status: released
last_action: "Released to production"
last_action_date: {today}
next_action: "Feature complete. Run /cks:new for next feature."
```

**Update PRD-ROADMAP.md:**
- Mark phase as "Released" with date
- Move feature to "Completed" section if all phases done

**Update PRD document:**
- Set status to "Complete"
- Add release notes

### Step 3: Completion Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► RELEASED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ✅ done
 [4] Review      ✅ done
 [5] Release     ✅ done
     [5a] Dev Deploy             ✅ validated
     [5b] Staging Deploy         ✅ feedback positive
     [5c] RC Deploy + E2E        ✅ {pass}/{total} passed
     [5d] Production Deploy      ✅ {platform}
     [5e] Post-Deploy            ✅ monitoring active

 Feature: PRD-{NNN} — {name}
 PR: #{number} ({url})
 Production: {production_url}

 discover ✅ → design ✅ → sprint ✅ → review ✅ → release ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next:
  /cks:new "next feature"    ← start next feature from roadmap
  /cks:progress              ← see overall project status
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.release.completed" "{NN}-{name}" "Release phase completed"`

### Step 4: Context Reset

```
━━━ Context Reset ━━━
Release complete. Clear context before next work:

  /clear
  /cks:next    ← if more features remain
  /cks:status  ← to check overall progress

State is on disk — nothing is lost.
━━━━━━━━━━━━━━━━━━━━━
```

## CD Integration

For continuous deployment monitoring, suggest:
```
Tip: Run /ralph-loop:ralph-loop "monitor production {url} for errors"
```

## Post-Conditions
- Feature deployed to production
- CHANGELOG.md updated
- Documentation refreshed (API, architecture, components, onboarding) — stale docs flagged
- CLAUDE.md updated
- PRD-STATE.md, PRD-ROADMAP.md, PRD document updated
- `.learnings/` updated (auto-retro)
- Monitoring confirmed active
