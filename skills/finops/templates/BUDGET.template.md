# Budget — <venture tag>

Written by `/cks:bootstrap` (Step 3d) after one question; read by `scripts/north-star-status.sh`
for the session banner and by the finops role for burn tracking. Replace every `<angle>` slot
before saving. Keep the four bullet lines exactly in this shape — the banner parses them.

- **Venture:** <venture-tag> — short slug for this venture, used in every finops ledger entry (e.g. `acme-app`)
- **Monthly ceiling:** <amount> — number only, no currency symbol or thousands separator (e.g. `500`)
- **Currency:** <CAD|USD|EUR> — three-letter ISO code
- **Period:** <YYYY-MM> — the month the ceiling applies to; roll it forward on the 1st and move old burn lines to the HQ ledger

## What counts as spend

Everything below counts against the monthly ceiling. Anything not listed is free until it appears here.

| Category | Includes |
|---|---|
| `api` | Model API calls and token usage, image/video generation, embeddings |
| `infra` | Hosting, databases, storage, bandwidth, domains |
| `tools` | SaaS subscriptions used by this venture (analytics, monitoring, design) |
| `contractors` | Any human work paid per hour or per deliverable |

## Burn

Append one line per spend, newest last. The finops role owns this section; other roles append and never edit prior lines.

Format: `- YYYY-MM-DD | category | amount | note` — `category` is one of the four above, `amount` is a number in the currency above.

