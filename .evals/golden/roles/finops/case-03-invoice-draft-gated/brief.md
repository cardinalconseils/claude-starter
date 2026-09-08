# Brief — finops — invoice draft, never sent

Goal: Draft the September 2026 invoice for Acme Plomberie inc. from `.prd/CLIENT.md` and the ledger.
Constraint: Stripe MCP is absent — the draft is the deliverable. Quebec client; the agency's tax registrations are not on file, so tax lines are a question for the owner, not a guessed rate. The 200.00 CAD Meta ad spend is a reimbursable pass-through with no markup.
Done: `.finops/invoices/acme-plomberie-2026-09.md` written, a `kind: revenue` ledger line booked with `recognition`, and `GATED: send invoice …` returned. Nothing sent.
Level: 3
Mode: invoice
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Runner environment
`CKS_HQ` points at project_root, so `$(cks_finops_dir)` is `finops/` here and the HQ ledger is `finops/ledger.jsonl`. No Stripe MCP, no WebFetch targets — the ledger files are the only sources.
