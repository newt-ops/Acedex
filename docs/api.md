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

## 4. Planned Endpoints Roadmap (Phases 2–5)

### 4.1 Authentication (`/api/v1/auth`)
- `POST /api/v1/auth/google`: Exchange Google ID token for Acedex JWT session.
- `POST /api/v1/auth/refresh`: Rotate refresh token and issue new access token.
- `POST /api/v1/auth/logout`: Revoke active refresh token session.
- `GET /api/v1/auth/me`: Fetch authenticated student profile.

### 4.2 Curriculum (`/api/v1/curriculum`)
- `GET /api/v1/curriculum/grades`: List supported grades (9, 10, 11, 12).
- `GET /api/v1/curriculum/subjects?grade=9`: List subjects for a grade.
- `GET /api/v1/curriculum/units?grade=9&subject=Physics`: List available units.

### 4.3 Question Bank (`/api/v1/units/:unitId/questions`)
- `GET /api/v1/units/:unitId/questions`: Return 30 public questions for practice or assessment.
  - **Security Rule:** Does not return `correctOptionId` or `explanation`.

### 4.4 Assessment Engine (`/api/v1/assessments`)
- `POST /api/v1/assessments/submit`: Submit batch answers for a unit.
  - Server evaluates answers against protected `answer_keys`.
  - Calculates score, percentage, and time spent.
  - Returns evaluation summary and permitted explanations.
  - Protected by idempotency via `attemptId`.
- `GET /api/v1/assessments/history`: List past assessment attempts.
- `GET /api/v1/assessments/:attemptId`: Retrieve detailed attempt result.

### 4.5 Progress & Analytics (`/api/v1/progress`)
- `GET /api/v1/progress/overview`: Student dashboard summary.
- `GET /api/v1/progress/subjects/:subjectId`: Breakdown per unit for a subject.

### 4.6 Administration (`/api/v1/admin`)
- `POST /api/v1/admin/question-bank/import`: Admin-only endpoint to import approved 30-question JSON files into MongoDB.
