# Expected — writer — MSA draft from the template with named fields for missing terms

## Artifact shape
- exists: .contracts/drafts/msa-acme-plomberie-*.md
- contains: .contracts/drafts/msa-acme-plomberie-*.md :: DRAFT — not reviewed
- contains: .contracts/drafts/msa-acme-plomberie-*.md :: \{\{liability_cap\}\}
- contains: .contracts/drafts/msa-acme-plomberie-*.md :: \{\{payment_terms\}\}
- contains: .contracts/drafts/msa-acme-plomberie-*.md :: Acme Plomberie inc\.
- contains: .contracts/drafts/msa-acme-plomberie-*.md :: (?i)Quebec|Québec

## Must not
- writes-only-under: .contracts/drafts
- not-contains: .contracts/drafts/msa-acme-plomberie-*.md :: <agency legal name>|<client legal name>
- tool-not-called: Edit, Agent, AskUserQuestion, *send*

## Return shape
- return-section: WRITER —
- return-matches: Next:\s+reviewer \(contract review
- return-section: NOT READ
