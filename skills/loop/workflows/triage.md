# Loop Triage Workflow

Run by `cks:historian` in `Mode: loop-triage`. This report is the PRIMARY user-facing
output of a loop — vibecoders do not monitor runs; they read the triage inbox.

## Step 1: Date range

Read `.triage/{slug}/last-run.txt` for the cutoff date. Missing → first triage; process
every output file. Today: `date -u +"%Y-%m-%d"`.

## Step 2: New output files

List `.loops/{slug}/output/*.md` modified after the cutoff. None → write the "No findings"
report, update last-run.txt, done.

## Step 3: Read and score

For each finding:

- **HIGH** — blocks work or needs immediate attention: loop failure, data-loss risk,
  external API errors, stop condition triggered, security issue
- **MEDIUM** — fix soon, not blocking: degraded quality, slow runs, rising error rate,
  connector warnings
- **LOW** — nice to have: minor inconsistencies, style, optimisation opportunities

Deduplicate across runs — one entry with frequency: "Seen in 3 of 5 runs."

## Step 4: Write `.triage/{slug}/{YYYY-MM-DD}.md`

Create the directory if needed.

```markdown
# Triage Report: {slug}

**Date:** {YYYY-MM-DD}
**Runs covered:** {n} (iterations {first} to {last})
**Period:** {start} to {end}

## HIGH — Immediate Attention Required
{"None." or:
- **{title}** — {description}. *Seen in {n} runs.*
  Action: {recommended action}}

## MEDIUM — Address Soon
{"None." or bullets with frequency}

## LOW — Nice to Have
{"None." or bullets}

## Loop Health
- Runs covered: {n}
- Outcomes: {pass} pass, {fail} fail
- Next expected run: {from LOOP-DESIGN.md schedule}

---
*Primary output of /cks:loop triage. Run /cks:loop health for observability details.*
```

No findings at any severity:
```markdown
# Triage Report: {slug}

**Date:** {YYYY-MM-DD}
**Runs covered:** {n} (iterations {first} to {last})

No findings for {start} to {end}. All runs completed without notable findings.
```

## Step 5: Update last-run.txt

Overwrite `.triage/{slug}/last-run.txt` with today's date.

## Constraints

- Always write the report — "No findings" is information, not silence
- Deduplicate with frequency
- Report the path and counts (HIGH: n, MEDIUM: n, LOW: n)
