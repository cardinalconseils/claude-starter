#!/bin/bash
# scripts/test-integrity.sh — Validate cross-references across the CKS plugin
#
# Checks:
#   1. Commands → Agents: every Agent(subagent_type="X") resolves to agents/X.md
#   2. Agents → Skills: every skills: entry resolves to skills/{name}/SKILL.md
#   3. Agent frontmatter: required fields present (name, subagent_type, description, tools, model, skills)
#   4. Command frontmatter: required fields present (description, allowed-tools)
#   5. help.md ↔ commands/*.md: listed commands match actual files
#   6. help.md agents section: listed agents match actual files
#   7. README.md command count matches reality
#   8. CLAUDE.md line count ≤ 150
#   9. No placeholder tokens left in committed files
#  10. Hook scripts don't use set -e
# 11. Skill SKILL.md files ≤ 300 lines
#  12. Orphan detection: agents not referenced by any command
#
# Usage: bash scripts/test-integrity.sh [--verbose] [--quick]
#   --verbose: show passing checks too
#   --quick:   only run fast checks (skip orphan detection), for pre-commit
# Exit: 0 = all pass, 1 = failures found

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERBOSE=0
QUICK=0
for arg in "$@"; do
  [ "$arg" = "--verbose" ] && VERBOSE=1
  [ "$arg" = "--quick" ] && QUICK=1
done

PASS=0
WARN=0
FAIL=0

pass() { PASS=$((PASS + 1)); [ "$VERBOSE" = "1" ] && echo "  ✅ $1"; }
warn() { WARN=$((WARN + 1)); echo "  ⚠️  $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  ❌ $1"; }

# ─────────────────────────────────────────────
# 1. Commands → Agents: subagent_type references
# ─────────────────────────────────────────────
echo "▸ Commands → Agents"
for cmd in "$PLUGIN_ROOT"/commands/*.md; do
  [ "$(basename "$cmd")" = "README.md" ] && continue
  # Extract all subagent_type="..." references
  grep -oE 'subagent_type="[^"]+"' "$cmd" 2>/dev/null | sed 's/subagent_type="//;s/"//' | while read -r full_agent_type; do
    # Strip cks: prefix for local file lookup
    agent_type="${full_agent_type#cks:}"
    if [ "$agent_type" = "general-purpose" ]; then
      pass "$(basename "$cmd") → built-in $agent_type"
      continue
    fi
    AGENT_FILE="$PLUGIN_ROOT/agents/${agent_type}.md"
    if [ ! -f "$AGENT_FILE" ]; then
      fail "$(basename "$cmd") → agent '$full_agent_type' — file not found: agents/${agent_type}.md"
    else
      # Verify the agent file actually declares this subagent_type
      DECLARED=$(grep -E '^subagent_type:' "$AGENT_FILE" 2>/dev/null | sed 's/subagent_type: *//' | tr -d '"' | xargs)
      if [ "$DECLARED" != "$agent_type" ]; then
        fail "$(basename "$cmd") → agent '$full_agent_type' — agents/${agent_type}.md declares subagent_type: '$DECLARED' (expected '$agent_type')"
      else
        pass "$(basename "$cmd") → $full_agent_type"
      fi
    fi
  done
done

# ─────────────────────────────────────────────
# 2. Agents → Skills: skills frontmatter
# ─────────────────────────────────────────────
echo "▸ Agents → Skills"
for agent in "$PLUGIN_ROOT"/agents/*.md; do
  [ "$(basename "$agent")" = "README.md" ] && continue
  AGENT_NAME=$(basename "$agent" .md)
  # Parse skills from YAML frontmatter (between --- lines)
  IN_SKILLS=0
  sed -n '/^---$/,/^---$/p' "$agent" | while IFS= read -r line; do
    if echo "$line" | grep -qE '^skills:'; then
      IN_SKILLS=1
      continue
    fi
    if [ "$IN_SKILLS" = "1" ]; then
      # Stop at next YAML key or end of frontmatter
      if echo "$line" | grep -qE '^[a-z]' || echo "$line" | grep -qE '^---$'; then
        break
      fi
      SKILL=$(echo "$line" | sed 's/^ *- *//' | tr -d '"' | xargs)
      [ -z "$SKILL" ] && continue
      SKILL_FILE="$PLUGIN_ROOT/skills/${SKILL}/SKILL.md"
      if [ ! -f "$SKILL_FILE" ]; then
        fail "agents/$AGENT_NAME → skill '$SKILL' — skills/${SKILL}/SKILL.md not found"
      else
        pass "agents/$AGENT_NAME → skill: $SKILL"
      fi
    fi
  done
done

# ─────────────────────────────────────────────
# 3. Agent frontmatter: required fields
# ─────────────────────────────────────────────
echo "▸ Agent frontmatter"
REQUIRED_AGENT_FIELDS="name subagent_type description tools model skills"
for agent in "$PLUGIN_ROOT"/agents/*.md; do
  [ "$(basename "$agent")" = "README.md" ] && continue
  AGENT_NAME=$(basename "$agent" .md)
  FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$agent")
  for field in $REQUIRED_AGENT_FIELDS; do
    if ! echo "$FRONTMATTER" | grep -qE "^${field}:"; then
      fail "agents/$AGENT_NAME — missing required field: $field"
    else
      pass "agents/$AGENT_NAME has $field"
    fi
  done
done

# ─────────────────────────────────────────────
# 4. Command frontmatter: required fields
# ─────────────────────────────────────────────
echo "▸ Command frontmatter"
REQUIRED_CMD_FIELDS="description allowed-tools"
for cmd in "$PLUGIN_ROOT"/commands/*.md; do
  [ "$(basename "$cmd")" = "README.md" ] && continue
  CMD_NAME=$(basename "$cmd" .md)
  FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$cmd")
  for field in $REQUIRED_CMD_FIELDS; do
    if ! echo "$FRONTMATTER" | grep -qE "^${field}:"; then
      fail "commands/$CMD_NAME — missing required field: $field"
    else
      pass "commands/$CMD_NAME has $field"
    fi
  done
done

# ─────────────────────────────────────────────
# 5. help.md ↔ commands: listed commands exist
# ─────────────────────────────────────────────
echo "▸ help.md ↔ commands"
HELP_FILE="$PLUGIN_ROOT/commands/help.md"
if [ -f "$HELP_FILE" ]; then
  # Extract /cks:{name} patterns from help.md
  grep -oE '/cks:[a-z][-a-z0-9]*' "$HELP_FILE" | sort -u | while read -r cks_cmd; do
    CMD_NAME=$(echo "$cks_cmd" | sed 's|/cks:||')
    CMD_FILE="$PLUGIN_ROOT/commands/${CMD_NAME}.md"
    if [ ! -f "$CMD_FILE" ]; then
      fail "help.md lists $cks_cmd — but commands/${CMD_NAME}.md not found"
    else
      pass "help.md → $cks_cmd exists"
    fi
  done

  # Reverse check: commands that exist but aren't in help.md
  for cmd in "$PLUGIN_ROOT"/commands/*.md; do
    CMD_NAME=$(basename "$cmd" .md)
    [ "$CMD_NAME" = "README" ] || [ "$CMD_NAME" = "help" ] && continue
    if ! grep -q "/cks:${CMD_NAME}" "$HELP_FILE" 2>/dev/null; then
      warn "commands/$CMD_NAME.md exists but not listed in help.md"
    fi
  done
else
  fail "commands/help.md not found"
fi

# ─────────────────────────────────────────────
# 6. README command count
# ─────────────────────────────────────────────
echo "▸ README command count"
README="$PLUGIN_ROOT/README.md"
if [ -f "$README" ]; then
  # Count actual command files (excluding README.md)
  ACTUAL_COUNT=$(find "$PLUGIN_ROOT/commands" -name "*.md" ! -name "README.md" | wc -l | xargs)
  # Try to find a count claim in README (patterns like "47 commands" or "50 slash commands")
  README_COUNT=$(grep -oiE '[0-9]+ *(slash )?commands' "$README" | head -1 | grep -oE '[0-9]+')
  if [ -n "$README_COUNT" ] && [ "$README_COUNT" != "$ACTUAL_COUNT" ]; then
    fail "README claims $README_COUNT commands but found $ACTUAL_COUNT command files"
  elif [ -n "$README_COUNT" ]; then
    pass "README command count ($ACTUAL_COUNT) matches"
  fi
fi

# ─────────────────────────────────────────────
# 7. CLAUDE.md line count ≤ 150
# ─────────────────────────────────────────────
echo "▸ CLAUDE.md size"
CLAUDEMD="$PLUGIN_ROOT/CLAUDE.md"
if [ -f "$CLAUDEMD" ]; then
  LINE_COUNT=$(wc -l < "$CLAUDEMD" | xargs)
  if [ "$LINE_COUNT" -gt 150 ]; then
    fail "CLAUDE.md is $LINE_COUNT lines (max 150)"
  else
    pass "CLAUDE.md is $LINE_COUNT lines"
  fi
fi

# ─────────────────────────────────────────────
# 8. No placeholder tokens in committed files
# ─────────────────────────────────────────────
echo "▸ Placeholder tokens"
PLACEHOLDER_HITS=$(grep -rlE '\[TOKENS?\]|\[PLACEHOLDER\]' \
  "$PLUGIN_ROOT/commands" "$PLUGIN_ROOT/agents" "$PLUGIN_ROOT/skills" \
  "$PLUGIN_ROOT/hooks" "$PLUGIN_ROOT/scripts" 2>/dev/null \
  | grep -v '/assets/' | grep -v '/templates/' | grep -v '\.template' | grep -v 'template\.md' || true)
if [ -n "$PLACEHOLDER_HITS" ]; then
  # Check if hit is just an instruction referencing placeholders vs actual placeholder
  REAL_HITS=""
  for f in $PLACEHOLDER_HITS; do
    # Skip files that only mention placeholders in instructions (e.g. "warn about [TOKENS]")
    if grep -qE '^\[|^>\s*.*\[TOKENS' "$f" 2>/dev/null; then
      REAL_HITS="$REAL_HITS $f"
    elif grep -cE '\[TOKENS?\]|\[PLACEHOLDER\]' "$f" 2>/dev/null | grep -q '^[2-9]\|^[0-9][0-9]'; then
      # Multiple occurrences — likely real placeholders
      REAL_HITS="$REAL_HITS $f"
    else
      # Single mention — check context: is it an instruction about placeholders?
      LINE=$(grep -E '\[TOKENS?\]|\[PLACEHOLDER\]' "$f" 2>/dev/null | head -1)
      if echo "$LINE" | grep -qiE 'warn|check|detect|still has|replace all'; then
        warn "Placeholder reference (instruction) in $(echo "$f" | sed "s|$PLUGIN_ROOT/||")"
      else
        REAL_HITS="$REAL_HITS $f"
      fi
    fi
  done
  REAL_HITS=$(echo "$REAL_HITS" | xargs)
  if [ -n "$REAL_HITS" ]; then
    for f in $REAL_HITS; do
      fail "Placeholder found in $(echo "$f" | sed "s|$PLUGIN_ROOT/||")"
    done
  fi
else
  pass "No placeholder tokens found"
fi

# ─────────────────────────────────────────────
# 9. Hook scripts: no set -e
# ─────────────────────────────────────────────
echo "▸ Hook scripts safety"
for hook in "$PLUGIN_ROOT"/hooks/handlers/*.sh; do
  [ ! -f "$hook" ] && continue
  HOOK_NAME=$(basename "$hook")
  if grep -qE '^set -e' "$hook" 2>/dev/null; then
    fail "hooks/handlers/$HOOK_NAME uses 'set -e' (violates hook rules)"
  else
    pass "hooks/handlers/$HOOK_NAME — no set -e"
  fi
  # Check line count (max 30 per rules)
  HLINES=$(wc -l < "$hook" | xargs)
  if [ "$HLINES" -gt 50 ]; then
    warn "hooks/handlers/$HOOK_NAME is $HLINES lines (guideline: ≤30)"
  fi
done

# ─────────────────────────────────────────────
# 10. Skill SKILL.md ≤ 300 lines
# ─────────────────────────────────────────────
echo "▸ Skill file sizes"
for skill_dir in "$PLUGIN_ROOT"/skills/*/; do
  [ ! -d "$skill_dir" ] && continue
  SKILL_NAME=$(basename "$skill_dir")
  SKILL_FILE="${skill_dir}SKILL.md"
  if [ ! -f "$SKILL_FILE" ]; then
    warn "skills/$SKILL_NAME/ exists but has no SKILL.md"
  else
    SLINES=$(wc -l < "$SKILL_FILE" | xargs)
    if [ "$SLINES" -gt 300 ]; then
      fail "skills/$SKILL_NAME/SKILL.md is $SLINES lines (max 300)"
    else
      pass "skills/$SKILL_NAME/SKILL.md is $SLINES lines"
    fi
  fi
done

# ─────────────────────────────────────────────
# 11. Orphan agents: not referenced by any command
# ─────────────────────────────────────────────
if [ "$QUICK" = "0" ]; then
echo "▸ Orphan detection"
for agent in "$PLUGIN_ROOT"/agents/*.md; do
  [ "$(basename "$agent")" = "README.md" ] && continue
  AGENT_NAME=$(basename "$agent" .md)
  # Check if any command references this agent's subagent_type
  SUBTYPE=$(grep -E '^subagent_type:' "$agent" 2>/dev/null | sed 's/subagent_type: *//' | tr -d '"' | xargs)
  [ -z "$SUBTYPE" ] && continue
  
  # Commands prefix subagent references with cks:
  SEARCH_TYPE="cks:$SUBTYPE"
  
  if ! grep -rlq "subagent_type=\"$SEARCH_TYPE\"" "$PLUGIN_ROOT/commands/" 2>/dev/null; then
    # Also check if referenced by other agents (nested dispatch) without cks: prefix just in case
    if ! grep -rlq "subagent_type=\"$SEARCH_TYPE\"" "$PLUGIN_ROOT/agents/" 2>/dev/null && ! grep -rlq "subagent_type=\"$SUBTYPE\"" "$PLUGIN_ROOT/agents/" 2>/dev/null; then
      warn "agents/$AGENT_NAME (subagent_type: $SUBTYPE) — not referenced by any command or agent"
    else
      pass "agents/$AGENT_NAME — referenced by another agent"
    fi
  else
    pass "agents/$AGENT_NAME — referenced by command"
  fi
done
fi  # end QUICK skip

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ $PASS passed  ⚠️  $WARN warnings  ❌ $FAIL failures"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  exit 0
fi
