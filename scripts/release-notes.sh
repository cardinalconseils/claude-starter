#!/bin/bash
# Generate release notes from git history between two versions.
# Usage: ./release-notes.sh [--from <tag>] [--to <tag|HEAD>] [--create-release]
#
# Without --create-release: prints markdown to stdout.
# With --create-release: creates a GitHub Release using `gh`.

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PLUGIN_DIR" || exit 1

FROM_TAG=""
TO_REF="HEAD"
CREATE_RELEASE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM_TAG="$2"; shift 2 ;;
    --to) TO_REF="$2"; shift 2 ;;
    --create-release) CREATE_RELEASE=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Auto-detect FROM_TAG: second-most-recent tag (current version is the latest)
if [ -z "$FROM_TAG" ]; then
  FROM_TAG=$(git tag --sort=-v:refname | sed -n '2p')
  if [ -z "$FROM_TAG" ]; then
    FROM_TAG=$(git rev-list --max-parents=0 HEAD)
  fi
fi

# Get current version for the release title
CURRENT_VERSION=$(jq -r '.version' "$PLUGIN_DIR/.claude-plugin/plugin.json" 2>/dev/null || echo "unknown")

# Gather commits, excluding merge commits
COMMITS=$(git log "$FROM_TAG..$TO_REF" --no-merges --format='%s|%h|%an' 2>/dev/null)

if [ -z "$COMMITS" ]; then
  echo "No commits found between $FROM_TAG and $TO_REF"
  exit 0
fi

# Categorize commits
FEATURES=""
FIXES=""
DOCS=""
REFACTORS=""
PERF=""
CHORES=""
OTHER=""

while IFS='|' read -r msg hash author; do
  # Strip prefix for clean description, capitalize first letter
  clean=$(echo "$msg" | sed -E 's/^[a-z]+(\([^)]*\))?: *//' | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
  entry="- $clean (\`$hash\`)"

  case "$msg" in
    feat:*|feat\(*)       FEATURES="$FEATURES$entry"$'\n' ;;
    fix:*|fix\(*)         FIXES="$FIXES$entry"$'\n' ;;
    docs:*|docs\(*)       DOCS="$DOCS$entry"$'\n' ;;
    refactor:*|refactor\(*) REFACTORS="$REFACTORS$entry"$'\n' ;;
    perf:*|perf\(*)       PERF="$PERF$entry"$'\n' ;;
    chore:*|chore\(*)     CHORES="$CHORES$entry"$'\n' ;;
    *)                    OTHER="$OTHER$entry"$'\n' ;;
  esac
done <<< "$COMMITS"

# Count PRs merged in this range
PR_COUNT=$(git log "$FROM_TAG..$TO_REF" --merges --format='%s' 2>/dev/null | grep -c 'Merge pull request' || echo "0")
COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')

# Build release notes
NOTES=""
NOTES+="## What's Changed"$'\n\n'

[ -n "$FEATURES" ]  && NOTES+="### Features"$'\n'"$FEATURES"$'\n'
[ -n "$FIXES" ]     && NOTES+="### Bug Fixes"$'\n'"$FIXES"$'\n'
[ -n "$REFACTORS" ] && NOTES+="### Refactoring"$'\n'"$REFACTORS"$'\n'
[ -n "$PERF" ]      && NOTES+="### Performance"$'\n'"$PERF"$'\n'
[ -n "$DOCS" ]      && NOTES+="### Documentation"$'\n'"$DOCS"$'\n'
[ -n "$CHORES" ]    && NOTES+="### Maintenance"$'\n'"$CHORES"$'\n'
[ -n "$OTHER" ]     && NOTES+="### Other"$'\n'"$OTHER"$'\n'

NOTES+="---"$'\n'
NOTES+="**$COMMIT_COUNT commits** | **$PR_COUNT PRs merged** | $FROM_TAG → v$CURRENT_VERSION"$'\n'

if [ "$CREATE_RELEASE" = true ]; then
  if ! command -v gh &>/dev/null; then
    echo "Error: 'gh' CLI not found. Install it or use --no-create-release."
    echo ""
    echo "$NOTES"
    exit 1
  fi

  TAG="v$CURRENT_VERSION"

  # Create tag if it doesn't exist
  if ! git rev-parse "$TAG" &>/dev/null 2>&1; then
    git tag "$TAG"
    echo "Created tag: $TAG"
  fi

  gh release create "$TAG" \
    --title "v$CURRENT_VERSION" \
    --notes "$NOTES" \
    --latest

  echo "GitHub Release created: v$CURRENT_VERSION"
else
  echo "$NOTES"
fi
