---
description: "View or change model strategy — which AI model runs each agent/phase"
argument-hint: "[show|set <tier|agent> <model>|reset]"
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
---

# /cks:model — Model Strategy Manager

View the current model assignments, change tier defaults, or override specific agents.

## Routing

| Invocation | Action |
|------------|--------|
| `/cks:model` | Show current model map |
| `/cks:model show` | Show current model map |
| `/cks:model set reason sonnet` | Change a tier default |
| `/cks:model set prd-executor opus` | Override a specific agent |
| `/cks:model reset` | Remove all overrides, restore defaults |

## Show (default)

1. Read `.prd/prd-config.json` — extract `models` section
2. Read `${CLAUDE_PLUGIN_ROOT}/skills/prd/references/model-strategy.md` — get the default map
3. Display the current effective model for each tier and any overrides:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Model Strategy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Tiers:
   reason  → {model}  (decisions, design, review)
   execute → {model}  (implementation, testing, deploy)
   bulk    → {model}  (docs, scanning, reports)

 Overrides:
   {agent} → {model}  (reason: {why})
   — or: (none)

 Sprint sub-steps:
   [3a] Planning       → {model} (reason)
   [3b] Architecture   → {model} (reason)
   [3c] Implementation → {model} (execute)
   [3d] Code Review    → {model} (reason)
   [3e] QA             → {model} (execute)
   [3f] UAT            → {model} (reason)

 /cks:model set <tier|agent> <model>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Set

Parse arguments: `set <target> <model>`

- If `<target>` is a tier name (`reason`, `execute`, `bulk`): update `models.default.<target>`
- If `<target>` is an agent name: update `models.overrides.<target>`
- `<model>` must be one of: `opus`, `sonnet`, `haiku`

Read `.prd/prd-config.json`, merge the change, write back.

If `.prd/prd-config.json` doesn't exist, create it with the default structure plus the requested change.

Confirm:
```
  ✅ Set {target} → {model}
```

## Reset

Remove the `models.overrides` section (keep `models.default` at factory defaults).

```
AskUserQuestion:
  question: "Reset model strategy to defaults?"
  options:
    - "Reset overrides only — keep tier defaults"
    - "Full reset — restore factory tiers (opus/sonnet/haiku)"
    - "Cancel"
```

## Quick Reference

```
/cks:model                          → show current map
/cks:model set reason sonnet        → cheaper reasoning (all-sonnet mode)
/cks:model set bulk sonnet          → upgrade bulk tasks
/cks:model set prd-executor opus    → override one agent
/cks:model reset                    → restore defaults
```
