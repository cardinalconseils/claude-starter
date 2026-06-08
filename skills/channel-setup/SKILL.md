---
name: channel-setup
description: Provisioning knowledge for per-project Telegram (and other channel) agents — gives each CKS project its own bot, its own isolated config dir, and its own always-on process, so one host runs many project bots without collision. Distinct from channel-brain (runtime message handling); this skill is about standing the channel up.
allowed-tools: [Read, Write, Bash, Glob, Grep, AskUserQuestion]
---

# Channel Setup — One Bot Per Project

`channel-brain` is how a running session *handles* messages. **This skill is how you stand
a channel up for a single project** so each CKS project has its own Telegram presence —
its own bot, its own process, its own config — instead of one bot shared across everything.

## The per-project model (Topology C)

A `claude --channels` session is already bound to one working directory = one project. So
"per project" means **one bot + one process per project**, each rooted in that repo:

| Per project | Mechanism |
|---|---|
| Its own bot (`@AlphaBot` vs `@BetaBot`) | a separate @BotFather token each |
| Its own always-on process | one `claude --channels …`, `WorkingDirectory` = that repo |
| Its own bot-token storage (no collision) | a per-process **`CLAUDE_CONFIG_DIR`** |
| One shared login across all of them | one **`CLAUDE_CODE_OAUTH_TOKEN`** |
| Its own project state | the repo's own `.prd/`, `CLAUDE.md` |

User memory (`~/.cks/user/<slug>/`) is **cross-project by design** — run every project's
bot with the same `CKS_ACTIVE_USER` and the agent remembers *you* across all of them while
each bot works on its own repo.

## Verified mechanism (from the Claude Code docs)

- **`CLAUDE_CONFIG_DIR`** relocates the config/state dir (`.credentials.json`, sessions,
  and the `channels/` config). This is what gives each process its **own**
  `channels/telegram/.env` (its own bot token). Confirmed: env-vars / authentication docs.
- **`claude setup-token`** prints a one-year `CLAUDE_CODE_OAUTH_TOKEN` for headless/systemd
  auth, **reusable across every process** — log in once, seed it into each service.
- **`--channels`** accepts multiple plugins, space-separated.
- The sender **allowlist** is per session, paired at runtime (`/telegram:access pair`).

## Validate on first setup (undocumented — the integrator checks these)

These three behaviours are not guaranteed by the docs; the setup agent confirms them on a
real host before declaring success, and reports any that fail:

1. **Config-dir channel path** — that `/telegram:configure` writes to
   `$CLAUDE_CONFIG_DIR/channels/telegram/.env`, not hard `~/.claude/...`. Test: set the var,
   configure, confirm the file landed in the custom dir.
2. **Concurrent processes** — that two `claude --channels` processes coexist without a
   socket/port clash (fakechat binds `:8787`; check Telegram's transport).
3. **OAuth token with channels** — that `CLAUDE_CODE_OAUTH_TOKEN` is accepted on the
   channels path (the docs note it is "inference-only, cannot establish Remote Control
   sessions"; channels may or may not count).

## Per-project layout

Keep the config dir and the bot token **outside the repo** (never commit a credential —
`.claude/rules/secrets.md`):

```
~/.cks/telegram/<project-slug>/
  .claude/                 # CLAUDE_CONFIG_DIR for this project's process (token lives here)
  launch.sh                # convenience launcher (no token inside — reads the config dir)
  cks-telegram@<slug>.service   # generated systemd unit (optional, for always-on)
```

`<project-slug>` is derived from the repo directory name, slugified
(`[a-z0-9_-]`). The repo itself only gains the **channel-brain snippet** in its `CLAUDE.md`.

## Setup steps (what the integrator does)

1. **Resolve** `<project-slug>` from the repo; `mkdir -p ~/.cks/telegram/<slug>/.claude`.
2. **Token** — emit an `▶ ACTION REQUIRED` block telling the user to create a bot with
   @BotFather and run, with this project's config dir, `/telegram:configure <token>`. Never
   ask the user to paste the token into chat or a file; it goes straight into the channel
   config via that command. The `secrets-scan-guard` hook backstops accidental writes.
3. **Brain wiring** — inject the channel-brain snippet (below) into the repo's `CLAUDE.md`
   if absent, so inbound messages route through the concierge.
4. **Launcher** — write `launch.sh` (and, if the user wants always-on, the systemd unit)
   that exports `CLAUDE_CONFIG_DIR`, `CKS_ACTIVE_USER`, and `CLAUDE_CODE_OAUTH_TOKEN` (read
   from the environment — not written literally), then runs `claude --channels …
   --dangerously-skip-permissions`.
5. **Validate** the three unknowns above; report pass/fail.
6. **Pair & lock** — `▶ ACTION REQUIRED`: DM the bot, `/telegram:access pair <code>`, then
   `/telegram:access policy allowlist`.

## Channel-brain snippet (injected into the project's CLAUDE.md)

```markdown
## Hermes channel brain
For every inbound `<channel source="…">` message, act as the CKS concierge per
`skills/channel-brain/SKILL.md`: classify Converse / Dispatch / Clarify, key per-user
memory off `CKS_ACTIVE_USER`, reply through the channel `reply` tool, and never use
AskUserQuestion — ask clarifications through the channel instead. A scheduled proactive
wake runs the `skills/proactive-brain` scan loop instead of the per-message loop.
```

## Systemd template (always-on, per project)

```ini
# /etc/systemd/system/cks-telegram@.service — instance per project slug
[Service]
User=cksuser
WorkingDirectory=/srv/projects/%i
Environment=HOME=/home/cksuser
Environment=CLAUDE_CONFIG_DIR=/home/cksuser/.cks/telegram/%i/.claude
Environment=CKS_ACTIVE_USER=cksuser
Environment=CLAUDE_CODE_OAUTH_TOKEN=%S          # seed via EnvironmentFile, not literal
ExecStart=/usr/bin/env claude --channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions
Restart=always
RestartSec=5
```
`systemctl enable --now cks-telegram@alpha` then `@beta` → two independent bots, one login.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "One bot can serve all projects, switch context per message" | A session is bound to one repo dir; switching projects mid-session breaks state and memory. One bot per project is the clean unit. |
| "Put the config dir inside the repo so it travels" | It holds the bot token and OAuth credentials. Keep it under `~/.cks/telegram/`, never committed. |
| "Write the token into the launcher / CLAUDE.md" | Never. Token goes into the channel config via `/telegram:configure`; launchers read it from the env/config dir. |
| "Skip the validation, the docs probably cover it" | Three behaviours are explicitly undocumented. Confirm them on the real host before trusting many projects to them. |

## Verification

- [ ] Each project has its own `CLAUDE_CONFIG_DIR` under `~/.cks/telegram/<slug>/`
- [ ] Bot token entered via `/telegram:configure`, never written to the repo or chat
- [ ] Channel-brain snippet present in the project's `CLAUDE.md`
- [ ] One shared `CLAUDE_CODE_OAUTH_TOKEN`; one `CKS_ACTIVE_USER` for cross-project memory
- [ ] The three undocumented behaviours validated on the host and reported
- [ ] Allowlist locked after pairing
