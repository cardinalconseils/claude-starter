---
description: "Per-project Telegram agent — give this project its own bot, isolated config, channel-brain wiring, and always-on service"
argument-hint: "[setup|status|service]"
allowed-tools:
  - Read
  - Agent
  - AskUserQuestion
---

# /cks:telegram — Per-Project Telegram Agent

Give **this project** its own Telegram bot and always-on brain — separate bot, separate
process, separate config from every other project on the host. One bot per project, not one
bot for all. Sibling of `/cks:slack`; the onboarding flow (`/cks:bootstrap`, `/cks:adopt`)
offers it after scaffolding.

## Arguments

| Arg | Action |
|---|---|
| `setup` | Wizard — isolated config dir, bot token via `/telegram:configure`, channel-brain wiring, launcher, on-host validation |
| `service` | Generate this project's `systemd` unit for always-on operation |
| `status` | Show this project's channel config (token never printed) |
| (no args) | Run setup |

## Dispatch

```
Agent(
  subagent_type="cks:telegram-integrator",
  prompt="
    SUBCOMMAND: {$ARGUMENTS or 'setup'}
    Set up Telegram for the CURRENT project only. Follow the channel-setup skill:
    isolated CLAUDE_CONFIG_DIR per project, token via /telegram:configure (never in the
    repo or chat), inject the channel-brain snippet into CLAUDE.md, write a launcher, and
    validate the undocumented behaviours on the host.
  "
)
```

## Quick Reference

```
/cks:telegram setup      — wizard: this project's bot + isolated config + brain wiring
/cks:telegram service    — generate the systemd unit for always-on
/cks:telegram status     — show config (token masked)
```

## How per-project isolation works

Each project gets its own `CLAUDE_CONFIG_DIR` (under `~/.cks/telegram/<slug>/`) holding its
own bot token, so many project bots run on one host without collision. One shared
`CLAUDE_CODE_OAUTH_TOKEN` (from `claude setup-token`) logs them all in; one `CKS_ACTIVE_USER`
keeps your memory consistent across projects. Full topology: `docs/hermes-vps-deploy.md`.
