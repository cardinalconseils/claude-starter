# CKS Version Changes — Migration Reference

## How to Use This File

When migrating a project, find the project's current version (from `.prd/.cks-version` or `0.0.0` if missing).
Apply all changes from that version forward to the current plugin version.

---

## v0.0.0 → v4.0.0 (Pre-CKS to v4 Architecture)

Projects that existed before the migration system. These have `.prd/` but no `.cks-version` stamp.

### Structural changes:
- **Create** `.prd/.cks-version` (version stamp file)
- **Create** `.prd/logs/` directory if missing
- **Create** `.prd/phases/` directory if missing
- **Create** `.learnings/` directory if missing

### PRD-STATE.md field additions:
- **Add** `Iteration Count: 0` if field missing
- **Add** `Iteration Reason: —` if field missing
- **Add** `Secrets Tracking: not scanned` if field missing

### Config backfill:
- **Create** `.prd/prd-config.json` with defaults if missing:
  ```json
  {
    "versioning": { "enabled": true, "strategy": "auto-patch", "changelog": true },
    "profile": "default",
    "migrated_from": "pre-4.0"
  }
  ```

### Log initialization:
- **Create** `.prd/logs/lifecycle.jsonl` if missing, with migration event entry

---

## v4.0.0 → v4.2.0 (Directory Expansion)

### Structural changes:
- **Create** `.monetize/phases/` directory if missing
- **Create** `.context/` directory if missing

### Gitignore updates:
- **Add** `.prd/logs/.current_session_id` to `.gitignore` if not already present

---

## v4.2.0 → v4.7.0 (Karpathy Coding Guardrails)

**CLAUDE.md is never modified by this migration.** Only a new rules file is created.

### Rule file backfill:
- **Create** `.claude/rules/karpathy.md` if missing, with the following content:

```markdown
# Coding Behavior Rules

Four principles that address the most common LLM coding failure modes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

Before implementing anything non-trivial:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

Test: Every changed line should trace directly to the user's request.

## 4. Define Success, Then Verify

Before starting non-trivial work, transform the task into a verifiable goal:

\`\`\`
Task: "fix the bug"
→ Success: test that reproduces the bug passes; no other tests break
\`\`\`

For multi-step tasks, state a brief plan with a verify step for each:
\`\`\`
1. [Step] → verify: [check]
2. [Step] → verify: [check]
\`\`\`

Then loop until every verify step produces evidence. "Seems right" is not done.
```

---

## v5.0.0 → v5.0.14 (Extended Bootstrap Guardrails)

**CLAUDE.md is never modified by this migration.** Only new rule files are created if missing.

### Rule file backfill:

Check for each file and create if missing:

- **Create** `.claude/rules/human-intervention.md` if missing
- **Create** `.claude/rules/output-voice.md` if missing
- **Create** `.claude/rules/verification.md` if missing
- **Create** `.claude/rules/engineering-discipline.md` if missing

**Content for `.claude/rules/human-intervention.md`:**

```markdown
# Human Intervention Rules

Three mandatory formats for any message requiring human attention. Use the correct format — never use plain prose for these situations.

---

## 1. Action Required

Use when the user **must** run a terminal command or perform a manual step Claude cannot do.

\`\`\`
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    [exact command or step]
Why:    [one-line reason]
Then:   [what to tell Claude or do next, or "continue"]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
\`\`\`

Triggers: interactive login (`gcloud auth login`, `gh auth login`), installing a tool, opening a URL to authenticate, copying an API key, starting a local server.

Rules:
- `Run:` field must be copy-pasteable — no placeholders like `<your-value>`
- `Then:` must tell the user exactly what to do or say next — never leave them guessing
- For multi-step sequences: one block per step, in order

---

## 2. Decision Required

Use when Claude **cannot proceed** without the user choosing an option.

\`\`\`
─────────────────────────────────────────────────
❓ DECISION REQUIRED
─────────────────────────────────────────────────
[One sentence describing what needs to be decided and why it matters]

  1. [Option A] — [one-line consequence]
  2. [Option B] — [one-line consequence]
  3. [Option C] — [one-line consequence]

Reply with the number or describe what you want.
─────────────────────────────────────────────────
\`\`\`

Triggers: architectural choice with real trade-offs, ambiguous user intent where guessing wrong wastes work, explicit user decision points in a lifecycle (e.g., "release or iterate?").

Rules:
- Maximum 4 options — if more exist, pre-filter to the realistic ones
- Always include a free-text escape ("describe what you want")
- Never ask for a decision that Claude can reasonably decide itself

---

## 3. Suggestion

Use for optional recommendations the user can ignore without breaking anything.

\`\`\`
· · · · · · · · · · · · · · · · · · · · · · · ·
💡 SUGGESTION
· · · · · · · · · · · · · · · · · · · · · · · ·
[The suggestion, 1–3 lines]
· · · · · · · · · · · · · · · · · · · · · · · ·
\`\`\`

Triggers: a next step the user might not have thought of, a better approach to what they just did, a follow-up worth scheduling.

Rules:
- Never use this format for blocking situations — use Action Required or Decision Required instead
- One suggestion per block — don't stack multiple inside a single box
- If the suggestion requires a command, include it; but it's optional, so no "Then:" field needed

---

## Visual Hierarchy Summary

| Format | Border | Emoji | Blocking? |
|--------|--------|-------|-----------|
| Destructive Action | `━━━` | ⛔ | Yes — user must confirm |
| Action Required | `━━━` | ▶ | Yes — Claude is waiting |
| Decision Required | `───` | ❓ | Yes — Claude is blocked |
| Suggestion | `· · ·` | 💡 | No — optional |

Heavy borders (`━━━`) = Claude is stopped. Light borders (`───`, `· · ·`) = Claude can continue.
```

**Content for `.claude/rules/output-voice.md`:**

```markdown
# Output Voice Rules

CKS default voice is **caveman speak**. Compress prose. Cut filler. Keep technical truth.

Motto: **why use many token when few do trick. brain still big. mouth small.**

## Default ON

- Every CKS agent, command, and orchestrator reply uses caveman `full` level by default
- Skill at `skills/caveman/SKILL.md` defines levels (`lite` / `full` / `ultra` / `wenyan`) and rules
- Agent at `agents/caveman-speaker.md` handles explicit compression jobs
- Toggle via `/cks:caveman on|off|status` — writes a flag file at `.cks/caveman-disabled` when off

## Auto-Clarity Override (ALWAYS wins over caveman)

Caveman MUST drop to normal prose for any of these. No exceptions.

- `⛔ DESTRUCTIVE ACTION` block — see `.claude/rules/destructive-ops.md`
- `▶ ACTION REQUIRED` block — see `.claude/rules/human-intervention.md`
- `❓ DECISION REQUIRED` block — see `.claude/rules/human-intervention.md`
- `💡 SUGGESTION` block — see `.claude/rules/human-intervention.md`
- Security findings — severity, scope, remediation must stay full prose
- PRD Phase 1 discovery questions — clarity wins, see `.claude/rules/ideation.md`
- First-time onboarding (`/cks:bootstrap`, `/cks:adopt`, `/cks:kickstart` intake)
- Quoted error messages from tools — copy verbatim
- Legal, license, or compliance text
- Verbatim user quotes when paraphrasing would distort intent

When in doubt, clarity wins. Caveman serve user. User no understand = caveman fail.

## Preserve Verbatim Inside Caveman

Even when caveman is on, never compress:

- Code blocks, file paths, function names, command names, API endpoints, URLs
- Numeric values, file:line citations, version numbers, hashes
- Tool output, command output, log lines

## Opt-Out Mechanism

User can disable per-project by creating `.cks/caveman-disabled` (any contents). The flag is checked by `hooks/handlers/session-start.sh` and surfaced in the session banner. `/cks:caveman off` creates the flag; `/cks:caveman on` removes it.

## Why Default On

- CKS workflows produce verbose logs (PRDs, sprint reports, DEVLOGs, retros) — compression has compounding value
- Token budget matters at scale across the 5-phase lifecycle
- Auto-clarity overrides guarantee safety-critical content stays full prose
- Aesthetic matches CKS brand voice — `🪨 Caveman Mode` is a first-class CKS concept
```

**Content for `.claude/rules/verification.md`:**

```markdown
# Verification Before Completion Rules

## Mandatory Behavior

Claude MUST NOT declare work "done", "complete", "shipped", "ready", or run any
`git commit` without first running the maturity-appropriate verification set
and showing the evidence inline.

## Trigger Points

The rule fires before any of these:

- Saying "done", "complete", "shipped", "ready", "finished", "all set", "good to go"
- Any `git commit` invocation
- Opening a pull request
- Closing a `/cks:*` phase or task
- Reporting a feature as implemented in a status update

## Minimum Verification Set by Maturity Stage

Read `PROJECT.md` to determine maturity stage. If unspecified, infer from
presence of test infra (no tests configured → Prototype; tests + CI → Pilot+).

### Prototype Stage

- **Required:** Happy path manually verified
- **Evidence:** One of:
  - Command output showing the feature ran successfully
  - Screenshot path or file reference
  - Plain-English description of what was clicked / called / observed

### Pilot Stage

- **Required:** Build passes + happy path manually verified + at least one
  automated test for the new code (smoke or unit)
- **Evidence:** Build command output, test command output, manual check note

### Candidate / Production Stage

- **Required:** Build passes + full test suite passes + key user paths checked
  (manual or scripted) + lint / typecheck pass
- **Evidence:** All command outputs inline, screenshots for UI changes,
  citation of the test files exercised

## What Counts as Evidence

Evidence MUST be shown inline in the response that claims "done". Acceptable forms:

- **Test pass:** the exact command and its output (last ~20 lines is fine)
- **Build pass:** the exact build command and its terminal output
- **Manual check:** a one-line description with file paths, URLs, or screenshot
  references
- **Lint / typecheck:** command + output

Insufficient evidence (never accept):

- "Looks good"
- "Should work"
- "Tested mentally"
- "Same pattern as before so it should be fine"

## Maturity Exception

Prototype stage may substitute "happy path manually verified" for the full
test set. Claude MUST still describe what was verified — vague claims do not
satisfy the rule, even at Prototype.

If the project has no test command configured AND no manual check is possible,
Claude MUST say so explicitly:

> "No tests configured and no observable behavior to check manually.
>  Maturity: Prototype. Proceeding without runtime verification — flagging
>  this gap as a candidate learning."

This is the ONLY acceptable path past the rule without evidence, and the
learning must be added to `.learnings/gotchas.md`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The change is too small to test" | Small changes break things just as often. The cost of running the test is seconds; the cost of a hotfix is hours. |
| "Tests pass in CI, that's enough" | CI runs after commit. The rule fires before commit. Local evidence is required up front. |
| "I'll fix it forward if it breaks" | The 4–8 hotfix-per-feature pattern this rule exists to stop. Verify first. |
| "It worked when I wrote it" | "Wrote it" ≠ "verified it". Run the command and show the output. |
| "User said move fast" | Speed without verification is rework. Verification is the fast path. |
| "Prototype stage means no testing" | Prototype means lighter testing. "Happy path manually verified" is still required and still has evidence. |

## Required Behavior

1. Before saying done / committing, identify the maturity stage
2. Run the maturity-appropriate verification set
3. Show the evidence inline (command output, screenshot path, manual check note)
4. Only then proceed with the "done" claim, commit, or PR

If verification fails, state the failure plainly, do not commit, and ask the
user how to proceed.
```

**Content for `.claude/rules/engineering-discipline.md`:**

```markdown
# Engineering Discipline Rules

Three rules that govern how Claude approaches every change. No exceptions based on task size.

---

## 1. Simplicity First

Every change must be as simple as possible while solving the actual problem.

- A one-line fix beats a clever rewrite
- If two approaches solve the problem equally, pick the one with fewer moving parts
- No abstractions for hypothetical future requirements
- No helper functions for code that appears once
- Three similar lines is better than a premature abstraction

**Test:** Would a junior engineer understand this change in 30 seconds? If not, simplify.

---

## 2. Minimal Impact

Touch only what the task requires. Nothing else.

- Do not refactor code adjacent to the change unless explicitly asked
- Do not rename variables, reformat files, or "clean up" unrelated sections
- Do not add error handling for scenarios outside the reported bug
- If a file must be opened to make the change, only edit the relevant lines

**Test:** Run `git diff` — every changed line must map directly to the task description.

---

## 3. Root Cause Only — No Lazy Fixes

Find the actual cause. Fix that. Never paper over symptoms.

- A symptom fix that masks the root cause is not a fix — it is future debt
- If a bug report points to a log line or stack trace, trace it to origin before touching code
- If a workaround feels necessary, state why the proper fix is blocked and get confirmation
- Never add a try/catch, default value, or early return to silence an error without understanding it

**Test:** Can you explain in one sentence WHY the fix works, not just WHAT it does?

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This refactor is small, I'll do it while I'm in here" | Unrequested changes introduce unrequested risk. Scope creep is a bug. |
| "The proper fix is too complex right now" | Say so explicitly and get confirmation. Don't silently ship the band-aid. |
| "Adding a default value is harmless" | Silent defaults hide bad states. The next engineer will not know why it's there. |
| "I'll simplify it later" | You won't. Simple now. |
| "A wrapper is cleaner than repeating the logic" | Wrappers hide intent. Repeat the two lines. |
| "The bug is in the log, not in the cause" | Fix the cause. The log is evidence, not the patient. |
```

---

## Adding Future Migrations

When CKS introduces breaking changes to state file structure, add a new section here:

```markdown
## v4.7.0 → v5.0.0 (Attractor Spine + v5 Release)

### Structural changes:
- `agents/sprint-runner.md` renamed to `agents/attractor-runner.md`
- `commands/sprint-close.md` deleted — Release node handles session close
- `board/public/` removed — board UI decommissioned; replaced by CKS Console
- `tools/webhook-listener.js` added — bidirectional Kanban automation
- `tools/github-project-sync.js` added — GitHub Projects GraphQL wrapper
- `scripts/migrate-v4-to-v5.sh` added — v4→v5 migration helper
- `docs/AUTOMATION.md` added — webhook automation guide
- `commands/setup-webhooks.md` added — GitHub Project onboarding command
- `commands/cks-wiki.md` added — wiki read/write command
- `agents/wiki.md` added — wiki agent
- `skills/github-project-setup/SKILL.md` added — Kanban setup skill
- `skills/parallel-dispatch/SKILL.md` added — parallel agent dispatch skill

### Field changes:
- `.prd/PRD-STATE.md` extended with attractor schema fields: `attractor_mode`, `phase_item_id`, `worktree_summaries`, `last_parallel_merge`

### Config changes:
- `plugin.json` gains `attractor_mode: true` (was `false` until Phase 8)
- `plugin.json` gains `webhook_enabled` and `github_project` fields
- `.claude/settings.json` in target projects: `attractor_mode` set to `true` by migration script

### Migration notes:
- Run `scripts/migrate-v4-to-v5.sh` from target project root (handled automatically by `/cks:migrate`)
- v4 behavior preserved via `attractor_mode: false` in `.claude/settings.json`
- All 73 agents and 45 skills preserved — no behavioral changes

---

## vX.Y.Z → vA.B.C (Short Description)

### Structural changes:
- What directories are created/moved

### Field changes:
- What fields are added/renamed/removed in state files

### Config changes:
- What changes to prd-config.json or other config files
```

The migrate agent reads this file to know exactly what to check and apply.
