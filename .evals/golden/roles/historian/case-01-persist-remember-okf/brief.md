# Brief — historian — persist a REMEMBER block: session file verbatim, wiki page with OKF frontmatter

Goal: Persist the REMEMBER block below (Level 1 — verbatim, add nothing) to today's control-plane session file, and write the decision it carries as the wiki page `decisions/csv-export-crlf` with OKF frontmatter.
Constraint: Session files under `.cks/control-plane/memory/` never get OKF frontmatter; wiki pages always do (`type: decision`, `name`, `description`). `memory/index.md` is only extended.
Done: Both files written; the HISTORIAN block lists them under WROTE.
Level: 1
Mode: persist + wiki
Source: routine (non-interactive) — no human is present; narrate any question in your return instead of calling AskUserQuestion.
project_root: . — the runner's scratch copy of this case's fixture/ (your cwd)

## Runner environment
`CKS_HQ` points at project_root; `CKS_ACTIVE_USER=eval`. The control plane is initialised at `.cks/control-plane/memory/`.

## REMEMBER

```
REMEMBER:
  Decision: CSV exports use CRLF line endings and a UTF-8 BOM so Excel FR opens them without a wizard.
  Why: Marie Tremblay's office runs Excel FR; the first export opened as one column.
  Next: builder adds the BOM in src/csv.js (issue #57).
```
