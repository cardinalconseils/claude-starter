# Draft Reply

One thread → one draft in the owner's voice, saved where the owner can send it with one
action. Never sent from here.

## 1. Context

- `get_thread` for the full thread; Brain 1 `crm_lookup` (when present) or Gmail
  `search_threads from:<sender>` for history with this person
- `profile.md` for signature, languages, tone notes; `followups.md` for what we already
  asked them
- Voice sample: 3–5 recent sent replies in the thread's language (`search_threads`
  `from:me newer_than:90d` plus a subject or recipient filter). Note greeting, sign-off,
  sentence length, formality, bullets or prose, how the owner declines

## 2. Decide what the reply must do

Exactly one of: answer a question, make an ask, confirm or decline, move to a meeting,
close the loop. If the thread needs a decision only the owner can make (a price, a
commitment, a yes to scope), write the two candidate answers as `[owner: choose A|B]` and
draft the surrounding text; do not choose.

## 3. Write

- Language of the counterpart's last message; Quebec French with `vous` unless the thread
  is on `tu`
- Under 120 words unless the owner's samples run longer; one ask, one next step
- Facts only from the thread, the CRM record, `.prd/`, or finops files — anything else is
  a `[owner: confirm <thing>]` marker in the body
- Dates in full (`mardi 9 septembre`, `Tuesday, September 9`) with the time zone when
  proposing a slot; propose two slots from `suggest_time`
- No commitments on delivery dates or prices without a marker
- Sign-off and signature from `profile.md`

## 4. Save

Preferred: Gmail `create_draft` as a reply on the thread (or `update_draft` when a draft
already exists for it — check `list_drafts`). Fallback: `drafts/YYYY-MM-DD-<slug>.md`
under the user dir with `To`, `Subject`, `In-reply-to thread`, and the body.

## 5. Return

```
Draft — reply to <person> re "<subject>" — <language> — <words> words
Purpose: <answer|ask|confirm|decline|meeting|close>
Markers: [owner: confirm <thing>], [owner: choose A|B]
Saved: Gmail draft <id> | <path>
Follow-up: added to followups.md, nudge <date>
GATED: send reply to <person> re "<subject>" — draft <id|path>
```
