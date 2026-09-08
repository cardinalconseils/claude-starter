# Canada — Privacy and AI Compliance Reference

Checklist the reviewer runs on any feature, contract clause, or deliverable that touches
personal information or an AI system serving people in Canada, with Quebec's stricter
regime called out. Surface detection and obligations, not legal advice; statutes change
— confirm current status with counsel before relying on any item marked *status*.

## Which law applies

| Situation | Regime |
|---|---|
| Private-sector organisation collecting personal information in the course of commercial activity, anywhere in Canada | **PIPEDA** (federal), unless a province has substantially similar law |
| Organisation established in Quebec, or collecting from people in Quebec | **Quebec Law 25** (the *Act respecting the protection of personal information in the private sector*, as amended by Bill 64) — applies alongside PIPEDA and is stricter |
| Alberta or British Columbia private sector | provincial PIPA (substantially similar; not covered here) |
| Health information | provincial health-information statutes on top of the above |
| Commercial electronic messages | **CASL** — see `skills/marketing/personas/outbound-prospector.md` |
| AI system deployed in Canada | **AIDA** *(status: tabled as Part 3 of Bill C-27; the bill died on the order paper when Parliament was prorogued in January 2025 and had not been re-enacted at the time of writing — treat its obligations as the design baseline and check current federal status)*; Quebec Law 25's automated-decision rules already apply |

## PIPEDA — the ten fair information principles

- [ ] **Accountability** — a named person responsible for compliance; contracts flow obligations to processors
- [ ] **Identifying purposes** — purposes documented at or before collection
- [ ] **Consent** — meaningful, appropriate to sensitivity; express for sensitive data; withdrawable
- [ ] **Limiting collection** — only what the purpose needs
- [ ] **Limiting use, disclosure, retention** — no secondary use without consent; retention schedule with deletion
- [ ] **Accuracy** — kept accurate for the purpose, especially where decisions are made
- [ ] **Safeguards** — proportional to sensitivity: access control, encryption, logging
- [ ] **Openness** — privacy policy in plain language, readily available
- [ ] **Individual access** — people can see and correct their information
- [ ] **Challenging compliance** — a complaint path that works

Breach: a breach of security safeguards posing a **real risk of significant harm** must be
reported to the Privacy Commissioner and to affected individuals as soon as feasible, and a
record of every breach kept for 24 months.

## Quebec Law 25 — obligations the reviewer checks

- [ ] **Person in charge of the protection of personal information** — by default the person with the highest authority (the owner); delegation must be in writing; title and contact published on the website
- [ ] **Privacy policy** — published in clear, simple language; drafted for the audience (children where relevant)
- [ ] **Consent** — clear, free, informed, given for specific purposes, requested separately from other terms in plain language; express consent for sensitive information; a minor under 14 requires the parent's consent
- [ ] **Privacy by default** — the most protective settings on by default for any product or service offered to the public (no dark patterns to opt in)
- [ ] **Privacy impact assessment (PIA)** — required **before** any project to acquire, develop, or overhaul an information system or electronic service delivery involving personal information, and proportionate to sensitivity, purpose, and volume; document it in `.prd/COMPLIANCE-SURFACE.md` and keep the PIA with the phase artifacts
- [ ] **Cross-border** — before communicating personal information outside Quebec, a PIA that considers sensitivity, purpose, safeguards, and the legal framework of the destination; the transfer proceeds only if the assessment concludes the information would receive adequate protection, and a written agreement records the safeguards. US hosting is a transfer; name the region in the SOW's data clause
- [ ] **Automated decision-making** — when a decision is based **exclusively** on automated processing, inform the person at or before the decision, and on request tell them the personal information used, the reasons and principal factors, and their right to have it corrected and to make observations to a human who can review the decision. This is the rule that binds AI agents today
- [ ] **Profiling and tracking technology** — inform the person and offer the means to deactivate identification, location, or profiling functions before use
- [ ] **Confidentiality incidents** — keep a register; where the incident presents a **risk of serious injury**, notify the Commission d'accès à l'information (CAI) and the affected persons; consider notifying anyone who can reduce the risk
- [ ] **Data portability** — on request, computerised personal information collected from the person is provided in a structured, commonly used technological format
- [ ] **Retention and destruction** — destroy or anonymise (per the regulation's standard) when the purpose is fulfilled
- [ ] **De-identified data** — de-identification and anonymisation are distinct; anonymised data requires the prescribed process and cannot be used to re-identify
- [ ] **Penalties** — administrative monetary penalties up to $10M or 2% of worldwide turnover; penal fines up to $25M or 4%; a private right of action for injury

## AIDA-style obligations (design baseline)

- [ ] **High-impact assessment** — decide and record whether the system is high-impact (employment, credit, health, essential services, biometrics, content moderation at scale, law enforcement); the strategist or architect records the reasoning in the design docs
- [ ] **Risk measures** — identify, assess, and mitigate risks of harm and biased output; document the measures and monitor them after deployment
- [ ] **Transparency** — publish a plain-language description of the system's intended use, the kinds of output, and the mitigation measures
- [ ] **Record keeping** — training data provenance, evaluation results (`.evals/`), incidents
- [ ] **Serious-incident notification** — a material harm to health, safety, property, or rights is reported to the responsible authority when the regime is in force, and to the client under the SOW in any case
- [ ] **Human oversight** — the human-review points in the SOW exist in the product, not only on paper

## Data residency

No Canadian statute imposes a blanket residency requirement on private-sector data, but:

- Quebec Law 25's cross-border PIA makes hosting outside Quebec a documented decision, not a default
- Public bodies in Quebec and several provinces (e.g. BC and Nova Scotia for public-sector data) carry residency or notification rules — check when the client is a public body or a supplier to one
- Foreign-law access (the US CLOUD Act for data held by US providers) belongs in the PIA's legal-framework analysis; Canadian regions of major providers reduce latency and simplify the narrative but do not remove foreign-law reach on their own
- State the region in the SOW (`skills/contracts/templates/sow.md` §5) and in the MSA data clause; changes are change orders

## CASL — the outbound reviewer's five checks

- [ ] Consent basis recorded per segment (express; implied via existing business relationship; implied via conspicuous publication for role-relevant B2B addresses; referral for one message)
- [ ] Sender identification: legal name and mailing address in every message
- [ ] Working unsubscribe, honoured within 10 business days
- [ ] No false or misleading subject lines or content
- [ ] Records kept to prove consent; penalties up to $10M per violation for organisations

## Where to record findings

`.prd/COMPLIANCE-SURFACE.md` per `skills/compliance/SKILL.md`: for each obligation
above that applies, the required artifact (PIA, privacy policy, incident register, ADM
notice, transfer assessment, CASL consent record) and whether it is present, deferred with
reason, or missing. Missing required artifacts block release at Phase 5.
