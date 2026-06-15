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

## Step 2 — Install the binary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    curl -fsSL https://github.com/mvanhorn/cli-printing-press/releases/latest/download/install.sh | bash
Why:    Installs the printing-press binary
Then:   Tell Claude "binary installed" to continue
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Verify: `printing-press version` exits 0.

## Step 3 — Register the Claude skill

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ ACTION REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run:    npx -y skills@latest add printing-press
Why:    Registers the printing-press Claude skill globally
Then:   Tell Claude "skill registered" to continue
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Step 4 — Confirm

Run: `printing-press version` → must exit 0 and print a version string.

Report: installed version, binary path (`which printing-press`).
