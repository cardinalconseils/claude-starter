# Workflow: Ingest — classify a news item into an ecosystem bulletin draft

Turn an article, URL, or topic into a bulletin in the format from `SKILL.md`. The
researcher drafts and classifies; the HIGH gate and the write into
`skills/ecosystem-watch/bulletins/` + `index.md` are the chief of staff's to route
(plugin-repo files are outside the researcher's write scope).

## 1. Acquire content

- URL → `WebFetch` the page.
- Topic or pasted text → use as-is; `WebSearch` for the source URL if none was given.
- Nothing → return "Paste the content or give a URL" and stop.

## 2. Classify with the rubric

Apply the priority rubric from `SKILL.md`. State the classification with reasoning before
drafting:

```
Classification:
  Priority: HIGH / MEDIUM / LOW
  Type: BREAKING_CHANGE / OPPORTUNITY / DEPRECATION / ENHANCEMENT / SECURITY
  Affects: [skill domains — database-design, migrations, rls, authentication, api-design,
            monitoring, performance, security-hardening, payments, cicd-starter,
            environment-management, no-code]
  Action required: true / false
  Reasoning: [one sentence]
```

When in doubt, MEDIUM — HIGH triggers a human gate.

## 3. Draft the bulletin

Write the draft to `.research/ecosystem/{YYYY-MM-DD}-{kebab-slug}.md` (slug: lowercase,
hyphens, ≤ 5 words from the title). Body per `SKILL.md` "Bulletin Format":

- `## What Changed` — 1–2 factual sentences, no editorializing
- `## Impact on Agents` — imperative and specific; start with "Always…", "Never…", or "When…"
- `## Required Pattern Going Forward` — code snippet or rule, or "No pattern change required."
- `## Reference` — source URL, or "No URL — user-provided text"

`expires`: BREAKING_CHANGE with a cutover date → cutover + 30 days; other HIGH → today + 90;
MEDIUM → today + 180; LOW → today + 90.

Also draft the index row: `| {date} | {source} | {title} | {priority} | {type} | {affects} |`.

## 4. Return

```
Bulletin draft: .research/ecosystem/{filename}
Priority: {HIGH/MEDIUM/LOW} — {type}   Affects: {domains}
Index row: {row}
Gate: {HIGH → "confirm before filing" | MEDIUM/LOW → "file without gate"}
Issue: {action_required → "file `[Ecosystem] {priority}: {title}` with label ecosystem-watch"
        | "none"}
```

The chief of staff confirms HIGH with the human (Confirm / Downgrade to MEDIUM / Skip),
then has the historian copy the bulletin into `skills/ecosystem-watch/bulletins/` and
prepend the row to `index.md` (newest first), and the project-manager file the issue.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The rubric is ambiguous here" | Default to MEDIUM. HIGH needs a hard cutover date or a security vulnerability. |
| "I'll summarize the article broadly" | "Impact on Agents" must be imperative and specific. Vague impact text is worthless. |
| "Filing it myself is faster" | The bulletins dir is plugin content. Draft here, let the gate and the historian do the write. |
