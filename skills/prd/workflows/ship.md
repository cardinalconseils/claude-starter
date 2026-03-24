# Workflow: Ship

## Overview
Handles the e2e test → commit → push → PR → review → deploy → update roadmap flow. This is the tail end of the lifecycle that bridges "code complete" to "deployed".

## Pre-Conditions
- At least one phase has been verified (VERIFICATION.md exists with PASS)
- Git is initialized and has a remote

## Steps

### Step 1: Preflight Checks

**1a. Verification status:**
```bash
# Find all verification files
find .prd/phases -name "*-VERIFICATION.md" 2>/dev/null
```
Read each and check for PASS verdict. Warn if any are FAIL/PARTIAL.

**1b. Working tree:**
```bash
git status --short
```
Note uncommitted changes.

**1c. Current branch:**
```bash
git branch --show-current
```
If on `main`/`master` → create a feature branch.

**1d. Remote:**
```bash
git remote -v | head -2
```
If no remote → error.

**1e. gh CLI:**
```bash
which gh && gh auth status 2>&1
```
If not available → warn, skip PR creation.

**1f. Dependency sync:**

Detect the project type and ensure dependencies are up to date:

```bash
# Detect project type
if [ -f "package.json" ]; then
  echo "NODE project detected"
  # Check if node_modules is out of sync with package.json
  npm ls --depth=0 2>&1 | grep -q "missing" && echo "DEPS_STALE" || echo "DEPS_OK"
elif [ -f "requirements.txt" ]; then
  echo "PYTHON project detected (requirements.txt)"
elif [ -f "pyproject.toml" ]; then
  echo "PYTHON project detected (pyproject.toml)"
elif [ -f "Pipfile" ]; then
  echo "PYTHON project detected (Pipfile)"
fi
```

**If Node.js (package.json):**
- Run `npm install` to ensure `node_modules/` and `package-lock.json` are in sync
- If new packages were added during the phase, `package-lock.json` may have changed — this ensures it's committed
- Run `npm run build` to verify the build still passes with current deps
- If build fails → stop and report the error

**If Python (requirements.txt / pyproject.toml / Pipfile):**
- Run `pip install -r requirements.txt` (or `pip install -e .` for pyproject.toml, or `pipenv install` for Pipfile)
- Run `pip freeze > requirements.txt` if using requirements.txt to lock versions
- Verify no broken imports: `python -c "import {main_module}"`

**If deps changed:**
```
Dependencies: Updated ✓
  {list of new/changed packages}
```

**If deps are clean:**
```
Dependencies: Up to date ✓
```

### Step 2: E2E Testing (Frontend Features)

**This runs BEFORE any commit, push, or PR.** If E2E fails, you fix before shipping.

Determine if the shipped phases include frontend/UI work by checking the PRD and phase summaries for keywords like: component, UI, page, canvas, node, editor, modal, sidebar, palette, drag, click, render.

**If frontend feature detected:**

```
━━━ E2E Testing ━━━
Frontend changes detected. Running browser tests before shipping...
```

Use the `/browse` skill to verify the feature works in a real browser:

```
Skill(skill="browse", args="Navigate to {app_url}. Test the following acceptance criteria from the shipped phases:
- {AC-1 from VERIFICATION.md — translated to browser action}
- {AC-2 — translated to browser action}
- {AC-3 — translated to browser action}
Take a screenshot after each test step.
Report: PASS/FAIL for each criterion with screenshot evidence.")
```

**How to translate acceptance criteria to browser actions:**

| Criterion Type | Browser Action |
|---|---|
| "User can drag X" | Click and drag element, verify position changed |
| "Component renders" | Navigate to page, take screenshot, verify element visible |
| "Double-click to edit" | Double-click element, type text, verify input appears |
| "Ctrl+Z undoes" | Perform action, press Ctrl+Z, verify reverted |
| "Modal/popover opens" | Click trigger, verify popover/modal visible |
| "Icon picker shows icons" | Open picker, search for icon, verify results |

**If E2E tests pass:**
```
E2E Testing: PASS ✓
  ✓ {criterion 1}
  ✓ {criterion 2}
  Screenshots saved to .prd/phases/{NN}-{name}/e2e/
```
Proceed to commit.

**If E2E tests fail:**
```
E2E Testing: FAIL ✗
  ✗ {criterion} — {what happened vs expected}
  Screenshot: {path}
```

Use `AskUserQuestion` to decide:
```
AskUserQuestion({
  questions: [{
    question: "E2E tests failed. How do you want to proceed?",
    header: "E2E Fail",
    multiSelect: false,
    options: [
      { label: "Fix and re-test (Recommended)", description: "Go back to fix the failing criteria, then re-run /prd:ship" },
      { label: "Ship anyway", description: "Proceed with shipping despite E2E failures — note them in the PR" },
      { label: "Abort shipping", description: "Cancel the ship workflow entirely" }
    ]
  }]
})
```

- **Fix** → Stop workflow. User fixes, then re-runs `/prd:ship`.
- **Ship anyway** → Continue but include E2E failures in the PR body.
- **Abort** → Stop workflow entirely.

**If no frontend feature or `/browse` not available:**
```
E2E Testing: Skipped (no frontend changes detected)
```

### Step 3: Commit Phase Work

For each completed phase (or all if shipping everything):

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(phase-{NN}): {phase name}

Implemented Phase {NN} of PRD-{NNN}: {feature name}
- {key change 1}
- {key change 2}
- {key change 3}

Acceptance criteria: {X}/{Y} verified
E2E: {PASS/SKIP/FAIL with note}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

If multiple phases, make one commit per phase for clean history.

### Step 4: Create Feature Branch (if needed)

```bash
CURRENT=$(git branch --show-current)
if [ "$CURRENT" = "main" ] || [ "$CURRENT" = "master" ]; then
  git checkout -b feat/prd-{NNN}-{kebab-name}
fi
```

### Step 5: Push to Remote

```bash
git push -u origin $(git branch --show-current)
```

### Step 6: Create Pull Request

Generate PR body from planning artifacts:

```bash
gh pr create --title "PRD-{NNN}: {Feature Title}" --body "$(cat <<'EOF'
## Summary

**Feature:** PRD-{NNN} — {Feature Title}
**Phases:** {N} implemented and verified

{One paragraph from SUMMARY.md files — what was built}

## Changes by Phase

### Phase {NN}: {Name}
{Summary from .prd/phases/{NN}-{name}/SUMMARY.md}

**Key files:**
- {modified files list}

## Verification

{From VERIFICATION.md}
- [x] {criterion 1} — PASS
- [x] {criterion 2} — PASS

## E2E Testing

{From Step 2 results}
- [x] {browser test 1} — PASS
- [x] {browser test 2} — PASS
{or: E2E skipped — no frontend changes}

## Requirements Addressed

{From PRD-REQUIREMENTS.md}
- REQ-{NNN}: {description}

## Test Plan

- [x] Acceptance criteria verified
- [x] E2E browser tests (if frontend)
- [ ] Manual regression check
- [ ] Check for regressions

---
*Generated by PRD Plugin*
EOF
)"
```

Record the PR number and URL.

### Step 7: Code Review

Attempt to invoke code review skills in order of preference:

```
1. Skill(skill="pr-review-toolkit:review-pr")
2. Skill(skill="code-review:code-review")
3. Skill(skill="coderabbit:review")
```

Use whichever is available. If none available, skip with a note.

### Step 8: Deploy (Optional)

Check if deploy skill is available:

```
Skill(skill="deploy")
```

If not available or not configured, skip with:
```
Deploy: Skipped (no deploy skill configured)
Tip: Set up /deploy or use /prd:cd for continuous deployment
```

### Step 9: Update State

**Update PRD-ROADMAP.md:**
- Mark all shipped phases as "Complete" with today's date
- Move feature to "Completed" section if all phases done

**Update PRD-STATE.md:**
```yaml
phase_status: shipped
last_action: "Shipped via PR #{number}"
next_action: "Monitor PR and deployment"
```

**Update PRD:**
- Set status to "Complete" (if all phases shipped)
- Add shipping notes

### Step 10: Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► SHIPPED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Feature: PRD-{NNN} — {name}
 Branch: {branch}
 PR: #{number} ({url})
 E2E: {PASS ✓ / SKIP / FAIL ✗}
 Review: {status}
 Deploy: {status}

 Roadmap updated ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## CD Integration

For continuous deployment monitoring, suggest:
```
Tip: Run /ralph-loop:ralph-loop "check PR #{number} status and deploy when merged"
```

This uses the ralph-loop plugin to poll PR status and trigger deployment when the PR is merged.
