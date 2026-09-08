# Inbox Triage

Turn the inbox into a short list of decisions and drafts. Read-only on mail except
labels and drafts.

## 1. Window and identity

- `USER_SLUG=$CKS_ACTIVE_USER` (default `local`); user dir per `SKILL.md`
- Read `profile.md` for VIPs, languages, quiet hours, and any triage preferences
- Window: since the last triage timestamp in `conversation-state.json` (`last_triage`),
  else 24h; the brief may override ("this week")

## 2. Fetch

Brain 1 `search_gmail` when present, else Gmail `search_threads` with
`newer_than:<window> -label:cks/read -label:cks/noise -in:sent`. Page until exhausted or
200 threads; beyond that, triage tier A only and say so. `get_thread` for anything that
might be tier A or B; never open tier D bodies beyond the snippet.

## 3. Tier

Apply the table in `SKILL.md`. Signals that lift a thread to A regardless of sender:
money words (invoice, facture, paiement, quote, devis, overdue), legal words (mise en
demeure, notice, breach, contract, contrat), a date inside 48h, or a VIP address. A thread
where the owner sent the last message and nothing new arrived is skipped.

## 4. Act per tier

- **A, B**: one draft per thread (`workflows/draft-reply.md`), or a **decision** item when
  the reply needs a choice only the owner can make; add B threads to `followups.md` with
  the first-nudge date from the cadence table
- **C**: one line — sender, subject, why it is worth reading; `label_thread` → `cks/read`
- **D**: `label_thread` → `cks/noise`; count only

`create_label` is not in the grant — when `cks/read` or
`cks/noise` do not exist (`list_labels`), report that they need creating and fall back to
listing without labelling.

## 5. Report

```
Inbox — <window> — <n> threads (<a> A · <b> B · <c> C · <d> noise)

A — decide today
- <sender> — "<subject>" — <the ask in one line> — draft <id|path> | DECISION: <question>
B — this week
- <sender> — "<subject>" — <ask> — draft <id|path> — nudge <date>
C — read
- <sender> — "<subject>" — <why>
Noise: <d> labelled, none summarised

Owner confirmations needed: <list of [owner: confirm …] markers across drafts>
Tools: Brain 1 <present|absent> · Gmail <present|absent>
GATED: send reply to <person> re "<subject>" — draft <id|path>
GATED: …
```

Update `conversation-state.json` `last_triage` and `followups.md` before returning.
