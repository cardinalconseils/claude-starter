---
name: contracts
description: "Client contract templates and review checklist for a Quebec/Canada AI agency — MSA, SOW, NDA in EN and FR with slotted clauses, plus the reviewer checklist (liability ceilings, IP assignment vs licence, data residency, termination, payment terms, non-solicit). Writer drafts from templates; reviewer checks against the checklist. Load for any contract, agreement, NDA, statement of work, terms, or scope-document request."
allowed-tools: Read, Write, Grep, Glob
---

# Contracts

Two roles, one skill. The **writer** fills a template into a draft the owner can send to
counsel or a client. The **reviewer** runs `references/checklist.md` against any contract —
ours or theirs — and returns findings. Neither gives legal advice: every draft and every
review ends with the line that counsel must review before signature.

## What is here

| File | Use |
|---|---|
| `templates/msa.md` | Master Services Agreement — the standing terms between the agency and a client |
| `templates/sow.md` | Statement of Work — one engagement under an MSA: scope, deliverables, acceptance, fees |
| `templates/nda.md` | Non-Disclosure Agreement — mutual by default, one-way by deleting the marked party |
| `references/checklist.md` | the review checklist with the positions the agency holds and the red lines |

Templates are bilingual: each clause appears in English then French under the same
number. Delete the language the client does not need; keep both for Quebec clients unless
the client asks for one. Quebec's Charter of the French language lets parties agree to
contract in English only when that is their express wish — record that wish in the
signature block when you drop the French.

## Slots

Every `<slot>` carries a one-line instruction after it in italics. Fill every slot or
delete the clause; a draft with a slot left in it is not a draft. The writer never
invents an amount, a date, a jurisdiction, or a party name — those come from the brief,
the SOW intake, finops (rates, payment terms), or a question back to the owner.

## Positions the templates encode

- Governing law and forum: Quebec and the courts of the judicial district named in the
  slot; language of proceedings follows the contract language
- Liability capped at fees paid in the preceding 12 months (MSA) or the SOW value (SOW);
  no cap on confidentiality breaches, wilful misconduct, or IP infringement indemnity
- IP: the agency assigns deliverables on full payment; it keeps pre-existing materials,
  tools, prompts, and generic components under a perpetual licence to the client; AI
  model weights and third-party model outputs are governed by the provider's terms
- Data: personal information processed under Law 25 and PIPEDA obligations; residency
  stated per SOW; the client is the controller of its end-users' data; sub-processors listed
- Termination: for convenience on 30 days' notice (MSA), for cause on 10 days uncured;
  work-in-progress paid on termination
- Payment: net 30 by default, interest on late amounts at the rate in the slot, suspension
  right after 15 days overdue with notice
- Non-solicit of personnel and contractors for 12 months; no non-compete (limited
  enforceability in Canada, and the agency does not want one)
- Compliance: `skills/compliance/references/canada.md` is the checklist the reviewer runs
  on any clause that touches personal information or AI systems

## When the writer drafts

1. Read the brief and the intake (`.prd/` discovery or the SOW questions the strategist
   asked); ask for the missing slots in one batch
2. Copy the template to the path the brief names (default `.contracts/<client>/<type>-<YYYY-MM-DD>.md`)
3. Fill every slot; delete clauses the brief excludes with a line noting the deletion in the
   cover note
4. Append a cover note: what was filled, what was deleted, the open points for counsel
5. End with: *This draft was prepared from the agency's templates and has not been
   reviewed by a lawyer. Have counsel review it before signature.*

## When the reviewer checks

Run `references/checklist.md` top to bottom; report each item as **holds**, **deviates**
(quote the clause, state the agency position, suggest language), or **missing**. Red lines
are findings in full prose. The reviewer changes nothing.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The client sent their paper, ours does not matter" | Their paper gets the same checklist. Deviations from our positions are the negotiation list. |
| "Bilingual doubles the length, I'll do English" | A Quebec client can demand French. Drop it only when the signature block records the parties' express choice. |
| "I'll put a reasonable number in the liability cap" | Numbers come from the owner or finops. A guessed cap is a guessed exposure. |
| "A short NDA does not need the checklist" | The shortest NDAs hide the widest definitions of confidential information. Run it. |
| "This is just a template, no counsel line needed" | Every draft ends with the counsel line. It is the difference between a template and advice. |

## Verification

- [ ] No `<slot>` remains in a delivered draft
- [ ] Cover note lists filled slots, deleted clauses, and open points for counsel
- [ ] Language choice recorded in the signature block when French was dropped
- [ ] Liability cap, IP position, termination, payment terms, and non-solicit each match `references/checklist.md` or the deviation is explained in the cover note
- [ ] Any clause touching personal information cites `skills/compliance/references/canada.md` obligations
- [ ] The counsel-review line closes every draft and every review
