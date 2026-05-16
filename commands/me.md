---
description: "Set or view your personal CKS user profile — name, role, style, domain, and preferences"
argument-hint: "[--show]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
  - Bash
---

# /cks:me — User Profile

Set up or update your personal CKS profile. Stored at `~/.cks/user-profile.md` and shown in every session banner.

## Routing

| Invocation | Behavior |
|------------|----------|
| `/cks:me` | Run guided interview — creates or updates profile |
| `/cks:me --show` | Print current profile without re-interviewing |

## Dispatch

Parse `$ARGUMENTS` for `--show`.

**Mode 1 — `--show`:**

Check if `~/.cks/user-profile.md` exists via Bash, then print it.

```bash
if [ -f "$HOME/.cks/user-profile.md" ]; then
  cat "$HOME/.cks/user-profile.md"
else
  echo "No profile found — run /cks:me to set one up."
fi
```

**Mode 2 — No args (interview mode):**

```
Agent(
  subagent_type="cks:user-profiler",
  prompt="Run the user profile interview. Output path: ~/.cks/user-profile.md"
)
```

## Quick Reference

```
/cks:me           # Run interview, create or update profile
/cks:me --show    # Print current profile
```
