# Calendar Review

Keep the next stretch of days honest: conflicts surfaced, focus protected, prep and travel
made visible, external meetings briefed. Writes only `[hold]` events with no attendees.

## 1. Read

- `profile.md`: quiet hours, focus-block preference, time zone, working days
- Brain 1 `get_calendar_events` when present, else `list_calendars` then `list_events`
  for the window (default: today through +5 working days; the brief may widen it)
- `get_event` for anything with attendees, a video link, or no description

## 2. Check, in this order

| Check | Finding when |
|---|---|
| conflicts | two events overlap, or an event overlaps a `[hold]` |
| purpose | an attendee-bearing event has no description and no agenda in the invite thread |
| focus | fewer than one ≥ 90-min free block in a working morning |
| density | more than 3 consecutive meetings without a 15-min gap |
| travel / prep | an in-person or external event has no preceding hold |
| prep brief | an external meeting within 24h has no `briefs/<date>-<slug>.md` |
| quiet hours | any event inside the quiet window |
| stale invites | an unanswered invite older than 3 days (report; never respond) |

## 3. Propose, then hold

For each finding, one proposal. Holds the assistant may create directly (`create_event`,
`update_event`; no attendees; title prefixed `[hold]`; description names the reason):
focus blocks, prep time, travel buffers, "decide by" markers. Anything that touches
another person — rescheduling, declining, inviting — is a draft message plus a `GATED:`
line. `suggest_time` finds candidate slots; the proposal lists two.

## 4. Report

```
Calendar — <window>

Today
- 09:00–10:30 [hold] focus — kept
- 11:00 <event> — <attendees> — purpose: <ok|missing> — prep: <brief path|none>
Findings
- CONFLICT <event A> / <event B> <time> — proposal: <move B to slot 1 or slot 2>
- NO PURPOSE <event> — proposal: draft asking <organizer> for the agenda
- FOCUS <day> — hold created 08:30–10:00
Holds created: <n>   Briefs due: <list>   Invites awaiting the owner: <list>
GATED: send reschedule request to <person> re "<event>" — draft <id|path>
```
