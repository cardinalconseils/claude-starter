#!/usr/bin/env bash

# Agentic OS Dashboard Refresh — rewrites the live values in board/index.html
# Usage: scripts/agentic-os-refresh.sh

set +e

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DASHBOARD="$PROJECT_ROOT/board/index.html"
DOMAINS_FILE="$PROJECT_ROOT/.agentic-os/domains.md"

if [ ! -f "$DASHBOARD" ]; then
  echo "Dashboard not found: $DASHBOARD" >&2
  exit 1
fi

count_files() { find "$1" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' '; }

raw_count=$(count_files "$PROJECT_ROOT/memory/raw")
wiki_count=$(count_files "$PROJECT_ROOT/memory/wiki")
output_count=$(count_files "$PROJECT_ROOT/memory/output")
domain_count=$(grep -c "^## [A-Z]" "$DOMAINS_FILE" 2>/dev/null || echo 0)

git_msg=$(cd "$PROJECT_ROOT" && git log -1 --format=%s 2>/dev/null | cut -c1-60)
git_age=$(cd "$PROJECT_ROOT" && git log -1 --format=%ar 2>/dev/null)
git_branch=$(cd "$PROJECT_ROOT" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
timestamp=$(date +%Y-%m-%d)

# Replace by element id against whatever the current value is, so re-running keeps
# working — the previous version matched a one-time "check terminal" placeholder that
# no longer existed anywhere in the file, making every run a silent no-op.
MEMORY_RAW="$raw_count" MEMORY_WIKI="$wiki_count" MEMORY_OUTPUT="$output_count" \
GIT_MSG="$git_msg" GIT_DATE="$git_age · $git_branch" REFRESHED="$timestamp" \
python3 - "$DASHBOARD" <<'PY'
import html, os, re, sys

path = sys.argv[1]
src = open(path, encoding="utf-8").read()
targets = {
    "memory-raw-count": os.environ["MEMORY_RAW"],
    "memory-wiki-count": os.environ["MEMORY_WIKI"],
    "memory-output-count": os.environ["MEMORY_OUTPUT"],
    "git-msg": os.environ["GIT_MSG"],
    "git-date": os.environ["GIT_DATE"],
    "refreshed-date": os.environ["REFRESHED"],
}
updated, missing = [], []
for el_id, value in targets.items():
    pattern = re.compile(r'(id="%s"[^>]*>)[^<]*' % re.escape(el_id))
    src, n = pattern.subn(lambda m: m.group(1) + html.escape(value), src, count=1)
    (updated if n else missing).append(el_id)
open(path, "w", encoding="utf-8").write(src)
print("  updated: " + ", ".join(updated) if updated else "  updated: none")
if missing:
    print("  MISSING ids (dashboard markup drifted): " + ", ".join(missing))
PY

echo "Dashboard refreshed: $timestamp  ($raw_count raw / $wiki_count wiki / $output_count output, $domain_count domains)"
