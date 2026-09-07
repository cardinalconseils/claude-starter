# Workflow: Advise — Stripe integration design and review

Guide a production-grade Stripe integration: secure, idempotent, resilient. Advice and
design here; code changes are the builder's, fixes the debugger's.

## 0. Grep checklist first

1. Read `references/checklist.yaml`.
2. `{src_dir}` from the brief, else ask (default `src/`).
3. Run each `grep_cmd` with `{src_dir}` substituted.
4. Report: CRITICAL failures as blocking findings, HIGH failures as warnings; label every
   item "pattern detected" / "pattern not found" — never "confirmed correct" or
   "confirmed vulnerable".
5. Diagnose with the results as context.

## 1. Diagnose

Understand what is being built or what broke. One focused question via
`AskUserQuestion` if intent is unclear.

## 2. Pick the Stripe product

Checkout vs Elements, Billing vs manual subscriptions, Connect for platforms — the
decision table in `SKILL.md`. Deep dives: `idempotency.md`, `webhooks.md`,
`subscription-billing.md`, `pci-compliance.md`.

## 3. Show concrete code

Runnable examples for the project's stack — never a description of what the code should do.

## 4. Flag risks

Idempotency gaps, PCI scope creep, missing webhook handling — say so plainly, in full
prose (security findings are never compressed).

## 5. Mandatory checks before approving any implementation

- [ ] Idempotency keys present, written to the DB before the processor call
- [ ] Payment state updated via webhook, not client redirect
- [ ] Webhook signatures verified against the raw body
- [ ] Money stored as integers
- [ ] No raw card data on the server (SAQ A or SAQ A-EP scope)

End with the verification checklist from `SKILL.md`.

## Out of scope

General frontend questions, ERP/ledger integration, crypto payments — say so and stop.
