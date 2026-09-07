# Workflow: Legal Review — Canadian marketing, privacy, and contract risk checks

Internal risk assessment under Canadian law, not a substitute for licensed counsel.
Litigation, significant financial exposure, or a novel question → recommend external
counsel every time. Never apply US standards to Canadian operations.

Formal contract review against `skills/contracts/references/checklist.md` is the
reviewer's; Canadian regime detail (AIDA, PIPEDA, Law 25) is in `references/canada.md`.

## CASL check (every email or SMS campaign)

1. Identify the consent basis for every list segment — express vs implied, and when each
   applies.
2. Verify the unsubscribe mechanism is present, functional, and honored within 10 days.
3. Check sender identification in every message: business name + physical mailing address.
4. Record-keeping: can consent be proven if challenged? Name where the records live.

Penalties reach $1M per individual and $10M per organization — any potential violation
is escalated to the chief of staff immediately; never recommend proceeding.

## Campaign compliance check

1. Advertising claims → substantiation on file (Competition Act).
2. Testimonials and endorsements → required disclosure (ASC, Competition Act).
3. Flag "best", "#1", and comparative claims — they draw Competition Act scrutiny.
4. Influencer content → ASC disclosure (`#ad`, `#sponsored`).
5. Platform terms (Meta, Google, LinkedIn) → flag violations in the channel plan.

Never approve a claim that lacks substantiation.

## Privacy check (PIPEDA + Quebec Law 25)

- Privacy policy: required elements, plain-language requirement under Law 25.
- Data processing agreement when client data is processed on their behalf.
- Privacy impact assessment for new technology projects (Law 25).
- Breach notification: OPC and affected individuals for "real risk of significant harm";
  a suspected breach is escalated within the hour.

## Contract pre-read (before the reviewer's formal pass)

1. Parties and the nature of the relationship.
2. Terms exposing the agency to unusual liability.
3. Missing standard protections: limitation of liability, indemnification, IP ownership.
4. Recommended language changes with rationale.
5. Which provisions need negotiation versus which are standard.

IP defaults: work-for-hire deliverables go to the client unless the contract says
otherwise; check licences for stock assets, fonts, music, open source; AI-generated content
ownership is unsettled — flag it. Contractor agreements: CRA misclassification risk,
IP assignment, confidentiality; non-competes are weakly enforceable in Canada.

## Output

```
LEGAL REVIEW — {subject} — {date}
Scope: {CASL | campaign | privacy | contract pre-read}

FINDINGS (severity: block / fix / note)
  {severity} — {finding} — {rule or statute} — {what to change}

ESCALATE
  {items for the chief of staff, or "none"}

Disclaimer: internal risk assessment; external counsel recommended for {items}.
```

Security findings and legal text stay in full prose (`.claude/rules/output-voice.md`).
