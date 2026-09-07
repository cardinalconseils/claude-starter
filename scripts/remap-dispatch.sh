#!/bin/bash
# scripts/remap-dispatch.sh — rewrite v5 dispatch sites to v6 roles using scripts/agent-map.tsv.
#
# Rewrites subagent_type="<old>" and cks_agent="<old>" wherever the map gives a cks:<role>
# target. Sites whose target is skill:<domain> need Skill(skill="cks:<domain>") by hand and
# are listed, never rewritten. Dry-run by default.
#
# Usage: bash scripts/remap-dispatch.sh [--apply] [--verbose]
set -uo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MAP="$PLUGIN_ROOT/scripts/agent-map.tsv"
APPLY=0; VERBOSE=0
for a in "$@"; do case "$a" in --apply) APPLY=1 ;; --verbose) VERBOSE=1 ;; esac; done
[ -f "$MAP" ] || { echo "map not found: $MAP"; exit 1; }

SCAN=("$PLUGIN_ROOT/commands" "$PLUGIN_ROOT/agents" "$PLUGIN_ROOT/skills" "$PLUGIN_ROOT/hooks" \
      "$PLUGIN_ROOT/pipelines" "$PLUGIN_ROOT/.claude/rules" "$PLUGIN_ROOT/CLAUDE.md")
EXCLUDE='(/legacy/|/scripts/agent-map\.tsv|/scripts/remap-dispatch\.sh|/docs/MIGRATION-|references/roster\.md)'

rewrites=0; manual=0
while IFS=$'\t' read -r old new _hint; do
  case "$old" in ''|'#'*) continue ;; esac
  [ "$old" = "$new" ] && continue
  files=$(grep -rlF "\"$old\"" "${SCAN[@]}" 2>/dev/null | grep -vE "$EXCLUDE" || true)
  [ -z "$files" ] && continue
  case "$new" in
    cks:*)
      for f in $files; do
        n=$(grep -cF "\"$old\"" "$f")
        rewrites=$((rewrites + n))
        [ "$VERBOSE" = "1" ] && echo "  $old -> $new  ($n) ${f#"$PLUGIN_ROOT"/}"
        if [ "$APPLY" = "1" ]; then
          sed -i "s|subagent_type=\"$old\"|subagent_type=\"$new\"|g; s|cks_agent *= *\"$old\"|cks_agent=\"$new\"|g" "$f"
        fi
      done ;;
    skill:*)
      for f in $files; do
        manual=$((manual + 1))
        echo "  MANUAL  $old -> Skill(skill=\"cks:${new#skill:}\")  in ${f#"$PLUGIN_ROOT"/}"
      done ;;
  esac
done < "$MAP"

echo "  rewrites=$rewrites manual=$manual $([ "$APPLY" = "1" ] && echo applied || echo dry-run)"
[ "$manual" = "0" ]
