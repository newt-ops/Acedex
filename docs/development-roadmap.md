# ACEDEX — Development Roadmap & Milestones

This document tracks development across all phases as defined in the master plan (`docs/plan.md`).

---

## Progress Overview

| Phase | Milestone | Focus Area | Status |
|:---:|---|---|:---:|
| **1** | **Backend Foundation** | Project setup, Express, TypeScript, MongoDB layer, health checks, error handling, tests | **COMPLETED** |
| **2** | **Authentication & Sessions** | Google OAuth token verification, MongoDB User model, JWT access/refresh rotation | *UP NEXT* |
| **3** | **Curriculum & Question Banks** | Grades, Subjects, Units APIs, Question Bank models, 30-item JSON importer & validation | *PLANNED* |
| **4** | **Assessment Engine** | Question delivery, server-side scoring, protected answer isolation, idempotency | *PLANNED* |
| **5** | **Student Progress** | Progress tracking, score history, subject/unit analytics APIs | *PLANNED* |
| **6** | **Cloud Deployment** | Render backend deployment, MongoDB Atlas production setup, OpenAPI/Swagger | *PLANNED* |
| **7** | **Client Integration** | Flutter Android application & Next.js Web application integration | *PLANNED* |

---

## Phase Details

### Phase 1 — Backend Foundation (COMPLETED)
- [x] Monorepo workspace established (`apps/`, `packages/`, `content/`, `docs/`).
- [x] Backend initialized in `apps/api` with Node.js, Express, TypeScript.
- [x] Shared data contracts package (`@acedex/contracts`) initialized with Zod schemas.
- [x] Configuration with Zod-validated environment variables and `.env.example`.
- [x] Centralized MongoDB Atlas connection layer via Mongoose with auto-reconnect and health status hooks.
- [x] Robust centralized error handling middleware (`AppError` hierarchy, Mongoose, Zod, and Syntax error mappers).
- [x] High-performance structured logging via `pino` and `pino-http`.
- [x] Standardized API response envelopes (`ApiSuccessResponse`, `ApiErrorResponse`).
- [x] Direct and versioned health-check endpoints (`/health`, `/ready`, `/api/v1/health`).
- [x] Automated test suite with Vitest and Supertest (8 passing tests).
- [x] Question bank samples (`PHY-G09-U01.json`, `PHY-G09-U02.json`) validated against schema contracts.
- [x] Complete Grade 9–12 Question Bank hierarchy established in `content/question-bank/` (238 files across 8 subjects).

---

### Phase 2 — Authentication (Up Next)
**Goal:** Enable seamless, secure student sign-in using Google accounts across Web and Android.

**Tasks:**
1. Install `google-auth-library` and `jsonwebtoken`.
2. Define MongoDB `User` and `RefreshToken` schemas & Mongoose models.
3. Implement `AuthService.verifyGoogleIdToken(idToken: string)`.
4. Implement user upsert logic (match by verified Google `sub` ID).
5. Implement dual-token issuance:
   - 15-minute Access Token (JWT).
   - 7-day Refresh Token (cryptographic hash in MongoDB).
6. Implement refresh token rotation with reuse detection.
7. Implement `POST /api/v1/auth/google`, `POST /api/v1/auth/refresh`, `POST /api/v1/auth/logout`, `GET /api/v1/auth/me`.
8. Write authentication middleware (`requireAuth`, `requireRole`).
9. Add automated unit and integration tests for authentication flows.

---

### Phase 3 — Curriculum and Question Banks
**Goal:** Ingest and manage Grade 9–12 subjects, units, and approved 30-question banks.

**Tasks:**
1. Implement Mongoose models for `Subject`, `Unit`, `Question`, and protected `AnswerKey`.
2. Implement curriculum query endpoints (`/api/v1/curriculum/grades`, `/subjects`, `/units`).
3. Build the CLI and API JSON importer for approved 30-question bank files.
4. Verify import integrity using question bank files in `content/question-bank/Grade-09/Physics/`.

---

### Phase 4 — Assessment Engine
**Goal:** Deliver sanitized questions to students and reliably evaluate batch submissions.

**Tasks:**
1. Implement student question delivery (`GET /api/v1/units/:unitId/questions`) ensuring zero leakage of answer keys.
2. Implement batch submission endpoint (`POST /api/v1/assessments/submit`).
3. Authoritative server-side evaluation against protected `AnswerKey` collection.
4. Idempotent attempt storage via client-generated `attemptId`.
5. Assessment history and review endpoints.

---

### Phase 5 — Student Progress
**Goal:** Aggregate student performance across subjects and units.

**Tasks:**
1. Model `StudentProgress` collection with incremental updates on assessment completion.
2. Implement analytics endpoints (`/api/v1/progress/overview`, `/subjects/:id`, `/units/:id`).

---

### Phase 6 — Cloud Deployment
**Goal:** Production deployment on Render and MongoDB Atlas.

**Tasks:**
1. Configure Render web service build and start commands.
2. Configure MongoDB Atlas IP access lists and production user credentials.
3. Configure Swagger / OpenAPI interactive documentation.
4. Verify live deployment with end-to-end smoke tests.

---

### Phase 7 — Client Integration
**Goal:** Connect Flutter Android and Next.js Web applications to the live API.
