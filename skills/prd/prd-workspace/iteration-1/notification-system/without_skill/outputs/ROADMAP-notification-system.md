# Implementation Roadmap: Process Status Notification System

**Date:** 2026-03-23

---

## Phase 1: In-App Notifications

### Step 1: Types & Data Model
**Files to create/modify:** `src/types.ts`

- Add `Notification` interface to `src/types.ts`.
- Add `NotificationPreferences` interface (with defaults, for forward compatibility).
- Extend `UserProfile` with optional `notificationPreferences` field.

**Estimated effort:** 30 minutes

### Step 2: Notification Creation Logic
**Files to create:** `src/notifications.ts`

Create a utility module with:

```
createNotification(recipientUid, processId, processTitle, previousStatus, newStatus, triggeredByUid, triggeredByName)
```

- Writes a new document to the `notifications` Firestore collection.
- Handles deduplication: do not notify the user who performed the action.
- Handles the case where `createdBy === updatedBy` (single notification).

**Why a separate module:** Keeps notification logic decoupled from UI components. Both `ProcessFlow.tsx` and `EditProcessModal.tsx` can call it.

**Estimated effort:** 1 hour

### Step 3: Integrate Notification Creation into Status Changes
**Files to modify:** `src/components/ProcessFlow.tsx`, `src/components/EditProcessModal.tsx`

- After a successful `updateDoc` call that changes `status`, call the notification creation function.
- Determine recipients based on the transition type:
  - Draft -> Pending Approval: query all admin users from Firestore `users` collection.
  - Pending Approval -> Approved: notify `createdBy` and `updatedBy` (deduplicated, excluding actor).
  - Pending Approval -> Draft (rejection): notify `createdBy` and `updatedBy` (deduplicated, excluding actor).

**Key consideration:** The `updateStatus` function in `ProcessFlow.tsx` (line 267) is the primary place. The `EditProcessModal.tsx` dropdown also allows status changes and needs the same integration.

**Estimated effort:** 1.5 hours

### Step 4: Notification Bell Component
**Files to create:** `src/components/NotificationBell.tsx`

- Bell icon (use Lucide `Bell` icon, already in the project's icon library).
- Real-time Firestore `onSnapshot` listener on `notifications` collection, filtered by `where('recipientUid', '==', currentUser.uid)`, ordered by `createdAt desc`, limited to 50.
- Unread count badge (red circle with number).
- Click toggles the NotificationPanel.

**Estimated effort:** 1.5 hours

### Step 5: Notification Panel & Items
**Files to create:** `src/components/NotificationPanel.tsx`

- Dropdown panel (absolute positioned below the bell icon, or a slide-out from the right).
- Renders list of `NotificationItem` components.
- Each item shows:
  - Status change icon (color-coded: green for approved, amber for pending, gray for draft/rejected).
  - "{processTitle} was {approved/submitted/returned to draft} by {triggeredByName}"
  - Relative timestamp.
  - Bold/unread styling for `read: false`.
- "Mark all as read" button at the top.
- Empty state: "No notifications yet."
- Click on item: update `read: true` on that document, navigate to the process.

**Estimated effort:** 2 hours

### Step 6: Integrate Bell into App Layout
**Files to modify:** `src/App.tsx`

- Add `NotificationBell` to the header/nav bar, next to the user profile area.
- Pass `user` prop for the Firestore query.
- Wire up process navigation callback (set `selectedProcess` state).

**Estimated effort:** 30 minutes

### Step 7: Firestore Index & Security Rules
**Files to modify:** `firestore.rules` (or Firebase console), `firestore.indexes.json`

- Add composite index: `notifications` collection on `(recipientUid ASC, createdAt DESC)`.
- Add security rules as specified in the PRD.

**Estimated effort:** 30 minutes

### Step 8: Testing & Edge Cases

Verify:
- [ ] Admin approves a process -> creator gets notification.
- [ ] Editor submits a process -> all admins get notifications.
- [ ] Admin rejects a process -> creator gets notification.
- [ ] User who performs the action does NOT get self-notification.
- [ ] Clicking notification navigates to the correct process.
- [ ] Unread count updates in real-time across tabs.
- [ ] "Mark all as read" works correctly.
- [ ] Status change via EditProcessModal also triggers notifications.
- [ ] Multiple rapid status changes create separate notifications.
- [ ] Bell renders correctly on mobile (responsive).

**Estimated effort:** 2 hours

---

## Phase 1 Total Estimate: ~9.5 hours

---

## Phase 2: Email Notifications (Future)

### Step 2.1: Firebase Cloud Functions Setup
- Initialize Firebase Functions in the project (`firebase init functions`).
- Create a Firestore-triggered function that listens to `notifications` collection `onCreate`.

### Step 2.2: Email Service Integration
- Set up a transactional email service (SendGrid recommended for Firebase projects).
- Create email templates for each notification type.
- Cloud Function checks user's `notificationPreferences.email` before sending.

### Step 2.3: User Preferences UI
- Add a settings/preferences panel accessible from the user menu.
- Toggle switches for in-app and email notifications.
- Email digest frequency selector (instant / daily / none).
- Persist to `users/{uid}/notificationPreferences` in Firestore.

### Step 2.4: Daily Digest (Optional)
- Scheduled Cloud Function (Firebase cron) that aggregates unread notifications.
- Sends a single digest email to users with `emailDigest: 'daily'`.

---

## File Impact Summary

### New Files (Phase 1)
| File | Purpose |
|---|---|
| `src/types.ts` | Add Notification interface (modify existing) |
| `src/notifications.ts` | Notification creation utility functions |
| `src/components/NotificationBell.tsx` | Bell icon with unread badge |
| `src/components/NotificationPanel.tsx` | Notification list dropdown/panel |

### Modified Files (Phase 1)
| File | Change |
|---|---|
| `src/types.ts` | Add Notification and NotificationPreferences interfaces |
| `src/components/ProcessFlow.tsx` | Call notification creation after status updates (around line 267-275) |
| `src/components/EditProcessModal.tsx` | Call notification creation when status changes via modal save |
| `src/App.tsx` | Add NotificationBell to header, wire navigation callback |

### Firestore Changes
| Collection | Action |
|---|---|
| `notifications` | New collection |
| Indexes | Composite index on (recipientUid, createdAt) |
| Rules | Read/write rules for notifications collection |

---

## Architecture Decision: Client-Side vs Cloud Functions

For Phase 1, notification documents are created **client-side** (from the React app) immediately after a successful status update. This is chosen because:

1. **No Cloud Functions infrastructure exists** in the current project.
2. **Simplicity:** Avoids adding a new runtime/deployment target.
3. **Speed:** Notification is written in the same client session, no function cold-start delay.
4. **Trade-off:** A malicious client could skip notification creation, but since status changes are already trusted client operations (protected by Firestore rules), this is acceptable.

For Phase 2 (email), Cloud Functions become necessary since email sending cannot happen client-side. At that point, notification creation could optionally be migrated to a Cloud Function trigger on the `processes` collection for consistency.

---

## Dependency Graph

```
Step 1 (Types)
  |
  v
Step 2 (Notification Logic)
  |
  +---> Step 3 (Integrate into ProcessFlow + EditProcessModal)
  |
  v
Step 4 (NotificationBell)
  |
  v
Step 5 (NotificationPanel)
  |
  v
Step 6 (Integrate into App.tsx)
  |
  v
Step 7 (Firestore Rules/Indexes)
  |
  v
Step 8 (Testing)
```

Steps 3 and 4-5 can be developed in parallel after Step 2 is complete.
