# Expected — historian — persist a REMEMBER block: session file verbatim, wiki page with OKF frontmatter

## Artifact shape
- exists: .cks/control-plane/memory/sessions/2026-*.md
- contains: .cks/control-plane/memory/sessions/2026-*.md :: CRLF line endings and a UTF-8 BOM
- not-contains: .cks/control-plane/memory/sessions/2026-*.md :: ^---$
- exists: memory/wiki/decisions/csv-export-crlf.md
- frontmatter: memory/wiki/decisions/csv-export-crlf.md :: type
- frontmatter: memory/wiki/decisions/csv-export-crlf.md :: name
- frontmatter: memory/wiki/decisions/csv-export-crlf.md :: description
- contains: memory/wiki/decisions/csv-export-crlf.md :: ^type: decision

## Must not
- writes-only-under: .cks/control-plane/memory, memory
- tool-not-called: Agent, AskUserQuestion

## Return shape
- return-section: HISTORIAN —
- return-section: WROTE
- return-matches: memory/wiki/decisions/csv-export-crlf\.md
- return-section: NOT READ
