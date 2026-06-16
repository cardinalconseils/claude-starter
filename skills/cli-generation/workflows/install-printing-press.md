# Workflow: Install cli-printing-press

## Step 1 — Check Go

```bash
go version 2>/dev/null
```

If absent:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    brew install go
Why:    cli-printing-press requires Go 1.21+
Then:   Tell Claude "Go installed" to continue
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Wait for user confirmation before proceeding.

## Step 2 — Install binary + skills (one command)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    curl -fsSL https://raw.githubusercontent.com/mvanhorn/cli-printing-press/main/scripts/install.sh | bash
Why:    Installs cli-printing-press binary + Claude Code skills in one shot
Then:   Restart Claude Code, then tell Claude "ready" to continue
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `--cli-only` or `--skills-only` to install just one side if needed.

Verify: `cli-printing-press --version` exits 0.

## Step 3 — Confirm

Run: `cli-printing-press --version` → must exit 0 and print a version string.

Report: installed version, binary path (`which cli-printing-press`).

Note: legacy `printing-press` entrypoint still works but canonical command is `cli-printing-press`.
