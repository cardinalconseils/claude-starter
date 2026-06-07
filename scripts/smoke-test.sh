#!/bin/bash
# scripts/smoke-test.sh — Standalone smoke test for CKS plugin load
# Runs without Claude Code. Validates plugin structure.
# Exit 0 = all pass, Exit 1 = failures

set -uo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

fail() { echo "  ❌ $1"; FAIL=1; }
pass() { echo "  ✅ $1"; }

# ── 1. Plugin manifest ──
echo "▸ Plugin manifest"
if python3 -c "import json; f=open('$PLUGIN_ROOT/.claude-plugin/plugin.json'); d=json.load(f); assert 'name' in d and 'version' in d" 2>/dev/null; then
  VER=$(python3 -c "import json; print(json.load(open('$PLUGIN_ROOT/.claude-plugin/plugin.json'))['version'])" 2>/dev/null)
  pass "plugin.json valid (v$VER)"
else
  fail "plugin.json missing or invalid"
fi

# ── 2. Commands have valid frontmatter ──
echo "▸ Commands"
for cmd in "$PLUGIN_ROOT"/commands/*.md; do
  [ "$(basename "$cmd")" = "README.md" ] && continue
  if grep -q "^---" "$cmd" && grep -q "^description:" "$cmd"; then
    pass "$(basename "$cmd") — frontmatter OK"
  else
    fail "$(basename "$cmd") — missing frontmatter"
  fi
done

# ── 3. Agents have valid frontmatter ──
echo "▸ Agents"
for agent in "$PLUGIN_ROOT"/agents/*.md; do
  [ "$(basename "$agent")" = "README.md" ] && continue
  if grep -q "^subagent_type:" "$agent" && grep -q "^description:" "$agent"; then
    pass "$(basename "$agent") — frontmatter OK"
  else
    fail "$(basename "$agent") — missing frontmatter"
  fi
done

# ── 4. Skills have valid SKILL.md ──
echo "▸ Skills"
for skill_dir in "$PLUGIN_ROOT"/skills/*/; do
  [ ! -d "$skill_dir" ] && continue
  SKILL_NAME=$(basename "$skill_dir")
  SKILL_FILE="${skill_dir}SKILL.md"
  if [ ! -f "$SKILL_FILE" ]; then
    # Lifecycle dirs are expected to be empty
    case "$SKILL_NAME" in archived|quarantine|validated) continue ;; esac
    fail "skills/$SKILL_NAME/ missing SKILL.md"
  else
    if grep -q "^name:" "$SKILL_FILE" && grep -q "^description:" "$SKILL_FILE"; then
      pass "skills/$SKILL_NAME/SKILL.md — frontmatter OK"
    else
      fail "skills/$SKILL_NAME/SKILL.md — missing frontmatter"
    fi
  fi
done

# ── 5. Hooks config ──
echo "▸ Hooks"
if [ -f "$PLUGIN_ROOT/hooks/hooks.json" ]; then
  if python3 -c "import json; json.load(open('$PLUGIN_ROOT/hooks/hooks.json'))" 2>/dev/null; then
    pass "hooks.json valid JSON"
  else
    fail "hooks.json invalid JSON"
  fi
else
  fail "hooks.json missing"
fi

# ── 6. All hook handlers referenced exist ──
HANDLERS=$(python3 -c "
import json
d=json.load(open('$PLUGIN_ROOT/hooks/hooks.json'))
for h in d.get('hooks',[]):
  print(h.get('handler',''))
" 2>/dev/null | sort -u)
for h in $HANDLERS; do
  if [ -f "$PLUGIN_ROOT/hooks/handlers/$h" ]; then
    pass "handler $h — exists"
  else
    fail "handler $h — missing"
  fi
done

# ── 7. Scripts are executable ──
echo "▸ Scripts"
for s in "$PLUGIN_ROOT"/scripts/*.sh; do
  [ ! -f "$s" ] && continue
  if [ -x "$s" ]; then
    pass "$(basename "$s") — executable"
  else
    fail "$(basename "$s") — not executable"
  fi
done

# ── 8. All JSON files valid ──
echo "▸ JSON files"
for f in $(find "$PLUGIN_ROOT" -name "*.json" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.claude/worktrees/*" 2>/dev/null); do
  if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
    pass "$(echo "$f" | sed "s|$PLUGIN_ROOT/||") — valid"
  else
    fail "$(echo "$f" | sed "s|$PLUGIN_ROOT/||") — invalid JSON"
  fi
done

# ── Summary ──
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ✅ All smoke tests passed"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ❌ Smoke tests failed"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi
