# Governance Signal Quality Audit

**Date:** 2026-06-21
**Source:** `.cks/governance.json` (JSONL, append-only)
**Sample target:** 20 entries
**Reviewer:** PMC
**Purpose:** Pre-G2 readiness — validate signal quality before AHE Evolution Agent consumes.

## Source Status

`.cks/governance.json` does not exist at the time of this audit. The governance log is a per-dev gitignored artifact written by `hooks/handlers/governance-log.sh` on each HIGH-risk Bash command that runs in a session. It is absent when no HIGH-risk commands have executed since the log was created or when it has not been initialized on this machine.

**Entries available:** 0 (target: 20)

Sample size note: actual entries sampled = 0 (target 20; `.cks/governance.json` absent on this machine at audit time).

## Sampled Entries

| # | args_digest | risk_reason | decision | cluster_label | notes |
|---|---|---|---|---|---|
| — | — | — | — | — | No entries available |

## Expected Cluster Taxonomy (for future population)

Based on `governance-log.sh` schema (`risk_reason` field) and the types of Bash commands CKS uses, future entries are expected to cluster as:

| Cluster | Signal pattern | Expected quality |
|---|---|---|
| `git-history-rewrite` | `git reset --hard`, `git push --force`, `git clean` | HIGH — clear bash patterns, distinct hash |
| `destructive-fs` | `rm -rf`, `find ... -exec rm`, overwriting `.env` | HIGH — risk_reason will include path |
| `db-mutation` | `DROP TABLE`, `TRUNCATE`, `DELETE FROM` without WHERE | HIGH — SQL keywords identifiable |
| `infra-delete` | `terraform destroy`, `kubectl delete`, cloud deletes | MED — args_digest hides resource name |
| `secret-exposure` | overwriting `*.pem`, `*.key`, `credentials.json` | HIGH — file extension in risk_reason |
| `other-high-risk` | everything else tagged HIGH by guard.sh | LOW — heterogeneous, needs sub-clustering |
| `noise` | false positives from guard.sh heuristics | LOW — will need tuning after G2 pilot |

## Schema Review

The current schema (`ts`, `session_id`, `tool`, `args_digest`, `risk_level`, `risk_reason`, `decision`) provides:
- `args_digest`: 8-char SHA256 hex — stable cluster key across sessions, not reversible
- `risk_reason`: human-readable string set by `guard.sh` — variable format, not normalized
- `decision`: `"approved"` or `"ran-with-error"` — binary signal, useful for G2 policy learning

Observed gap: `risk_reason` is unstructured prose. G2 AHE Evolution Agent would benefit from a pre-normalized `risk_category` field emitted by `governance-log.sh` at write time.

## Verdict

**CONDITIONAL — add `risk_category` tag** for G2 AHE Evolution Agent consumption.

The schema has the right primitives (`args_digest + risk_reason + decision`) but `risk_reason` is unstructured, making clustering non-deterministic for an automated consumer. Recommend extending `governance-log.sh` to emit a normalized `risk_category` field.

Proposed patch (recommendation only — not applied in this phase per PLAN §D4):

```diff
--- a/hooks/handlers/governance-log.sh
+++ b/hooks/handlers/governance-log.sh
@@ governance-log.sh
-  "risk_level": "$RISK_LEVEL",
-  "risk_reason": "$RISK_REASON",
+  "risk_level": "$RISK_LEVEL",
+  "risk_reason": "$RISK_REASON",
+  "risk_category": "$RISK_CATEGORY",
```

Where `RISK_CATEGORY` is set by the guard script pattern match (e.g., `git-history-rewrite`, `destructive-fs`, `db-mutation`, `infra-delete`, `secret-exposure`, `other-high-risk`) before appending to `governance.json`.

**G2 readiness block:** Do not ship G2 AHE Evolution Agent until either (a) `risk_category` tag is added per above, or (b) G2 includes its own clustering layer. The `args_digest` alone is insufficient for interpretable policy learning without normalized category labels.

**Retry condition:** Re-run this audit after 5+ CKS sessions on this machine to obtain real samples. Target 20 entries before re-scoring readiness.
