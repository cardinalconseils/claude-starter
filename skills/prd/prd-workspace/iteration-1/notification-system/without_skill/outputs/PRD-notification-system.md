# Product Requirements Document: Process Status Notification System

**Date:** 2026-03-23
**Status:** Draft
**Author:** Claude (AI-assisted planning)

---

## 1. Problem Statement

When an admin approves a process (changing its status from "Draft" or "Pending Approval" to "Approved"), the user who created or submitted that process has no way of knowing unless they manually revisit the app and check. This creates a communication gap in the approval workflow and slows down process adoption.

## 2. Goal

Build a notification system that:
1. Alerts relevant users when a process status changes (primarily Draft/Pending Approval to Approved).
2. Provides in-app notifications as the first delivery channel.
3. Supports email notifications as a future second channel.

## 3. Current Architecture Context

### Relevant Stack
- **Frontend:** React 18 with hooks-based state management (no Redux/Zustand)
- **Backend:** Express server (dev/prod serving only; no business logic endpoints)
- **Database:** Firebase Firestore with real-time listeners
- **Auth:** Firebase Google OAuth with role-based access (admin/editor/viewer)
- **Types:** `ProcessStatus = 'Draft' | 'Pending Approval' | 'Approved'`

### Current Status Change Flow
1. `ProcessFlow.tsx` has an `updateStatus()` function that writes directly to Firestore via `updateDoc()`.
2. Status transitions are:
   - **Draft -> Pending Approval** (editor or admin clicks "Submit")
   - **Pending Approval -> Approved** (admin clicks "Approve")
   - **Pending Approval -> Draft** (admin clicks "Reject" / returns to draft)
3. The `EditProcessModal.tsx` also allows direct status changes via a dropdown select.
4. No notification infrastructure currently exists.

### Users & Roles
- **Admin:** Can approve/reject processes. Should be notified when processes are submitted for approval.
- **Editor:** Can create and submit processes. Should be notified when their processes are approved or rejected.
- **Viewer:** Read-only. May want to be notified when processes they follow are approved.

## 4. Requirements

### 4.1 Notification Triggers

| Trigger Event | Status Change | Notify Who |
|---|---|---|
| Process Submitted | Draft -> Pending Approval | All admins |
| Process Approved | Pending Approval -> Approved | Process creator (`createdBy`) + last editor (`updatedBy`) |
| Process Rejected | Pending Approval -> Draft | Process creator (`createdBy`) + last editor (`updatedBy`) |

### 4.2 In-App Notifications (Phase 1)

**Data Model - Firestore `notifications` collection:**

```typescript
interface Notification {
  id: string;
  recipientUid: string;       // user who should see this
  type: 'status_change';       // extensible for future types
  processId: string;           // reference to the process
  processTitle: string;        // denormalized for display
  previousStatus: ProcessStatus;
  newStatus: ProcessStatus;
  triggeredBy: string;         // uid of user who made the change
  triggeredByName: string;     // denormalized display name
  read: boolean;
  createdAt: Timestamp;
}
```

**UI Components:**

- **NotificationBell:** Icon in the top nav bar (App.tsx header) showing unread count badge.
- **NotificationPanel:** Dropdown/slide-out panel listing recent notifications, sorted newest-first.
- **NotificationItem:** Individual notification row with:
  - Process title (linked to process)
  - Status change description (e.g., "Marketing Onboarding was approved by Admin User")
  - Timestamp (relative, e.g., "2 hours ago")
  - Read/unread visual indicator
  - Click to navigate to the process and mark as read

**Behavior:**

- Real-time updates via Firestore `onSnapshot` listener filtered by `recipientUid`.
- Clicking a notification navigates to the process and marks it as read.
- "Mark all as read" action available.
- Notifications persist for 90 days (cleanup via scheduled function or TTL).
- Maximum 50 notifications shown in the panel; older ones accessible via "View all" (future).

### 4.3 Email Notifications (Phase 2 - Future)

**Approach:** Firebase Cloud Functions triggered by Firestore document writes.

- A Cloud Function listens to writes on the `notifications` collection (or the `processes` collection status field).
- Checks user preferences for email opt-in.
- Sends email via a transactional email service (SendGrid, Mailgun, or Firebase Extensions for email).
- Email contains: process title, old/new status, link to the process in the app, who triggered the change.

**User Preferences (extends UserProfile):**

```typescript
interface NotificationPreferences {
  inApp: boolean;        // default: true
  email: boolean;        // default: false
  emailDigest: 'instant' | 'daily' | 'none';  // default: 'none'
}
```

### 4.4 Non-Functional Requirements

- Notifications must appear within 2 seconds of the status change (leveraging Firestore real-time).
- The notification bell must not cause additional Firestore reads when there are no changes (use snapshot listeners, not polling).
- Notification writes must not block the status update operation (write notification after successful status update).
- The system must handle the case where the creator and updater are the same person (send only one notification).
- Do not notify the user who performed the action (e.g., if an admin approves, do not notify that admin).

## 5. Out of Scope

- Push notifications (browser/mobile)
- Notification preferences UI (Phase 2 alongside email)
- Notifications for non-status events (e.g., process edited, comment added)
- Notification grouping/batching for in-app display
- Admin notification management panel

## 6. Firestore Security Rules (Additions)

```
match /notifications/{notificationId} {
  // Users can only read their own notifications
  allow read: if request.auth != null && resource.data.recipientUid == request.auth.uid;
  // Only the system (or authenticated users performing status changes) can create
  allow create: if request.auth != null;
  // Users can only update the 'read' field of their own notifications
  allow update: if request.auth != null
    && resource.data.recipientUid == request.auth.uid
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['read']);
  allow delete: if false;
}
```

## 7. Success Metrics

- 100% of status changes generate appropriate notifications within 2 seconds.
- Unread notification count is accurate in real-time across all connected clients.
- No duplicate notifications for the same event.
- Zero impact on existing status change performance (< 100ms additional latency).

## 8. Open Questions

1. Should viewers be able to "watch" a process and receive notifications when it is approved?
2. Should there be a notification when a process is deleted?
3. What is the desired notification retention period? (Proposed: 90 days)
4. For email (Phase 2): Which email service provider is preferred?
