# Recipe: trust_gate

## Trigger
Security scan failure, detected secret/credential, or CONFIDENCE.md gate failure after 2 attempts.

## Severity
`blocking` — Auto-recoverable: No

## Steps

1. Identify the file and line containing the detected secret or failing gate check.
2. Do NOT echo or display the raw credential value (see `.claude/rules/secrets.md`).
3. Check `.gitignore` — is the file already excluded? If not, add it.
4. If secret is committed: flag for human rotation. Provide rotation guidance for the credential type.
5. If CONFIDENCE.md gate: show which criterion failed and why.
6. Escalate to user — this type requires human review before proceeding.

## Auto-Fix: None
Trust gate failures require human judgment. Do not attempt automatic remediation.

## Escalation Message
> Secret detected or gate failed. Cannot auto-recover. Provide the file path and line to the user. They must rotate credentials and verify `.gitignore` before the branch can proceed.
