#!/bin/bash
# Auto-bump plugin version from git state
# Reads the latest git tag (semver), bumps patch, writes to:
#   - .claude-plugin/plugin.json
#   - .claude-plugin/marketplace.json
#   - README.md (version badge line)
#   - docs/WORKFLOW.md (version line)
#   - CHANGELOG.md (prepend entry for new version)
# Then auto-stages all updated files so they're included in the commit.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$PLUGIN_DIR/.claude-plugin/marketplace.json"
README="$PLUGIN_DIR/README.md"
WORKFLOW="$PLUGIN_DIR/docs/WORKFLOW.md"
CHANGELOG="$PLUGIN_DIR/CHANGELOG.md"

# Get latest semver tag, or default to 0.0.0
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG="0.0.0"
fi

# Count commits since that tag
COMMITS_SINCE=$(git rev-list "${LATEST_TAG:+v$LATEST_TAG..}HEAD" --count 2>/dev/null || echo "0")

# Parse semver
MAJOR=$(echo "$LATEST_TAG" | cut -d. -f1)
MINOR=$(echo "$LATEST_TAG" | cut -d. -f2)
PATCH=$(echo "$LATEST_TAG" | cut -d. -f3)

# New version: tag + commits since tag as patch bump
NEW_VERSION="$MAJOR.$MINOR.$((PATCH + COMMITS_SINCE))"

# Get current date
BUILD_DATE=$(date +%Y-%m-%d)

# Get short commit hash
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# --- Update plugin.json ---
if [ -f "$PLUGIN_JSON" ]; then
  sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$PLUGIN_JSON"
fi

# --- Update marketplace.json ---
if [ -f "$MARKETPLACE_JSON" ]; then
  sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$MARKETPLACE_JSON"
fi

# --- Update README.md ---
if [ -f "$README" ]; then
  # Replace the version line (format: > **Version X.Y.Z** | ...)
  if grep -q '> \*\*Version' "$README"; then
    sed -i '' "s/> \*\*Version [^*]*\*\* |.*/> **Version $NEW_VERSION** | Built $BUILD_DATE | \`$COMMIT_HASH\`/" "$README"
  fi
fi

# --- Update WORKFLOW.md ---
if [ -f "$WORKFLOW" ]; then
  # Replace the version line (format: > **Version X.Y.Z** | ...)
  if grep -q '> \*\*Version' "$WORKFLOW"; then
    sed -i '' "s/> \*\*Version [^*]*\*\* |.*/> **Version $NEW_VERSION** | Built $BUILD_DATE | \`$COMMIT_HASH\`/" "$WORKFLOW"
  fi
fi

# --- Update CHANGELOG.md ---
if [ -f "$CHANGELOG" ]; then
  # Get the current top version in CHANGELOG
  CURRENT_CHANGELOG_VERSION=$(grep -m1 '^\## \[' "$CHANGELOG" | sed 's/## \[\([^]]*\)\].*/\1/')

  # Only add entry if version changed
  if [ "$CURRENT_CHANGELOG_VERSION" != "$NEW_VERSION" ]; then
    # Build a changelog entry from staged file names
    STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | grep -v '\.claude-plugin/' | grep -v 'CHANGELOG.md' | head -10)

    # Use a temp file for reliable multiline insertion (macOS sed can't do this)
    TMPFILE=$(mktemp)
    {
      # Copy everything up to (but not including) the first ## [ line
      awk '/^## \[/{found=1} !found{print}' "$CHANGELOG"
      # Insert new entry
      echo ""
      echo "## [$NEW_VERSION] - $BUILD_DATE"
      echo ""
      echo "### Changed"
      echo "$STAGED_FILES" | while IFS= read -r f; do
        [ -n "$f" ] && echo "- \`$f\`"
      done
      echo ""
      # Copy the rest (from first ## [ onward)
      awk '/^## \[/{found=1} found{print}' "$CHANGELOG"
    } > "$TMPFILE"
    mv "$TMPFILE" "$CHANGELOG"
  fi
fi

# --- Auto-stage all bumped files ---
cd "$PLUGIN_DIR"
git add -f \
  "$PLUGIN_JSON" \
  "$MARKETPLACE_JSON" \
  "$README" \
  "$WORKFLOW" \
  "$CHANGELOG" \
  2>/dev/null

echo "$NEW_VERSION"
