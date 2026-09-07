# Workflow: Compliance Surface — scan at Phase 1, validate at Phase 5

Identify which regulations apply to a feature and track the required artifacts through
the lifecycle. Surface detection, not legal audit; never legal advice.

## Mode: scan (Phase 1, or `/cks:compliance --scan`)

1. Read CONTEXT.md (`.prd/phases/{NN}-*/*CONTEXT.md`, or the path in the brief).
2. Grep for trigger signals (`SKILL.md` "Regulatory Triggers"):
   - PII: user, email, account, profile, personal info, address, phone
   - Payment: payment, charge, checkout, credit card, stripe, pay
   - Health: health, medical, fitness, diagnosis, medication, BMI, wellness
   - B2B/enterprise: enterprise, SOC 2, audit, B2B, customer compliance, SLA
   - Privacy regimes: GDPR, EU, Europe, CCPA, privacy, PIPEDA, Law 25, Quebec
3. No signals → "No compliance surface detected. No COMPLIANCE-SURFACE.md created." Stop.
4. Signals → write `.prd/COMPLIANCE-SURFACE.md`:

```markdown
## Detected Compliance Surface

### Signals Found
- {quoted CONTEXT.md line}

### Applicable Regulations
| Regulation | Trigger | Required Artifacts |
|---|---|---|

### Artifact Status
| Artifact | Status (required/recommended) | Deferred? | Notes |
|---|---|---|---|
```

5. For each artifact the user wants to defer, `AskUserQuestion` for the reason and the
   acceptance; record both. No silent deferrals.
6. Vendor scope: Stripe, Auth0, and other processors add obligations (a BAA for HIPAA,
   a DPA for GDPR). Say so in Notes.

## Mode: validate (Phase 5, or `/cks:compliance --validate`)

1. Read `.prd/COMPLIANCE-SURFACE.md`; absent → skip validation.
2. Per required artifact: exists as a file under `.prd/` or the project root, is referenced
   in CONTEXT.md, or is explicitly deferred with a reason.
3. Output:

```
## Compliance Validation
✅ {artifact} — found at {path}
⚠️ {artifact} — recommended (deferred for v2)
❌ {artifact} — MISSING (BLOCKING)

### Verdict
RELEASE BLOCKED: required artifact "{name}" not found. Remediation: {what to add where}.
```

Block only on required, non-deferred artifacts; recommend the rest.

## Constraints

- Read-only except `.prd/COMPLIANCE-SURFACE.md`; never create the artifacts themselves.
- Always recommend consulting a lawyer for jurisdiction-specific questions.
- Grep before concluding "no compliance"; never confuse recommended with required.
