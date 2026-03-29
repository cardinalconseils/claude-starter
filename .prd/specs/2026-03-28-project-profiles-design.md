# Design Spec: Project Profiles & Phase Autonomy

**Date:** 2026-03-28
**Status:** Approved
**Scope:** Add project type profiles to CKS that adapt versioning, changelog, release ceremony, and phase autonomy based on what the user is building.

## Problem

CKS assumes every project is a versioned app. The bump-version script is hardcoded for the CKS plugin itself (updates `plugin.json`, `marketplace.json`, `README.md`, `WORKFLOW.md`). The pre-commit hook nags about version bumps even for marketing websites. The release ceremony (Dev -> Staging -> RC -> Production) is overkill for a static site. There's no way to control which phases run interactively vs autonomously.

## Solution

A `profile` field in `prd-config.json` that drives behavior across all commands. Four profiles ship by default: App, Website, Library, API. Each defines sensible defaults for versioning, changelog, and phase autonomy modes. Any default can be overridden per-field.

## Profiles

| Profile | Description | Examples |
|---------|-------------|----------|
| `app` | Versioned product with users | SaaS, voice agent, Claude Agent SDK app, dashboard |
| `website` | Marketing/docs site, no versioning | Landing page, documentation site, portfolio |
| `library` | Published package consumed by others | npm module, pip package, MCP server |
| `api` | Versioned service consumed by other services | REST API, microservice, webhook handler |

### Profile Defaults

| Setting | App | Website | Library | API |
|---------|-----|---------|---------|-----|
| `versioning.enabled` | true | false | true | true |
| `versioning.strategy` | auto-patch | skip | manual | auto-patch |
| `versioning.changelog` | true | false | true | true |
| `phases.discover.mode` | interactive | interactive | interactive | interactive |
| `phases.design.mode` | interactive | interactive | interactive | interactive |
| `phases.sprint.mode` | auto | auto | auto | auto |
| `phases.review.mode` | gated | gated | gated | gated |
| `phases.release.mode` | gated | auto | gated | gated |

**Versioning strategies:**
- `auto-patch` — Bump patch version automatically on every commit (current behavior)
- `manual` — Only bump when explicitly requested (for libraries where semver matters)
- `skip` — No versioning at all

## Config Schema

After bootstrap sets the profile, `prd-config.json` looks like:

```json
{
  "profile": "app",
  "versioning": {
    "enabled": true,
    "source": "package.json",
    "strategy": "auto-patch",
    "changelog": true
  },
  "phases": {
    "discover": { "mode": "interactive" },
    "design":   { "mode": "interactive" },
    "sprint":   { "mode": "auto" },
    "review":   { "mode": "gated" },
    "release":  { "mode": "gated" }
  },
  "granularity": "fine",
  "parallelization": true,
  "commit_docs": true,
  "workflow": {
    "research": true,
    "plan_check": true,
    "verifier": true,
    "ask_style": "select"
  }
}
```

New fields: `profile`, `versioning`, `phases`. The old top-level `mode` field is replaced by per-phase modes in `phases`. If only `mode` exists (no `phases` field), all phases use that mode for backwards compatibility. Existing workflow fields unchanged.

### Version Source Detection

The `versioning.source` field is auto-detected by bootstrap from available files:

| File found | Source value |
|------------|-------------|
| `.claude-plugin/plugin.json` | `plugin.json` |
| `package.json` | `package.json` |
| `pyproject.toml` | `pyproject.toml` |
| `Cargo.toml` | `Cargo.toml` |
| `go.mod` | `null` (Go uses git tags for versioning, not a file field) |
| None | `null` (versioning disabled regardless of profile) |

## Phase Autonomy Modes

Each phase orchestrator reads its mode from `prd-config.json` and adapts.

### Phase Hierarchy

CKS has five top-level lifecycle phases and several legacy/alias command phases. Only the five top-level phases are configured in `prd-config.json`:

| Top-Level Phase | Orchestrator | Sub-commands (aliases/deprecated) |
|-----------------|-------------|-----------------------------------|
| `discover` | `discover-phase.md` | `discuss-phase.md` (deprecated alias) |
| `design` | `design-phase.md` | — |
| `sprint` | `sprint-phase.md` | `plan-phase.md`, `execute-phase.md`, `verify-phase.md` (sub-steps within sprint) |
| `review` | `review-phase.md` | — |
| `release` | `release-phase.md` | — |

The `plan`, `execute`, and `verify` phases are sub-steps of Sprint (Phase 3: [3a] plan, [3c] execute, [3e] verify). They inherit the sprint phase's mode. The `discuss` command is a deprecated alias for `discover`. Only the five orchestrators listed above read the phase mode from config.

### `interactive` mode

- Enters plan mode before starting
- Pauses between sub-steps for user review
- Uses AskUserQuestion for all decisions
- Shows progress banners between steps
- **This is the current default behavior** -- no changes needed

### `auto` mode

- Skips plan mode -- goes straight to execution
- Runs all sub-steps sequentially without pausing
- Makes decisions autonomously (picks recommended options)
- Only stops on errors or when user input is truly required
- Logs all autonomous decisions to lifecycle.jsonl for post-hoc review
- Discovery questions that gather requirements ALWAYS ask the user regardless of mode

### `gated` mode

- Runs auto within the phase (no pausing between sub-steps)
- Pauses at the phase boundary -- shows results and asks: "Phase complete. Proceed?"
- Think of it as "auto with a checkpoint at the exit"
- Appropriate for phases where you want to see the output before moving on

### Implementation in Orchestrators

Each phase orchestrator adds one read at the top:

```markdown
### Load phase mode
Read `.prd/prd-config.json` -> extract `phases.{current_phase}.mode`
Set PHASE_MODE to the result (default: "interactive" if not set)
```

Then adapts behavior:
- `interactive` -> current behavior
- `auto` -> skip plan mode, suppress AskUserQuestion where defaults exist, run all steps
- `gated` -> same as auto, but gate at the last step with an approval question

### What Does NOT Change

- Sub-step files themselves -- unchanged
- Lifecycle logging -- all modes log events
- Agent dispatches -- agents run in all modes
- Discovery questions -- ALWAYS interactive (per project convention)

## bump-version.sh Changes

### New Behavior

1. Read `.prd/prd-config.json` -> extract `profile` and `versioning` settings
2. If `versioning.enabled` is `false` -> exit 0 silently
3. If `versioning.strategy` is `manual` -> exit 0 silently (only bump when explicitly asked)
4. Detect version source from `versioning.source`:
   - `package.json` -> read/write `version` field via `jq`
   - `pyproject.toml` -> read/write `version` in `[project]` section via targeted `sed` pattern matching `^version = ` under `[project]` header only
   - `plugin.json` -> current behavior (for CKS plugin development)
   - `Cargo.toml` -> read/write `version` in `[package]` section
5. If `versioning.changelog` is `true` -> update `CHANGELOG.md` (generic, no CKS-specific files)
6. Auto-stage only the files that were actually modified

### What Gets Removed

- Hardcoded `marketplace.json`, `README.md`, `docs/WORKFLOW.md` updates -- CKS-plugin-specific
- Those files only get updated when `versioning.source` is `plugin.json` (self-development mode)

### Backwards Compatibility

If no `prd-config.json` exists:
- If `plugin.json` exists -> current behavior (CKS plugin development)
- If `package.json` exists -> use it as version source
- Otherwise -> skip silently

### Pre-commit Hook

The version bump guard in `.claude/settings.json` is a `type: "prompt"` hook (not a bash script). The prompt text must be updated to instruct Claude to:
- Read `prd-config.json` before checking for version bumps
- If `versioning.enabled` is `false` -> skip the version bump check entirely
- If `versioning.strategy` is `manual` -> skip the automatic bump check
- Only enforce version bumps when `versioning.strategy` is `auto-patch`

## Bootstrap Integration

### When the Profile Question Gets Asked

During `/cks:bootstrap` or `/cks:adopt`, after the stack scan and before generating CLAUDE.md.

### The Question

```
What kind of project is this?
  * App / SaaS / Agent       -- versioned, full release ceremony
  * Website / Landing Page   -- no versioning, deploy-on-push
  * Library / Package        -- strict versioning, publish to registry
  * API / Microservice       -- versioned, endpoint-focused release
```

### Auto-Detection Hints

Bootstrap already detects the stack. Use it to suggest a default:
- Has `.claude-plugin/` -> suggest "App"
- Has `index.html` + no server framework -> suggest "Website"
- Has `files` field or `publishConfig` in package.json -> suggest "Library"
- Has Express/FastAPI/Flask route patterns -> suggest "API"
- Default -> "App"

### What Bootstrap Does With the Answer

1. Sets `profile` in `prd-config.json`
2. Populates `versioning` with profile defaults
3. Auto-detects `versioning.source` from available files
4. Populates `phases` with profile default modes
5. Writes to `.prd/prd-config.json`

### The /cks:adopt Path

Works identically -- adds the profile question to its existing intake flow.

## Files to Create

None. This feature modifies existing files only.

## Files to Modify

| File | Change |
|------|--------|
| `scripts/bump-version.sh` | Read prd-config.json, respect profile, detect version source |
| `.prd/prd-config.json` | Add `profile`, `versioning`, `phases` fields |
| `skills/cicd-starter/workflows/bootstrap.md` | Add profile question during bootstrap |
| `commands/adopt.md` | Add profile question during adopt |
| `skills/prd/workflows/discover-phase.md` | Read phase mode, adapt behavior |
| `skills/prd/workflows/design-phase.md` | Read phase mode, adapt behavior |
| `skills/prd/workflows/sprint-phase.md` | Read phase mode, adapt behavior |
| `skills/prd/workflows/review-phase.md` | Read phase mode, adapt behavior |
| `skills/prd/workflows/release-phase.md` | Read phase mode, adapt behavior |
| `.claude/settings.json` | Version bump hook respects profile |
| `commands/help.md` | Document profile concept |

## Design Decisions

1. **Profile in prd-config.json, not a separate file** -- One config file, one place to look. The profile is metadata about the project, not a separate concern.
2. **Four profiles, not two** -- "Versioned vs Unversioned" is too coarse. App and Library have different versioning strategies (auto vs manual). API has different release concerns than App.
3. **Phase modes are per-phase, not global** -- You want Discovery interactive but Sprint auto. A global toggle doesn't serve this.
4. **Backwards compatible** -- If no profile/versioning/phases fields exist in prd-config.json, everything defaults to current behavior (interactive, CKS plugin versioning).
5. **Discovery always interactive** -- Per project convention: "Discovery must ask clarifying questions, never decide autonomously."
6. **No /cks:profile command yet** -- YAGNI. Users can edit prd-config.json directly. Add the command later if there's demand.
7. **Auto-detection as hints, not decisions** -- Bootstrap suggests a profile based on detected files but always asks the user to confirm.

## What This Does NOT Include

- Custom user-defined profiles (can be added later)
- Per-sub-step mode overrides (phase-level is sufficient)
- Monorepo support (multiple profiles per workspace -- future feature)
- Migration of existing projects (if prd-config.json exists without profile field, everything defaults to current behavior)

## Notes

- **Website auto-release:** The Website profile sets `release.mode` to `auto` (deploy-on-push, no gate). This is intentional for marketing sites but may surprise users of documentation sites that serve as critical references. The profile description makes this explicit.
- **Changing profiles mid-project:** Changing the `profile` field in `prd-config.json` takes effect immediately. No migration is needed -- the profile only affects runtime behavior of commands and hooks, not stored artifacts.
