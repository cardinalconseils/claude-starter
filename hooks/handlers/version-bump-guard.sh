#!/bin/bash
# CKS Version Bump Guard — ensures bump-version.sh was run before committing
# Exits 0 (allow) or 2 (block)

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CONFIG="$PLUGIN_ROOT/.prd/prd-config.json"

# Allow if no versioning config or versioning disabled/manual
if [ ! -f "$CONFIG" ]; then exit 0; fi
ENABLED=$(python3 -c "import json,sys; d=json.load(open('$CONFIG')); print(d.get('versioning',{}).get('enabled','true'))" 2>/dev/null)
STRATEGY=$(python3 -c "import json,sys; d=json.load(open('$CONFIG')); print(d.get('versioning',{}).get('strategy','auto-patch'))" 2>/dev/null)
[ "$ENABLED" = "False" ] && exit 0
[ "$STRATEGY" = "skip" ] || [ "$STRATEGY" = "manual" ] && exit 0

# Determine version source file
SOURCE=$(python3 -c "import json,sys; d=json.load(open('$CONFIG')); print(d.get('versioning',{}).get('source',''))" 2>/dev/null)
[ -z "$SOURCE" ] || [ "$SOURCE" = "None" ] && exit 0

# Check if version source file or README.md is staged (evidence of bump)
STAGED=$(git diff --cached --name-only 2>/dev/null)
if echo "$STAGED" | grep -qE "^(${SOURCE}|README\.md)$"; then
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CKS Version Bump Guard"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  Run scripts/bump-version.sh and stage the version files before committing."
echo "    Version source: $SOURCE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit 2
