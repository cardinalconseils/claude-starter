#!/bin/bash
# scripts/hq-path.sh — sourced helper: resolve cross-venture state (HQ repo or ~/.cks).
# Cloud sessions are ephemeral, so ~/.cks/ is lost between runs; a private HQ repo
# (pointed to by $CKS_HQ) is the durable home. Every ~/.cks reader goes through here.
# Safe to `source` — no set -e, no side effects, functions only.

cks_hq_root() {
  if [ -n "${CKS_HQ:-}" ] && [ -d "$CKS_HQ" ]; then
    printf '%s\n' "$CKS_HQ"
  else
    printf '%s\n' "$HOME/.cks"
  fi
}

# Legacy layout is ~/.cks/user/<slug>; the HQ repo uses users/<slug>.
cks_user_dir() {
  if [ -n "${CKS_HQ:-}" ] && [ -d "$CKS_HQ" ]; then
    printf '%s/users/%s\n' "$CKS_HQ" "$1"
  else
    printf '%s/user/%s\n' "$HOME/.cks" "$1"
  fi
}

cks_north_star_path() {
  local candidate
  for candidate in ".prd/NORTH-STAR.md" "NORTH-STAR.md" "$(cks_hq_root)/NORTH-STAR.md" "$HOME/.cks/north-star.md"; do
    if [ -f "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 0
}

cks_finops_dir() {
  printf '%s/finops\n' "$(cks_hq_root)"
}
