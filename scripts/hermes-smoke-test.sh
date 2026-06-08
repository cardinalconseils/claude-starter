#!/bin/bash
# scripts/hermes-smoke-test.sh — Deterministic readiness checks for Hermes Mode.
# Exit 0 = critical checks pass. Warnings are informational.

set -uo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATUS_ONLY=0
for arg in "$@"; do
  [ "$arg" = "--status" ] && STATUS_ONLY=1
done

FAIL=0
WARN=0

pass() { echo "  OK   $1"; }
warn() { echo "  WARN $1"; WARN=$((WARN + 1)); }
fail() { echo "  FAIL $1"; FAIL=$((FAIL + 1)); }

has_file() {
  [ -f "$PLUGIN_ROOT/$1" ] && pass "$1 exists" || fail "$1 missing"
}

has_exec() {
  [ -x "$PLUGIN_ROOT/$1" ] && pass "$1 executable" || fail "$1 not executable"
}

hook_wired() {
  if grep -q "$1" "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null; then
    pass "$1 wired in hooks/hooks.json"
  else
    fail "$1 not wired in hooks/hooks.json"
  fi
}

echo "Hermes Mode Readiness"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "▸ Skills"
has_file "skills/channel-brain/SKILL.md"
has_file "skills/user-memory/SKILL.md"
has_file "skills/conversation-state/SKILL.md"
has_file "skills/proactive-brain/SKILL.md"

echo "▸ Command and agent"
has_file "commands/hermes.md"
has_file "agents/hermes-readiness.md"

echo "▸ Deterministic guards"
has_file "hooks/hooks.json"
hook_wired "user-memory-guard.sh"
hook_wired "destructive-op-guard.sh"
hook_wired "secrets-scan-guard.sh"
has_exec "hooks/handlers/user-memory-guard.sh"
has_exec "hooks/handlers/destructive-op-guard.sh"
has_exec "hooks/handlers/secrets-scan-guard.sh"

echo "▸ Project instruction"
if grep -q "## Hermes channel brain" "$PLUGIN_ROOT/CLAUDE.md" 2>/dev/null; then
  pass "CLAUDE.md contains Hermes channel-brain block"
else
  warn "CLAUDE.md missing Hermes channel-brain block; run /cks:hermes init"
fi

echo "▸ Runtime identity"
ACTIVE_USER="${CKS_ACTIVE_USER:-}"
if [ -n "$ACTIVE_USER" ]; then
  pass "CKS_ACTIVE_USER=$ACTIVE_USER"
else
  warn "CKS_ACTIVE_USER unset; Hermes VPS service should set a stable user slug"
  ACTIVE_USER="local"
fi

case "$ACTIVE_USER" in
  *[!a-zA-Z0-9_-]*)
    warn "CKS_ACTIVE_USER contains characters outside [a-zA-Z0-9_-]; use a slugified value"
    ;;
esac

USER_DIR="$HOME/.cks/user/$ACTIVE_USER"
if [ -d "$USER_DIR" ]; then
  pass "user memory dir exists: $USER_DIR"
else
  warn "user memory dir missing: $USER_DIR"
fi

if [ -f "$USER_DIR/proactive.json" ]; then
  pass "proactive wake marker exists"
else
  warn "proactive wake marker missing; set first reminder or register a wake"
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Hermes critical checks passed"
  echo "Warnings: $WARN"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Hermes critical checks failed"
  echo "Failures: $FAIL"
  echo "Warnings: $WARN"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  [ "$STATUS_ONLY" = "1" ] && exit 1
  exit 1
fi
