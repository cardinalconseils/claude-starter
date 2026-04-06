# Peer Message Protocol

All CKS workflow messages between peers use structured JSON with a `type` field. Free-form text is allowed for ad-hoc coordination.

## Message Types

### task — Assign work to a peer
```json
{
  "type": "task",
  "phase": "01-auth",
  "task_group": "TG-1",
  "description": "Implement JWT middleware and session management",
  "files_scope": ["src/auth/", "src/middleware/"],
  "plan_path": ".prd/phases/01-auth/01-PLAN.md",
  "constraints": "Do not modify src/routes/ — owned by TG-2"
}
```

**Required fields**: `type`, `phase`, `task_group`, `files_scope`
**Optional fields**: `description`, `plan_path`, `constraints`

### status — Report progress
```json
{
  "type": "status",
  "phase": "01-auth",
  "task_group": "TG-1",
  "state": "in_progress",
  "progress": "3/5 files complete",
  "blockers": null
}
```

**States**: `in_progress`, `complete`, `blocked`, `failed`

### review_request — Ask a peer to review work
```json
{
  "type": "review_request",
  "phase": "01-auth",
  "files_changed": ["src/auth/jwt.ts", "src/auth/middleware.ts"],
  "summary_path": ".prd/phases/01-auth/01-SUMMARY.md",
  "criteria": "Check for OWASP auth vulnerabilities, verify token expiry logic"
}
```

### review_response — Return review findings
```json
{
  "type": "review_response",
  "phase": "01-auth",
  "verdict": "approved",
  "findings": [
    { "severity": "info", "file": "src/auth/jwt.ts", "line": 42, "note": "Consider adding refresh token rotation" }
  ]
}
```

**Verdicts**: `approved`, `changes_requested`, `blocked`

### result — Report task completion
```json
{
  "type": "result",
  "phase": "01-auth",
  "task_group": "TG-1",
  "outcome": "success",
  "files_changed": ["src/auth/jwt.ts", "src/auth/middleware.ts", "src/auth/session.ts"],
  "summary": "JWT middleware implemented with 15-minute access tokens and 7-day refresh tokens",
  "tests_passing": true
}
```

**Outcomes**: `success`, `partial`, `failed`

### broadcast — Notify all peers
```json
{
  "type": "broadcast",
  "event": "merge_freeze",
  "message": "Sprint review starting — do not push to main",
  "expires": "2025-01-15T18:00:00Z"
}
```

**Common events**: `merge_freeze`, `review_ready`, `sprint_complete`, `blocker_found`, `context_update`

## Free-Form Messages

For ad-hoc coordination, plain text is fine:
```
"Hey, I'm done with the auth module — you can start on the API routes now"
```

Receiving agents should check if the message parses as JSON. If not, treat as free-form.

## Parsing Pattern

```
1. Try JSON.parse(message)
2. If valid JSON with "type" field → route by type
3. If valid JSON without "type" → treat as free-form with metadata
4. If not JSON → treat as plain text
```

## Sender Context

Messages delivered via channel push include sender metadata:
- `from`: peer ID
- `summary`: sender's current work summary
- `cwd`: sender's working directory
- `timestamp`: when the message was sent

Use `from` + `summary` to understand who is messaging and what they're working on.
