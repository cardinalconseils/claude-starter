---
description: "View or switch the Luv Marketing model routing profile — quality / budget / speed"
argument-hint: "[quality|budget|speed]"
allowed-tools: Read, Bash, AskUserQuestion
---

# /cks:luv-profile — Luv Model Profile

View the active profile or switch to a different one.

## Quick Reference

```
/cks:luv-profile              → show active profile and model table
/cks:luv-profile quality      → switch to quality (client deliverables)
/cks:luv-profile budget       → switch to budget (cost-optimized)
/cks:luv-profile speed        → switch to speed (lowest latency)
```

## Profile Hierarchy

Resolution order (first match wins):
1. `$LUV_PROFILE` env var
2. `.luv/active-profile` in project root
3. `~/.cks/profiles/luv/active` (global Hermes tier)
4. Default: `quality`

## Dispatch

**with args (profile name):**

```javascript
// Validate
const valid = ["quality", "budget", "speed"]
if (!valid.includes($ARGUMENTS.trim())) {
  AskUserQuestion("Which profile?", options: ["quality", "budget", "speed"])
}

// Set project-level default
Bash("mkdir -p .luv && echo '" + $ARGUMENTS.trim() + "' > .luv/active-profile")
Bash("echo 'Active profile set to: " + $ARGUMENTS.trim() + "'")

// Show the profile
Bash("cat ${CLAUDE_PLUGIN_ROOT}/skills/luv-model-routing/profiles/" + $ARGUMENTS.trim() + ".yaml")
```

**no args:** Show the current profile.

```javascript
Bash(`
PROFILE="${LUV_PROFILE:-$(cat .luv/active-profile 2>/dev/null || cat ~/.cks/profiles/luv/active 2>/dev/null || echo quality)}"
echo "Active Luv profile: $PROFILE"
echo ""
PFILE="${CLAUDE_PLUGIN_ROOT}/skills/luv-model-routing/profiles/${PROFILE}.yaml"
[ -f ".luv/profiles/${PROFILE}.yaml" ] && PFILE=".luv/profiles/${PROFILE}.yaml"
[ -f "${HOME}/.cks/profiles/luv/${PROFILE}.yaml" ] && PFILE="${HOME}/.cks/profiles/luv/${PROFILE}.yaml"
cat "$PFILE"
`)
```
