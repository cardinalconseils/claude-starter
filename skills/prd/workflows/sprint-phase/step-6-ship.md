# Step 6: Ship (Lightweight Release)

<context>
Phase: Sprint (Phase 3) — conditional step
Requires: User chose "Ship it" in Step 5
Produces: Merged PR, version bump, tag, changelog, updated state
</context>

**This step only runs if the user chose "Ship it" in Step 5.**

## Instructions

### 1. Merge the PR

Check if the PR from [3g] can be merged:

```bash
gh pr view --json mergeable,mergeStateStatus
```

- If mergeable → merge it:
  ```bash
  gh pr merge --squash --delete-branch
  ```
- If not mergeable (protected branch, conflicts) → tell the user:
  ```
  ⚠️  PR #{number} can't be auto-merged. Merge it manually, then run /cks:next.
  ```
  Update STATE.md with `phase_status: reviewed`, stop here.

After merge, pull main:
```bash
git checkout main && git pull origin main
```

### 2. Version Bump

If `scripts/bump-version.sh` exists:
```bash
bash scripts/bump-version.sh
```

Stage any version-bumped files:
```bash
git add -A
git diff --cached --quiet || git commit -m "$(cat <<'EOF'
chore: bump version after Phase {NN} release

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

### 3. Changelog

Read SUMMARY.md and generate a changelog entry.

If `CHANGELOG.md` exists, prepend the new entry under the latest version heading.
If not, create `CHANGELOG.md` with the entry.

Entry format:
```markdown
### Phase {NN}: {name}
- {key change 1}
- {key change 2}
- {key change 3}
```

Stage and commit if changed:
```bash
git add CHANGELOG.md
git diff --cached --quiet || git commit -m "$(cat <<'EOF'
docs: update changelog for Phase {NN}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

### 4. Tag Release

```bash
git tag -a "phase-{NN}-{slugified-name}" -m "Phase {NN}: {name} — released"
git push origin main --tags
```

### 5. Update PRD State

Update `.prd/PRD-STATE.md`:
```yaml
phase_status: released
last_action: "Phase {NN} released"
last_action_date: {today}
next_action: "Start next feature with /cks:new"
suggested_command: /cks:new
```

Update `.prd/PRD-ROADMAP.md` — mark the phase as released.

Update the PRD document `docs/prds/PRD-{NNN}-{name}.md` — add release date.

Add to Feature History table in PRD-STATE.md:
```
| PRD-{NNN} | {name} | 1-5 | released |
```

**Log:** `bash ${CLAUDE_PLUGIN_ROOT}/scripts/cks-log.sh INFO "phase.released" "{NN}-{name}" "Phase released — merged, tagged, changelog updated"`

### 6. Completion Banner

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 ✅ SHIPPED — Phase {NN}: {name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 PR:        #{number} merged ✓
 Version:   {version} (bumped ✓)
 Tag:       phase-{NN}-{slugified-name}
 Changelog: updated ✓
 State:     released ✓

 What's next?
   /cks:new "{next feature}"   ← start next feature
   /cks:retro                  ← optional retrospective
   /cks:status                 ← project overview

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Do NOT chain to any other workflow. The feature is done. Stop here.**
