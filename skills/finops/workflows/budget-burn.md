# Budget Burn

The one line the chief of staff prints on every mandate brief:
`<name> — <stage> — <spend> of <budget>` (`skills/chief-of-staff/references/output-format.md`).
Finops owns the `<spend> of <budget>` half. Same figure as the session banner from
`scripts/north-star-status.sh`; when they disagree, the ledger wins and the banner's
source (`.finops/BUDGET.md` burn lines) is what needs fixing.

## 1. Read

- `.finops/BUDGET.md`: `Venture`, `Monthly ceiling`, `Currency`, `Period`, every
  `- YYYY-MM-DD | category | amount | note` burn line
- `.finops/costs.jsonl`: lines whose `period` equals `Period`, `kind: cost`
- when a mandate is named: `MANDATE.md` or `.prd/mandates/<name>.md` for its own
  `Budget:` ceiling and its `Spend to date` row

## 2. Compute

```
spend      = Σ burn-line amounts for the period ∪ Σ costs.jsonl amounts for the period (dedup by note/source — a line present in both counts once)
pct        = spend / ceiling × 100
pace       = spend / days elapsed × days in month   (projected month-end)
status     = green < 60% · amber 60–80% · red ≥ 80% or pace > ceiling
```

Per mandate: the same, against the mandate's ceiling, counting only lines whose `note` or
`client` names the mandate.

## 3. Write

Append any spend the brief reports but the ledger lacks as a burn line in `BUDGET.md`
(`- <date> | <category> | <amount> | <note>`) — append only, never edit prior lines, never
touch the four bullet lines. Book the same to `costs.jsonl`.

## 4. Return

One line, then optional detail:

```
<spend> of <ceiling> <currency> (<pct>%) — <green|amber|red> — pace <projected> by month end
```

Amber or red: add the category driving it and one lever. Red before the 20th: full prose,
flag to the chief of staff as a constraint on new dispatches (a mandate in the red gets
no new spend without the owner's say). Never soften a red with an estimate; if the
numbers are unconfirmed say "unconfirmed" and name the missing source.

## Month roll

On the first run in a new month: move the closed period's burn lines to the HQ ledger
(`references/ledger-schema.md`, Month roll), empty `## Burn`, advance `Period:`. Report
the closed month's final figure once.
