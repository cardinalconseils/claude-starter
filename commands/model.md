---
description: "View or change model strategy — which AI model runs each agent/phase"
argument-hint: "[show|set <tier|agent> <model>|reset]"
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
---

# /cks:model — Model Strategy Manager

| Invocation | Action |
|------------|--------|
| `/cks:model` / `show` | Show current model map with list prices |
| `/cks:model set reason sonnet` | Change a tier default |
| `/cks:model set builder opus` | Override a specific role |
| `/cks:model reset` | Remove all overrides, restore defaults |

## Show (default)

1. Read `.prd/prd-config.json` — extract `models` section
2. Read `${CLAUDE_PLUGIN_ROOT}/skills/prd/references/model-strategy.md` — the default map
3. Read `${CLAUDE_PLUGIN_ROOT}/skills/finops/references/model-prices.json` — `tiers.<tier>.input` / `.output` (USD per million tokens, list price)
4. Display, one `$in/$out per M` figure per tier from step 3:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Model Strategy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Tiers:                          list price /M tokens
   reason  → {model}  (decisions, design, review)   ${in} in / ${out} out
   execute → {model}  (implementation, testing)     ${in} in / ${out} out
   bulk    → {model}  (docs, scanning, reports)     ${in} in / ${out} out
 Overrides:  {role} → {model} ({why})  — or: (none)
 Sprint sub-steps: [3a][3b][3d][3f] → reason · [3c][3e] → execute
 Prices: skills/finops/references/model-prices.json (updated {updated}) — estimates, not a bill
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Set

`set <target> <model>` — `<model>` is one of `opus`, `sonnet`, `haiku`. A tier name
(`reason`, `execute`, `bulk`) updates `models.default.<target>`; a role name
(`agents/<target>.md`) updates `models.overrides.<target>`. Read `.prd/prd-config.json`,
merge, write back (create it with the default structure if missing). Confirm: `✅ Set {target} → {model}`.

## Reset

`AskUserQuestion` — "Reset model strategy to defaults?": overrides only / full reset (factory
tiers opus/sonnet/haiku) / cancel. Then remove `models.overrides` (and restore `models.default` on a full reset).

## Quick Reference

```
/cks:model                          → show current map + list prices per tier
/cks:model set reason sonnet        → cheaper reasoning (all-sonnet mode)
/cks:model set builder opus         → override one role
/cks:model reset                    → restore defaults
```
