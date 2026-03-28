# Project Profiles & Phase Autonomy Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add project type profiles (App, Website, Library, API) that adapt versioning, changelog, release ceremony, and per-phase autonomy modes.

**Architecture:** Profile is a field in `prd-config.json`. Commands and scripts read it at runtime. The bump-version script becomes profile-aware. Phase orchestrators read their mode and adapt between interactive/auto/gated behavior.

**Tech Stack:** Bash (bump-version.sh), Markdown (orchestrators, commands), JSON (prd-config.json)

**Spec:** `.prd/specs/2026-03-28-project-profiles-design.md`

---

## Chunk 1: Profile Config & Bump Script

### Task 1: Update prd-config.json with profile fields

**Files:**
- Modify: `.prd/prd-config.json`

- [ ] **Step 1: Add profile, versioning, and phases fields**

Current content:
```json
{
  "mode": "interactive",
  "granularity": "fine",
  "parallelization": true,
  "commit_docs": true,
  "workflow": { ... }
}
```

Replace with (keeping existing workflow fields, removing top-level `mode`):
```json
{
  "profile": "app",
  "versioning": {
    "enabled": true,
    "source": "plugin.json",
    "strategy": "auto-patch",
    "changelog": true
  },
  "phases": {
    "discover": { "mode": "interactive" },
    "design":   { "mode": "interactive" },
    "sprint":   { "mode": "auto" },
    "review":   { "mode": "gated" },
    "release":  { "mode": "gated" }
  },
  "granularity": "fine",
  "parallelization": true,
  "commit_docs": true,
  "workflow": {
    "research": true,
    "plan_check": true,
    "verifier": true,
    "ask_style": "select"
  }
}
```

Note: `versioning.source` is `plugin.json` because THIS project (Claude-Starter) is a Claude plugin. For user projects, bootstrap will set the appropriate source.

- [ ] **Step 2: Commit**

```bash
git add .prd/prd-config.json
git commit -m "feat: add profile, versioning, and phases fields to prd-config.json"
```

---

### Task 2: Rewrite bump-version.sh to be profile-aware

**Files:**
- Modify: `scripts/bump-version.sh`

- [ ] **Step 1: Rewrite the script**

The new script must:
1. Read `.prd/prd-config.json` for versioning config (if exists)
2. If `versioning.enabled` is `false` or `versioning.strategy` is `manual` or `skip` -> exit 0
3. Determine version source from config or auto-detect
4. Bump version in the detected source file
5. Update CHANGELOG.md if `versioning.changelog` is true
6. Auto-stage modified files only
7. Backwards compatible: if no config, fall back to current detection logic

```bash
#!/bin/bash
# Auto-bump version from git state — profile-aware
# Reads .prd/prd-config.json for versioning config.
# Falls back to auto-detection if no config exists.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$PLUGIN_DIR/.prd/prd-config.json"
CHANGELOG="$PLUGIN_DIR/CHANGELOG.md"

# --- Read profile config ---
VERSIONING_ENABLED="true"
VERSIONING_SOURCE=""
VERSIONING_STRATEGY="auto-patch"
VERSIONING_CHANGELOG="true"

if [ -f "$CONFIG_FILE" ] && command -v jq &>/dev/null; then
  VERSIONING_ENABLED=$(jq -r '.versioning.enabled // true' "$CONFIG_FILE")
  VERSIONING_SOURCE=$(jq -r '.versioning.source // empty' "$CONFIG_FILE")
  VERSIONING_STRATEGY=$(jq -r '.versioning.strategy // "auto-patch"' "$CONFIG_FILE")
  VERSIONING_CHANGELOG=$(jq -r '.versioning.changelog // true' "$CONFIG_FILE")
fi

# Exit if versioning disabled or manual
if [ "$VERSIONING_ENABLED" = "false" ] || [ "$VERSIONING_STRATEGY" = "skip" ] || [ "$VERSIONING_STRATEGY" = "manual" ]; then
  exit 0
fi

# --- Auto-detect source if not configured ---
if [ -z "$VERSIONING_SOURCE" ] || [ "$VERSIONING_SOURCE" = "null" ]; then
  if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    VERSIONING_SOURCE="plugin.json"
  elif [ -f "$PLUGIN_DIR/package.json" ]; then
    VERSIONING_SOURCE="package.json"
  elif [ -f "$PLUGIN_DIR/pyproject.toml" ]; then
    VERSIONING_SOURCE="pyproject.toml"
  elif [ -f "$PLUGIN_DIR/Cargo.toml" ]; then
    VERSIONING_SOURCE="Cargo.toml"
  else
    # No version source found — skip silently
    exit 0
  fi
fi

# --- Get latest tag and compute new version ---
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG="0.0.0"
fi

COMMITS_SINCE=$(git rev-list "${LATEST_TAG:+v$LATEST_TAG..}HEAD" --count 2>/dev/null || echo "0")

MAJOR=$(echo "$LATEST_TAG" | cut -d. -f1)
MINOR=$(echo "$LATEST_TAG" | cut -d. -f2)
PATCH=$(echo "$LATEST_TAG" | cut -d. -f3)
NEW_VERSION="$MAJOR.$MINOR.$((PATCH + COMMITS_SINCE))"

BUILD_DATE=$(date +%Y-%m-%d)
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

STAGED_FILES=""

# --- Update version in source file ---
case "$VERSIONING_SOURCE" in
  plugin.json)
    # CKS plugin self-development mode — update all plugin files
    PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
    MARKETPLACE_JSON="$PLUGIN_DIR/.claude-plugin/marketplace.json"
    README="$PLUGIN_DIR/README.md"
    WORKFLOW="$PLUGIN_DIR/docs/WORKFLOW.md"

    [ -f "$PLUGIN_JSON" ] && sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$PLUGIN_JSON"
    [ -f "$MARKETPLACE_JSON" ] && sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$MARKETPLACE_JSON"
    [ -f "$README" ] && grep -q '> \*\*Version' "$README" && sed -i '' "s/> \*\*Version [^*]*\*\* |.*/> **Version $NEW_VERSION** | Built $BUILD_DATE | \`$COMMIT_HASH\`/" "$README"
    [ -f "$WORKFLOW" ] && grep -q '> \*\*Version' "$WORKFLOW" && sed -i '' "s/> \*\*Version [^*]*\*\* |.*/> **Version $NEW_VERSION** | Built $BUILD_DATE | \`$COMMIT_HASH\`/" "$WORKFLOW"

    STAGED_FILES="$PLUGIN_JSON $MARKETPLACE_JSON $README $WORKFLOW"
    ;;

  package.json)
    PKG="$PLUGIN_DIR/package.json"
    if [ -f "$PKG" ] && command -v jq &>/dev/null; then
      jq --arg v "$NEW_VERSION" '.version = $v' "$PKG" > "$PKG.tmp" && mv "$PKG.tmp" "$PKG"
    elif [ -f "$PKG" ]; then
      sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$PKG"
    fi
    STAGED_FILES="$PKG"
    ;;

  pyproject.toml)
    PYPROJECT="$PLUGIN_DIR/pyproject.toml"
    if [ -f "$PYPROJECT" ]; then
      # Only replace version under [project] section, not [tool.*] sections
      sed -i '' '/^\[project\]/,/^\[/{s/^version = ".*"/version = "'"$NEW_VERSION"'"/;}' "$PYPROJECT"
    fi
    STAGED_FILES="$PYPROJECT"
    ;;

  Cargo.toml)
    CARGO="$PLUGIN_DIR/Cargo.toml"
    if [ -f "$CARGO" ]; then
      sed -i '' '/^\[package\]/,/^\[/{s/^version = ".*"/version = "'"$NEW_VERSION"'"/;}' "$CARGO"
    fi
    STAGED_FILES="$CARGO"
    ;;

  *)
    # Unknown source — skip
    exit 0
    ;;
esac

# --- Update CHANGELOG.md ---
if [ "$VERSIONING_CHANGELOG" = "true" ] && [ -f "$CHANGELOG" ]; then
  CURRENT_CHANGELOG_VERSION=$(grep -m1 '^\## \[' "$CHANGELOG" | sed 's/## \[\([^]]*\)\].*/\1/')

  if [ "$CURRENT_CHANGELOG_VERSION" != "$NEW_VERSION" ]; then
    CHANGED_FILES=$(git diff --cached --name-only 2>/dev/null | grep -v '\.claude-plugin/' | grep -v 'CHANGELOG.md' | head -10)

    TMPFILE=$(mktemp)
    {
      awk '/^## \[/{found=1} !found{print}' "$CHANGELOG"
      echo ""
      echo "## [$NEW_VERSION] - $BUILD_DATE"
      echo ""
      echo "### Changed"
      echo "$CHANGED_FILES" | while IFS= read -r f; do
        [ -n "$f" ] && echo "- \`$f\`"
      done
      echo ""
      awk '/^## \[/{found=1} found{print}' "$CHANGELOG"
    } > "$TMPFILE"
    mv "$TMPFILE" "$CHANGELOG"
  fi

  STAGED_FILES="$STAGED_FILES $CHANGELOG"
fi

# --- Auto-stage modified files ---
cd "$PLUGIN_DIR"
for f in $STAGED_FILES; do
  [ -f "$f" ] && git add -f "$f" 2>/dev/null
done

echo "$NEW_VERSION"
```

- [ ] **Step 2: Verify script is executable**

```bash
chmod +x scripts/bump-version.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/bump-version.sh
git commit -m "feat: make bump-version.sh profile-aware with multi-source support"
```

---

### Task 3: Update pre-commit hook prompt

**Files:**
- Modify: `.claude/settings.json`

- [ ] **Step 1: Update the prompt to respect profile**

Replace the entire hook prompt with:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "The user is about to run a Bash command. Check if the command contains 'git commit'. If it does: First check .prd/prd-config.json — if versioning.enabled is false or versioning.strategy is 'skip' or 'manual', allow the commit without a version bump. Otherwise, check whether scripts/bump-version.sh has already been run in this turn (look for evidence of version bump in the conversation). If git commit is being run WITHOUT a prior version bump and versioning requires it, respond with: {\"decision\": \"block\", \"reason\": \"Run scripts/bump-version.sh and stage the version files before committing.\"}. If the command is not a git commit, or versioning is disabled, or the version was already bumped, allow it. Command to check: $ARGUMENTS"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add .claude/settings.json
git commit -m "feat: pre-commit hook respects versioning profile"
```

---

## Chunk 2: Bootstrap & Adopt Integration

### Task 4: Add profile question to bootstrap workflow

**Files:**
- Modify: `skills/cicd-starter/workflows/bootstrap.md`

- [ ] **Step 1: Add profile question as Q0 before Q1**

Insert a new question block between the `---` after Step 2 and before Step 3's Q1. This becomes the first question in the guided intake:

Find the section starting with `### Step 3: Guided Intake (minimal)` and add before Q1:

```markdown
**Q0: Project profile**

```
What kind of project is this?
```
Options:
- `App / SaaS / Agent (Recommended)` — versioned, full release ceremony
- `Website / Landing Page` — no versioning, deploy-on-push
- `Library / Package` — strict versioning, publish to registry
- `API / Microservice` — versioned, endpoint-focused release

Auto-detection hint (suggest as default based on scan):
- Has `.claude-plugin/` → suggest App
- Has `index.html` + no server framework → suggest Website
- Has `files` or `publishConfig` in package.json → suggest Library
- Has Express/FastAPI/Flask route patterns → suggest API
- Default → App

Store the answer as `{profile}` for use in Step 5.
```

- [ ] **Step 2: Update Step 5 to pass profile to init-project.sh**

After the `bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh "{project_name}"` line, add:

```markdown
**5b. Write profile to prd-config.json:**

After init-project.sh creates `.prd/prd-config.json`, update it with the profile settings:

Read `.prd/prd-config.json` and merge in the profile fields:

| Profile | versioning.enabled | versioning.strategy | versioning.changelog | phases.sprint.mode | phases.release.mode |
|---------|-------------------|--------------------|--------------------|-------------------|-------------------|
| app | true | auto-patch | true | auto | gated |
| website | false | skip | false | auto | auto |
| library | true | manual | true | auto | gated |
| api | true | auto-patch | true | auto | gated |

All profiles set: `phases.discover.mode` = `interactive`, `phases.design.mode` = `interactive`, `phases.review.mode` = `gated`.

Auto-detect `versioning.source` from available files:
- `.claude-plugin/plugin.json` exists → `plugin.json`
- `package.json` exists → `package.json`
- `pyproject.toml` exists → `pyproject.toml`
- `Cargo.toml` exists → `Cargo.toml`
- Otherwise → `null`

Write the merged config to `.prd/prd-config.json`.
```

- [ ] **Step 3: Update Step 7 completion report**

Add profile to the CONFIGURED section:

```markdown
    .prd/prd-config.json            Profile: {profile} | Versioning: {enabled/disabled}
```

- [ ] **Step 4: Update the intake question count**

Change `That's it. 4 questions max.` to `That's it. 5 questions max.` (line 168).

- [ ] **Step 5: Commit**

```bash
git add skills/cicd-starter/workflows/bootstrap.md
git commit -m "feat: add project profile question to bootstrap workflow"
```

---

### Task 5: Add profile question to adopt command

**Files:**
- Modify: `commands/adopt.md`

- [ ] **Step 1: Read the full adopt command**

Read `commands/adopt.md` to understand the current flow.

- [ ] **Step 2: Add profile question after codebase scan**

In the adopt command, after Step 1 (Scan the Codebase) and before the intake questions, add:

```markdown
### Step 1b: Project Profile

Ask the user with AskUserQuestion:
```
What kind of project is this?
```
Options:
- `App / SaaS / Agent (Recommended)` — versioned, full release ceremony
- `Website / Landing Page` — no versioning, deploy-on-push
- `Library / Package` — strict versioning, publish to registry
- `API / Microservice` — versioned, endpoint-focused release

Auto-detect hint from Step 1 scan results (same logic as bootstrap Q0).

When writing `.prd/prd-config.json`, include the profile, versioning, and phases fields based on the selected profile (same defaults table as bootstrap Step 5b).
```

- [ ] **Step 3: Commit**

```bash
git add commands/adopt.md
git commit -m "feat: add project profile question to adopt command"
```

---

## Chunk 3: Phase Autonomy in Orchestrators

### Task 6: Add phase mode reading to all five orchestrators

**Files:**
- Modify: `skills/prd/workflows/discover-phase.md`
- Modify: `skills/prd/workflows/design-phase.md`
- Modify: `skills/prd/workflows/sprint-phase.md`
- Modify: `skills/prd/workflows/review-phase.md`
- Modify: `skills/prd/workflows/release-phase.md`

The same pattern applies to all five files. Insert after the shared context loading and before the first step:

- [ ] **Step 1: Add phase mode block to discover-phase.md**

After the `Read .prd/PRD-STATE.md` line and before `### Step 0: Progress Banner`, insert:

```markdown
### Load phase mode
Read `.prd/prd-config.json` — extract `phases.discover.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps below as written (current behavior). Use AskUserQuestion for all decisions.
- `auto` → Execute all steps without pausing. For AskUserQuestion calls, select the first (recommended) option automatically. Exception: Step 4 (11 Elements discovery) ALWAYS asks the user regardless of mode — per project convention.
- `gated` → Execute steps like auto, but after Step 7 (Completion), pause and ask: "Discovery complete. Review {NN}-CONTEXT.md and proceed? (Yes / Re-run discovery)"
```

- [ ] **Step 2: Add phase mode block to design-phase.md**

Same pattern. After shared context load, before first step:

```markdown
### Load phase mode
Read `.prd/prd-config.json` — extract `phases.design.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps as written. Use AskUserQuestion for all decisions.
- `auto` → Execute all steps without pausing. Select recommended options automatically for design decisions.
- `gated` → Execute steps like auto, but after the final step, pause and ask: "Design complete. Review {NN}-DESIGN.md and proceed? (Yes / Revise design)"
```

- [ ] **Step 3: Add phase mode block to sprint-phase.md**

After the iteration mode detection (Step 0b) and before Step 0c (Progress Banner):

```markdown
### Load phase mode
Read `.prd/prd-config.json` — extract `phases.sprint.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all sub-steps as written. Pause between major steps ([3a], [3c], [3d], [3e]).
- `auto` → Execute all sub-steps sequentially without pausing. Select recommended options automatically. This is the default for sprint — the plan was already approved in design.
- `gated` → Execute steps like auto, but after the final sub-step ([3f] UAT or merge), pause and ask: "Sprint complete. Review results and proceed to review? (Yes / Continue iterating)"
```

- [ ] **Step 4: Add phase mode block to review-phase.md**

After shared context load, before first step:

```markdown
### Load phase mode
Read `.prd/prd-config.json` — extract `phases.review.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps as written. Use AskUserQuestion for all decisions.
- `auto` → Execute all steps without pausing. Select recommended options for review decisions.
- `gated` → Execute steps like auto, but after the final step, pause and ask: "Review complete. Proceed to release, iterate, or stop? (Release / Iterate / Stop)"
```

- [ ] **Step 5: Add phase mode block to release-phase.md**

After shared context load, before first step:

```markdown
### Load phase mode
Read `.prd/prd-config.json` — extract `phases.release.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps as written. Pause at each environment gate ([5a] Dev, [5b] Staging, [5c] RC, [5d] Prod).
- `auto` → Execute all environment promotions without pausing. Only stop on deployment failures.
- `gated` → Execute steps like auto, but pause after [5d] Production deploy and ask: "Production deploy complete. Verify and finalize? (Yes / Rollback)"
```

- [ ] **Step 6: Commit all orchestrators**

```bash
git add skills/prd/workflows/discover-phase.md skills/prd/workflows/design-phase.md skills/prd/workflows/sprint-phase.md skills/prd/workflows/review-phase.md skills/prd/workflows/release-phase.md
git commit -m "feat: add phase autonomy mode reading to all five orchestrators"
```

---

## Chunk 4: Help & Documentation

### Task 7: Update help command with profile info

**Files:**
- Modify: `commands/help.md`

- [ ] **Step 1: Add profile section to help text**

After the `HOOKS (automatic):` section and before `━━━━━`, add:

```
PROFILES (set during /cks:bootstrap):
  app                        Versioned, full release ceremony (default)
  website                    No versioning, deploy-on-push
  library                    Strict versioning, publish to registry
  api                        Versioned, endpoint-focused release
  Edit .prd/prd-config.json to change profile or phase modes
```

- [ ] **Step 2: Add prd-config.json to FILES section**

After `.prd/` line:

```
  .prd/prd-config.json       Profile, versioning, phase autonomy settings
```

- [ ] **Step 3: Commit**

```bash
git add commands/help.md
git commit -m "docs: add profile info to help command"
```

---

### Task 8: Final verification

- [ ] **Step 1: Verify all files were modified**

```bash
git log --oneline feat/project-profiles..HEAD
```

Expected: 7 commits covering config, bump script, pre-commit hook, bootstrap, adopt, orchestrators, help.

- [ ] **Step 2: Test bump-version.sh with current config**

```bash
bash scripts/bump-version.sh
```

Expected: outputs a version number (plugin.json mode since this project has `.claude-plugin/`).

- [ ] **Step 3: Test bump-version.sh with versioning disabled**

```bash
# Temporarily set versioning.enabled to false
jq '.versioning.enabled = false' .prd/prd-config.json > /tmp/test-config.json
cp .prd/prd-config.json .prd/prd-config.json.bak
cp /tmp/test-config.json .prd/prd-config.json
bash scripts/bump-version.sh
echo "Exit code: $?"
# Should exit 0 with no output
cp .prd/prd-config.json.bak .prd/prd-config.json
rm .prd/prd-config.json.bak
```

Expected: no output, exit code 0.

- [ ] **Step 4: Push and create PR**

```bash
git push -u origin feat/project-profiles
gh pr create --title "feat: project profiles & phase autonomy" --body "..."
```
