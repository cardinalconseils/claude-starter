# Workflow: Follow-ups — issue-backed reminders

A follow-up the founder must not forget is a GitHub Issue, not a note in a file.
Issues survive sessions, show on the board, and close with evidence. File-backed
personal reminders (`~/.cks/user/<slug>/reminders.md`) belong to the assistant role;
this workflow covers project follow-ups.

## Set

1. Split the request into `<when>` and `<what>` (the text after "to", or the remainder).
2. Parse `<when>` to an ISO-8601 UTC due time:
   ```bash
   date -u -d "tomorrow 09:00" +%Y-%m-%dT%H:%M:%SZ
   date -u -d "+2 hours"       +%Y-%m-%dT%H:%M:%SZ
   ```
   If `date -d` cannot parse it, say what was ambiguous and ask for a clearer time — never
   guess a due date.
3. Dedup: `mcp__plugin_github_github__list_issues(owner, repo, state="open", labels="cks:follow-up")`
   and skip if an open issue already carries the same `<what>`.
4. File with `mcp__plugin_github_github__issue_write`:
   - Title: `Follow up: {what}`
   - Labels: `cks:follow-up` plus `needs-you` when the founder is the one who must act
   - Body:
     ```
     ## Due
     {ISO due time} ({human-readable, local})

     ## Outcome
     {what is true when this is done}

     ## Done
     {the observable check that closes it}

     ## Source
     {who asked, in which session or channel}
     ```
5. Ensure the label exists once per repo:
   ```bash
   gh label create "cks:follow-up" --color "0EA5E9" --description "Issue-backed reminder" --repo {owner}/{repo} 2>/dev/null || true
   ```

## List

`mcp__plugin_github_github__list_issues(owner, repo, state="open", labels="cks:follow-up")`,
sorted by the `## Due` line. Overdue first. Show `#{n} — due {when} — {title}`.

## Clear

Close with `issue_write` (`state="closed"`, `state_reason: completed`) only when the `## Done`
check is evidenced; otherwise `not_planned` with a one-line reason in a comment. Never delete.

## Wake

Firing due follow-ups is the chief of staff's proactive wake
(`skills/chief-of-staff/workflows/proactive-wake.md`), which reads open `cks:follow-up`
issues past their due time. Do not register Routines or CronCreate entries from this role —
return "wake needed" to the chief of staff if no wake is registered.

## Never

- Never file a follow-up without a parseable due time.
- Never echo a secret the request happens to contain (`.claude/rules/secrets.md`).
