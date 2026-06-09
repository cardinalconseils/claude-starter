---
name: loop-engine
description: "Deterministic step machine for the autoresearch keep/discard loop"
---

# Loop Engine

Two zones: the **outer shell is deterministic** (same steps, same decision logic, same exits every iteration). The **inner mutation step is indeterministic** (agent invents what to try). Never blend them.

## Pre-Loop Setup

1. `git checkout -b autoresearch/<tag>` from HEAD
2. Create `.autoresearch/<tag>/`
3. Write `program.md` from SKILL.md template
4. Write TSV header: `iteration\tcommit\tmetric_value\tdelta\tstatus\tdescription`
5. **Baseline:** run metric command once. Record `iteration=0, status=baseline`. Set `current_best = baseline_value`. If baseline fails → exit (metric must work before loop starts).
6. Set `iteration = 1`, `consecutive_crashes = 0`

## Main Loop

### A — Checkpoint (DETERMINISTIC)

Write `.autoresearch/<tag>/checkpoint.json`:
```json
{"iteration": N, "current_best": X, "consecutive_crashes": N, "timestamp": "ISO8601"}
```

Check exits — if any true, go to Exit:
- `iteration > budget`
- `consecutive_crashes >= 3`
- `.autoresearch/<tag>/STOP` exists

### B — Read program.md (DETERMINISTIC trigger, INDETERMINISTIC content)

Re-read `program.md` before every mutation. User may have edited it. Respect changes.

### C — Mutate Target (INDETERMINISTIC)

**This is the creative core.** Agent decides what to change.

Deterministic constraints:
- Modify `--target` file ONLY. No other file. Ever.
- One focused hypothesis per iteration.
- Do not commit yet.

Guidance (informs but does not constrain):
- Early (1–5): conservative, low-risk changes
- Mid (6–15): moderate restructuring
- Late (16+): bolder changes if earlier passes stalled
- Avoid repeating failed hypotheses from program.md

### D — Run Metric (DETERMINISTIC)

Run the exact metric command string from args. No variations.

For eval metrics → `Agent(subagent_type="cks:evals-runner", prompt="Run smoke evals. Return pass rate 0.0–1.0 on last line.")`.

For crashes: `consecutive_crashes += 1`, `git checkout -- <target>`, log `status=crash`, skip to F.
On success: `consecutive_crashes = 0`.

### E — Compare and Keep/Discard (DETERMINISTIC)

```
delta = metric_value - current_best
improved = (delta > 0) if higher-is-better else (delta < 0)
```

**If improved:**
```bash
git add <target>
git commit -m "autoresearch(<tag>) iter N: <description> [<old>→<new>]"
```
`current_best = metric_value`, `status = kept`

**If not improved:**
```bash
git reset --hard HEAD
```
`status = reset`

No judgment. No exceptions. The number decides.

### F — Log TSV (DETERMINISTIC timing, INDETERMINISTIC description)

Append: `N\t<sha_or_empty>\t<value_or_empty>\t<delta_or_empty>\t<status>\t<description>`

Description is generated fresh — natural language summary of what was tried and why.

### G — Update program.md (every 5 iterations, INDETERMINISTIC)

Append genuine reflections to "What Has Worked" / "What Has Failed" based on TSV history.

### H — Increment (DETERMINISTIC)

`iteration += 1` → go to A.

## Exit

Print summary:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 autoresearch/<tag> — Loop Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Iterations:   N total (X kept · Y reset · Z crash)
 Baseline:     <value>  →  Best: <value> (iter N)
 Exit reason:  <budget | crash limit | user stop>
 Next:  Good results → merge into feature branch
        Poor results → git branch -D autoresearch/<tag>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Dry-Run Mode

Baseline → one mutation → one metric run → show WOULD have kept/reset → `git checkout -- <target>` → exit. No commits, no resets.

## Crash Recovery

On restart: read `checkpoint.json`, `git checkout -- <target>` if uncommitted changes, resume from Step A at `checkpoint.iteration`.
