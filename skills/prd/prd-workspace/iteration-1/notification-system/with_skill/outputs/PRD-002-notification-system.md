# PRD-002: Process Status Change Notification System

**Status:** Draft
**Author:** User / Claude (PRD Skill)
**Created:** 2026-03-23
**Last Updated:** 2026-03-23
**Priority:** P1-High

## Problem Statement

When a business process transitions from Draft to Approved, the process creator and relevant admins have no way of knowing unless they manually check the process list. In a team environment with dozens of processes across multiple departments, this means approvals go unnoticed, downstream work stalls, and users waste time polling the UI for status changes.

## Motivation

The approval workflow (Draft -> Pending Approval -> Approved) already exists in the application, but it is a "fire and forget" action — the admin clicks Approve, the Firestore document updates, and nobody is actively told. As the user base grows and more departments onboard, this communication gap will become a bottleneck. Notifications close this loop and make the approval workflow actionable.

## Personas

| Persona | Role | Goal | Context |
|---------|------|------|---------|
| Process Author | Editor/Admin | Know immediately when my submitted process is approved | Submitted a process, waiting for approval, working on other things |
| Department Admin | Admin | Stay informed about approval activity across my processes | Responsible for approving processes and tracking department workflow |
| Viewer | Viewer | (Phase 2+) Be notified about processes relevant to me | Passive consumer who needs to act on newly approved processes |

## Solution Overview

A notification system with two delivery channels, rolled out in phases:

1. **In-app notifications** — A bell icon in the top nav with a dropdown showing recent notifications. Notifications are stored in a Firestore `notifications` collection, scoped per user, with real-time listeners for instant delivery.
2. **Email notifications** (future phase) — A Firebase Cloud Function triggers on Firestore writes to the `processes` collection, detects status transitions, and sends email via a transactional email provider.

**Data flow:**
```
Process status changes in Firestore
        |
        v
Cloud Function (onUpdate trigger on `processes` collection)
        |
        ├──> Write notification doc to `notifications/{userId}`
        |
        └──> (Phase 3) Send email via SendGrid / Firebase Extension

Client-side:
  onSnapshot listener on `notifications/{userId}` subcollection
        |
        v
  Bell icon badge count updates in real-time
        |
        v
  Dropdown renders notification list with links to processes
```

## Detailed Requirements

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-1 | When a process status changes from any state to Approved, a notification is created for the process creator | Must |
| FR-2 | When a process status changes from any state to Approved, a notification is created for all admin users | Must |
| FR-3 | A bell icon in the top navigation bar shows the count of unread notifications | Must |
| FR-4 | Clicking the bell icon opens a dropdown listing recent notifications (most recent first) | Must |
| FR-5 | Each notification displays: process title, old status, new status, who approved it, and timestamp | Must |
| FR-6 | Clicking a notification navigates the user to the relevant process | Must |
| FR-7 | Users can mark individual notifications as read | Must |
| FR-8 | Users can mark all notifications as read | Should |
| FR-9 | Notifications older than 30 days are automatically cleaned up | Should |
| FR-10 | The system is extensible to support additional status transitions beyond Draft->Approved | Should |
| FR-11 | Email notifications are sent for approval events | Could (Phase 3) |
| FR-12 | Users can configure notification preferences (on/off per channel) | Could (Phase 4) |

### Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-1 | In-app notification delivery latency | < 2 seconds after status change |
| NFR-2 | Notification dropdown render time | < 500ms |
| NFR-3 | Notification storage per user | Max 100 retained, oldest pruned |
| NFR-4 | No impact on process save performance | < 200ms added latency |

## User Stories

1. As a **process author**, I want to see a notification when my process is approved so that I know it is finalized and can proceed with downstream work.
2. As an **admin**, I want to see notifications for all process approvals so that I have visibility into approval activity across the organization.
3. As any **logged-in user**, I want to click on a notification and be taken directly to the relevant process so that I can review it immediately.
4. As any **logged-in user**, I want to mark notifications as read so that I can track what I have and have not reviewed.

## Acceptance Criteria

- [ ] When an admin approves a process (status changes to "Approved"), a notification document is created in Firestore for the process creator
- [ ] When an admin approves a process, notification documents are created for all admin users
- [ ] A bell icon appears in the top navigation bar for all authenticated users
- [ ] The bell icon displays a red badge with the count of unread notifications (hidden when count is 0)
- [ ] Clicking the bell icon opens a dropdown with up to 20 most recent notifications
- [ ] Each notification shows process title, transition description, approver name, and relative timestamp
- [ ] Clicking a notification navigates to the ProcessFlow view for that process
- [ ] Clicking a notification marks it as read
- [ ] A "Mark all as read" button exists and functions correctly
- [ ] Notifications appear in real-time without page refresh (Firestore onSnapshot)
- [ ] The notification system does not break existing process save/update functionality
- [ ] UI renders correctly on both desktop and mobile viewports

## Out of Scope

- **Notification preferences / opt-out** — Deferred to a future phase. All users receive all relevant notifications for now.
- **Push notifications (browser/mobile)** — Not included. Only in-app and eventually email.
- **Notifications for status transitions other than -> Approved** — The data model supports it, but only Approved triggers are implemented in Phase 1-2. Other transitions can be added later.
- **Notification for process rejection (Approved -> Draft)** — Will be a fast follow but not in initial scope.
- **Digest / batched email notifications** — Individual emails only when email is implemented.
- **Slack / Teams / webhook integrations** — Out of scope entirely.

## Technical Design

### Architecture Impact

**Files to modify:**
- `src/types.ts` — Add `Notification` interface and `NotificationType` enum
- `src/App.tsx` — Add notification listener, pass notification state to components, integrate bell icon in top nav
- `src/components/ProcessFlow.tsx` — Trigger notification creation in `updateStatus` function (Phase 1) or move to Cloud Function (Phase 2)
- `src/firebase.ts` — Add notification helper functions (createNotification, markAsRead, markAllAsRead)

**New files:**
- `src/components/NotificationBell.tsx` — Bell icon component with badge and dropdown
- `src/components/NotificationItem.tsx` — Individual notification row component
- `functions/src/index.ts` — Firebase Cloud Function for server-side notification creation (Phase 2)

### Data Model Changes

**New Firestore collection: `notifications`**

```typescript
interface Notification {
  id: string;
  userId: string;           // Recipient user ID
  type: NotificationType;   // e.g., 'process_approved'
  processId: string;        // Reference to the process
  processTitle: string;     // Denormalized for display without extra reads
  oldStatus: ProcessStatus;
  newStatus: ProcessStatus;
  triggeredBy: string;      // UID of user who caused the change
  triggeredByName: string;  // Denormalized display name
  read: boolean;
  createdAt: Timestamp;
}

type NotificationType = 'process_approved' | 'process_rejected' | 'process_submitted';
```

**Firestore indexes needed:**
- `notifications` collection: composite index on `userId` + `createdAt` (descending) for efficient per-user queries

### API Changes

No REST API changes. All data flows through Firestore directly (Phase 1) or via Cloud Functions writing to Firestore (Phase 2).

### Dependencies

- **Phase 1:** No new dependencies. Uses existing Firebase/Firestore SDK.
- **Phase 2:** `firebase-functions` and `firebase-admin` packages for Cloud Functions.
- **Phase 3:** SendGrid SDK or Firebase Email Extension (`firebase/extensions-mail`).

## Implementation Phases

### Phase 1: Client-Side In-App Notifications
**Goal:** Deliver real-time in-app notifications when a process is approved, using client-side Firestore writes.
**Estimated Scope:** Medium

Tasks:
- [ ] Add `Notification` type and `NotificationType` to `src/types.ts`
- [ ] Create `notifications` Firestore collection structure
- [ ] Add `createNotification` and `markAsRead` helpers to `src/firebase.ts`
- [ ] Modify `updateStatus` in `ProcessFlow.tsx` to create notification docs when status changes to Approved
- [ ] Query admin users from Firestore to determine notification recipients
- [ ] Build `NotificationBell.tsx` component with badge count and dropdown
- [ ] Build `NotificationItem.tsx` component for individual notification display
- [ ] Integrate `NotificationBell` into the top nav bar in `App.tsx`
- [ ] Add real-time `onSnapshot` listener for current user's notifications
- [ ] Implement "mark as read" on click and "mark all as read" button
- [ ] Add click-to-navigate: clicking a notification selects the relevant process

Acceptance Criteria:
- [ ] Approving a process creates notification docs for the creator and all admins
- [ ] Bell icon shows unread count badge in real-time
- [ ] Dropdown lists notifications with process title, approver, and timestamp
- [ ] Clicking a notification opens the process and marks it as read
- [ ] Works on both desktop and mobile layouts

### Phase 2: Server-Side Notification Creation via Cloud Function
**Goal:** Move notification creation from client-side to a Firestore-triggered Cloud Function for reliability and extensibility.
**Estimated Scope:** Medium

Tasks:
- [ ] Initialize Firebase Functions project in `functions/` directory
- [ ] Create `onProcessStatusChange` Cloud Function triggered by Firestore `processes` document updates
- [ ] Detect status transitions by comparing `before` and `after` snapshots
- [ ] Move notification creation logic from client to Cloud Function
- [ ] Remove client-side notification creation from `ProcessFlow.tsx`
- [ ] Add support for additional transition types (submitted, rejected) in the function
- [ ] Deploy Cloud Function and verify end-to-end flow
- [ ] Add Firestore TTL policy or scheduled function for 30-day cleanup

Acceptance Criteria:
- [ ] Cloud Function fires on process status changes and creates correct notifications
- [ ] Client-side code no longer writes notification documents directly
- [ ] Notifications still appear in real-time in the UI
- [ ] Old notifications (>30 days) are cleaned up automatically

### Phase 3: Email Notifications
**Goal:** Send email notifications for process approvals alongside in-app notifications.
**Estimated Scope:** Medium

Tasks:
- [ ] Choose email provider (SendGrid or Firebase Email Extension)
- [ ] Add email sending logic to the Cloud Function
- [ ] Create email template for approval notification (process title, link, approver)
- [ ] Handle email failures gracefully (log, don't block notification creation)
- [ ] Test email delivery and spam/deliverability

Acceptance Criteria:
- [ ] Process approval triggers an email to the process creator
- [ ] Email contains process title, approver name, and a link to the process
- [ ] Email failures do not prevent in-app notification creation
- [ ] Emails are not sent to users who triggered the action themselves

### Phase 4: Notification Preferences
**Goal:** Allow users to control which notifications they receive and through which channels.
**Estimated Scope:** Small

Tasks:
- [ ] Add `notificationPreferences` field to `UserProfile` type
- [ ] Create preferences UI (settings page or modal)
- [ ] Cloud Function checks user preferences before creating notifications / sending emails
- [ ] Default all preferences to "on" for existing users

Acceptance Criteria:
- [ ] Users can toggle in-app notifications on/off
- [ ] Users can toggle email notifications on/off
- [ ] Preferences are respected by the Cloud Function
- [ ] New users default to all notifications enabled

## Success Metrics

| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| Time to learn about process approval | Unknown (manual checking) | < 5 seconds | Firestore timestamp delta between status change and notification read |
| Notification engagement rate | N/A | > 60% of notifications clicked | Count of read notifications / total notifications |
| Missed approvals (processes approved but not viewed within 24h) | Unknown | < 10% | Query processes approved >24h ago where creator hasn't viewed |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Client-side notification writes fail silently (Phase 1) | Medium | Medium | Wrap in try/catch with error logging; Phase 2 moves to server-side for reliability |
| Notification volume overwhelms admins in large orgs | Low | Medium | Cap notifications at 100 per user; add "mark all read"; Phase 4 adds preferences |
| Cloud Function cold start delays notification delivery | Medium | Low | Acceptable for non-real-time email; in-app still uses client write in Phase 1 |
| Email deliverability issues (spam filters) | Medium | Medium | Use authenticated sender domain; follow email best practices; monitor bounce rates |
| Firestore read costs increase from notification listeners | Low | Low | Query only current user's notifications; limit to 20 most recent; use composite indexes |

## Open Questions

- [ ] Should the notification badge count persist across sessions (Firestore-driven, yes by design) or reset on login?
- [ ] What is the admin email list — is it dynamically queried from Firestore `users` where role=admin, or a hardcoded list? (Assumed: dynamic query)
- [ ] For email notifications, do we need a custom domain sender or is a generic Firebase sender acceptable for MVP?

## Implementation Notes

*To be added during execution.*

---
*PRD created: 2026-03-23*
