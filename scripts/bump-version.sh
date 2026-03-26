#!/bin/bash
# Auto-bump plugin version from git state
# Reads the latest git tag (semver), bumps patch, writes to:
#   - .claude-plugin/plugin.json
#   - .claude-plugin/marketplace.json
#   - README.md (version badge line)
#   - docs/WORKFLOW.md (version line)

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$PLUGIN_DIR/.claude-plugin/marketplace.json"
README="$PLUGIN_DIR/README.md"
WORKFLOW="$PLUGIN_DIR/docs/WORKFLOW.md"

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

echo "$NEW_VERSION"
