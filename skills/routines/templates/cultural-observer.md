---
slug: cultural-observer
goal: "Every Friday the founder gets one digest of upcoming cultural events in his cities that match his interests, sorted by lead-time bucket, with a 'book now' line for anything that will sell out before the next digest."
north_star_goal: "<slot: the NORTH-STAR.md goal this serves — often a personal one such as 'one evening out a week'; 'none' is a valid answer and means DROP is recommended at registration>"
owner_role: researcher
sources:
  - "Web: official listings and ticketing for each city below — the interview fills references/cultural-observer-sources.md with the exact URLs"
  - "last30days (discovery mode): what people are talking about attending in each city in the last 30 days — engagement counts break ties"
  - "HQ: users/<founder slug>/profile.md — travel dates, quiet weeks, standing commitments"
  - "HQ: .routines/cultural-observer/STATE.md seen: — events already surfaced"
connectors: []
cadence: "0 12 * * 5"
environment: inherit
repo: HQ
autonomy_level: 1
stop_condition: "3 consecutive digests with zero events kept after filtering (interests too narrow or sources dead — re-interview); or 52 runs since created, whichever first."
report_to: ["channel:<slot: telegram | slack | email — where the founder wants Friday's digest>"]
budget_per_run: 3.00
quiet_hours: "<slot: HH:MM-HH:MM tz, or none — the digest is scheduled, so usually none>"
created: "<slot: ISO date the founder accepted this profile>"
trigger_id: ""
---

# cultural-observer

Researcher plus `last30days` plus the open web, filtered by a profile the interview fills.
Everything below marked `<slot:` is answered in `workflows/interview.md` questions 1, 3, 4,
6 and 8; the profile is a draft until none remain.

## Cities and radius

- Montréal — `<slot: radius or neighbourhoods, e.g. island + Laval>`
- Paris — `<slot: arrondissements or 'intra-muros', and whether the run only looks when a Paris trip is in profile.md>`
- London — `<slot: zones, and the same trip condition>`

## Interests — the filter

| Field | Fill from the interview |
|---|---|
| Genres | `<slot: e.g. jazz, contemporary dance, photography, architecture talks — ranked>` |
| Never | `<slot: what to drop on sight — e.g. stadium concerts, children's shows>` |
| Venues loved | `<slot: named venues that always pass the filter>` |
| Venues avoided | `<slot: named venues that never pass>` |
| Company | `<slot: solo / with partner / hosting clients — changes what 'good' means>` |
| Price ceiling | `<slot: per ticket, in CAD/EUR/GBP>` |
| Language | `<slot: FR / EN / either; matters for theatre and talks>` |

## Lead-time buckets

| Bucket | Event date is | Digest section |
|---|---|---|
| book now | ≤ 7 days, or selling out per last30days signal | first, max 3 lines |
| this month | 8–31 days | second |
| next quarter | 32–90 days | third, one line each |
| on the radar | > 90 days | last, only if a venue-loved or a genre ranked first |

`<slot: how far ahead to look at most — default 90 days>`

## What a finding is

An event not in `seen:` (key: `<city>:<venue>:<date>:<title hash>`), inside the cities and
radius, passing the interests filter, under the price ceiling, on a date not blocked in
`profile.md`. Each line: date, venue, title, price, one reason it matched, the booking URL.

## What noise is

Recurring weekly programming (a jazz club's regular Tuesday), anything in the Never list,
duplicates across listing sites (same venue + date + title), and last30days threads with no
event date. Sources that time out are `NOT READ` — the digest says which city was blind.

## Report

The digest, in the channel's format rule (`skills/chief-of-staff/SKILL.md`, source-aware
output): Telegram gets the book-now section and counts for the rest with a link to the run
log; email gets all four sections. No findings → one line, "nothing matched this week", so
the founder knows the run happened. Level 1 permanently: it never books, never buys.
