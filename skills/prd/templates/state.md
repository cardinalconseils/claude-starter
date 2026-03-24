# STATE.md Template

Use this template for `.prd/PRD-STATE.md`. This file enables session continuity — any new session reads this to know where things stand.

---

```markdown
# Session State

**Last Updated:** {YYYY-MM-DD}

## Current Position

- **Active Phase:** {NN or "none"}
- **Phase Name:** {name or "—"}
- **Phase Status:** {not_started | discussing | discussed | planned | executing | executed | verifying | verified | verification_failed}
- **Last Action:** {description of what was done}
- **Last Action Date:** {YYYY-MM-DD}
- **Next Action:** {what should be done next}
- **Suggested Command:** {/cks:command args}

## Active PRD

- **PRD Path:** {docs/prds/PRD-NNN-name.md or "none"}
- **PRD Status:** {Draft | In Progress | Complete}

## Session History

| Date | Phase | Action | Result |
|------|-------|--------|--------|
<!-- Append one row per significant action -->

## Notes

{Any context that helps the next session pick up smoothly.
Things like: "User wants to revisit Phase 2 acceptance criteria before proceeding"
or "Blocked on API key — check with user first."}
```

## How to Update STATE.md

Every workflow step that changes project state MUST update STATE.md. The fields to update:

1. **Active Phase** — Which phase number is current
2. **Phase Status** — Where in the lifecycle (discussed → planned → executed → verified)
3. **Last Action** — What just happened
4. **Next Action** — What should happen next
5. **Session History** — Append a row

This ensures any new conversation can read STATE.md and immediately know where to pick up.
