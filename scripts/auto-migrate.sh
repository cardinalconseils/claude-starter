#!/bin/bash
# auto-migrate.sh — Silently apply CKS project migrations at session start
# Usage: auto-migrate.sh [PLUGIN_ROOT]
# Exit 0 always. Silent on success. Caller prints the summary line.

# Resolve PLUGIN_ROOT
if [ -n "$1" ]; then
  PLUGIN_ROOT="$1"
else
  PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

# Read plugin version
PLUGIN_VER=$(grep '"version"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -1 | sed 's/.*: *"//;s/".*//')
if [ -z "$PLUGIN_VER" ]; then
  exit 0
fi

# Only migrate CKS-managed projects (must have .prd/)
if [ ! -d ".prd" ]; then
  exit 0
fi

# Read project version (treat missing/empty as 0.0.0)
VERSION_FILE=".prd/.cks-version"
PROJECT_VER=$(cat "$VERSION_FILE" 2>/dev/null | head -1 | xargs 2>/dev/null)
if [ -z "$PROJECT_VER" ]; then
  PROJECT_VER="0.0.0"
fi

# Semver-to-int: X.Y.Z -> X*10000 + Y*100 + Z
semver_int() {
  local ver="$1"
  local major minor patch
  major=$(echo "$ver" | cut -d. -f1)
  minor=$(echo "$ver" | cut -d. -f2)
  patch=$(echo "$ver" | cut -d. -f3)
  # Default to 0 if not numeric
  major=$(echo "$major" | grep -E '^[0-9]+$' || echo 0)
  minor=$(echo "$minor" | grep -E '^[0-9]+$' || echo 0)
  patch=$(echo "$patch" | grep -E '^[0-9]+$' || echo 0)
  echo $(( major * 10000 + minor * 100 + patch ))
}

PROJECT_INT=$(semver_int "$PROJECT_VER")
PLUGIN_INT=$(semver_int "$PLUGIN_VER")

# Already up to date
if [ "$PROJECT_INT" -ge "$PLUGIN_INT" ]; then
  exit 0
fi

# ISO timestamp helper
iso_now() {
  date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S"
}

# ── Migration: v0.0.0 → v4.0.0 ──────────────────────────────────────────────
# Applies when .prd/ exists but .cks-version is missing (project_ver == 0.0.0)
if [ "$PROJECT_INT" -lt 40000 ]; then

  # Structural directories
  mkdir -p ".prd/logs" ".prd/phases" ".learnings" 2>/dev/null

  # PRD-STATE.md field backfill
  if [ -f ".prd/PRD-STATE.md" ]; then
    if ! grep -q "Iteration Count:" ".prd/PRD-STATE.md" 2>/dev/null; then
      printf '\nIteration Count: 0' >> ".prd/PRD-STATE.md"
    fi
    if ! grep -q "Iteration Reason:" ".prd/PRD-STATE.md" 2>/dev/null; then
      printf '\nIteration Reason: —' >> ".prd/PRD-STATE.md"
    fi
    if ! grep -q "Secrets Tracking:" ".prd/PRD-STATE.md" 2>/dev/null; then
      printf '\nSecrets Tracking: not scanned' >> ".prd/PRD-STATE.md"
    fi
  fi

  # prd-config.json backfill
  if [ ! -f ".prd/prd-config.json" ]; then
    cat > ".prd/prd-config.json" <<'JSONEOF'
{"versioning":{"enabled":true,"strategy":"auto-patch","changelog":true},"profile":"default","migrated_from":"pre-4.0"}
JSONEOF
  fi

  # lifecycle.jsonl initialization
  if [ ! -f ".prd/logs/lifecycle.jsonl" ]; then
    TS=$(iso_now)
    printf '{"event":"auto-migrated","from":"pre-4.0","to":"4.0.0","ts":"%s"}\n' "$TS" > ".prd/logs/lifecycle.jsonl"
  fi

fi

# ── Migration: v4.0.0 → v4.2.0 ──────────────────────────────────────────────
if [ "$PROJECT_INT" -lt 40200 ]; then

  mkdir -p ".monetize/phases" ".context" 2>/dev/null

  # Add .prd/logs/.current_session_id to .gitignore if not already present
  if [ -f ".gitignore" ]; then
    if ! grep -qF ".prd/logs/.current_session_id" ".gitignore" 2>/dev/null; then
      printf '\n.prd/logs/.current_session_id\n' >> ".gitignore"
    fi
  fi

fi

# ── Migration: v4.2.0 → v4.7.0 ──────────────────────────────────────────────
if [ "$PROJECT_INT" -lt 40700 ]; then

  if [ -d ".claude/rules" ] && [ ! -f ".claude/rules/karpathy.md" ]; then
    cat > ".claude/rules/karpathy.md" <<'MDEOF'
# Coding Behavior Rules

Four principles that address the most common LLM coding failure modes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

Before implementing anything non-trivial:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

Test: Every changed line should trace directly to the user's request.

## 4. Define Success, Then Verify

Before starting non-trivial work, transform the task into a verifiable goal:

```
Task: "fix the bug"
→ Success: test that reproduces the bug passes; no other tests break
```

For multi-step tasks, state a brief plan with a verify step for each:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

Then loop until every verify step produces evidence. "Seems right" is not done.
MDEOF
  fi

fi

# ── Stamp the project with current plugin version ────────────────────────────
echo "$PLUGIN_VER" > "$VERSION_FILE"

exit 0
