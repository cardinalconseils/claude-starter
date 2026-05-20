---
name: compliance
description: "Regulatory compliance surface detection — GDPR, PCI, HIPAA, SOC 2 triggers. Use when: planning features that touch PII, payments, health data, or B2B SaaS. Produces COMPLIANCE-SURFACE.md with regulations that apply and required artifacts."
allowed-tools: Read, Grep, Glob, Bash
---

# Compliance Surface Detection

## Overview

Domain expertise for detecting regulatory compliance obligations early in the feature lifecycle. This skill identifies WHICH regulations apply to your feature based on data sensitivity signals — NOT deep legal analysis. Surface detection prevents "we'll handle compliance later" debt.

Use this skill at Phase 1 (Discovery) and Phase 5 (Release) to catch compliance gates before building.

## When to Use

- Planning features that collect, store, or process user data
- Integrating payment processing or accepting credit cards
- Building health, medical, or fitness tracking features
- Selling to enterprise / B2B customers who require audit evidence
- Handling user accounts, authentication, or personal information
- Scanning existing features at release time

## When NOT to Use

- Infrastructure security (firewalls, network controls — see security-hardening)
- Deep legal interpretation or jurisdiction-specific advice (consult a lawyer)
- Penetration testing or active compliance audits (you need a QSA or assessor)

## Regulatory Triggers

| Data Signal | Regulation | Scope | Required Artifacts |
|---|---|---|---|
| PII collection, user accounts, email, EU users | GDPR | EU data subjects | Privacy policy, consent mechanism, data map, breach procedure, DPA template |
| Payment processing, credit card checkout, stored card data | PCI DSS | Any card data handling | Stripe-hosted checkout (SAQ A), no card storage, audit log, quarterly scan |
| Health data, medical records, diagnoses, fitness metrics | HIPAA | US-regulated healthcare | BAA with processor, access logs, encryption at rest, minimum necessary principle |
| B2B SaaS, enterprise customers, "SOC 2?" question | SOC 2 Type II | Enterprise sales | Security policies, access controls, incident response plan, annual audit timeline |

## Data Classification

- **Public**: marketing copy, published documentation, non-sensitive metadata
- **Internal**: configuration, build logs, deployment details, team-only docs
- **Confidential**: API keys, database credentials, private keys, encryption keys
- **Regulated**: user PII (names, emails, addresses), payment data, health records, any data covered by GDPR/HIPAA/PCI

## Required Artifacts by Regulation

| Regulation | Artifact | Purpose | Before Release? |
|---|---|---|---|
| GDPR | Privacy Policy | Transparency on data use | Required |
| GDPR | Consent Mechanism | Documented user opt-in | Required |
| GDPR | Data Map | What data, where stored, how long | Required |
| GDPR | Breach Procedure | Notification plan if compromised | Required |
| GDPR | DPA Template | Processor agreement if using vendors | Required (if using third-party services) |
| PCI DSS | Stripe Checkout Config | Hosted payment form (SAQ A scope) | Required |
| PCI DSS | No Raw Card Storage | Verify card data never touches your server | Required |
| PCI DSS | Audit Log | Payment processing audit trail | Required |
| HIPAA | Business Associate Agreement | Processor compliance attestation | Required |
| HIPAA | Access Logs | Who accessed health data, when, why | Required |
| HIPAA | Encryption at Rest | Health data encrypted in database | Required |
| SOC 2 Type II | Security Policy | Written controls and procedures | Required for enterprise sales |
| SOC 2 Type II | Access Control Matrix | Who has what permissions | Required |
| SOC 2 Type II | Incident Response Plan | How you respond to breaches | Required |

## Phase Gate Behavior

### Phase 1 (Discover)

- Scan CONTEXT.md for trigger signals (keywords: "PII", "user", "email", "health", "medical", "payment", "card", "enterprise", "SOC 2")
- If no signals found: output "No compliance surface detected. Proceeding."
- If signals found: produce `.prd/COMPLIANCE-SURFACE.md` with detected regulations and required artifacts
- User must accept all required artifacts or explicitly defer with stated reason (via AskUserQuestion)

### Phase 5 (Release)

- Read `.prd/COMPLIANCE-SURFACE.md` if it exists
- For each required artifact: verify it exists (as a file, link in CONTEXT.md, or explicit deferral)
- Blocking: required artifact missing AND not deferred → BLOCKS release
- Non-blocking: recommended artifacts → suggest completion but don't block

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll add GDPR later" | GDPR applies from first EU user collection. Retrofitting consent flows is 10x harder. Wire it at design time. |
| "We use Stripe, PCI doesn't apply to us" | PCI scope includes your checkout UX, webhook handling, and audit logging — not just card storage. You're in scope. |
| "We're not a healthcare company" | One health-data field (BMI, diagnosis, medication list) puts you in HIPAA scope. Data type, not industry, determines compliance. |
| "SOC 2 is for huge enterprises" | Enterprise sales stall at "do you have SOC 2?" — it's a sale blocker. Building it in is easier than retrofitting. |
| "Compliance is the legal team's job" | Compliance is an engineering requirement. Your code must enforce it. Legal drafts policy; you implement it. |

## Verification

- [ ] COMPLIANCE-SURFACE.md created (Phase 1) or validated (Phase 5)
- [ ] All trigger signals identified and documented
- [ ] Required artifacts list complete and accurate per regulation
- [ ] No artifacts marked "deferred" without explicit user acceptance and reason
- [ ] Blocking artifacts verified present before Phase 5 release gate
- [ ] User consulted on any regulatory scope questions (not decided silently)
