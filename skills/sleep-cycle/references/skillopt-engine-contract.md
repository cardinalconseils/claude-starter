# SkillOpt Engine Contract

Interface specification between `scripts/sleep-engine.sh` and the `skillopt` Python package.

## Package

- PyPI: `skillopt==0.1.0`
- Python requirement: ≥3.10
- License: MIT
- GitHub: https://github.com/microsoft/SkillOpt
- Claude Code plugin: `plugins/claude-code/` (reference implementation)

## Installation Check

```bash
python3 --version | awk '{print $2}' | awk -F. '{if ($1*100+$2 < 310) exit 1}'
pip show skillopt 2>/dev/null | grep -q "Version: 0.1.0"
```

If either check fails, `sleep-engine.sh` exits with a structured error.

## Invocation Modes

### Mode 1: Generate Proposal

```bash
bash scripts/sleep-engine.sh \
  --input /tmp/skillopt-input-{skill}.json \
  --output .sleep/proposals/{skill}-{date}-raw.md \
  --skill {skill}
```

**Input JSON schema:**
```json
{
  "skill_content": "string — full SKILL.md content",
  "task_examples": ["string — task description 1", "..."],
  "seed": "string — 8 hex chars from session_id",
  "held_out_count": 5
}
```

**Output:** A `.md` file containing either:
- A unified diff (`--- a/SKILL.md` / `+++ b/SKILL.md`) for targeted edits
- A `## Proposed Changes` section with before/after blocks for section replacements

### Mode 2: Apply Proposal

```bash
bash scripts/sleep-engine.sh \
  --apply-proposal \
  --input .sleep/proposals/{skill}-{date}-raw.md \
  --target /tmp/sleep-proposed-{skill}.md
```

Applies the proposal to the target file in-place. Target is always a temp copy —
never the canonical `skills/*/SKILL.md`.

**Proposal format for Mode 2:**

```markdown
## Proposed Changes

### Section: Common Rationalizations

**Before:**
| Rationalization | Reality |
| "..." | "..." |

**After:**
| Rationalization | Reality |
| "..." | "..." (improved) |
| "..." (new entry) | "..." |
```

The script parses Before/After blocks and applies the replacement.
If no matching section found: write error to stderr, exit 1.

## Domain Map (skill → tool signal keywords)

Used during harvest to map session telemetry to skill domains:

| Skill | Tool/agent keywords |
|-------|-------------------|
| `prd` | prd-orchestrator, prd-executor, prd-planner, prd-discoverer, prd-verifier, sprint, discover |
| `retrospective` | retrospective, retro, session-log, learnings |
| `evals` | evals-runner, smoke, standard, comprehensive, eval |
| `autoresearch` | autoresearch-runner, keep, discard, loop |
| `caveman` | caveman-speaker, compress |
| `cicd-starter` | cicd, pipeline, deploy, github-actions |

For unlisted skills: use the skill name as a keyword against agent names and Bash tool output.

## Error Handling

All errors from `sleep-engine.sh` are written to:
- stdout: human-readable summary
- `.sleep/blocked/{skill}-{date}.json`: structured error for cycle logging

Exit codes:
- `0` — success
- `1` — skillopt error (proposal generation failed)
- `2` — Python version too low
- `3` — skillopt not installed
- `4` — apply failed (section not found)

## Version Pinning

`scripts/sleep-engine.sh` hardcodes `SKILLOPT_VERSION="0.1.0"` and validates it
against `pip show skillopt`. If a newer version is installed, the script warns
but proceeds (semver-compatible patch). If the installed version is older, it exits 3.

Do not update the pinned version without testing the new upstream API contract.
