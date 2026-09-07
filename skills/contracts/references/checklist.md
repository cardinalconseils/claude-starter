# Contract Review Checklist

The reviewer runs this against any MSA, SOW, NDA, or vendor agreement — ours or the
other side's. Each item is reported as **holds**, **deviates** (quote, position, suggested
language), or **missing**. Red lines are findings in full prose, never caveman. The
reviewer does not edit the contract; the writer or counsel does.

## Parties and basics

- [ ] Legal names and addresses of both parties match their registration (NEQ / business number where shown)
- [ ] Effective date, term, and which document prevails on conflict are stated
- [ ] Signatories have authority (title shown); electronic signature clause present
- [ ] Language: both versions present, or the English-only election is recorded expressly in the signature block (Quebec)

## Liability ceilings

- [ ] Cap on each party's total liability: our position is fees paid in the preceding 12 months (MSA) or the SOW value (SOW)
- [ ] Exclusion of indirect, consequential, punitive damages and lost profits
- [ ] Carve-outs from the cap limited to: confidentiality breach, wilful misconduct or gross negligence, IP indemnity
- **Red line**: an uncapped liability on us, or a cap that covers the other side only
- **Red line**: liability for AI outputs used without the human review the SOW requires

## IP — assignment vs licence

- [ ] Deliverables assigned to the client **on full payment**, not on creation
- [ ] Provider Materials (pre-existing code, prompts, agent frameworks, tools, templates, generic components) excluded from the assignment and licensed perpetually, non-exclusively
- [ ] Third-party model outputs and weights governed by the provider's terms, named in the SOW
- [ ] Moral rights waiver present (Canada does not allow assignment of moral rights, only waiver)
- [ ] Open-source components and their licences identified where a deliverable includes them
- **Red line**: assignment of Provider Materials, or a licence-back that is revocable or exclusive
- **Red line**: work-for-hire language without the payment condition

## Personal information and data residency

- [ ] Roles clear: client is responsible for consent and lawful basis; provider processes on documented instructions
- [ ] Law 25 and PIPEDA obligations referenced; confidentiality-incident notice period stated (48 hours is our default)
- [ ] Hosting location and residency stated; transfers outside Quebec conditioned on the Law 25 assessment
- [ ] Sub-processors listed (every provider that touches the data, model APIs included)
- [ ] Retention and deletion or return at end of engagement
- [ ] No clause permitting the other side (or their vendor) to train models on our data or our client's data without consent
- [ ] Run `skills/compliance/references/canada.md` on any clause touching personal information or automated decisions
- **Red line**: an obligation on us to guarantee compliance for data the client collected

## Termination

- [ ] Convenience termination for both parties with notice (30 days is our position)
- [ ] Cause termination with a cure period (10 days)
- [ ] Payment for work performed and non-cancellable costs on termination
- [ ] Survival clause lists confidentiality, IP (paid deliverables), liability, indemnity, non-solicit
- [ ] Transition assistance, if any, is paid work with a defined duration
- **Red line**: termination for convenience for the client only, or forfeiture of fees for work delivered

## Payment terms

- [ ] Fees, currency, pricing model, and billing schedule stated and match the SOW and the finops pricing floor
- [ ] Payment term (net 30 default); late interest rate; suspension right after 15 days overdue with notice
- [ ] Taxes extra (GST/HST, QST as applicable); pass-through costs at cost, no markup unless agreed
- [ ] Acceptance window bounded (10 business days) so invoices are not blocked by silence
- [ ] Change-order process before out-of-scope work begins
- **Red line**: payment contingent on the client's downstream success, or set-off rights against unrelated amounts
- **Red line**: "pay when paid" or open-ended acceptance

## Non-solicit and restrictive covenants

- [ ] Mutual non-solicit of personnel and contractors, 12 months, general advertisements excluded
- [ ] No non-compete on us (limited enforceability in Canada and not a position we accept)
- [ ] No exclusivity unless separately priced
- **Red line**: a non-compete, or a non-solicit of our *clients*

## Confidentiality

- [ ] Definition covers prompts, model configurations, evaluation data, and personal information
- [ ] Standard exclusions present; compelled-disclosure carve-out with notice
- [ ] Survival: 5 years, indefinite for trade secrets and personal information
- [ ] No-AI-training clause: neither side inputs the other's information into systems that retain or train on inputs without consent

## AI-specific

- [ ] Models and providers named; where they are hosted
- [ ] Human-review points named for high-impact decisions
- [ ] Evaluation obligation and thresholds referenced (the evals the tester runs)
- [ ] Disclaimer that outputs are probabilistic and the client owns decisions made with them
- [ ] Who pays model and hosting costs after handover

## Insurance and indemnity

- [ ] IP infringement indemnity from us limited to Canadian rights, excluding client materials and third-party outputs, with notice and control of defence
- [ ] Client indemnity for its data, content, and instructions
- [ ] Any insurance requirement matches a policy the agency actually holds (ask the owner; never assume)

## Close

Every review ends with: *This review checks the agreement against the agency's standard
positions. It is not legal advice. Have counsel review before signature.*
