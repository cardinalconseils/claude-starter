# Workflow: Ship

## Overview
Handles the e2e test → commit → push → PR → review → deploy → update roadmap flow. This is the tail end of the lifecycle that bridges "code complete" to "deployed".

## Pre-Conditions
- At least one phase has been verified (VERIFICATION.md exists with PASS)
- Git is initialized and has a remote

## Steps

### Auto Mode Tip

Ship runs many permission-triggering operations (git push, gh pr create, deploy). Display this tip once before the progress banner:

```
💡 Ship runs best with Auto mode — enable it with Shift+Tab → "auto" or claude --auto
```

Then proceed immediately — do not wait for a response.

### Progress Banner

Display at the start of ship:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SHIP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discuss     ✅ done
 [2] Plan        ✅ done
 [3] Execute     ✅ done
 [4] Verify      ✅ passed
 [5] Ship        ▶ current
     [5a] Doctor       ○ pending
     [5b] E2E Tests    ○ pending
     [5c] Commit       ○ pending
     [5d] Push + PR    ○ pending
     [5e] Review       ○ pending
     [5f] Deploy       ○ pending
     [5g] Changelog    ○ pending
     [5h] Retro        ○ pending
 [6] Retro       ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Update the sub-step status as each completes:**

After each sub-step, display its completion:
```
  [5a] Doctor       ✅ Health: {score}/100
  [5b] E2E Tests    ✅ {N} passed (or ⊘ skipped)
  [5c] Commit       ✅ {hash} {message}
  [5d] Push + PR    ✅ PR #{number} — {url}
  [5e] Review       ✅ {tool used} (or ⊘ skipped)
  [5f] Deploy       ✅ {platform} (or ⊘ skipped)
  [5g] Changelog    ✅ CHANGELOG.md updated
  [5h] Retro        ✅ {N} learnings captured
```

### Step 0: Project Health Check (Doctor)

Run a quick health diagnostic before shipping:

Try `Skill(skill="doctor")` if available. If the doctor skill is not installed, run an inline check instead:

**Inline fallback (if doctor skill unavailable):**
1. Check for `TODO`/`FIXME`/`HACK` markers in changed files: `git diff --name-only HEAD~1 | xargs grep -l "TODO\|FIXME\|HACK" 2>/dev/null`
2. Check test suite passes: detect test runner from package.json/Makefile, run tests
3. Check for uncommitted changes: `git status --porcelain`
4. Report health score: 0 issues = proceed, 1-3 = warn, 4+ = ask user

**If health score < 50:** Warn the user and list critical issues. Ask whether to proceed.
**If health score 50-79:** Show warnings but proceed.
**If health score >= 80:** Proceed with confidence.

Skip this step if the user passed `--skip-doctor` to the ship command.

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

Try the `/browse` skill if available. If not installed, skip E2E browser testing and note it in the report.

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
      { label: "Fix and re-test (Recommended)", description: "Go back to fix the failing criteria, then re-run /cks:ship" },
      { label: "Ship anyway", description: "Proceed with shipping despite E2E failures — note them in the PR" },
      { label: "Abort shipping", description: "Cancel the ship workflow entirely" }
    ]
  }]
})
```

- **Fix** → Stop workflow. User fixes, then re-runs `/cks:ship`.
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

Attempt to invoke code review tools in order of preference:

```
1. Skill(skill="pr-review-toolkit:review-pr")
2. Skill(skill="code-review:code-review")
3. Skill(skill="coderabbit:review")
```

Use whichever is available. If none available, skip with a note.

### Step 7b: Generate Changelog

After the PR is created, generate a changelog entry.

Try `Skill(skill="changelog")` if available. If the changelog skill is not installed, generate inline:

**Inline fallback:**
1. Read the git log since the last tag: `git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~10")..HEAD --oneline`
2. Categorize commits by conventional commit prefix (feat, fix, docs, etc.)
3. Write/update CHANGELOG.md with a new version entry

If CHANGELOG.md was updated, stage and commit:
```bash
git add CHANGELOG.md
git commit -m "$(cat <<'EOF'
docs: update changelog for PRD-{NNN}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
git push
```

### Step 8: Deploy (Optional)

Try `Skill(skill="deploy")` or dispatch the deployer agent if available:

```
Agent(subagent_type="cks:deployer", prompt="Deploy the current release. Read .prd/PRD-STATE.md for context.")
```

If neither is available or not configured, skip with:
```
Deploy: Skipped (no deploy agent/skill configured)
Tip: Set up /cks:deploy or configure a deploy skill for automated deployment
```

### Step 9: Update CLAUDE.md

After shipping, the project has evolved — new patterns, dependencies, conventions, or env vars may have been introduced. Update CLAUDE.md to reflect the current state.

**Scan for changes introduced by the shipped phases:**

1. **New dependencies** — check `package.json`, `pyproject.toml`, etc. for packages added during the feature
2. **New env vars** — check `.env.local`, `.env.example` for vars added
3. **New conventions** — scan SUMMARY.md files for architectural decisions or patterns established
4. **New workflows** — check if the feature introduced commands, scripts, or processes worth documenting
5. **Stack changes** — any new integrations (Stripe, Supabase, etc.) that Claude should know about

**Apply updates to CLAUDE.md:**
- Add new deps to the Stack section
- Add new env vars to the Environment Variables section
- Add new conventions to the Always Follow These Rules section
- Add new workflows to the Key Workflows section
- Don't duplicate — check what's already there before adding

Make the updates directly.

If CLAUDE.md was updated, commit it:
```bash
git add CLAUDE.md
git commit -m "$(cat <<'EOF'
docs: update CLAUDE.md after shipping PRD-{NNN}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
git push
```

### Step 10: Update State

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

### Step 11: Ship Completion Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► SHIPPED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discuss     ✅ done
 [2] Plan        ✅ done
 [3] Execute     ✅ done
 [4] Verify      ✅ passed
 [5] Ship        ✅ done
     [5a] Doctor       ✅ {score}/100
     [5b] E2E Tests    {✅ passed | ⊘ skipped}
     [5c] Commit       ✅ {hash}
     [5d] Push + PR    ✅ PR #{number} — {url}
     [5e] Review       {✅ reviewed | ⊘ skipped}
     [5f] Deploy       {✅ {platform} | ⊘ skipped}
     [5g] Changelog    ✅ updated
     [5h] Retro        ✅ {N} learnings

 Feature: PRD-{NNN} — {name}
 Branch: {branch}
 Roadmap updated ✓

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 12: Auto-Retrospective

After shipping is complete, run a lightweight retrospective to capture learnings:

```
Skill(skill="retro", args="--auto")
```

This analyzes the shipped work (git history, verification results, commit patterns) and saves learnings to `.learnings/`. No user interaction — it's fully automatic.

If the retro skill is not available, skip silently.

### Step 13: Context Reset

All state is persisted to disk. Instruct the user to clear the context window before continuing:

```
━━━ Context Reset ━━━
Ship complete. Clear context before next work:

  /clear
  /cks:next    ← if more phases remain
  /cks:status  ← to check overall progress

State is on disk — nothing is lost.
━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to the next workflow via Skill().** Stop here. The user runs `/clear` then decides what's next.

## CD Integration

For continuous deployment monitoring, suggest:
```
Tip: Run /ralph-loop:ralph-loop "check PR #{number} status and deploy when merged"
```

This uses the ralph-loop plugin to poll PR status and trigger deployment when the PR is merged.
