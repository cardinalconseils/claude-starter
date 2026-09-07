# Meeting Prep

A brief the owner reads in two minutes before walking in. Output:
`briefs/YYYY-MM-DD-<meeting-slug>.md` under the user directory.

## 1. Which meetings

From the brief, or every external meeting in the next 24h found by
`workflows/calendar-review.md`. Internal solo holds get no brief.

## 2. Gather

| Source | Get |
|---|---|
| `get_event` | attendees, description, links, location |
| Brain 1 `crm_lookup` (when present) | account status, deal stage, notes |
| Gmail `search_threads from:<attendee> OR to:<attendee> newer_than:180d` | last 3 touches, open asks in either direction |
| `followups.md` | what we are waiting on from them |
| `.prd/` state and mandate files, when the meeting maps to a project | stage, blockers, decisions pending |
| finops (`.finops/invoices/`, ledger revenue lines, `BUDGET.md`) | unpaid invoices, quotes outstanding, burn on their mandate |
| `.contracts/` or SOW paths | scope, dates, commitments in writing |

Missing sources are named in the brief, not papered over.

## 3. Write

Use the shape in `SKILL.md` (Meeting-prep brief shape), under 40 lines, every fact with its
source in parentheses (`thread "Re: SOW v2", Sep 3`; `CRM note`; `.finops/invoices/acme-2026-08.md`).
The **one decision to get** line is mandatory — a meeting with no decision to get is a
finding ("consider cancelling") rather than a brief.

## 4. Return

Brief path, the one decision, the top risk, and any draft it produced (an agenda email to
send beforehand is a draft plus `GATED:` line).
