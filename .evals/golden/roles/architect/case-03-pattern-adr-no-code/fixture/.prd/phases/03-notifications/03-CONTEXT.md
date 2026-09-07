# Feature Context: Phase 03 — Applicant notification emails
## 1. Problem
Employers miss new applicants. Send an email per application; retry with exponential backoff on provider errors and park undeliverable notifications in a dead-letter queue for review.
## 3. Acceptance criteria
- AC-1: A transient provider error is retried up to 5 times with exponential backoff.
- AC-2: After the last retry the notification lands in a dead-letter table with the error.
