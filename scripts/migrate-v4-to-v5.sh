#!/bin/bash
# migrate-v4-to-v5.sh — CKS v4 → v5 migration helper
# Run from the TARGET PROJECT root (not the CKS plugin dir).

set -uo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${HOME}/.claude/plugins/cks}"
TODAY="$(date +%Y-%m-%d)"

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
  if [[ -f ".claude-plugin/plugin.json" ]] && \
     grep -q '"name".*"cks"' ".claude-plugin/plugin.json" 2>/dev/null; then
    fail "Running from CKS plugin dir. Run this from your TARGET PROJECT root."
    exit 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    fail "jq is required. Install: brew install jq"
    exit 1
  fi
}

# ── v4 detection ───────────────────────────────────────────────────────────────
V4_SIGNALS=()
detect_v4() {
  V4_SIGNALS=()

  if [[ -f ".prd/PRD-STATE.md" ]]; then
    grep -q "sprint_runner" ".prd/PRD-STATE.md" 2>/dev/null && \
      V4_SIGNALS+=("PRD-STATE.md contains 'sprint_runner'")
    grep -q "attractor_mode" ".prd/PRD-STATE.md" 2>/dev/null || \
      V4_SIGNALS+=("PRD-STATE.md lacks 'attractor_mode' field")
  fi

  for candidate in ".claude/plugin.json" "plugin.json"; do
    if [[ -f "$candidate" ]] && grep -q '"attractor_mode"' "$candidate" 2>/dev/null; then
      local am
      am="$(jq -r '.attractor_mode // false' "$candidate" 2>/dev/null)"
      [[ "$am" == "false" ]] && V4_SIGNALS+=("$candidate has attractor_mode: false")
      break
    fi
  done

  if [[ -d ".claude" ]]; then
    while IFS= read -r f; do
      [[ -n "$f" ]] && V4_SIGNALS+=(".claude/ references 'sprint-runner': $f")
    done < <(grep -rl "sprint-runner" ".claude/" 2>/dev/null | head -5 || true)

    while IFS= read -r f; do
      [[ -n "$f" ]] && V4_SIGNALS+=("command references 'cks:sprint-close': $f")
    done < <(grep -rl "cks:sprint-close" ".claude/" 2>/dev/null | head -5 || true)
  fi
}

# ── Locate config file to patch ────────────────────────────────────────────────
CONFIG_FILE="" CONFIG_TYPE=""
find_config() {
  if [[ -f ".claude/settings.json" ]]; then
    CONFIG_FILE=".claude/settings.json"; CONFIG_TYPE="settings"; return
  fi
  local installed="${PLUGIN_ROOT}/plugin.json"
  if [[ -f "$installed" ]]; then
    CONFIG_FILE="$installed"; CONFIG_TYPE="plugin"; return
  fi
}

# ── Patch config ───────────────────────────────────────────────────────────────
patch_config() {
  [[ -z "$CONFIG_FILE" ]] && { warn "No config file found — skipping attractor_mode patch."; return; }
  local tmp
  tmp="$(mktemp)"
  jq --argjson am true \
     --arg owner "${1:-}" --arg repo "${2:-}" --argjson number "${3:-0}" \
     '. + {attractor_mode: $am, github_project: {owner: $owner, repo: $repo, number: $number}}' \
     "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
  pass "attractor_mode set to true in ${CONFIG_FILE}"
}

# ── Rename sprint-runner refs in .claude/ ──────────────────────────────────────
rename_sprint_runner_refs() {
  [[ ! -d ".claude" ]] && return
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    sed -i.bak 's/sprint-runner/attractor-runner/g' "$f" && rm -f "${f}.bak"
    info "Renamed sprint-runner → attractor-runner in: $f"
  done < <(grep -rl "sprint-runner" ".claude/" 2>/dev/null || true)
}

# ── Write migration log ────────────────────────────────────────────────────────
write_migration_log() {
  mkdir -p ".prd"
  {
    echo "# CKS v4 → v5 Migration Log"
    echo "**Date:** ${TODAY}"
    echo "**Script:** scripts/migrate-v4-to-v5.sh"
    echo ""
    echo "## v4 Signals Found"
    for sig in "${V4_SIGNALS[@]:-none}"; do echo "- $sig"; done
    echo ""
    echo "## Changes Applied"
    echo "- attractor_mode set to true in \`${CONFIG_FILE:-<none>}\`"
    echo "- GitHub Project: owner=${1:-<not configured>} repo=${2:-<not configured>} number=${3:-0}"
    echo "- sprint-runner refs renamed to attractor-runner in .claude/ (if any)"
    echo ""
    echo "## Next Steps"
    echo "1. Run \`/cks:standup\` to confirm v5 session state"
    [[ -n "${1:-}" ]] && echo "2. Run \`/cks:setup-webhooks\` to activate Kanban automation"
  } > ".prd/MIGRATION.md"
  pass "Migration log written: .prd/MIGRATION.md"
}

# ── Validation ─────────────────────────────────────────────────────────────────
validate() {
  local ok=0
  hr; info "Validation"; hr
  detect_v4
  if [[ "${#V4_SIGNALS[@]}" -eq 0 ]]; then
    pass "No v4 signals remain"; ok=$((ok+1))
  else
    fail "v4 signals still present (${#V4_SIGNALS[@]}):"
    for sig in "${V4_SIGNALS[@]}"; do warn "  $sig"; done
  fi
  if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]]; then
    local am; am="$(jq -r '.attractor_mode // false' "$CONFIG_FILE" 2>/dev/null)"
    if [[ "$am" == "true" ]]; then
      pass "attractor_mode is true in ${CONFIG_FILE}"; ok=$((ok+1))
    else
      fail "attractor_mode is NOT true in ${CONFIG_FILE} (got: ${am})"
    fi
  else
    warn "Config file not found — cannot verify attractor_mode"
  fi
  [[ -f ".prd/MIGRATION.md" ]] && { pass ".prd/MIGRATION.md written"; ok=$((ok+1)); } || fail ".prd/MIGRATION.md not found"
  echo ""
  [[ "$ok" -ge 3 ]] && pass "Migration validated (${ok}/3)" || warn "Partial validation (${ok}/3) — review failures above"
}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
  hr; info "CKS v4 → v5 Migration"; hr

  preflight
  detect_v4

  if [[ "${#V4_SIGNALS[@]}" -eq 0 ]]; then
    pass "Already v5 — no v4 signals detected. Nothing to do."
    exit 0
  fi

  warn "v4 signals found (${#V4_SIGNALS[@]}):"
  for sig in "${V4_SIGNALS[@]}"; do info "  • $sig"; done
  echo ""

  find_config
  [[ -n "$CONFIG_FILE" ]] && info "Config to patch: ${CONFIG_FILE} (${CONFIG_TYPE})" || warn "No config file found."
  echo ""

  local gh_owner="" gh_repo="" gh_number=0 gh_answer=""
  printf "Configure GitHub Project Kanban? (y/N): "
  read -r gh_answer </dev/tty 2>/dev/null || gh_answer="n"
  if [[ "$gh_answer" == "y" || "$gh_answer" == "Y" ]]; then
    printf "  GitHub owner (org or user): "; read -r gh_owner </dev/tty 2>/dev/null || gh_owner=""
    printf "  Repository name: ";            read -r gh_repo </dev/tty 2>/dev/null || gh_repo=""
    printf "  Project number (from URL /projects/N): "; read -r gh_number </dev/tty 2>/dev/null || gh_number=0
    gh_number="${gh_number:-0}"
    info "GitHub Project: ${gh_owner}/${gh_repo} #${gh_number}"
  else
    info "Skipping GitHub Project config — Kanban fields left empty."
  fi
  echo ""

  hr; info "Applying changes…"; hr
  patch_config "$gh_owner" "$gh_repo" "$gh_number"
  rename_sprint_runner_refs
  write_migration_log "$gh_owner" "$gh_repo" "$gh_number"

  validate

  hr; info "Done."; hr
  info "• attractor_mode → true in ${CONFIG_FILE:-<no config>}"
  [[ -n "$gh_owner" ]] && info "• GitHub Project → ${gh_owner}/${gh_repo} #${gh_number}"
  info "• Log → .prd/MIGRATION.md"
  echo ""
  info "Next: run /cks:standup to confirm v5 loads correctly."
  [[ -n "$gh_owner" ]] && info "Then: run /cks:setup-webhooks to activate Kanban automation."
  hr
}

main "$@"
