# Hermes Mode — VPS Deployment Runbook (P4)

> Operational companion to [`hermes-mode.md`](hermes-mode.md). That doc is the *design*;
> this is the *copy-paste* path to a supervised, always-on Telegram brain on a Linux VPS,
> running on your Claude subscription. Read the design doc's section 5 (determinism
> governance) before going unattended — the safety pre-flight here implements it.

---

## 0. The one decision that shapes everything: topology

`CKS_ACTIVE_USER` is a **process-level** environment variable. It is set once when the
`claude --channels …` process launches and does **not** change per message. The
`user-memory-guard` hook keys all isolation off it. That single fact dictates the topology:

| Topology | Who can DM the bot | How identity is keyed | Isolation |
|---|---|---|---|
| **A — single trusted user** *(ship this first)* | exactly one paired sender (you) | one session, `CKS_ACTIVE_USER=<you>` fixed | ✅ correct & simple |
| **B — multi-user, session-per-user** | a small set of trusted senders | **one process per sender**, each with that sender's `CKS_ACTIVE_USER`, behind a router | ✅ correct, more moving parts |
| ❌ **shared session, many users** | many senders → one session | impossible: one fixed `CKS_ACTIVE_USER` can't represent N senders | ❌ in-context data is shared — do not do this for untrusted users |

**Recommendation:** deploy **Topology A** now. It is fully supported by everything built
in P0–P5. Move to **Topology B** (section 10) only when you actually need multiple users,
and never run mutually-untrusted users in a single shared session — the guard stops
cross-*directory* access, but a shared session still shares in-context data (the residual
gap recorded in `skills/user-memory`).

---

## 1. Prerequisites

- A Linux VPS you control (1 vCPU / 1 GB RAM is enough; more headroom helps).
- Claude Code **≥ v2.1.80** installed for a **non-root** user, logged into a **Pro/Max**
  subscription (`claude` stores auth under that user's `~/.claude`). Run the service as
  that user — never root.
- `tmux` and `systemd` available.
- The CKS plugin installed in that user's Claude Code.
- A Telegram bot token from **@BotFather** (keep it secret — it is a credential).

---

## 2. One-time channel setup

Do this once, interactively, as the service user (so pairing/allowlist persist in
`~/.claude`):

```bash
# inside an interactive `claude` session as the service user
/plugin install telegram@claude-plugins-official
/telegram:configure $TELEGRAM_BOT_TOKEN     # token saved to ~/.claude/channels/telegram/.env
```

Then start the channel once, DM the bot, and lock it down to **only you**:

```bash
claude --channels plugin:telegram@claude-plugins-official
# DM your bot, read the pairing code it shows, then:
/telegram:access pair <code>
/telegram:access policy allowlist           # allowlist = nobody but paired senders
```

> The token now lives in `~/.claude/channels/telegram/.env`. Do not copy it elsewhere; the
> systemd service finds it via the service user's `HOME`. Never paste the raw token into a
> commit, log, or this runbook (`.claude/rules/secrets.md`).

---

## 3. The channel-brain instruction

For inbound messages to route through the concierge brain (not the raw session), add this
to the always-on project's `CLAUDE.md` (per `skills/channel-brain`):

```markdown
## Hermes channel brain
For every inbound `<channel source="…">` message, act as the CKS concierge per
`skills/channel-brain/SKILL.md`: classify Converse / Dispatch / Clarify, key per-user
memory off `CKS_ACTIVE_USER`, reply through the channel `reply` tool, and never use
AskUserQuestion — ask clarifications through the channel instead. A scheduled proactive
wake runs the `skills/proactive-brain` scan loop instead of the per-message loop.
```

---

## 4. Unattended safety pre-flight (do not skip)

Unattended means launching with `--dangerously-skip-permissions`, which **removes the
human as the safety backstop**. The hook plane becomes the only net. Verify, as the
service user, before enabling the service:

```bash
# Deterministic guards present and registered:
for g in user-memory-guard destructive-op-guard secrets-scan-guard; do
  grep -q "$g" hooks/hooks.json && test -x "hooks/handlers/$g.sh" \
    && echo "✓ $g wired + executable" || echo "✗ $g MISSING"
done
```

Checklist (from `hermes-mode.md` §5):

- [ ] `user-memory-guard`, `destructive-op-guard`, and `secrets-scan-guard` all active
      (command above prints `✓` for each).
- [ ] Allowlist locked: `/telegram:access policy allowlist`, only your sender paired.
- [ ] `secrets-scan-guard` blocks raw credentials in Write/Edit/Bash — still keep the bot
      off repos full of live secrets and the allowlist to trusted senders (defense in depth).
- [ ] You accept that `--dangerously-skip-permissions` lets tool calls run without a
      prompt (this is required: a permission prompt stalls an unattended session and the
      reply never reaches chat — the confirmed gotcha in §9 of the design doc).

---

## 5. The systemd service (Topology A)

`/etc/systemd/system/cks-hermes.service` — replace `cksuser` with the service user and set
the always-on project path:

```ini
[Unit]
Description=CKS Hermes — always-on Telegram brain
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=cksuser
WorkingDirectory=/home/cksuser/hermes-project
Environment=HOME=/home/cksuser
Environment=CKS_ACTIVE_USER=cksuser
ExecStart=/usr/bin/env claude \
  --channels plugin:telegram@claude-plugins-official \
  --dangerously-skip-permissions
Restart=always
RestartSec=5
# Give the model room; channel sessions are long-lived:
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now cks-hermes
sudo systemctl status cks-hermes          # should be active (running)
journalctl -u cks-hermes -f               # live engine-room view
```

> `CKS_ACTIVE_USER` here is *your* slug — the one fixed identity this session serves. Pick a
> stable, slugified value (`[a-z0-9_-]`); it names your memory dir `~/.cks/user/<slug>/`.

---

## 6. Proactive wake on the VPS (P5)

Register the recurring wake once so the brain pushes blockers and due reminders. Easiest:
DM the bot `/cks:remind <when> to <what>` — the first reminder auto-registers the wake at
your chosen cadence (`agents/reminder.md`). To register without a reminder, ask the brain
to set up a proactive wake, or run `cks:scheduler`. The wake re-enters **this** session
with `CKS_ACTIVE_USER=cksuser`, so it scans exactly your memory dir — correct for
Topology A.

---

## 7. Smoke test (prove the loop)

1. **Reply path:** DM the bot "hi" → expect a conversational reply in Telegram; the
   `journalctl` feed shows the inbound message and a `sent` confirmation.
2. **Memory:** tell it a durable preference ("keep replies short"), then in a later message
   confirm it honors it (written to `~/.cks/user/cksuser/profile.md`).
3. **Reminder + wake:** `/cks:remind in 2 minutes to test the wake` → confirm the wake
   registers (`~/.cks/user/cksuser/proactive.json`), then that the reminder pushes when due.
4. **Restart resilience:** `sudo systemctl restart cks-hermes`, then send a follow-up to a
   mid-thread question → it resumes via `conversation-state.json` (P3).

---

## 8. Operate & observe

- **Engine room:** `journalctl -u cks-hermes -f`, or run under `tmux` instead of systemd
  during bring-up (`tmux new -s hermes` → launch the command → `Ctrl-b d` to detach,
  `tmux attach -t hermes` to watch). The tmux/journal feed is your live window into every
  bash command the agents run.
- **Cockpit:** Telegram — steer in natural language, read final replies.
- **CKS commands:** `/cks:status`, `/cks:logs`, `/cks:cost` work over the channel too.
- **Update:** `git pull` in the project, then `sudo systemctl restart cks-hermes`.
- **Stop:** `sudo systemctl stop cks-hermes` (and `disable` to keep it off across reboots).

---

## 9. Multi-user (Topology B) — sketch, not turnkey

When you need more than one user, run **one session per user** rather than one shared
session:

- A lightweight router maps each paired Telegram sender → a dedicated, long-lived
  `claude --channels …` process launched with that sender's `CKS_ACTIVE_USER`.
- Each process is its own `systemd` unit (templated: `cks-hermes@<slug>.service`) so each
  has a fixed, correct identity and the guard confines it to that user's dir.
- The router needs a per-sender bot/session binding; the official single-bot Telegram
  channel does not split senders across processes on its own, so this is custom glue.

This preserves the deterministic isolation the guard provides. The alternative — one shared
session keyed by the model deciding "who is talking" per turn — is **probabilistic** and
violates the must-vs-should test in the design doc. Don't ship it for untrusted users.

---

## 10. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| No reply in Telegram, `sent` never appears | session not running / not paired | `systemctl status`; re-pair; check allowlist |
| Reply only after you click in the IDE | permission prompt stalling (you launched without skip) | confirm `--dangerously-skip-permissions` is in `ExecStart` |
| `🔒 USER-MEMORY ISOLATION — ACCESS BLOCKED` in logs | a tool touched another user's dir | expected guard behavior — fix the path; never widen the guard |
| Bot replies to strangers | allowlist not locked | `/telegram:access policy allowlist`, re-verify paired senders |
| Reminder never fires | no wake registered | check `~/.cks/user/<slug>/proactive.json`; set a reminder to auto-register |
| Service flaps / restarts | auth expired or quota exhausted | `journalctl -u cks-hermes`; re-login `claude`; check subscription quota |

---

## Relationship to the design doc

This runbook implements roadmap **P4** from [`hermes-mode.md`](hermes-mode.md). The design
rationale (why channels over the Agent SDK, the determinism two-plane model, the
observability surfaces, the residual multi-tenant isolation gap) lives there; the
commands to stand it up live here.
