#!/usr/bin/env bash
# CKS — Claude Code Starter Kit installer
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/cardinalconseils/claude-starter/main/install.sh)

set -euo pipefail

MARKETPLACE_ID="cks-marketplace"
PLUGIN_ID="cks@cks-marketplace"

echo "Installing CKS — Claude Code Starter Kit..."

# Ensure ~/.claude exists
mkdir -p "$HOME/.claude"

# Merge marketplace + plugin into settings.json using Python
# Python resolves all paths natively (avoids MSYS/Windows path mismatch on Git Bash)
python3 - "$MARKETPLACE_ID" "$PLUGIN_ID" <<'PYEOF'
import json, sys
from pathlib import Path

marketplace_id, plugin_id = sys.argv[1], sys.argv[2]
settings_path = Path.home() / ".claude" / "settings.json"
settings_path.parent.mkdir(parents=True, exist_ok=True)

try:
    s = json.loads(settings_path.read_text(encoding="utf-8")) if settings_path.exists() else {}
except json.JSONDecodeError:
    s = {}

s.setdefault("extraKnownMarketplaces", {})
s["extraKnownMarketplaces"][marketplace_id] = {
    "source": {"source": "github", "repo": "cardinalconseils/claude-starter"}
}

s.setdefault("enabledPlugins", {})
s["enabledPlugins"][plugin_id] = True

settings_path.write_text(json.dumps(s, indent=2), encoding="utf-8")
print("  ✔ settings.json updated")
PYEOF

# Fetch the plugin from the marketplace
echo "  Fetching plugin from marketplace..."
claude plugin marketplace update "$MARKETPLACE_ID"

# Read installed version from plugin cache (Python resolves path natively)
VERSION=$(python3 - "$MARKETPLACE_ID" <<'PYEOF' 2>/dev/null || echo "unknown"
import json, sys
from pathlib import Path

marketplace_id = sys.argv[1]
cache_dir = Path.home() / ".claude" / "plugins" / "cache" / marketplace_id / "cks"
plugin_files = list(cache_dir.rglob("plugin.json")) if cache_dir.exists() else []
versions = []
for f in plugin_files:
    try:
        versions.append(json.loads(f.read_text(encoding="utf-8"))["version"])
    except Exception:
        pass
print(max(versions) if versions else "unknown")
PYEOF
)

echo ""
echo "✔ CKS v${VERSION} installed successfully."
echo "  Restart Claude Code and run /cks:help to get started."
