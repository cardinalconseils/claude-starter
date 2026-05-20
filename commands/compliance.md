---
description: "Compliance surface scan — detect GDPR, PCI, HIPAA, SOC 2 obligations from feature context"
argument-hint: "[--scan | --validate | --status]"
allowed-tools:
  - Read
  - Agent
---

# /cks:compliance — Compliance Surface Scan

Dispatch the **compliance-advisor** agent to detect regulatory obligations early in the feature lifecycle.

## Mode Detection

Parse `$ARGUMENTS`:

| Argument | Mode | Behavior |
|----------|------|----------|
| `--scan` or no args | Phase 1 Scan | Scan CONTEXT.md for GDPR, PCI, HIPAA, SOC 2 signals → produce COMPLIANCE-SURFACE.md |
| `--validate` | Phase 5 Validate | Check required artifacts before release |
| `--status` | Status | Read COMPLIANCE-SURFACE.md and show current status |

## Dispatch

```
Agent(subagent_type="cks:compliance-advisor", prompt="Phase: {detected_phase}. Mode: {detected_mode}. Project root: {cwd}. {mode_instructions}")
```

For `--scan`: "Scan CONTEXT.md for regulatory signals (PII, payment, health, B2B/enterprise). If signals found, produce COMPLIANCE-SURFACE.md. Ask user to accept or defer required artifacts."

For `--validate`: "Read COMPLIANCE-SURFACE.md. Verify all required (non-deferred) artifacts exist. Block release if any are missing."

For `--status`: Read and display the current COMPLIANCE-SURFACE.md status.

## Quick Reference

```
/cks:compliance              → Scan CONTEXT.md for compliance signals
/cks:compliance --scan       → Same as above (explicit)
/cks:compliance --validate   → Validate artifacts before release
/cks:compliance --status     → Show current artifact status
```

The compliance-advisor agent handles: signal detection, regulation mapping, artifact tracking, deferral capture, and release blocking.
