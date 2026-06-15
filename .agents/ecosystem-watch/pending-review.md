# Ecosystem Watch — Pending Human Review

HIGH-classified findings. Each item requires manual review before a bulletin is written.
Run `/cks:learn` and paste the title/URL to create the bulletin after review.

---

## [2026-06-15] anthropic: Statement on the US government directive to suspend access to Fable 5 and Mythos 5
- URL: https://www.anthropic.com/news/fable-mythos-access
- Classified: HIGH / SECURITY
- Affects: api-design, security-hardening
- Action: Run `/cks:learn` and paste this title/URL to create the bulletin. The US government issued an export control directive suspending all access to Fable 5 and Mythos 5 for foreign nationals. Any team using these models with international employees or foreign-national API consumers is potentially affected.

## [2026-06-15] vercel: Deprecating the DHE cipher suite for TLS connections
- URL: https://vercel.com/changelog/deprecating-the-dhe-cipher-suite-for-tls-connections
- Classified: HIGH / DEPRECATION
- Affects: security-hardening, environment-management
- Action: Run `/cks:learn` and paste this title/URL to create the bulletin. DHE cipher deprecation may affect clients using older TLS configurations. Verify no deployed apps depend on DHE cipher suites.

## [2026-06-15] vercel: Summary of CVE-2026-23869
- URL: https://vercel.com/changelog/summary-of-cve-2026-23869
- Classified: HIGH / SECURITY
- Affects: security-hardening, cicd-starter
- Action: Run `/cks:learn` and paste this title/URL to create the bulletin. CVE in Next.js affecting App Router across versions 13.x-16.x. Detected April 2026 — not previously tracked. Review whether deployed Next.js apps are patched.

## [2026-06-15] vercel: Next.js May 2026 security release
- URL: https://vercel.com/changelog/next-js-may-2026-security-release
- Classified: HIGH / SECURITY
- Affects: security-hardening, cicd-starter
- Action: Run `/cks:learn` and paste this title/URL to create the bulletin. Coordinated security release addressed 13 advisories across DoS, middleware bypass, SSRF, cache poisoning, and XSS. May 7, 2026 — not previously tracked. Confirm all Next.js apps are on a patched version.

## [2026-06-15] vercel: New deployments of vulnerable Next.js applications are now blocked by default
- URL: https://vercel.com/changelog/new-deployments-of-vulnerable-next-js-applications-are-now-blocked-by
- Classified: HIGH / SECURITY
- Affects: security-hardening, cicd-starter
- Action: Run `/cks:learn` and paste this title/URL to create the bulletin. Vercel now blocks deployments of apps with known-vulnerable Next.js versions. Any CKS-scaffolded project using an older Next.js version may fail to deploy. Update Next.js dependencies before next deploy.
