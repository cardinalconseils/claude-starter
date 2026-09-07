# Workflow: Go

Quick actions — `dev`, `start`, `build`, `commit`, `pr`, `worktrees` — and the `full` pipeline
(deps → build + audit → tests → review → secret gate → version → CI → commit → push → PR →
watch CI → release → cleanup → issues). Ported from the `go-runner` agent. Run by the shipper
role. Where go-runner dispatched the reviewer and security auditor itself, the shipper cannot:
that step returns to the chief of staff.

## Dispatch format

`action`: `commit` | `pr` | `dev` | `build` | `start` | `worktrees` | `full` (default);
`args`: optional user text (commit message, PR title); `project_root`.

## Step 1: Project detection

Check once, stop at the first match:

| File | Type | Dev | Build | Start | Test |
|---|---|---|---|---|---|
| `package.json` | Node.js | `scripts.dev` | `scripts.build` | `scripts.start` | `scripts.test` |
| `deno.json(c)` | Deno | `deno task dev` | `deno task build` | `deno task start` | `deno task test` |
| `pyproject.toml` | Python | `[project.scripts]` | `python -m build` | `[project.scripts]` | `pytest` |
| `manage.py` | Django | `python manage.py runserver` | — | same | `python manage.py test` |
| `app.py` / `main.py` | Python app | `python {file}` | — | same | `pytest` |
| `requirements.txt` | Python (legacy) | find entry point | — | same | `pytest` |
| `Cargo.toml` | Rust | `cargo run` | `cargo build --release` | `cargo run` | `cargo test` |
| `go.mod` | Go | `go run .` | `go build ./...` | `go run .` | `go test ./...` |
| `Gemfile` | Ruby | `bundle exec rails s` or `ruby app.rb` | — | same | `bundle exec rspec` |
| `composer.json` | PHP | `php artisan serve` or `php -S localhost:8000` | — | same | `vendor/bin/phpunit` |
| `Makefile` | Make | `make dev` | `make build` | `make run`/`make start` | `make test` |
| `docker-compose.yml` | Docker | `docker compose up` | `docker compose build` | `docker compose up -d` | `docker compose run test` |
| `CMakeLists.txt` | C/C++ | `cmake --build build && ./build/main` | `cmake --build build` | `./build/main` | `ctest --test-dir build` |

Node.js: always read `package.json` scripts — never guess. Python: activate `venv/`, `.venv/`,
or `env/` if present. Report `Detected: {type} ({file})`. Nothing detected → say which files
were checked, suggest `/cks:kickstart`, stop.

## Step 2: PRD context

If `.prd/PRD-STATE.md` exists: read phase and status; after every action append one line
`📋 PRD Phase {NN}: {name} ({status}) — next: /cks:{suggested}`; update `last_action` and
`last_action_date` (never `phase_status`). Without `.prd/`: run the action, then
`💡 Tip: Run /cks:new to add lifecycle management`. Hints, never gates.

## Actions

**dev** — install deps if missing (`node_modules/` absent → `npm install`), run the dev
command, stream output, report `▶ {command} (detected: {type})`.

**start** — same with the start column (`npm start`, `docker compose up -d`).

**build** — install deps if missing, run the build, show full output, report duration or the
last 30 lines on failure.

**commit**
1. `git status --short` — clean → say so, stop
2. Stage: already-staged files, else all modified/added. Never stage `.env*` (except
   `.env.example`), credentials, `node_modules/`, `dist/`, `build/`, `__pycache__/`,
   `target/`. List untracked files and ask before staging them.
3. Conventional message from `git diff --cached` (`feat:`/`fix:`/`refactor:`/`docs:`/
   `style:`/`chore:`, one line, 50–72 chars); user text wins
4. Pre-commit scan of staged files for the marker words in `.claude/rules/verification.md`
5. Commit with the co-author trailer the session specifies
6. Report `✅ {short-hash} {message} ({N} files)`

**pr**
1. `commit` first if the tree is dirty
2. On `main`/`master` → `git checkout -b feat/{slug}`
3. `git push -u origin $(git branch --show-current)` — never force-push
4. `gh pr create --title "{title}" --body "## Summary\n{bullets from commits}\n\n## Changes\n{key files}"`
   (or `create_pull_request` via the GitHub MCP); no `gh` → push only, print the manual URL
5. Report `✅ PR #{number} — {url}`

**worktrees** — `git worktree list --porcelain`; per non-main worktree
`gh pr list --head {branch} --json number,state,statusCheckRollup`; classify open / merged /
no PR; table; `git worktree remove {path} --force` for merged ones (`🧹 Cleaned: {branch}`).

## Action: full

0. **Worktree detection** — `git rev-parse --show-toplevel` vs the main worktree path from
   `git worktree list --porcelain`; set `IN_WORKTREE`; show `🌿 Worktree: {branch}` if so.
0.5. **Dependency refresh** — Node `npm update && npm install`; Python
   `pip install --upgrade -r requirements.txt`; Rust `cargo update`; Go
   `go get -u ./... && go mod tidy`; Ruby `bundle update`; PHP `composer update
   --no-interaction`. Stage changed lockfiles. `📦 Deps updated: {N}` or `📦 Deps: already
   current`. Warn and continue on failure — never block here.
1. **Build + dependency audit** in parallel. Build failure → stop with full output. Audit
   (`npm audit --audit-level=high --json`, `pip-audit --strict`, `cargo audit`,
   `govulncheck ./...`, `bundle audit check --update`) never blocks: `🔍 Audit: clean ✓` or
   `🔍 Audit: {N} high vulns`.
1.5. **Test suite** — unit → integration → E2E, **blocking**:

   | Signal | Command |
   |---|---|
   | `playwright.config.*` | `npx playwright test` |
   | `cypress.config.*` | `npx cypress run` |
   | `package.json` `scripts.test` | `npm test` |
   | `vitest.config.*` | `npx vitest run` |
   | `jest.config.*` | `npx jest --ci` |
   | `pytest.ini` / `[tool.pytest]` | `pytest -x` |
   | `Cargo.toml` | `cargo test` |
   | `go.mod` | `go test ./...` |

   Failure → `STOP — fix failing tests before committing` with `{file}:{line} — "{test}"`
   (Playwright visual diffs: name the diverged screenshot). No tests → `⚠️ No tests —
   committing without coverage` and continue.
2. **Code review + security scan** — the shipper does not review its own diff. Return to
   the chief of staff: "ready for reviewer (code-review mode) + reviewer (security mode,
   quick scan) on `git diff HEAD --name-only`; resume `full` from step 3 with the results".
   Empty diff → `🔍 skipped (clean tree)`. Findings never stop the pipeline; they are
   reported (`🔍 Review: {N} blocking, {N} warnings` / `🔒 Security: Grade {A-F}`) and filed in
   step 12.
3. **Secret gate** (blocking) — `gitleaks detect --source . --staged --no-git` if installed,
   else grep the staged diff for
   `AKIA[A-Z0-9]{16}|sk_live_|sk_test_|ghp_|xoxb-|xoxp-|-----BEGIN (RSA |EC )?PRIVATE KEY`.
   Hit → STOP, show file:line only, never the value.
4. **Version bump** — if `scripts/bump-version.sh` exists: `bash scripts/bump-version.sh`
   (reads commit history, picks patch/minor/major; `--bump-type` to force). Never ask, never
   block. `🔖 auto: {old} → {new} ({type})`. Changelog: `workflows/changelog.md`.
5. **CI check** — `ls .github/workflows/*.yml`; none → generate `.github/workflows/ci.yml`
   on `push`/`pull_request` to `main`, `ubuntu-latest`, `actions/checkout@v4`, then per type:
   Node `setup-node@v4` (node 20, npm cache) → `npm ci` → `npm run build --if-present` →
   `npm test --if-present` → `npm audit --audit-level=high`; Python `setup-python@v5` (3.11)
   → `pip install -r requirements.txt` → `pytest --tb=short` → `pip-audit --strict`; Rust
   `dtolnay/rust-toolchain@stable` → `cargo build` → `cargo test` → `cargo audit`; Go
   `setup-go@v5` (stable) → `go build ./...` → `go test ./...`; generic/plugin/docs →
   validate every `*.json` with `python3 -m json.tool` and `shellcheck --severity=error` on
   `*.sh`. Stage it: `⚙️ Created .github/workflows/ci.yml ({type})`.
6. **Commit** (action above). 7. **Branch** off `main`/`master`. 8. **Push**. 9. **PR** —
   store number and URL.
10. **Watch CI** — `gh pr checks {n} --watch --interval 30 >/dev/null 2>&1`; non-zero →
    `gh pr checks {n} --json name,state`, show `❌ CI failed: {checks}`, skip step 11; no
    `gh` → `⚠️ CI watch skipped`.
11. **Release** (CI green only) — with `.prd/`: run `skills/environment-management/workflows/deploy.md`
    for the active phase (production is `GATED:`); without `.prd/`:
    `gh pr merge {n} --squash --delete-branch` → `✅ merged → main`.
11.5. **Worktree cleanup** — `IN_WORKTREE` and merged →
    `git -C "$MAIN_PATH" worktree remove "$CURRENT_PATH" --force`.
12. **File issues** — labels `cks:auto-filed`, `cks:blocking`, `cks:enhancement`
    (idempotent `gh label create … 2>/dev/null || true`); blocking review findings and
    critical security findings → `[CKS] 🔴 {summary}` with `cks:blocking,cks:auto-filed`;
    warnings and high → `[CKS] 🟡 {summary}` with `cks:enhancement,cks:auto-filed`. Body:
    Source PR, Finding, File.
13. **Report**

```
✅ /cks:go complete
   Deps: … | Audit: … | Tests: … | Review: … | Security: … | Build: passed ✓
   Version: {old} → {new} | Commit: {hash} {message} | Branch: {branch}
   PR: #{n} — {url} | CI: ✅ green | ❌ {checks}
   Release: ✅ deployed | ✅ merged → main | ⏭ skipped (CI failed) | GATED: production
   Worktree: 🧹 {branch} removed | — | Issues: filed #{X}, #{Y} | none
```

Blocking issues filed → append `Next: #{X} — {title}`. Steps 0–9 failures stop the pipeline
(dep refresh warns); steps 10–13 never block.

## Release node (attractor pipeline)

1. Record node entry: `.prd/PRD-STATE.md` `current_node = Release`, `node_history`; move the
   GitHub Phase item to "Done" when `github_phase_item_id` is set and `attractor_mode: true`.
2. Close child issues listed in `node_history` for this sprint: `gh issue close <n>`.
   `github_phase_item_id` null → skip silently; `gh` unavailable → log, continue.
3. Post `Released: {release_url}` on the Phase item via `tools/github-project-sync.js`
   `commentOnPhaseItem`; unreachable → warn, release still succeeded.
4. GitHub failures never fail the release; always report what was attempted and skipped.

## Rules

1. Auto-detect everything — type, message, title, branch
2. Show output — build, tests, diff
3. Hints, not gates — PRD lines come after the action
4. Never force-push; respect `.gitignore`
5. User text overrides generated text
6. Stop on failure — no PR on a broken build
