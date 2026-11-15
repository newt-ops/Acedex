# ACEDEX — REST API Specification

## 1. Conventions & Standards

- **Base Path:** `/api/v1`
- **Transport:** HTTPS only
- **Format:** JSON (`application/json; charset=utf-8`)
- **Authentication:** `Authorization: Bearer <access_token>`

### 1.1 Success Response Envelope
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### 1.2 Error Response Envelope
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "idToken",
        "message": "Google ID token is required",
        "code": "too_small"
      }
    ],
    "timestamp": "2026-11-15T02:00:00.000Z",
    "path": "/api/v1/auth/google"
  }
}
```

---

## 2. Standard Error Codes

| Error Code | HTTP Status | Description |
|---|---|---|
| `BAD_REQUEST` | 400 | Malformed query or parameters |
| `MALFORMED_JSON` | 400 | Unparseable JSON body |
| `INVALID_ID` | 400 | Malformed MongoDB ObjectId or parameter |
| `UNAUTHORIZED` | 401 | Missing, invalid, or expired authentication token |
| `FORBIDDEN` | 403 | Authenticated user lacks required permissions (e.g. non-admin) |
| `NOT_FOUND` | 404 | Requested route or database entity was not found |
| `CONFLICT` | 409 | Conflicting state or operation |
| `DUPLICATE_KEY` | 409 | Duplicate entity constraint violated |
| `VALIDATION_ERROR` | 422 | Input data failed Zod schema validation rules |
| `INTERNAL_SERVER_ERROR` | 500 | Unexpected server-side failure |

---

## 3. Implemented Endpoints (Phase 1)

### 3.1 `GET /`
Returns top-level API metadata.
- **Status:** `200 OK`
- **Response:**
  ```json
  {
    "name": "Acedex API",
    "description": "EUEE Study Management and Assessment Platform API",
    "version": "1.0.0",
    "environment": "development",
    "endpoints": {
      "health": "/health",
      "apiV1": "/api/v1"
    }
  }
  ```

### 3.2 `GET /health` & `GET /api/v1/health`
Returns runtime status, MongoDB Atlas connectivity, process uptime, and memory usage.
- **Status:** `200 OK` (or `503 Service Unavailable` if database is down in production)
- **Response:**
  ```json
  {
    "success": true,
    "data": {
      "status": "healthy",
      "timestamp": "2026-11-15T02:00:00.000Z",
      "uptimeSeconds": 120,
      "environment": "production",
      "version": "1.0.0",
      "database": {
        "status": "connected",
        "connected": true,
        "name": "acedex",
        "host": "cluster0.mongodb.net"
      },
      "memory": {
        "heapUsedMB": 32.4,
        "heapTotalMB": 48.0,
        "rssMB": 85.2
      }
    }
  }
  ```

### 3.3 `GET /ready`
Readiness probe for Render or orchestration gateways.
- **Status:** `200 OK` when ready; `503 Service Unavailable` when not.

---

## 4. Implemented Endpoints: Authentication & RBAC (Phase 2)

### 4.1 `POST /api/v1/auth/google`
Authenticates a user via a Google OAuth 2.0 / OpenID Connect ID token.
- **Request Body:**
  ```json
  {
    "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6...",
    "platform": "web" // or "android"
  }
  ```
- **Response:** `200 OK`
  ```json
  {
    "success": true,
    "data": {
      "user": {
        "id": "6736a1b2c3d4e5f6a7b8c9d0",
        "email": "student@example.com",
        "displayName": "Abebe Bikila",
        "avatarUrl": "https://lh3.googleusercontent.com/...",
        "role": "student",
        "status": "active",
        "lastLoginAt": "2026-11-15T02:30:00.000Z",
        "createdAt": "2026-11-15T02:00:00.000Z",
        "updatedAt": "2026-11-15T02:30:00.000Z"
      },
      "tokens": {
        "accessToken": "eyJhbGciOiJIUzI1NiIsIn...",
        "refreshToken": "4a71b... (set in HTTP-only cookie on web / body on mobile)",
        "expiresIn": 900
      }
    }
  }
  ```

### 4.2 `POST /api/v1/auth/refresh`
Rotates the refresh token and issues a new 15-minute access token. Features token family reuse detection (invalidating all tokens if a reused token is detected).
- **Request:** Cookie `refreshToken` OR JSON body `{"refreshToken": "..."}`.
- **Response:** `200 OK` with updated `accessToken` and rotated `refreshToken`.

### 4.3 `POST /api/v1/auth/logout`
Revokes the refresh token family and clears the authentication cookie.
- **Status:** `200 OK`

### 4.4 `GET /api/v1/auth/me`
Retrieves the currently authenticated user's profile.
- **Headers:** `Authorization: Bearer <access_token>`
- **Response:** `200 OK` with `AuthUserProfile`.

---

## 5. Planned Endpoints Roadmap (Phases 3–5)

### 5.1 Curriculum & Question Bank (`/api/v1/curriculum`)
- `GET /api/v1/curriculum/grades`: List supported grades (`[9, 10, 11, 12]`).
- `GET /api/v1/curriculum/subjects?grade=9`: List subjects for a grade.
- `GET /api/v1/curriculum/units?grade=9&subject=Physics`: List published units for students.
- `GET /api/v1/curriculum/units/:unitId/questions`: Return 30 public questions for practice/assessment.
  - **Security Rule:** Answer keys and explanations are completely omitted.

### 5.2 Assessment Engine (`/api/v1/assessments`)
- `POST /api/v1/assessments/submit`: Submit batch answers for a unit.
  - Server evaluates answers against protected `answer_keys`.
  - Calculates score, percentage, and time spent.
  - Returns evaluation summary and permitted explanations.
  - Protected by idempotency via `attemptId`.
- `GET /api/v1/assessments/history`: List past assessment attempts.
- `GET /api/v1/assessments/:attemptId`: Retrieve detailed attempt result.

### 5.3 Progress & Analytics (`/api/v1/progress`)
- `GET /api/v1/progress/overview`: Student dashboard summary.
- `GET /api/v1/progress/subjects/:subjectId`: Breakdown per unit for a subject.

### 5.4 Internal Admin Portal APIs (`/api/v1/admin`)
Restricted to users with role `admin` or `super_admin`:
- `GET /api/v1/admin/dashboard`: Platform overview (users, questions, activity).
- `POST /api/v1/admin/question-bank/preview`: Upload/validate JSON question bank file and return preview & validation report.
- `POST /api/v1/admin/question-bank/import`: Persist approved 30-item unit and questions.
- `PATCH /api/v1/admin/units/:unitId/publish`: Publish unit to make it accessible to students.
- `GET /api/v1/admin/students`: Search and inspect student accounts and records.
- `GET /api/v1/admin/audit-logs`: Inspect administrative audit log history.
