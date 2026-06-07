#!/bin/bash
# CKS Secrets-Scan Guard — blocks a tool call that would write or echo a RAW credential.
# PreToolUse on Write/Edit/MultiEdit/Bash. Exit 2 = BLOCK | Exit 0 = allow.
# High-precision: provider-prefixed keys, PEM private keys, JWTs, and DB URLs with an
# embedded password. Placeholders ($VAR, ***, your-…, xxx) are ignored to avoid noise.
# NEVER echoes the secret value — reports the type only (.claude/rules/secrets.md).

INPUT=$(cat 2>/dev/null)

HITS=$(printf '%s' "$INPUT" | python3 -c '
import sys, json, re
try: d = json.load(sys.stdin)
except Exception: sys.exit(0)
ti = d.get("tool_input", d)
parts = []
for k in ("content", "new_string", "command"):
    v = ti.get(k)
    if isinstance(v, str): parts.append(v)
edits = ti.get("edits")
if isinstance(edits, list):
    for e in edits:
        if isinstance(e, dict) and isinstance(e.get("new_string"), str):
            parts.append(e["new_string"])
text = "\n".join(parts)
patterns = {
  "Stripe secret key":      r"sk_(live|test)_[A-Za-z0-9]{16,}",
  "Slack bot token":        r"xoxb-[0-9]{6,}-[0-9A-Za-z-]{10,}",
  "GitHub token":           r"gh[pousr]_[A-Za-z0-9]{30,}",
  "GitLab PAT":             r"glpat-[A-Za-z0-9_-]{18,}",
  "Stripe webhook secret":  r"whsec_[A-Za-z0-9]{20,}",
  "AWS access key id":      r"AKIA[0-9A-Z]{16}",
  "Google API key":         r"AIza[0-9A-Za-z_-]{30,}",
  "Private key (PEM)":      r"-----BEGIN [A-Z ]*PRIVATE KEY-----",
  "JWT / bearer token":     r"eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{6,}",
  "DB URL with password":   r"[a-z][a-z0-9+.-]*://[^\s:@/]+:(?!\$|\*\*\*|your[_-]|x{3,}|password|pass@)[^\s@/]{3,}@",
}
found = [label for label, pat in patterns.items() if re.search(pat, text)]
print("\n".join(sorted(set(found))))
' 2>/dev/null)

if [ -n "$HITS" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔑  SECRETS GUARD — RAW CREDENTIAL BLOCKED"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  A tool call would write/echo a raw credential:"
  while IFS= read -r h; do [ -n "$h" ] && echo "    • $h"; done <<< "$HITS"
  echo "  Use a placeholder (\$ENV_VAR) or read from the environment instead."
  echo "  Value not echoed — see .claude/rules/secrets.md"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  exit 2
fi

exit 0
