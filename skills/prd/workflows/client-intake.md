# Workflow: Client Intake — onboarding interview for agency work

One interview that produces both the engagement record and the first feature's discovery
context. It merges the 11-elements discovery (`discover-elements.md`) with the kickstart
intake (`skills/kickstart/workflows/intake.md`) and adds what an agency needs before it
signs: legacy systems, who owns credentials, integration constraints, critical roadblocks,
budget and timeline, the decision maker, and the one metric that defines success.

Every question is an `AskUserQuestion` call: recommended answer first with one sentence of
reasoning, 2–5 concrete options, "(Recommended)" on the first label, `multiSelect` where
several apply. In channel mode, questions go through the channel reply as pending
clarifications instead. Never a plain-text question.

## Outputs

- `.prd/CLIENT.md` — the engagement record (one per client repo)
- `.prd/phases/{NN}-{slug}/CONTEXT.md` — discovery context for the first feature

## 0. Read before asking

`CLAUDE.md`, `.kickstart/context.md`, `.kickstart/ideation.md`, `.prd/PRD-STATE.md`,
`.prd/CLIENT.md` (resume if partial), any brief or transcript in the dispatch. Pre-fill
whatever those answer and present it for confirmation.

## 1. Who and why (batch 1)

1. **Client and contact** — company, primary contact, role. Free text.
2. **Decision maker** — who signs off scope changes and invoices?
   Options: primary contact · someone else (name) · a committee (name the chair).
3. **Problem** — the business problem in one sentence, and what it costs them today
   (hours, revenue, risk). Options derived from the brief.
4. **Success metric** — the single number that says the engagement worked, with a target
   and a date. Options: time saved per week · revenue or leads per month · error/incident
   rate · a named KPI (describe). Exactly one.

## 2. Existing world (batch 2)

5. **Legacy systems** — what runs today that this must live with?
   Multi-select: CRM · ERP/accounting · spreadsheets · custom app · website/CMS ·
   telephony · none.
   For each selected: vendor, version if known, who administers it, can it be replaced.
6. **Credentials owner** — who holds admin access to those systems and to hosting, DNS,
   payment, email?
   Options: the client's IT · the primary contact · a former vendor (risk) · unknown (risk).
   Record names only. Never collect a secret in chat (`.claude/rules/secrets.md`).
7. **Integration constraints** — APIs available? Data export possible? Auth model? Data
   residency (Canada/Quebec) or compliance rules (PIPEDA, Law 25, PCI)?
   Multi-select from the detected signals; hand compliance signals to
   `skills/compliance/workflows/surface-scan.md` after the interview.

## 3. Risk and money (batch 3)

8. **Critical roadblocks** — what could stop this? Multi-select: missing access ·
   unavailable stakeholder · data quality · vendor lock-in · legal review · budget approval
   · none known. For each: owner and the date it must be cleared.
9. **Budget** — ceiling and shape. Options: fixed price · monthly retainer · hourly with
   cap · not decided (flag). Record the number and the currency.
10. **Timeline** — hard date and why (launch, contract, season). Options derived; include
    "no hard date".
11. **Maturity target** — Prototype / Pilot / Candidate / Production (see `CLAUDE.md`).

## 4. The first feature (11 elements)

Run `discover-elements.md` for the first feature the client wants, using everything above
as pre-fill. Elements 1–3 usually come straight from the answers; the hard gate (stories,
acceptance criteria, test plan, UAT) still applies.

## 5. Write

`.prd/CLIENT.md`:

```markdown
# Client — {company}

**Contact:** {name, role} · **Decision maker:** {name} · **Intake:** {date}

## Problem and success
- Problem: {one sentence} — costs them {…}
- Success metric: {metric} → {target} by {date}

## Legacy systems
| System | Vendor/version | Admin | Replaceable |
|---|---|---|---|

## Access and credentials
| Asset | Owner | Status |
|---|---|---|

## Integration constraints
- {constraint} — {implication}

## Roadblocks
| Roadblock | Owner | Clear by | Status |
|---|---|---|---|

## Commercials
- Budget: {amount} {currency} ({shape}) · Timeline: {date — reason} · Maturity: {stage}

## Compliance surface
{summary, or "none detected" — full detail in .prd/COMPLIANCE-SURFACE.md}
```

Then `CONTEXT.md` per `discover-elements.md` step 6, in the phase directory the
project-manager created (or `00-{slug}` when none exists — say so).

## 6. Confirm

`AskUserQuestion`: "Intake complete — CLIENT.md and CONTEXT.md written. Proceed?"
Options: Approve — hand to the chief of staff (Recommended) · Adjust a section · Redo.

Return both paths, the success metric, the top roadblock, and the budget/timeline line.
The chief of staff has the project-manager open the mandate issue from this.
