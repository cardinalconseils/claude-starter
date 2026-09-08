# Feature Context: Phase 03 — CSV serializer
## 3. Acceptance criteria
- AC-1: header `name,email,phone,job,applied_at`; empty input returns the header only; lines end with CRLF.
- AC-2: values containing commas, quotes or newlines are quoted and inner quotes doubled.
