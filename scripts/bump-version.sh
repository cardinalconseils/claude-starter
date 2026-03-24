#!/bin/bash
# Auto-bump plugin version from git state
# Reads the latest git tag (semver), bumps patch, writes to plugin.json + marketplace.json

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$PLUGIN_DIR/.claude-plugin/marketplace.json"

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

# Update plugin.json
if [ -f "$PLUGIN_JSON" ]; then
  sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$PLUGIN_JSON"
fi

# Update marketplace.json
if [ -f "$MARKETPLACE_JSON" ]; then
  sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$MARKETPLACE_JSON"
fi

echo "$NEW_VERSION"
