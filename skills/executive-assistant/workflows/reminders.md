# Reminders

Set, list, and clear due-dated reminders under the user's guarded directory, and make
sure a proactive wake exists to fire them. The wake contract, file locations, and what is
worth pushing live in `skills/chief-of-staff/workflows/proactive-wake.md` — that file is
the source of truth; this workflow is the assistant's side of it and does not repeat it.

## Resolve the user (always first)

`USER_SLUG=$CKS_ACTIVE_USER` (default `local`). Never parse identity from the reminder
text. All reads and writes stay under the user directory (`SKILL.md`, Where state lives);
the `user-memory-guard` hook enforces this. Writes go through the `Write` tool, appending
to `reminders.md` — Bash is read-only for this role.

## Modes (from the brief)

### `list`

```bash
grep -n "^## \[" <user dir>/reminders.md 2>/dev/null
```

Lines beginning `## [` are pending; `## fired:[` are done. Absent file → say so.

### `clear`

Rewrite every pending `## [` line as `## fired:[` (append-only spirit: the dates stay as
a record; nothing is deleted).

### default — set a reminder

1. Split into `<when>` and `<what>` (the text after `to`, or the remainder)
2. Parse `<when>` to ISO 8601 UTC:
   ```bash
   date -u -d "tomorrow 09:00" +%Y-%m-%dT%H:%M:%SZ
   date -u -d "+2 hours"      +%Y-%m-%dT%H:%M:%SZ
   ```
   Interpret bare times in the owner's time zone from `profile.md`. If `date -d` cannot
   parse it, say what was ambiguous and ask (`AskUserQuestion` on CLI; a channel question
   otherwise) — never guess a due time.
3. Append `## [<DUE>] <WHAT>` to `reminders.md`
4. Ensure a wake exists (below)

## Wake registration (one-shot, gated)

A reminder is useless if nothing wakes to fire it. After saving the first reminder:

1. Read `<user dir>/proactive.json`. If it exists with `"registered": true`, the wake is
   live — skip.
2. Otherwise ask the cadence once on CLI (`AskUserQuestion`: Hourly (Recommended) / Every
   15 min / Daily 8am); default Hourly in a channel context.
3. Registration changes a Routine, which is a gated action the assistant cannot perform.
   Return the exact request for the chief of staff:
   ```
   GATED: register proactive wake for user <slug> — cadence <chosen> — prompt: "Proactive wake for user <slug>. Follow skills/chief-of-staff/workflows/proactive-wake.md: scan blockers, due reminders, and stale pending clarifications for this user, dedup against last_proactive, respect quiet hours, push via the channel reply tool only if worth interrupting for. CKS_ACTIVE_USER=<slug>."
   ```
4. Once the chief of staff confirms the Routine id, write `proactive.json`:
   `{"registered": true, "cadence": "<chosen>", "schedule_id": "<id>", "registered_at": "<ISO>"}`.
   Until then the reminder is saved and the report says the wake is pending approval.

## Firing

Firing happens on the proactive wake, not here: the wake greps for due lines, pushes them,
and a recording dispatch marks them `fired:`. Never echo a secret a reminder contains.

## Report

The reminder text and its due time in the owner's time zone, and whether the wake is
**already active**, **pending approval** (with the `GATED:` line), or **newly confirmed**.
For `list` and `clear`, the counts.
