#!/usr/bin/env bash

# Agentic OS Dashboard Refresh — regenerates dashboard/index.html with live data
# Usage: scripts/agentic-os-refresh.sh

set +e

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DASHBOARD="$PROJECT_ROOT/board/index.html"
DOMAINS_FILE="$PROJECT_ROOT/.agentic-os/domains.md"

# Count files in memory dirs (exclude .gitkeep)
count_files() {
  local dir="$1"
  find "$dir" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' '
}

raw_count=$(count_files "$PROJECT_ROOT/memory/raw")
wiki_count=$(count_files "$PROJECT_ROOT/memory/wiki")
output_count=$(count_files "$PROJECT_ROOT/memory/output")

# Get last git commit
git_output=$(cd "$PROJECT_ROOT" && git log -1 --format="%s|%ar" 2>/dev/null)
IFS='|' read -r git_msg git_age <<< "$git_output"
git_msg="${git_msg:0:60}"  # truncate to 60 chars

# Count domains (lines matching "^## [A-Z]" excluding header)
domain_count=$(grep "^## [A-Z]" "$DOMAINS_FILE" 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')

# Get current timestamp
timestamp=$(date +%Y-%m-%d)

# Escape special characters for sed
git_msg_esc=$(printf '%s\n' "$git_msg" | sed 's/[&/\]/\\&/g')
git_age_esc=$(printf '%s\n' "$git_age" | sed 's/[&/\]/\\&/g')

# Update HTML using sed with proper patterns
sed -i '' \
  -e "s/id=\"live-raw\">check terminal</id=\"live-raw\">$raw_count files</g" \
  -e "s/id=\"live-wiki\">check terminal</id=\"live-wiki\">$wiki_count files</g" \
  -e "s/id=\"live-output\">check terminal</id=\"live-output\">$output_count files</g" \
  -e "s/id=\"git-msg\">check terminal</id=\"git-msg\">$git_msg_esc</g" \
  -e "s/id=\"git-date\">check terminal</id=\"git-date\">$git_age_esc</g" \
  -e "s/Generated [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/Generated $timestamp/g" \
  "$DASHBOARD"

echo "Dashboard refreshed: $timestamp"
echo "  memory/raw:    $raw_count files"
echo "  memory/wiki:   $wiki_count files"
echo "  memory/output: $output_count files"
echo "  domains:       $domain_count"
echo "  last commit:   $git_msg ($git_age)"
