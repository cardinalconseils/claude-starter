# Feature Context: Phase 02 — Applicant CSV export

## 1. Problem
Employers copy applicants by hand into spreadsheets; Acme Plomberie asked for a download.

## 2. User stories
- As an employer, I download every applicant on my jobs as one CSV so my office can call them.

## 3. Acceptance criteria
- AC-1: `GET /api/employers/me/applicants.csv` returns `text/csv` with header `name,email,phone,job,applied_at`.
- AC-2: Values containing commas, quotes or newlines are quoted per RFC 4180.
- AC-3: An employer never receives another employer's applicants.
- AC-4: A request without an employer token returns 401.

## 4. Out of scope
Scheduled or emailed exports. XLSX.

## 5. Test plan
Unit tests for the CSV serializer; integration test on the route with two employers.

## 6. UAT
Marie Tremblay (Acme) downloads and opens the file in Excel FR.

## 7. Data
Reads `applicants` joined to `jobs`; no new tables.

## 8. Dependencies
None.

## 9. Non-functional
Under 2 s for 5,000 rows.

## 10. Rollout
Behind the employer dashboard; no flag.

## 11. Definition of done
AC-1..AC-4 verified; VERIFICATION.md PASS.

## 12. Maturity
Pilot.
