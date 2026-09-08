# Brief — writer — MSA draft from the template with named fields for missing terms

Goal: Contract mode — MSA, language `en`, between Cardinal Conseils (Provider, Montréal) and Acme Plomberie inc. (Client, Laval), effective 2026-09-15.
Constraint: Fill the template from these terms only: Quebec governing law, data hosted in Canada, IP licence to the Client on payment with the Provider keeping pre-existing tools, 30-day termination for convenience. The liability cap and the payment terms were not supplied — leave them as named fields (`{{liability_cap}}`, `{{payment_terms}}`), never a guessed number. Header `DRAFT — not reviewed`.
Done: `.contracts/drafts/msa-acme-plomberie-2026-09-07.md` written and returned for the reviewer's contract review.
Level: 1
Mode: contracts
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)
