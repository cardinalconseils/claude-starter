#!/bin/bash
# Scaffolds .cks/control-plane/ in the current project directory.
# Copies default persona files and RAID log template from the plugin.
# Run once per project to opt into the CKS v6 control plane.

set -uo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
TARGET_DIR=".cks/control-plane"

# Safety: don't overwrite existing config
if [ -f "$TARGET_DIR/config.yaml" ]; then
  echo "⚠️  $TARGET_DIR/config.yaml already exists — not overwriting."
  echo "   Delete it and re-run to reset, or edit it directly."
  exit 0
fi

# Create directories
mkdir -p "$TARGET_DIR/personas"
mkdir -p "$TARGET_DIR/raid"
mkdir -p "$TARGET_DIR/heartbeat/state"
mkdir -p "$TARGET_DIR/memory/agents"
mkdir -p "$TARGET_DIR/memory/project"
mkdir -p "$TARGET_DIR/memory/sessions"
# Phase 5: Improvements dirs
mkdir -p "$TARGET_DIR/improvements/pending"
mkdir -p "$TARGET_DIR/improvements/accepted"
mkdir -p "$TARGET_DIR/improvements/rejected"
# Phase 6: Health + sync-queue dirs
mkdir -p "$TARGET_DIR/health"
mkdir -p "$TARGET_DIR/sync-queue"
mkdir -p "$(dirname "$TARGET_DIR")/backups" 2>/dev/null || mkdir -p ".cks/backups"

# Copy config template
if [ -f "$PLUGIN_ROOT/skills/control-plane/config.yaml.template" ]; then
  cp "$PLUGIN_ROOT/skills/control-plane/config.yaml.template" "$TARGET_DIR/config.yaml"
  echo "✓ Created $TARGET_DIR/config.yaml (edit to set your org name)"
fi

# Copy default persona files
if [ -d "$PLUGIN_ROOT/skills/control-plane/personas" ]; then
  cp "$PLUGIN_ROOT/skills/control-plane/personas/"*.md "$TARGET_DIR/personas/" 2>/dev/null || true
  cp "$PLUGIN_ROOT/skills/control-plane/personas/manifest.yaml" "$TARGET_DIR/personas/" 2>/dev/null || true
  PERSONA_COUNT=$(ls "$TARGET_DIR/personas/"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "✓ Copied ${PERSONA_COUNT} persona files to $TARGET_DIR/personas/"
fi

# Copy RAID log template
if [ -f "$PLUGIN_ROOT/skills/control-plane/raid/raid.md.template" ]; then
  cp "$PLUGIN_ROOT/skills/control-plane/raid/raid.md.template" "$TARGET_DIR/raid/raid.md"
  echo "✓ Created $TARGET_DIR/raid/raid.md"
fi

if [ -d "$PLUGIN_ROOT/skills/control-plane/memory/templates" ]; then
  for f in facts decisions gotchas; do
    [ ! -f "$TARGET_DIR/memory/project/${f}.md" ] && \
      cp "$PLUGIN_ROOT/skills/control-plane/memory/templates/${f}.md" \
         "$TARGET_DIR/memory/project/${f}.md" 2>/dev/null || true
  done
  echo "✓ Created memory/project/ knowledge base files"
fi

echo ""
echo "Control plane initialized. Next steps:"
echo "  1. Edit $TARGET_DIR/config.yaml — set your org name"
echo "  2. Start a new Claude Code session — the session banner will show the control plane status"
echo "  3. Run /cks:personas to view the team roster"
