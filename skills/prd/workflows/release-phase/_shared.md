# Shared: Release Phase Variables & Banners

## Variables

- `{NN}` — phase number (e.g., `01`)
- `{name}` — phase name (e.g., `user-authentication`)
- `{number}` — PR number from Sprint [3g]
- `{preview_url}` — dev/preview URL
- `{staging_url}` — staging URL
- `{rc_url}` — release candidate URL
- `{production_url}` — production URL
- `{platform}` — deployment platform (Vercel, Railway, etc.)

## Progress Banner Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► RELEASE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ✅ done (PR #{number})
 [4] Review      ✅ done — approved for release
 [5] Release     ▶ current
     [5a] Dev Deploy             ○ pending
     [5b] Staging Deploy         ○ pending
     [5c] RC Deploy + E2E        ○ pending
     [5d] Production Deploy      ○ pending
     [5e] Post-Deploy            ○ pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Completion Banner Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD ► Phase {NN}: {name} ► RELEASED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 [1] Discover    ✅ done
 [2] Design      ✅ done
 [3] Sprint      ✅ done
 [4] Review      ✅ done
 [5] Release     ✅ done
     [5a] Dev Deploy             ✅ validated
     [5b] Staging Deploy         ✅ feedback positive
     [5c] RC Deploy + E2E        ✅ {pass}/{total} passed
     [5d] Production Deploy      ✅ {platform}
     [5e] Post-Deploy            ✅ monitoring active

 Feature: PRD-{NNN} — {name}
 PR: #{number} ({url})
 Production: {production_url}

 discover ✅ → design ✅ → sprint ✅ → review ✅ → release ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next:
  /cks:new "next feature"    ← start next feature from roadmap
  /cks:progress              ← see overall project status
```
