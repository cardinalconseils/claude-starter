# Hermes Mode — CKS as an Always-On Conversational Agent

> How to turn CKS from a command-dispatch plugin into an always-on, Hermes-style
> conversational agent you reach from Telegram (and iMessage) — **on your Claude.ai
> subscription, not per-token API billing.**

This is a design + roadmap document. It does not change code. It explains the
recommended architecture, what CKS already gives you, the gaps to close, how
deterministic and probabilistic behaviour are governed, and how you watch the whole
lifecycle execute.

---

## TL;DR

- **Transport is the easy, solved part.** Use Claude Code **channels** (research
  preview). They push Telegram / Discord / iMessage messages into a running Claude
  Code session and let Claude reply back through the same chat. Channels run on a
  **Pro/Max subscription with no API key** — exactly the billing you want.
- **The real work is the conversational brain**, and CKS is already ~60% there: the
  `concierge` is a natural-language front-door, and CKS has file memory, a learning
  loop, and a persona system.
- **The load-bearing decision:** run the concierge as the **brain of the top-level
  always-on session**, so it can both *converse* and *dispatch* lifecycle agents.
- **Governance:** push everything that *must* hold into the **deterministic plane**
  (hooks, allowlists, cron, permission gates) and let the LLM own only the *should*.
- **Visibility:** the VPS terminal/tmux is your live window into every bash and tool
  call; Telegram is the cockpit for steering and final replies.

---

## 1. Subscription & transport (the short part)

Two ways to drive Claude programmatically, and only one keeps your subscription:

| Path | Auth / billing | Verdict |
|---|---|---|
| **Anthropic Agent SDK** | API key, per-token (Pro/Max now get a *separate* monthly SDK credit pool — still not your subscription session) | ❌ breaks the "use my subscription" requirement |
| **Claude Code channels** | your claude.ai login (Pro/Max), no API key | ✅ recommended |

**How channels work.** A channel is an MCP server that pushes events into a running
Claude Code session. Each inbound Telegram message arrives as a
`<channel source="telegram">` event; Claude reasons and replies through the channel's
`reply` tool. Your CKS plugin loads in that same session **unchanged** — all commands,
agents, skills, and hooks are available. Setup (per the official docs):

```bash
# 1. Create a bot with @BotFather, copy the token
# 2. In Claude Code:
/plugin install telegram@claude-plugins-official
/telegram:configure <token>          # saved to ~/.claude/channels/telegram/.env
# 3. Restart with the channel enabled (this is the always-on process):
claude --channels plugin:telegram@claude-plugins-official
# 4. DM the bot, then pair + lock down:
/telegram:access pair <code>
/telegram:access policy allowlist
```

**Host:** channels only deliver while a session is open, so run the `claude --channels …`
process on an always-on **Linux VPS** under `tmux` or a `systemd` service.

**iMessage caveat.** The iMessage channel reads `~/Library/Messages/chat.db` and sends
via AppleScript — it **requires a macOS host and cannot run on the Linux VPS.** Two
topologies:
- **A — single Linux VPS:** Telegram (and Discord). No iMessage.
- **B — Linux VPS + always-on Mac:** VPS hosts Telegram; the Mac runs its own
  `claude --channels plugin:imessage@…` process for iMessage. Two hosts, more cost.

> Channels are a research preview (Claude Code ≥ v2.1.80). The `--channels` flag and
> protocol may change. Individual Pro/Max users are enabled by default; Team/Enterprise
> orgs must turn on `channelsEnabled`.

---

> **Does the CKS plugin survive? Yes — fully.** Channels run Claude Code with CKS
> loaded as a normal plugin, so every command, agent, skill, and hook works unchanged,
> and you keep using CKS in your IDE/terminal exactly as today. This is the reason
> channels is chosen over the Agent SDK: the SDK path would force porting CKS out of the
> plugin format and lose it. The Hermes upgrades in section 6 are themselves implemented
> as CKS skills/agents/hooks — you **extend** the plugin, you do not replace it.

## 2. What CKS already has (the head start)

You are not starting from zero on the brain. CKS already ships the hard pieces:

- **Conversational front-door — the concierge.** `agents/concierge.md` (model: opus) +
  `skills/concierge/SKILL.md`. It parses free text → an intent verb (a CRUD++ mapping
  table) → reads `.prd/PRD-STATE.md` for context → confirms via `AskUserQuestion` when
  unsure → dispatches the right CKS agent → records the outcome in
  `.cks/concierge-state.json`. Below ~80% confidence it asks instead of guessing. It is
  already multi-transport (CLI / Slack / voice via a `--source` flag).
- **Memory.** `skills/control-plane/memory/SKILL.md` — append-only file memory: project
  `facts.md` / `decisions.md` / `gotchas.md`, per-agent scratchpads, and **session
  snapshots** written by the Stop hook and re-read on the next SessionStart. Optional
  Supabase sync at session end.
- **A learning loop.** `skills/retrospective/SKILL.md` and
  `skills/control-plane/improvements/SKILL.md` extract conventions and gotchas, score
  their confidence, and promote high-confidence ones into `.claude/rules/`. This is
  CKS's analog of "an agent that grows with you."
- **Persona & voice.** `skills/agent-persona/`, the caveman voice, and
  `skills/user-profile/` for per-user communication preferences.
- **Multi-turn continuity.** `board/session.js` resumes sessions with
  `--resume {session_id}` and parses the `stream-json` event feed.

---

## 3. Command-dispatch vs. always-on assistant (the conceptual gap)

CKS today is a **command-dispatch system**: you say a thing, the concierge routes it to
a lifecycle agent, the agent does the work. Hermes is an **always-on assistant**: it
converses, remembers *you* across projects, summarizes, and proactively surfaces
blockers without being asked. Bridging the two is mostly **brain and state work**, not
plumbing.

---

## 4. The brain architecture

**Decision: the concierge is the brain of the top-level session, not a sub-agent.**

Channels deliver events to the *main* session, and Claude Code forbids sub-agents from
dispatching further agents. So the conversational front-door must live at the top level.
CKS already has a precedent for this — the **Orchestrator Exception** in
`.claude/rules/commands.md`, where orchestrator commands load a skill into the top-level
session via `Skill(skill=...)` instead of dispatching an agent. Hermes Mode reuses that
pattern: load the concierge brain at the top level so it can both **converse** and
**dispatch** lifecycle agents.

```
Telegram / iMessage message
   → <channel> event in the persistent top-level session
      → Concierge BRAIN (skill loaded at top level, conversational mode)
          ├─ small talk / Q&A / advice          → reply directly via the channel
          ├─ clear lifecycle intent (build/ship) → dispatch cks:prd-* agent, report back
          └─ proactive (heartbeat fired)         → push a message out via the channel
      → read/write user-scoped memory + conversation-state on every turn
```

---

## 5. Determinism governance

A Hermes-style agent must cleanly separate **deterministic** (guaranteed) from
**probabilistic** (LLM-judgment) behaviour — especially when it runs unattended.

**The truth to internalize:** `.claude/rules/*.md` are **not** deterministic. They are
context injected into a probabilistic model, which is *asked* to comply. The only truly
deterministic enforcement is **hooks** plus a few platform primitives.

**Two planes:**

- **Deterministic plane (no model judgment):** hooks (`hooks/hooks.json` →
  `hooks/handlers/*.sh`; a `PreToolUse` hook blocks by exit code regardless of what the
  model "decided" — `hooks/handlers/destructive-op-guard.sh` already does this), the
  channel **sender allowlist**, `CronCreate`/scheduler timing, and permission modes.
- **Probabilistic plane (judgment is the point):** concierge routing, conversation,
  agent selection, reply wording — guided by rules, **confidence thresholds**
  (`< 80%` → clarify), and **`AskUserQuestion`** for real decision points.

**Bridge pattern — defense in depth.** Every *must-hold* rule gets a deterministic hook
backstop:

| Concern | Probabilistic rule | Deterministic backstop |
|---|---|---|
| Destructive ops | `.claude/rules/destructive-ops.md` | `hooks/handlers/destructive-op-guard.sh` (PreToolUse) ✅ exists |
| User-memory isolation | `skills/user-memory` instructions | `hooks/handlers/user-memory-guard.sh` (PreToolUse, keyed on `CKS_ACTIVE_USER`) ✅ exists |
| Secrets | `.claude/rules/secrets.md` | *gap* — add an output / PreToolUse scan hook |
| Scheduling triggers | `.claude/rules/scheduling.md` | model-matched today; promote to a hook if it must be guaranteed |
| Sender trust | persona / instructions | channel allowlist ✅ |

**Decision test — "must vs. should":**
- **Must** (security, money, deletion, who may talk to it) → deterministic
  (hook / allowlist / permission gate). Never trust the prompt alone.
- **Should** (helpfulness, workflow choice, phrasing) → probabilistic
  (LLM + confidence + human-in-the-loop).

**Why this matters more here.** An unattended VPS agent likely runs with
`--dangerously-skip-permissions` (otherwise it stalls waiting for you), which **removes
the human as the backstop** — so the hook plane is the only safety net. Pre-flight before
going unattended:
1. `destructive-op-guard` active.
2. A secrets-scan hook added.
3. Allowlist locked (`/telegram:access policy allowlist`).
4. A `PreToolUse` "tripwire" hook for irreversible actions that messages you out-of-band
   for approval instead of silently proceeding.

---

## 6. The five gaps to close

| # | Gap | Today | Target |
|---|-----|-------|--------|
| 1 | **Converse vs. dispatch** | concierge only routes to lifecycle agents | add a first-class "just talk / answer / advise" branch so it is a general assistant |
| 2 | **User-scoped memory** | memory is project-scoped; snapshots are per-project | cross-project memory keyed to the person (`~/.cks/user/<id>/…`): preferences, history, learned style — survives VPS restarts |
| 3 | **Conversation state across restarts** | continuity = `--resume` within one live session | persist `.cks/conversation-state.json`, rehydrate on session start so a restart resumes the thread |
| 4 | **Proactive messaging** | fully reactive | reuse `agents/heartbeat-agent.md` + `CronCreate` to push blockers/reminders out through the channel `reply` tool |
| 5 | **Comeback / state-of-the-union** | facts spread across PRD-STATE, snapshots, RAID | a `session-loader` brain step: one narrative "here's what happened, what's blocked, what's next" |

Each is an evolution of an existing CKS asset, not a new subsystem.

---

## 7. Observability — seeing it work

"Seeing it work" splits into two complementary surfaces.

**Engine room — terminal / tmux / logs.** Every agent dispatch, `Bash` command, file
edit, and test run streams live in the terminal. This is the richest view. Per the
channels docs, **even when driven from Telegram the terminal still shows the inbound
message and the tool calls** (it shows a `sent` confirmation where the reply text would
be; the reply itself appears in Telegram). On the VPS, the **tmux session is your live
window into every bash command the agents run**.

**Cockpit — Telegram.** Steer in natural language; read the agent's final replies.

**Driving the full lifecycle** — every stage is reachable both as a slash command and
conversationally through `/cks:concierge` (the same front-door that becomes the Telegram
brain):

| Stage | Slash command | Say it conversationally | Agent(s) |
|---|---|---|---|
| Kickstart | `/cks:kickstart` | "start a new project" | `kickstart-ideator` → scaffold |
| Bootstrap | `/cks:bootstrap` / `/cks:adopt` | "adopt CKS into this repo" | `bootstrap-scanner` → `bootstrap-generator` |
| Discovery | `/cks:discover` | "gather requirements" | `prd-discoverer` |
| Design | `/cks:design` | "design the UX / API" | `prd-planner`, `design-system-generator` |
| Sprint | `/cks:sprint` | "build it / start the sprint" | Attractor pipeline → `prd-executor`, `prd-verifier` |
| Review | `/cks:review` | "review and retro" | `sprint-reviewer`, `retrospective` |
| Release | `/cks:release` | "ship it" | release node / deployer |

**Four ways to watch:**
1. **Live terminal** — richest, default.
2. **`claude -p --output-format stream-json`** — structured tool-use events; this is what
   `board/session.js` consumes to render a watchable board.
3. **CKS observability commands** — `/cks:status` (git + build + phase dashboard),
   `/cks:logs` (activity log via `scripts/cks-log.sh`), `/cks:progress`, `/cks:observe`,
   `/cks:cost`.
4. **Hook status pings into Telegram** — mirror `hooks/handlers/slack-notify.sh` (fires on
   `SubagentStop` / `Stop`) so the chat gets progress, not just the final reply.

**Fastest demo (no Telegram needed):** open a local Claude Code session on a throwaway
target project with CKS installed, run `/cks:kickstart` (or `/cks:status` for a quick safe
one), and watch the agents run bash, tests, and edits live. Telegram is just transport
layered on this exact loop.

---

## 8. Phased roadmap

| Phase | Goal | Notes |
|---|---|---|
| **P0 — Prove the loop** | `fakechat` channel + concierge at top level; a free-text message gets a *conversational* reply (not just a command dispatch) on the subscription | localhost demo, nothing to authenticate |
| **P1 — Conversational concierge** | add the "converse / answer / advise" branch to `skills/concierge/SKILL.md` | gap #1 |
| **P2 — Durable user memory** | user-scoped memory (`~/.cks/user/<id>/`), read each turn, written on key turns | gap #2 |
| **P3 — Conversation state** | persist `.cks/conversation-state.json`; rehydrate on start | gap #3 |
| **P4 — Telegram on VPS, always-on** | `systemd`-supervised `claude --channels …`, pairing + allowlist, unattended-mode pre-flight | section 5 |
| **P5 — Proactive brain** | heartbeat pushes blockers/reminders out through the channel | gap #4 |
| **P6 — iMessage (optional)** | second host topology B (needs a Mac) | section 1 |

---

## 9. Risks & open questions

- **Research-preview instability** — the channels flag and protocol may change.
- **Unattended permissions** — `--dangerously-skip-permissions` removes the human
  backstop; the hook plane (section 5) becomes mandatory, not optional.
- **Permission-prompt stalls** — if a prompt fires while you are away and you have *not*
  skipped permissions, the session pauses until you respond. Channels can relay prompts
  if the plugin supports it.
- **Memory keying** — **decided: multi-user (shared bot).** Memory is keyed per channel
  sender ID under `~/.cks/user/<user_slug>/` (`skills/user-memory`). The remaining open
  question is **isolation strength**. The deterministic guard
  `hooks/handlers/user-memory-guard.sh` now blocks cross-user file access, traversal, and
  enumeration at the process boundary, keyed on `CKS_ACTIVE_USER` (which the channel
  adapter must export from the trusted sender ID). Residual gap: in one shared session all
  users share context — strong multi-tenant isolation of in-context data needs per-user
  sessions. Settle before exposing the bot beyond trusted users.
- **Always-on cost** — a persistent subscription session consuming usage continuously;
  watch quota.
- **iMessage requires a Mac** — confirm whether topology B is worth the second host.

---

## References

- Claude Code channels — https://code.claude.com/docs/en/channels
- Channels reference (build your own) — https://code.claude.com/docs/en/channels-reference
- Official channel plugins — https://github.com/anthropics/claude-plugins-official
- Use the Agent SDK with your Claude plan — https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan
- CKS internals cited above: `agents/concierge.md`, `skills/concierge/SKILL.md`,
  `skills/control-plane/memory/SKILL.md`, `skills/retrospective/SKILL.md`,
  `agents/heartbeat-agent.md`, `hooks/handlers/slack-notify.sh`,
  `hooks/handlers/destructive-op-guard.sh`, `board/session.js`, `scripts/cks-log.sh`,
  `.claude/rules/commands.md`, `skills/slack/SKILL.md`, `skills/voice/SKILL.md`.
