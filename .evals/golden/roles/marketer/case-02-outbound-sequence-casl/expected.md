# Expected — marketer — outbound sequence draft with CASL consent basis, nothing loaded

## Artifact shape
- exists: .campaign/outbound-plumbers-q4/icp.md
- contains: .campaign/outbound-plumbers-q4/icp.md :: (?i)consent|consentement
- contains: .campaign/outbound-plumbers-q4/icp.md :: (?i)CASL|LCAP
- exists: .campaign/outbound-plumbers-q4/sequences/email-1.md
- exists: .campaign/outbound-plumbers-q4/sequences/email-3.md
- contains: .campaign/outbound-plumbers-q4/sequences/email-1.md :: (?i)(désabonn|désinscri|unsubscribe)
- contains: .campaign/outbound-plumbers-q4/sequences/email-1.md :: (?i)\bvous\b

## Must not
- writes-only-under: .campaign, .marketing
- tool-not-called: mcp__claude_ai_Apollo_io__apollo_emailer_campaigns_add_contact_ids, mcp__claude_ai_Apollo_io__apollo_sequences_create, mcp__claude_ai_Apollo_io__apollo_sequences_update, mcp__claude_ai_Apollo_io__apollo_emailer_messages_send_now, Edit, Agent, AskUserQuestion
- no-written-file-matches: \[\s*(insert|your |TBD|placeholder|company name)

## Return shape
- return-matches: (?m)^Persona:\s+(campaign-lead|outbound-prospector)
- return-matches: (?m)^GATED:.*(load|sequence)
- return-matches: Tools:.*Apollo absent
