# ACEDEX — Development Roadmap & Milestones

This document tracks development across all phases as defined in the master plan (`docs/plan.md`).

---

## Progress Overview

| Phase | Milestone | Focus Area | Status |
|:---:|---|---|:---:|
| **1** | **Backend Foundation** | Project setup, Express, TypeScript, MongoDB layer, health checks, error handling, tests | **COMPLETED** |
| **2** | **Authentication & RBAC** | Google OAuth token verification, User model, JWT access/refresh rotation, RBAC, audit logging | **COMPLETED** |
| **3** | **Curriculum & Question Banks** | Grades, Subjects, Units APIs, Question Bank models, 30-item JSON importer & validation | *IN PROGRESS* |
| **4** | **Assessment Engine** | Question delivery, server-side scoring, protected answer isolation, idempotency | *PLANNED* |
| **5** | **Student Progress** | Progress tracking, score history, subject/unit analytics APIs | *PLANNED* |
| **6** | **Cloud Deployment** | Render backend deployment, MongoDB Atlas production setup, OpenAPI/Swagger | *IN PROGRESS* |
| **7** | **Client Applications** | Flutter Student Mobile App & Next.js Admin Management Portal | *PLANNED* |

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

### Phase 2 — Authentication, Sessions & RBAC (COMPLETED)
**Goal:** Enable seamless, secure student sign-in using Google accounts across Web and Android, with strict role-based access control and session management.

**Delivered Tasks:**
- [x] Installed `google-auth-library` and `jsonwebtoken` with TypeScript definitions.
- [x] Defined MongoDB `User`, `RefreshToken`, and `AuditLog` schemas & Mongoose models.
- [x] Implemented `AuthService.verifyGoogleIdToken` with multi-client support (Web and Android Client IDs).
- [x] Implemented user registration/login upsert logic (matching on verified Google `sub` ID).
- [x] Implemented dual-token issuance:
  - 15-minute Access Token (JWT).
  - 7-day Refresh Token (cryptographic SHA-256 hash in MongoDB with TTL expiry index).
- [x] Implemented refresh token rotation with token family reuse detection (revoking entire family on replay attacks).
- [x] Implemented session endpoints:
  - `POST /api/v1/auth/google` (Sign-in / sign-up via Google ID token).
  - `POST /api/v1/auth/refresh` (Session rotation via refresh token).
  - `POST /api/v1/auth/logout` (Session revocation and cookie clearing).
  - `GET /api/v1/auth/me` (Authenticated user profile).
- [x] Implemented security middlewares:
  - `requireAuth` (validates Bearer token or cookie, populates `req.user`).
  - `requireRole(...roles)` (enforces strict RBAC: student, content_manager, admin, super_admin).
- [x] Implemented admin bootstrapping:
  - Auto-promotion for whitelisted emails (`ADMIN_EMAILS`).
  - CLI script `npm run admin:promote -- <email> <role>` for manual promotion.
- [x] Automated test suite: 19/19 tests passing across 5 test suites.

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
