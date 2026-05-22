# Recipe: prompt_delivery

## Trigger
Context overflow, token limit exceeded, agent dispatch failure, empty agent response, timeout on dispatch.

## Severity
`degraded` — Auto-recoverable: Yes (one attempt)

## Steps

1. Check the prompt size — is the context window being exceeded?
2. If context overflow: summarize or truncate the payload, then retry the dispatch.
3. If agent dispatch failed with a tool error: log the error, wait 2 seconds, retry once.
4. If empty agent response: check that the `subagent_type` value matches a real agent definition.
5. If still failing after one retry: escalate with the dispatch payload size and the error.

## Auto-Fix: Reduce scope and retry once
- Strip non-essential context from the prompt (verbose logs, large file contents)
- Retry the dispatch with the reduced payload
- If retry succeeds: note in the output that context was trimmed
- If retry fails: escalate

## Escalation Message
> Agent dispatch failed after one retry. Provide the user with the failing subagent_type, the error message, and the approximate prompt size.
