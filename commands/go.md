---
description: "Quick action command — commit, PR, dev, build. PRD-aware: guides you through the lifecycle."
argument-hint: "[action: commit|pr|dev|build] or no arg for full flow"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Skill
---

# /cks:go — One Command, Every Quick Action

A single entry point for daily dev actions. Always PRD-aware — when `.prd/` exists, it keeps you in the lifecycle.

## Step 0: Context Check (runs before every action)

Before doing anything, read the project state:

```
1. Check: does .prd/PRD-STATE.md exist?
2. If yes → read it, note current phase and status
3. Check: does package.json / pyproject.toml / Cargo.toml / go.mod exist?
4. If no project files → this is a fresh project
```

This determines the behavior described in each action below.

---

## Routing

| Invocation | What happens |
|------------|-------------|
| `/cks:go` | **Full quick flow:** build → commit → push → PR (PRD-aware) |
| `/cks:go commit` | Stage + smart commit |
| `/cks:go pr` | Commit + push + open PR |
| `/cks:go dev` | Start dev server |
| `/cks:go build` | Run build |

No argument = the most common path: get your work reviewed.

---

## PRD Lifecycle Awareness

Every action checks PRD state first and adapts:

### If no project files exist (fresh directory)

```
📋 No project detected.
   Run /kickstart to go from idea → scaffolded project → PRD lifecycle
   Or create your project files manually, then try again.
```
Stop. Don't guess.

### If project files exist but no `.prd/`

Run the action as-is — this is a standalone project, no lifecycle to track.
Add a one-time hint after the action completes:

```
💡 Tip: Run /cks:new to add lifecycle management (discuss → plan → execute → verify → ship)
```

### If `.prd/` exists — integrate with lifecycle

Read `PRD-STATE.md` and adjust behavior based on current phase:

| Phase Status | `/cks:go dev` | `/cks:go commit` | `/cks:go` or `/cks:go pr` |
|-------------|---------------|-------------------|---------------------------|
| `idle` / no active phase | Start dev + suggest `/cks:discuss` | Commit normally | Full flow + suggest `/cks:discuss` |
| `discussed` / `planned` | Start dev + update state to `executing` | Commit normally | Full flow + suggest `/cks:execute` |
| `executing` | Start dev | Commit + update state: note checkpoint | Full flow normally |
| `executed` | Start dev | Commit normally | Full flow + suggest `/cks:verify` |
| `verified` | Start dev | Commit normally | Full flow + suggest `/cks:ship` instead |
| `shipped` | Start dev | Commit normally | Full flow + suggest `/cks:next` |

**State updates are lightweight** — just updating `last_action` and `last_action_date` in PRD-STATE.md. Never change `phase_status` unless transitioning into `executing`.

**Suggestions are one-line hints** after the action completes, not gates:
```
✅ Committed: abc1234 feat: add user avatar component (3 files)
   📋 PRD Phase 03 (executing) — when ready: /cks:verify
```

---

## Project Detection

All actions auto-detect the project type. Check these files **once** at the start:

| File found | Type | Dev command | Build command |
|------------|------|-------------|---------------|
| `package.json` | Node.js | Read `scripts.dev` or `scripts.start` | Read `scripts.build` |
| `deno.json` / `deno.jsonc` | Deno | `deno task dev` | `deno task build` |
| `pyproject.toml` | Python | Check `[project.scripts]` | `python -m build` |
| `manage.py` | Django | `python manage.py runserver` | — |
| `app.py` / `main.py` | Python | `python {file}` | — |
| `Cargo.toml` | Rust | `cargo run` | `cargo build` |
| `go.mod` | Go | `go run .` | `go build ./...` |
| `Makefile` | Make | `make dev` (if target exists) | `make build` (if target exists) |
| `docker-compose.yml` | Docker | `docker compose up` | `docker compose build` |

For Node.js, read `package.json` scripts to get the exact commands — don't guess.

---

## Action: `dev`

**Trigger:** `/cks:go dev`

1. **Context check** (Step 0)
2. Detect project type
3. If Node.js and no `node_modules/` → run `npm install` first
4. If `.prd/` exists and phase is `planned` → update PRD-STATE to `executing`
5. Run the detected dev command in foreground
6. Report:
   ```
   ▶ {command} (detected: {type})
   📋 PRD Phase {NN}: {name} — now executing
   ```

If nothing detected → list what was checked and stop.

---

## Action: `commit`

**Trigger:** `/cks:go commit` or `/cks:go commit fix typo in header`

1. **Context check** (Step 0)
2. `git status --short` — if clean, say so and stop
3. Stage changes:
   - If files already staged → use those
   - If nothing staged → stage all modified/added files
   - **Never stage** `.env*` (except `.env.example`), credentials, `node_modules/`, `dist/`, `build/`
   - Warn about untracked files — list them and ask before staging
4. Generate conventional commit message from `git diff --cached`:
   - `feat:` / `fix:` / `refactor:` / `docs:` / `style:` / `chore:`
   - One line, 50-72 chars
   - If user provided text after `commit` → use that as the message
5. Commit with Co-Authored-By trailer
6. If `.prd/` exists → update PRD-STATE.md `last_action` and `last_action_date`
7. Report:
   ```
   ✅ {short-hash} {message} ({N} files)
   📋 PRD Phase {NN} ({status}) — {next suggestion}
   ```

---

## Action: `pr`

**Trigger:** `/cks:go pr` or `/cks:go pr Add user avatar support`

1. **Context check** (Step 0)
2. Run `commit` action first (if uncommitted changes exist)
3. If on `main`/`master` → create branch: `feat/{slugified-description}`
4. `git push -u origin $(git branch --show-current)`
5. Generate PR:
   ```bash
   gh pr create --title "{title}" --body "$(cat <<'EOF'
   ## Summary
   {bullets from commits}

   ## Changes
   {key files}

   ---
   *Quick PR via /cks:go*
   EOF
   )"
   ```
6. If `.prd/` exists and phase is `executed` → hint: "Run `/cks:verify` before merging"
7. If `.prd/` exists and phase is `verified` → hint: "Ready for `/cks:ship` (full deploy ceremony)"
8. Report:
   ```
   ✅ PR #{number} — {url}
   📋 PRD Phase {NN} ({status}) — {next suggestion}
   ```

If `gh` not available → push only, print the manual PR URL.

---

## Action: `build`

**Trigger:** `/cks:go build`

1. **Context check** (Step 0)
2. Detect project type
3. If Node.js and no `node_modules/` → run `npm install` first
4. Run the detected build command
5. Report success with duration, or failure with the last 20 lines of output

---

## Action: Full Quick Flow (no argument)

**Trigger:** `/cks:go`

Runs the complete quick-ship pipeline:

```
build check → commit → push → PR
```

1. **Context check** (Step 0)
2. **Build check** — detect and run build command. If fails → stop. If no build command → skip.
3. **Version bump** — if `scripts/bump-version.sh` exists, run it to sync version in plugin.json + marketplace.json from git tags. Stage the version files if changed.
4. **Commit** — run the `commit` action (stage, message, commit)
5. **Branch** — if on `main`/`master`, create feature branch
6. **Push** — `git push -u origin {branch}`
6. **PR** — create PR via `gh`
7. **CLAUDE.md staleness check** — compare CLAUDE.md's last modified date to the most recent code changes:
   - If CLAUDE.md is older than the last 5+ code commits → hint once:
     ```
     💡 CLAUDE.md may be stale — last updated {date}. Run /cks:ship for a full update, or edit manually.
     ```
   - If CLAUDE.md is current → say nothing
8. **PRD hint** — based on current phase:
   ```
   ✅ /cks:go complete
      Build:  passed ✓
      Commit: {hash} {message}
      Branch: {branch}
      PR:     #{number} — {url}

      📋 PRD Phase {NN}: {name} ({status})
         Next: /cks:verify    ← run this before merging
   ```

If any step fails → stop at that step and report.

---

## The Full Integrated Flow

This is how `/cks:go` fits into the complete lifecycle:

```
/kickstart                        ← idea → design → scaffold (package.json created)
  ↓
/cks:go dev                       ← start dev server (project is real, running)
  ↓
/cks:new "feature brief"          ← define what to build (discuss → plan)
  ↓
/cks:execute                      ← build it (or code manually)
  ├── /cks:go dev                 ← dev server running while you work
  ├── /cks:go commit              ← save checkpoints as you code
  ├── /cks:go commit              ← more checkpoints
  └── /cks:go pr                  ← quick PR for review (mid-phase)
  ↓
/cks:verify                       ← test acceptance criteria
  ↓
/cks:ship                         ← full ceremony: doctor → changelog → deploy
  ↓
/cks:go dev                       ← start next cycle
```

**`/cks:go` is the hands. PRD is the brain.** You use `/cks:go` constantly during development. The PRD lifecycle tells you what to build and when it's done.

---

## Rules

1. **Auto-detect everything** — project type, commit message, PR title, branch name
2. **Always check PRD state** — adapt hints, never block
3. **Hints not gates** — suggestions are one-line, after the action. Never prevent an action.
4. **Never force-push** — if push fails, report the conflict
5. **Respect .gitignore** — never force-add ignored files
6. **User text overrides** — if they provide text, use it for commit message / PR title
7. **Stop on failure** — don't create a PR if the build is broken
8. **No deploy** — that's `/cks:ship`
