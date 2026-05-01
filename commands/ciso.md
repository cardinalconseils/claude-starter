---
description: "Personal CISO — audit repos and infra for supply chain attacks, secrets exposure, RLS gaps, webhook exposure, and GitHub Actions hardening"
argument-hint: "[--repo <name> | --all | --threat <name> | --quick]"
allowed-tools:
  - Agent
---

# /cks:ciso — Personal CISO Audit

Dispatch the **ciso** agent with the current arguments.

```
Agent(subagent_type="cks:ciso", prompt="Run a CISO audit. Arguments: $ARGUMENTS. CWD: {cwd}. PMC's portfolio: PayFacto, Cardinal Conseils, ServiConnect. Stack: Railway, Supabase, n8n, GitHub, Telnyx, ElevenLabs, Deepgram, Stripe, AI APIs. Apply the full audit protocol from the ciso skill.")
```

## Quick Reference

```
/cks:ciso                         → interactive mode (ask which audit to run)
/cks:ciso --repo payfacto-api     → audit a single repo
/cks:ciso --all                   → full portfolio scan
/cks:ciso --quick                 → CRITICAL-class checks only (fastest)
/cks:ciso --threat shai-hulud     → check for Mini Shai-Hulud compromise indicator
/cks:ciso --threat axios          → check for compromised axios versions
/cks:ciso --threat rls            → Supabase RLS gaps on sensitive tables only
```

The ciso agent handles: supply chain audit, secret detection, GitHub Actions hardening, Supabase RLS validation, webhook exposure, MCP allowlist check, repo hygiene — graded report with exact fix commands, confirmation before applying.
