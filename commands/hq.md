---
description: "Workforce HQ repo — scaffold cross-venture state (North Star, finops, routines, memory, users) or show what exists at $CKS_HQ"
argument-hint: "init [--user <slug>] | status"
allowed-tools:
  - Read
  - Agent
  - Bash
---

# /cks:hq — Workforce HQ

Cross-venture state (North Star, finops ledger, routine profiles, workforce memory, per-user
memory) lives in a private HQ repo, not in `~/.cks/` — cloud sessions are ephemeral. The plugin
resolves `$CKS_HQ` first and falls back to `~/.cks/`. See `docs/hq.md`.

## `init [--user <slug>]`

Run from inside the HQ clone (an empty or freshly created private repo). Dispatch:

```
Agent(subagent_type="cks:bootstrap-generator", prompt="HQ MODE — scaffold the workforce HQ layout in the current directory per your HQ Mode section. User slug: {slug or 'local'}. Never overwrite existing files; report written vs kept. Finish by reminding the user to export CKS_HQ=<this clone's absolute path> in their shell profile and cloud environment setup.")
```

After it returns, show the written/kept list and this reminder:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    export CKS_HQ="$PWD"   (add to ~/.zshrc or ~/.bashrc, and to the cloud environment setup script)
Why:    session-start, user-memory-guard and the chief of staff read HQ state only when CKS_HQ points here
Then:   git add -A && git commit -m "chore: scaffold HQ" && git push, then continue
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## `status`

Resolve the root and print what exists — no agent needed:

```bash
. "${CLAUDE_PLUGIN_ROOT}/scripts/hq-path.sh"; R=$(cks_hq_root); echo "HQ root: $R (CKS_HQ=${CKS_HQ:-unset})"
for p in CLAUDE.md NORTH-STAR.md .finops/BUDGET.md finops/ledger.jsonl .routines memory/index.md users; do
  [ -e "$R/$p" ] && echo "  ✅ $p" || echo "  ⚠️  $p — missing"; done
```

If `CKS_HQ` is unset, add one line: `CKS_HQ unset — legacy ~/.cks/ layout in use; run /cks:hq init inside your HQ clone.`

## Quick Reference

```
/cks:hq init                 # scaffold HQ in the current (HQ) repo, user slug "local"
/cks:hq init --user pmc      # same, with users/pmc/profile.md
/cks:hq status               # what exists at $CKS_HQ (or ~/.cks)
```
