# Sub-step [5c]: RC Deploy + E2E Regression Suite

<context>
Phase: Release (Phase 5)
Requires: Staging feedback positive ([5b])
Produces: RC validated with E2E results
</context>

**Quality Gate: RC → Production**

## Instructions

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

### Agent Team RC Validation (full-stack features)

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

### Sequential Validation (backend-only or simple features)

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
