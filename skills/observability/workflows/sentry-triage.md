# Sentry Triage Workflow

Authenticate → list issues → drill → suggest fix.

## Prerequisites

- `SENTRY_AUTH_TOKEN` env var set
- Sentry project and organization slug known (or discoverable via API)

If `SENTRY_AUTH_TOKEN` is not set:
- Report: "Sentry is not configured. Set `SENTRY_AUTH_TOKEN` to enable error triage."
- Suggest: "To set up Sentry, see the `monitoring` skill."

## Step 1: Authenticate

Use the Sentry MCP for OAuth authentication:
```
mcp__plugin_sentry_sentry__authenticate
mcp__plugin_sentry_sentry__complete_authentication
```

For direct REST API calls, use `SENTRY_AUTH_TOKEN` as a Bearer token:
```
Authorization: Bearer ${SENTRY_AUTH_TOKEN}
```

Base URL: `https://sentry.io/api/0/`

## Step 2: Discover Organization and Projects

```
GET https://sentry.io/api/0/organizations/
```

Pick the relevant organization slug, then:

```
GET https://sentry.io/api/0/projects/
```

Match project slug to the current repo name.

## Step 3: List Unresolved Issues

```
GET https://sentry.io/api/0/projects/{org-slug}/{project-slug}/issues/?is_unresolved=true&limit=25
```

Sort options (add as query param `?sort=`):
- `freq` — by event count (most frequent first)
- `date` — by last seen (most recent first)
- `new` — by first seen (newest regressions first)

Default to `freq` for initial triage.

## Step 4: Tag with Git SHA (Optional)

Get current SHA:
```bash
git rev-parse HEAD
```

Filter Sentry issues by release:
```
GET https://sentry.io/api/0/projects/{org-slug}/{project-slug}/issues/?release={sha}&is_unresolved=true
```

This surfaces issues that first appeared in the current commit — useful for catching regressions immediately after deploy.

## Step 5: Drill Into a Specific Issue

```
GET https://sentry.io/api/0/issues/{issue-id}/events/latest/
```

From the response, extract:
- `exception.values[].stacktrace.frames` — stack frames (file, function, line)
- `tags` — release, environment, user context
- `contexts.runtime` — Node/Python/etc. version
- `breadcrumbs` — events leading up to the error

## Step 6: Group by Release

```
GET https://sentry.io/api/0/projects/{org-slug}/{project-slug}/issues/?query=is:unresolved&sort=date&groupStatsPeriod=24h
```

Compare `firstSeen` against deploy timestamps to identify regressions introduced by a specific release.

## Step 7: Report

Present findings as:

```
SENTRY TRIAGE REPORT
━━━━━━━━━━━━━━━━━━━━
Project:   {project-slug}
Unresolved issues: {N}
Queried:   {timestamp}

TOP ISSUES
━━━━━━━━━━
#1  {issue title} — {N} events, last seen {time}
    File: {file}:{line}
    First seen: {date} (release: {release})

#2  {issue title} ...

SUGGESTED NEXT STEPS
━━━━━━━━━━━━━━━━━━━━
/cks:debug "TypeError: ..."   → trace root cause in code
```
