# Invoice

Draft a client invoice, prepare the Stripe call, hand the send to the owner. Output:
`.finops/invoices/<client>-YYYY-MM.md` and a `GATED:` line. Nothing is sent from here.

## 1. What is billable

Read, in order: the client's contract or SOW (`.contracts/` or the path the brief names —
terms, rate, billing day, milestones, currency, payment terms), the ledger's revenue lines
already booked for this client and period (avoid double billing), the period's
pass-through lines for this client (reimbursables to itemise separately), and any
milestone acceptance in `.prd/phases/*/VERIFICATION.md` when billing is milestone-based.

Billable when the SOW says so and the evidence exists: a retainer on its billing day, a
milestone with a PASS verdict, hours the owner confirms, reimbursables with a source. If
the SOW is missing, stop and ask for it — an invoice with no agreed terms is a dispute.

## 2. Draft

```
# Invoice draft — <client> — <YYYY-MM>

From:        <agency legal name>, <address>          Tax ids: <GST/HST>, <QST> when applicable
To:          <client legal name>, <billing contact>
Currency:    <ISO>       Terms: net <n> (from SOW)   Due: <date>
Recognition: <cash | accrual>

| Line | Description | Qty | Unit | Amount |
|---|---|---|---|---|
| 1 | <retainer / milestone / hours> — period or milestone name | | | |
| 2 | Reimbursable: <client ad spend, vendor, dates> — pass-through, no markup | | | |
Subtotal · GST/HST <rate> · QST <rate> (Quebec clients) · Total

Evidence: <SOW clause>, <VERIFICATION.md path>, <ledger lines>
```

Tax lines follow the client's province and the agency's registration; when either is not
on file, leave the tax lines as a question for the owner rather than guessing a rate.
Bilingual (FR/EN) description lines for Quebec clients when the SOW is in French.

## 3. Stripe

The Stripe MCP grant (`"mcp__claude_ai_Stripe__*"`) may be absent from the session; check
by listing customers or products first. When present, look up the customer and any open
invoice (read calls only), then write the exact create-invoice and add-line-item inputs
into the draft under `## Stripe call`. Creating the invoice object, finalising it, and
sending it are all gated — prepare, do not execute. When the grant is absent, the draft is
the deliverable and the owner sends from the Stripe dashboard.

## 4. Book and return

Append a `kind: revenue` ledger line with `recognition`, `invoice_id` (draft path until
Stripe assigns one), and `source: <draft path>`. Then return:

```
GATED: send invoice <client> <YYYY-MM> — <total> <currency> — draft at .finops/invoices/<client>-<YYYY-MM>.md
```

## 5. Follow-up

On later runs: unpaid at 30 days → flag in the burn brief; at 45 days → escalate to the
chief of staff with a reminder draft for the assistant to send (gated). Never chase a
client directly from finops.
