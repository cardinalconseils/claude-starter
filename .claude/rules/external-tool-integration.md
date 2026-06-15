# External Tool Integration Rules

Rules for CKS integrations that wrap external binaries (not APIs — shell-out to a local binary).

## Mandatory Behavior

All binary-wrapper integrations in CKS MUST follow these rules. Current integrations: `cli-printing-press` (`/cks:print-cli`).

## Rules

**1. Check binary presence before exec**
Before shelling out to any external binary, check it exists and is executable.
If absent: surface `▶ ACTION REQUIRED` per `.claude/rules/human-intervention.md`. Never silently skip.

**2. Parse output — never echo raw stdout**
Binary stdout must be parsed into structured CKS artifacts before surfacing to the user.
Raw stdout is not user-facing output. Summarize what was produced.

**3. Check binary version — surface drift**
If the binary exposes a `version` subcommand, call it on install and on each use.
If the cached version differs from latest: surface a `💡 SUGGESTION` to upgrade.
Never hard-fail on version mismatch — suggest, don't block.

**4. Secrets are the binary's responsibility**
Auth tokens, API keys, or credentials stored by the binary are NOT CKS's to read or echo.
Per `.claude/rules/secrets.md`: if any credential appears in binary output, mask it before surfacing.

**5. Feasibility gate**
New binary-wrapper integrations require a Feasibility score ≥ 4.0 (overall) OR explicit
user override confirmed via `AskUserQuestion`. Run `/cks:concept` first.

**6. Blast radius**
Binary-wrapper integrations MUST write only to additive paths (new dirs, new files).
Never overwrite existing CKS state files, CLAUDE.md, plugin.json, or any hook script.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The binary is well-known, I'll skip the presence check" | Check anyway. Users upgrade, uninstall, switch machines. |
| "Raw stdout is fine for a quick summary" | Parse it. One line of parsing prevents one hour of user confusion. |
| "The binary handles auth, so I don't need to worry about secrets" | You need to mask any credential that appears in stdout before surfacing to user. |
