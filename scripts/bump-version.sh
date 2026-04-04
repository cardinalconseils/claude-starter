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
  VERSIONING_ENABLED=$(jq -r 'if .versioning.enabled == false then "false" else "true" end' "$CONFIG_FILE")
  VERSIONING_SOURCE=$(jq -r '.versioning.source // empty' "$CONFIG_FILE")
  VERSIONING_STRATEGY=$(jq -r '.versioning.strategy // "auto-patch"' "$CONFIG_FILE")
  VERSIONING_CHANGELOG=$(jq -r 'if .versioning.changelog == false then "false" else "true" end' "$CONFIG_FILE")
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

MAJOR=$(echo "$LATEST_TAG" | cut -d. -f1)
MINOR=$(echo "$LATEST_TAG" | cut -d. -f2)
PATCH=$(echo "$LATEST_TAG" | cut -d. -f3)

# --- Detect bump type from conventional commits since last tag ---
BUMP_TYPE="patch"
if [ "$VERSIONING_STRATEGY" = "semver" ] || [ "$VERSIONING_STRATEGY" = "auto-semver" ]; then
  COMMIT_LOG=$(git log "v$LATEST_TAG..HEAD" --format='%s%n%b' 2>/dev/null)

  # BREAKING CHANGE (in body or ! suffix) → major
  if echo "$COMMIT_LOG" | grep -qiE '^BREAKING[ -]CHANGE' || \
     echo "$COMMIT_LOG" | grep -qE '^[a-z]+(\([^)]*\))?!:'; then
    BUMP_TYPE="major"
  # feat: → minor
  elif echo "$COMMIT_LOG" | grep -qE '^feat(\([^)]*\))?:'; then
    BUMP_TYPE="minor"
  fi
fi

# --- Compute new version (standard semver: +1, reset lower segments) ---
case "$BUMP_TYPE" in
  major) NEW_VERSION="$((MAJOR + 1)).0.0" ;;
  minor) NEW_VERSION="$MAJOR.$((MINOR + 1)).0" ;;
  patch) NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))" ;;
esac

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
    # Collect ALL commits since last tag (not just the last one)
    TAG_REF="v$LATEST_TAG"
    git rev-parse "$TAG_REF" &>/dev/null || TAG_REF="$LATEST_TAG"
    git rev-parse "$TAG_REF" &>/dev/null || TAG_REF=""

    if [ -n "$TAG_REF" ]; then
      COMMIT_SUBJECTS=$(git log "$TAG_REF..HEAD" --format='%s' --no-merges 2>/dev/null)
    else
      COMMIT_SUBJECTS=$(git log --format='%s' --no-merges -20 2>/dev/null)
    fi

    # If no commits in range, fall back to current commit
    if [ -z "$COMMIT_SUBJECTS" ]; then
      COMMIT_SUBJECTS=$(git log -1 --format='%s' HEAD 2>/dev/null)
    fi

    # Categorize each commit subject into groups
    ADDED=""
    FIXED=""
    CHANGED=""
    DOCS=""
    PERF=""
    MAINT=""

    while IFS= read -r msg; do
      [ -z "$msg" ] && continue
      # Strip conventional commit prefix for clean description
      clean=$(echo "$msg" | sed -E 's/^[a-z]+(\([^)]*\))?: *//' | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
      case "$msg" in
        feat:*|feat\(*)       ADDED="${ADDED}- ${clean}"$'\n' ;;
        fix:*|fix\(*)         FIXED="${FIXED}- ${clean}"$'\n' ;;
        docs:*|docs\(*)       DOCS="${DOCS}- ${clean}"$'\n' ;;
        refactor:*|refactor\(*) CHANGED="${CHANGED}- ${clean}"$'\n' ;;
        perf:*|perf\(*)       PERF="${PERF}- ${clean}"$'\n' ;;
        chore:*|chore\(*)     MAINT="${MAINT}- ${clean}"$'\n' ;;
        *)                    CHANGED="${CHANGED}- ${clean}"$'\n' ;;
      esac
    done <<< "$COMMIT_SUBJECTS"

    # Build the new changelog entry
    TMPFILE=$(mktemp)
    {
      awk '/^## \[/{found=1} !found{print}' "$CHANGELOG"
      echo ""
      echo "## [$NEW_VERSION] - $BUILD_DATE"
      [ -n "$ADDED" ]  && echo "" && echo "### Added"  && printf '%s' "$ADDED"
      [ -n "$FIXED" ]  && echo "" && echo "### Fixed"  && printf '%s' "$FIXED"
      [ -n "$CHANGED" ] && echo "" && echo "### Changed" && printf '%s' "$CHANGED"
      [ -n "$DOCS" ]   && echo "" && echo "### Documentation" && printf '%s' "$DOCS"
      [ -n "$PERF" ]   && echo "" && echo "### Performance" && printf '%s' "$PERF"
      [ -n "$MAINT" ]  && echo "" && echo "### Maintenance" && printf '%s' "$MAINT"
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
