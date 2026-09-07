#!/bin/bash
# migrate-v5-to-v6.sh — CKS v5 → v6 migration helper for a TARGET PROJECT.
#
# Rewrites v5 subagent_type="…" (and cks_agent="…") dispatch sites in the project's own
# .claude/commands/**, .claude/agents/**, CLAUDE.md and .prd/**/*.md to the v6 role named in
# scripts/agent-map.tsv. All three v5 spellings resolve: cks:<name>, <name>, luv:<short>.
# Sites whose target is an orchestrator skill are printed as MANUAL — they must become
# Skill(skill="cks:<domain>") in a top-level command by hand.
#
# Usage (from the target project root, or with --target):
#   bash migrate-v5-to-v6.sh                 dry run — list every rewrite
#   bash migrate-v5-to-v6.sh --apply         rewrite in place, log to .prd/MIGRATION-v6.md
#   bash migrate-v5-to-v6.sh --target <dir>  operate on <dir> instead of $PWD

set -uo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
MAP="$PLUGIN_ROOT/scripts/agent-map.tsv"
TODAY="$(date +%Y-%m-%d)"
APPLY=0; TARGET="$PWD"
while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1 ;;
    --target) shift; TARGET="${1:-$PWD}" ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
  esac
  shift
done

# ── Color helpers ──────────────────────────────────────────────────────────────
if command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; then
  G="$(tput setaf 2)" Y="$(tput setaf 3)" R="$(tput setaf 1)" E="$(tput sgr0)"
else
  G="" Y="" R="" E=""
fi
pass() { printf "%s✓ %s%s\n" "$G" "$*" "$E"; }
warn() { printf "%s⚠ %s%s\n" "$Y" "$*" "$E"; }
fail() { printf "%s✗ %s%s\n" "$R" "$*" "$E"; }
info() { printf "  %s\n" "$*"; }
hr()   { printf "────────────────────────────────────────────\n"; }

# ── Preflight ──────────────────────────────────────────────────────────────────
preflight() {
  [ -d "$TARGET" ] || { fail "target not found: $TARGET"; exit 1; }
  if [ -f "$TARGET/.claude-plugin/plugin.json" ] && grep -q '"name".*"cks"' "$TARGET/.claude-plugin/plugin.json" 2>/dev/null; then
    fail "Target is the CKS plugin dir. Run this from your TARGET PROJECT root (or pass --target)."
    fail "For the plugin itself use scripts/remap-dispatch.sh."
    exit 1
  fi
  [ -f "$MAP" ] || { fail "map not found: $MAP"; exit 1; }
}

# ── Scan set ───────────────────────────────────────────────────────────────────
scan_files() {
  [ -f "$TARGET/CLAUDE.md" ] && echo "$TARGET/CLAUDE.md"
  find "$TARGET/.claude/commands" "$TARGET/.claude/agents" -type f -name '*.md' 2>/dev/null
  find "$TARGET/.prd" -type f -name '*.md' 2>/dev/null
}

# ── Variants: cks:<name> → "cks:<name>" "<name>" and, for a Luv persona, "luv:<short>" ──
variants() {
  local old="$1" bare="${1#cks:}"
  echo "$old"; echo "$bare"
  case "$bare" in luv-*) echo "luv:${bare#luv-}" ;; esac
}

# ── Main pass ──────────────────────────────────────────────────────────────────
rewrites=0; manual=0; touched=0
LOG_LINES=""
run_pass() {
  local files old new hint v n f
  files=$(scan_files)
  [ -z "$files" ] && { warn "Nothing to scan under $TARGET (no CLAUDE.md, .claude/commands, .claude/agents, .prd)."; return; }
  while IFS=$'\t' read -r old new hint; do
    case "$old" in ''|'#'*) continue ;; esac
    for v in $(variants "$old"); do
      [ "$v" = "$new" ] && continue
      for f in $files; do
        n=$(grep -cE "(subagent_type|cks_agent) *= *\"$v\"" "$f" 2>/dev/null || true)
        [ "${n:-0}" = "0" ] && continue
        case "$new" in
          skill:*)
            manual=$((manual + n))
            printf "  MANUAL  %-34s → Skill(skill=\"cks:%s\")  ×%s  %s\n" "\"$v\"" "${new#skill:}" "$n" "${f#"$TARGET"/}" ;;
          *)
            rewrites=$((rewrites + n))
            printf "  %-42s → %-22s ×%s  %s%s\n" "\"$v\"" "\"$new\"" "$n" "${f#"$TARGET"/}" "${hint:+  # $hint}"
            if [ "$APPLY" = "1" ]; then
              sed -i.bak -E "s#(subagent_type|cks_agent) *= *\"$v\"#\1=\"$new\"#g" "$f" && rm -f "$f.bak"
              touched=$((touched + 1))
              LOG_LINES="$LOG_LINES
- \`$v\` → \`$new\` (×$n) in \`${f#"$TARGET"/}\`"
            fi ;;
        esac
      done
    done
  done < "$MAP"
}

write_log() {
  [ "$APPLY" = "1" ] || return 0
  [ -d "$TARGET/.prd" ] || return 0
  {
    echo "# CKS v5 → v6 Migration Log"
    echo "**Date:** ${TODAY}"
    echo "**Script:** scripts/migrate-v5-to-v6.sh"
    echo ""
    echo "## Dispatch sites rewritten"
    [ -n "$LOG_LINES" ] && echo "$LOG_LINES" || echo "- none"
    echo ""
    echo "## Manual sites (orchestrator skills)"
    echo "- $manual site(s) must become Skill(skill=\"cks:<domain>\") in a top-level command — see the MANUAL lines above"
    echo ""
    echo "## Next Steps"
    echo "1. Run \`/cks:standup\` to confirm v6 loads cleanly"
    echo "2. Read \`docs/MIGRATION-v5-to-v6.md\` in the plugin for the role catalogue"
  } > "$TARGET/.prd/MIGRATION-v6.md"
  pass "Migration log written: .prd/MIGRATION-v6.md"
}

main() {
  hr; info "CKS v5 → v6 Migration — target: $TARGET ($([ "$APPLY" = "1" ] && echo apply || echo dry-run))"; hr
  preflight
  run_pass
  echo ""
  if [ "$rewrites" = "0" ] && [ "$manual" = "0" ]; then
    pass "No v5 dispatch sites found. Nothing to do."
  elif [ "$APPLY" = "1" ]; then
    pass "Rewrote $rewrites site(s) in $touched file pass(es); $manual MANUAL site(s) left for you"
    write_log
  else
    warn "Dry run: $rewrites site(s) would be rewritten, $manual MANUAL. Re-run with --apply."
  fi
  hr
  echo "  rewrites=$rewrites manual=$manual $([ "$APPLY" = "1" ] && echo applied || echo dry-run)"
  [ "$manual" = "0" ]
}

main
