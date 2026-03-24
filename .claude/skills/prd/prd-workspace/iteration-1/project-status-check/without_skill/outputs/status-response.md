# ProcessFlow AI -- Project Status Report

**Date:** 2026-03-23

---

## Current State

ProcessFlow AI is a React + Firebase + XY Flow application for business process management. The app is functional at a **prototype/MVP stage** with the core features built but significant gaps in production-readiness.

### What's Built and Working

- **Authentication:** Google OAuth via Firebase with role-based access (admin/editor/viewer) and auto-admin promotion for a hardcoded email.
- **Process Catalog:** Department-based browsing with real-time Firestore sync. Users can view, create, edit, and delete processes.
- **BPMN Diagram Visualization:** Custom swimlane layout engine using dagre + XY Flow (ReactFlow). Supports task, gateway, event, and swimlane node types with automatic positioning.
- **Approval Workflow:** Draft -> Pending Approval -> Approved status transitions with role-based controls.
- **AI Features (Gemini):** SOP generation, benchmarking/improvement suggestions, AI chatbot assistant, and document-to-process extraction (file upload in AdminPanel).
- **Process Editing:** EditProcessModal for metadata, inline node adding, and diagram save.
- **Admin Panel:** Department CRUD, user listing, file upload with AI extraction.
- **Firestore Security Rules:** Defined in `firestore.rules` with role-based read/write controls and data validation.

### What's In Progress (Uncommitted Changes)

The `src/components/ProcessFlow.tsx` file has significant uncommitted modifications (+232 lines changed). The current version includes an improved dagre-based swimlane layout engine with better vertical stacking, cross-lane edge styling, dynamic lane heights, and responsive lane widths. Several `.claude/` config files are being reorganized (old nested structure deleted, new flat structure added).

---

## Key Gaps and Risks

### Critical (Address First)

1. **No Tests Whatsoever.** Zero test files, no test framework configured, no CI pipeline. Every change is a risk.
2. **API Key Exposed in Frontend.** The Gemini API key (`process.env.GEMINI_API_KEY`) is used directly in browser-side code (`ProcessFlow.tsx`, `ChatBot.tsx`, `AdminPanel.tsx`). Anyone can extract it from the build.
3. **No Environment Validation.** The app boots without checking for required env vars. AI features fail silently with cryptic errors.
4. **Hardcoded Admin Email.** `info@pmcardinal.com` is hardcoded in both `App.tsx` and `firestore.rules`. No way to manage admins without code changes.

### High Priority

5. **Large Monolithic Components.** `AdminPanel.tsx` and `ProcessFlow.tsx` are 400-500+ lines each, mixing concerns (UI, data, AI, modals).
6. **Inconsistent Gemini Model Versions.** Three different model strings hardcoded across three files: `"gemini-3-flash-preview"` in ProcessFlow, `"gemini-3.1-flash-preview"` in AdminPanel and ChatBot.
7. **No Process Version History.** The `version` field increments but previous versions are not stored. No diff/rollback capability.
8. **Excessive `any` Types.** TypeScript safety is undermined throughout -- node arrays, edge arrays, error boundary props, Firestore timestamps all typed as `any`.
9. **`alert()` for User Feedback.** All success/error feedback uses `window.alert()`, blocking the UI thread.

### Medium Priority

10. **No Undo/Redo** for diagram editing.
11. **No Audit Logging.** Operations logged to console only.
12. **Hard Deletes.** Processes and departments are permanently deleted with no recovery path.
13. **Export and Share Buttons are Stubs.** The Export/Share buttons in ProcessFlow render but have no functionality.
14. **AI Streaming Re-render Thrashing.** Every chunk from the Gemini stream triggers a React state update with no debouncing.
15. **No Offline Support.** Edits are lost if the connection drops.

---

## Recommended Next Steps (Priority Order)

### 1. Secure the API Key (Immediate -- Security)
Move all Gemini API calls to the Express backend (`server.ts`). Create `/api/ai/sop`, `/api/ai/benchmark`, and `/api/ai/chat` endpoints. The backend already imports `@google/genai` and `express`. This closes the most critical security hole.

**Files to change:** `server.ts`, `src/components/ProcessFlow.tsx`, `src/components/ChatBot.tsx`, `src/components/AdminPanel.tsx`

### 2. Set Up Vitest + Basic Tests (Immediate -- Foundation)
Install Vitest and React Testing Library. Write tests for:
- `getLayoutedElements()` in ProcessFlow (pure function, easy to test)
- `handleFirestoreError()` in firebase.ts
- Status transition logic

This gives you a safety net before refactoring.

**New files:** `vitest.config.ts`, `src/components/ProcessFlow.test.tsx`, `src/firebase.test.ts`

### 3. Create a Shared Config Module (Quick Win)
Extract the Gemini model name, admin email, and other constants into a single `src/config.ts`. This eliminates the inconsistent model versions and hardcoded values.

**New file:** `src/config.ts`

### 4. Refactor Large Components (Tech Debt)
Break apart the monolithic components:
- **ProcessFlow.tsx:** Extract `AiContentModal`, `ProcessInfoSidebar`, `DiagramControls`, `NotesPanel` as separate components.
- **AdminPanel.tsx:** Extract `DepartmentManager`, `UserManager`, `FileUploadProcessor`.

### 5. Replace `alert()` with Toast Notifications (UX)
Add a lightweight toast library (e.g., sonner or react-hot-toast) to replace all `alert()` calls. This is a high-impact UX improvement with low effort.

### 6. Implement Export Functionality (Feature Gap)
The Export button is rendered but does nothing. Implement PDF or PNG export of the process diagram using ReactFlow's `toObject()` and a library like html-to-image or jspdf.

### 7. Add Process Version History (Feature)
Store previous versions in a Firestore subcollection (`processes/{id}/versions`). Enable diff view and rollback.

---

## Architecture Summary

```
src/
  App.tsx              -- Root: auth, routing, department/process list, error boundary
  main.tsx             -- React entry point
  types.ts             -- All TypeScript interfaces (UserProfile, Department, Process, etc.)
  firebase.ts          -- Firebase init, auth, db, error handling
  index.css            -- Tailwind CSS
  components/
    ProcessFlow.tsx    -- BPMN diagram viewer/editor with AI actions
    AdminPanel.tsx     -- Department/user management, file upload + AI extraction
    ChatBot.tsx        -- AI assistant conversation
    EditProcessModal.tsx -- Process metadata editor
    OnboardingModal.tsx  -- File upload onboarding flow
    BpmnNodes.tsx      -- Custom ReactFlow node components (Task, Gateway, Event)
    ui.tsx             -- Reusable UI primitives (Button, Card, Input)
server.ts              -- Express server (Vite dev middleware + production static)
firestore.rules        -- Firestore security rules
```

**Stack:** React 19, TypeScript, Vite 6, Tailwind CSS 4, Firebase 12 (Auth + Firestore), XY Flow 12, dagre, Google Gemini AI, Express, Framer Motion

---

## Commit Status

- **5 commits** on `main` branch (initial commit through architecture docs)
- **Uncommitted changes:** Major rewrite of `ProcessFlow.tsx` layout engine, `.claude/` directory restructure
- **No branches** other than `main`
- **No CI/CD** configured
- **No deployment** pipeline (Railway referenced in CLAUDE.md but not set up)
