# Workflow: Summarize Session Metrics — cost proxies from `.cks/control-plane/observability/`

Surface session duration, tool-call counts, and development-time analytics. All figures
are proxy metrics — hooks expose no real token counts or API cost. Label them as such.

## Preconditions

- `.cks/control-plane/observability/` missing → "Observability not initialized. Start a
  session in a control-plane project." and stop.
- `totals.json` missing but `sessions/` exists → compute totals from the session files.
- `jq` absent → say so and show the raw file path instead of parsing.
- Never expose `supabase_service_key` from `config.yaml`.

## Modes (from the `Mode:` line of the brief)

**summary** (default) — read `totals.json`; show total sessions, total dev hours, this
week's sessions and hours, total tool calls, and the last session (date, duration, tool
calls — read the most recent session file).

**sessions** — last 10 session files (`ls -t`); per file: `session_id`, duration in
minutes, `tool_calls`, `branch`.

**trends** — last 7 session files; average duration and tool calls, high and low.

**session {ID}** — read `sessions/{ID}.json`; show every field, duration human-readable.

## Output

Compact caveman table, e.g.

```
Sessions   Dev hours   This week        Tool calls   Last session
{n}        {h}         {n} / {h}h       {n}          {date} · {min}m · {calls} calls
(proxy metrics — no token cost data from hooks)
```
