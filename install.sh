#!/usr/bin/env bash
# CKS — Claude Code Starter Kit installer
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/cardinalconseils/claude-starter/main/install.sh)

set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
MARKETPLACE_ID="cks-marketplace"
PLUGIN_ID="cks@cks-marketplace"

echo "Installing CKS — Claude Code Starter Kit..."

# Ensure ~/.claude exists
mkdir -p "$HOME/.claude"

# Create settings.json if it doesn't exist
if [ ! -f "$SETTINGS" ]; then
  echo "{}" > "$SETTINGS"
fi

# Merge marketplace + plugin into settings.json using Python
python3 - <<PYEOF
import json, sys

with open("$SETTINGS", "r") as f:
    try:
        s = json.load(f)
    except json.JSONDecodeError:
        s = {}

s.setdefault("extraKnownMarketplaces", {})
s["extraKnownMarketplaces"]["$MARKETPLACE_ID"] = {
    "source": {"source": "github", "repo": "cardinalconseils/claude-starter"}
}

s.setdefault("enabledPlugins", {})
s["enabledPlugins"]["$PLUGIN_ID"] = True

with open("$SETTINGS", "w") as f:
    json.dump(s, f, indent=2)

print("  ✔ settings.json updated")
PYEOF

# Fetch the plugin from the marketplace
echo "  Fetching plugin from marketplace..."
claude plugin marketplace update "$MARKETPLACE_ID"

echo ""
echo "✔ CKS installed successfully."
echo "  Restart Claude Code and run /cks:help to get started."
