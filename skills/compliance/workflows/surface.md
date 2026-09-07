# Workflow: Compliance Surface

Phase 1 scan and Phase 5 validate for regulatory obligations. Ported from the
`compliance-advisor` agent. Run by the reviewer role (Canadian compliance mode reads
`references/canada.md` alongside this; the reviewer has no write tool, so
`COMPLIANCE-SURFACE.md` content is returned for the strategist, who owns `.prd/` discovery
artifacts, to write).

## Mode: scan (Phase 1)

1. Read CONTEXT.md (`.prd/phases/{NN}-*/CONTEXT.md` or the path in the prompt)
2. Grep for signals — never conclude "no compliance" without the grep:
   - PII: user, email, account, profile, personal info, address, phone
   - Payment: payment, charge, checkout, credit card, stripe, pay
   - Health: health, medical, fitness, diagnosis, medication, BMI, wellness
   - B2B/Enterprise: enterprise, SOC 2, audit, B2B, customer compliance, SLA
   - EU/GDPR: GDPR, EU, Europe, CCPA, privacy
   - Canada: Canadian users, Québec, PIPEDA, Law 25, AIDA, data residency (`references/canada.md`)
3. No signals → "No compliance surface detected. No COMPLIANCE-SURFACE.md needed." Stop.
4. Signals → draft `.prd/COMPLIANCE-SURFACE.md`:

```
## Detected Compliance Surface

### Signals Found
- {quoted CONTEXT.md line}

### Applicable Regulations
| Regulation | Trigger | Required Artifacts |

### Artifact Status
| Artifact | Status (required/recommended) | Deferred? | Notes |
```

5. For each artifact the user wants to defer, capture name + reason + acceptance
   (`AskUserQuestion`); no silent deferrals. Vendor scope counts — Stripe, Auth0, and other
   processors add obligations (e.g. a BAA for HIPAA).

## Mode: validate (Phase 5)

1. Read `.prd/COMPLIANCE-SURFACE.md`; absent → skip validation
2. Per required artifact: exists as a file in `.prd/` or the project root, or is referenced
   in CONTEXT.md, or is explicitly deferred with a reason
3. Output:

```
## Compliance Validation
✅ {artifact} — found at {path}
⚠️ {artifact} — recommended (deferred for v2)
❌ {artifact} — MISSING (BLOCKING)

### Verdict
RELEASE BLOCKED: required artifact "{name}" not found. Remediation: {what to add}.
```

Block only on required, non-deferred artifacts; recommend the rest.

## Constraints

- Surface detection, not a legal audit — recommend counsel for jurisdiction questions
- Never give legal advice
- Deferral must be explicit
