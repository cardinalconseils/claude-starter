# Step 0: Initialize Release

<context>
Phase: Release (Phase 5)
Requires: Phase reviewed (phase_status = "reviewed")
Produces: Phase mode set, progress banner displayed, preflight passed
</context>

## Load Phase Mode

Read `.prd/prd-config.json` — extract `phases.release.mode`.
If not set or file missing, default to `interactive`.
Set PHASE_MODE = the extracted value.

**Mode behavior for this phase:**
- `interactive` → Execute all steps as written. Pause at each environment gate ([5a] Dev, [5b] Staging, [5c] RC, [5d] Prod).
- `auto` → Execute all environment promotions without pausing. Only stop on deployment failures.
- `gated` → Execute steps like auto, but pause after [5d] Production deploy and ask: "Production deploy complete. Verify and finalize? (Yes / Rollback)"

## Auto Mode Tip

```
💡 Release runs many permission-triggering operations. Enable Auto mode (Shift+Tab → "auto")
```

## Display Progress Banner

Display the progress banner from `_shared.md`.

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.release.started" "{NN}-{name}" "Release phase started"`

## Preflight Checks

**1a. Project Health:**
```
Skill(skill="doctor")
```
If health score < 50 → warn and ask whether to proceed.
Skip if `--skip-doctor` flag.

**1b. Verification status:**
Read VERIFICATION.md — confirm PASS verdict.

**1c. Working tree:**
```bash
git status --short
```

**1d. Dependencies:**
```bash
if [ -f "package.json" ]; then
  npm install && npm run build
elif [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
fi
```
If build fails → stop.

**1e. Remote + gh CLI:**
```bash
git remote -v | head -2
which gh && gh auth status 2>&1
```
