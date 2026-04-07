# Directive Protocol

Directives are messages from a main session to worker sessions for coordination and deconfliction. Sent via `send_message`, received via channel push.

## Directive Types

### directive_stop
Main tells a worker to stop working on specific files/features.
```json
{
  "type": "directive_stop",
  "reason": "I'm already implementing auth middleware in this session",
  "files": ["src/auth/middleware.ts", "src/auth/session.ts"],
  "feature": "F-004"
}
```

### directive_redirect
Main tells a worker to switch to a different task.
```json
{
  "type": "directive_redirect",
  "from": "F-004 Auth",
  "to": "F-010 Standings",
  "reason": "Auth is blocked on API key — switch to standings which is ready"
}
```

### directive_priority
Main tells a worker to reorder their work.
```json
{
  "type": "directive_priority",
  "message": "Finish the current phase before starting review — release is tomorrow"
}
```

### status_request
Main asks a worker for detailed status.
```json
{
  "type": "status_request",
  "detail": "What files have you changed? What's left?"
}
```

### info
General notification — no action required.
```json
{
  "type": "info",
  "message": "Merge freeze in 30 minutes — wrap up and push"
}
```

## Receiving Directives

When a worker session receives a directive via channel push:

1. **directive_stop**: Immediately stop work on the specified files. Announce updated summary.
2. **directive_redirect**: Finish current atomic operation, then switch. Announce new task.
3. **directive_priority**: Acknowledge and adjust work order. No need to stop current work.
4. **status_request**: Respond with current phase, feature, changed files, remaining work.
5. **info**: Acknowledge. No action needed unless the info implies urgency.

## Plain Text Directives

The main session can also send plain text directives via natural language:
```
"Hey, stop working on auth — I've got it covered here"
```

The receiving Claude session understands natural language. Structured JSON is optional — it helps with parsing but isn't required.
