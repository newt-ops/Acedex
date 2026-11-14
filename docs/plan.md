# ACEDEx — Complete System Rebuild & Architecture

You are the lead software architect and developer responsible for rebuilding **Acedex**, a cross-platform study management and assessment platform designed for Ethiopian students preparing for the Ethiopian University Entrance Examination (EUEE).

We are rebuilding the system from scratch in a new project directory. Treat this as a fresh implementation. Do not assume the old architecture or database design should be preserved.

Your responsibility is to establish a clean, scalable, maintainable architecture and implement it in clear development phases.

# 1. Product Vision

Acedex will be available on two platforms:

- Android application built with Flutter.
- Web application built with Next.js and TypeScript.

Both platforms must use the same backend, authentication system, database, question bank, assessment engine, and student records.

A student should be able to use either platform with the same account and access synchronized progress.

Acedex is a study management and assessment platform. It does not provide textbooks or complete educational courses.

Its primary purpose is to help students:
- Practice questions from Grades 9–12.
- Complete unit-based assessments.
- Track their study progress.
- Monitor performance across subjects and units.
- Understand their strengths and weaknesses.
- Maintain consistent study habits.
- Prepare systematically for the EUEE.

# 2. Technology Stack

Use the following stack as the architectural foundation.

## Backend
- Node.js
- Express.js
- TypeScript
- MongoDB Atlas
- Mongoose
- REST API
- JWT-based application authentication
- Google OAuth 2.0 / OpenID Connect
- Zod for request validation
- Swagger / OpenAPI for API documentation

Hosting: Render.

## Web
- Next.js
- TypeScript
- App Router
- Responsive interface
- API communication with the Express backend

Hosting: Vercel.

## Mobile
- Flutter
- Dart
- Native-feeling Android experience
- API communication with the same Express backend
- Secure local session storage
- Offline-friendly question access and attempt management

## Database
- MongoDB Atlas
- Backend-only database access
- Proper schemas, validation, indexes, and relationships through references where appropriate.

Do not introduce:
- Supabase
- PostgreSQL
- Firebase Authentication
- Firebase Firestore
- Next.js as a second backend
- Unnecessary microservices

Express is the central backend and the only application server responsible for business logic and database operations.

# 3. Project Structure

Organize the repository for long-term development.

Use a structure similar to:

Acedex/
├── apps/
│   ├── api/
│   │   ├── src/
│   │   ├── tests/
│   │   ├── package.json
│   │   └── .env.example
│   │
│   ├── web/
│   │   └── (Next.js application, future phase)
│   │
│   └── mobile/
│       └── (Flutter application, future phase)
│
├── packages/
│   └── contracts/
│       └── (shared API schemas and documented data contracts)
│
├── content/
│   ├── textbooks/
│   └── question-bank/
│       ├── drafts/
│       ├── approved/
│       └── archive/
│
├── docs/
│   ├── architecture.md
│   ├── database.md
│   ├── authentication.md
│   ├── api.md
│   └── development-roadmap.md
│
├── .gitignore
└── README.md

Adjust the structure where technically justified, but maintain clear separation between applications, content, documentation, and backend logic.

# 4. Backend Architecture

The backend is the foundation of the entire platform.

Build it as a modular monolith, not as a collection of unnecessary microservices.

Organize the backend into independent modules:

- Authentication
- Users
- Curriculum
- Subjects
- Units
- Question Banks
- Assessments
- Assessment Attempts
- Assessment Results
- Student Progress
- Administration

Each module should have a clear responsibility.

Separate:
- Routes
- Controllers
- Services
- Models
- Validation schemas
- Middleware
- Utilities

Use TypeScript consistently. Avoid unnecessary abstractions and overly complicated architecture.

# 5. Authentication — Google OAuth

Acedex will initially support Google Sign-In.

Students should not need to create a separate password.

Authentication flow:

1. Student selects Continue with Google.
2. The client obtains a Google ID token through the appropriate Google sign-in flow.
3. Client sends the ID token to the Express backend.
4. Backend verifies the token using Google's official authentication library.
5. Backend validates signature, issuer, audience, and expiration.
6. Backend identifies the Google account using its verified `sub` identifier.
7. Backend finds or creates the corresponding Acedex user in MongoDB.
8. Backend issues Acedex application credentials.

MongoDB user records should support:

- Google account identifier
- Email
- Display name
- Profile picture
- Authentication provider
- User role
- Account status
- Created timestamp
- Updated timestamp

Use a unique index on the Google account identifier.

Never trust unverified client profile data.

Never store Google passwords.

Never expose OAuth secrets or database credentials in frontend applications.

## Session management

Implement a secure session architecture suitable for both platforms.

- Short-lived access tokens.
- Refresh-token rotation.
- Secure refresh-token storage.
- Server-side refresh-token validation and revocation.
- Sign-out and session invalidation.
- Expired-session handling.

For web:
- Use secure, HTTP-only cookies for refresh credentials.
- Configure CORS and cookie policies appropriately for the deployed domains.
- Avoid storing authentication tokens in localStorage.

For Flutter:
- Store refresh credentials in secure device storage.
- Handle access-token refresh automatically.

Do not implement separate user accounts for web and mobile.

# 6. Curriculum Architecture

Acedex supports Grades 9, 10, 11, and 12.

The curriculum hierarchy is:

Grade → Subject → Unit → Question Bank.

Design this system to support:
- Multiple grades.
- Multiple subjects per grade.
- Different numbers of units per subject.
- Independent question banks for each unit.
- Future curriculum updates.
- Published and unpublished content.

Do not hardcode curriculum data into frontend applications.

Curriculum information must be managed through the backend and database.

# 7. Question Bank Architecture

The question bank is a central part of Acedex.

Questions are authored and reviewed separately before being imported into the production database.

The workflow:

Textbook → Question Generation → Human Review → Approved JSON → Backend Importer → MongoDB → Student Applications.

NotebookLM can assist with drafting questions, but only reviewed and approved questions should be imported.

## Question format

Every unit contains exactly 30 multiple-choice questions.

Each question must have:
- Unique ID
- Question type
- Difficulty
- Question text
- Four answer options
- Correct option identifier
- Explanation
- Source reference

Difficulty values:
- easy
- medium
- challenging

Question IDs follow this format:

`PHY-G09-U01-Q001`

Example approved JSON structure:

```json
{
  "grade": 9,
  "subject": "Physics",
  "unitNumber": 1,
  "unitTitle": "Physics and Human Society",
  "questions": [
    {
      "id": "PHY-G09-U01-Q001",
      "type": "multiple_choice",
      "difficulty": "easy",
      "question": "Example question",
      "options": [
        {"id": "A", "text": "Option A"},
        {"id": "B", "text": "Option B"},
        {"id": "C", "text": "Option C"},
        {"id": "D", "text": "Option D"}
      ],
      "correctOptionId": "B",
      "explanation": "Explanation of the correct answer.",
      "sourceReference": "Section 1.1, Page 2"
    }
  ]
}
```

The JSON importer must:
- Validate the complete file before importing.
- Validate question count and structure.
- Reject duplicate question IDs.
- Validate correct option identifiers.
- Check grade, subject, unit, and unit title.
- Prevent accidental duplicate imports.
- Provide useful import reports.
- Support future question-bank updates and versioning.

Keep drafts separate from approved content.

# 8. Assessment Architecture and Answer Security

This is a critical architectural requirement.

Never expose correct answers to students before they submit an assessment.

Do not rely on hiding answers in Flutter or Next.js.

Separate public question content from protected answer keys.

The student-facing API may return:
- Question ID
- Question text
- Options
- Difficulty where appropriate

It must not return:
- Correct option IDs
- Protected answer keys
- Explanations before submission, if explanations are intended to be part of the post-submission review

When a student submits an assessment:

1. Client sends the assessment identifier and selected answers.
2. Backend validates the authenticated user.
3. Backend retrieves the authoritative answer key.
4. Backend evaluates the submission.
5. Backend calculates the score.
6. Backend stores the attempt and result.
7. Backend returns the result and permitted explanations.

Never trust client-calculated scores.

## Performance requirement

Do not send a request to the backend every time a student selects an answer.

Question selection should happen instantly on the client.

The client should submit answers as a batch.

This is important for a smooth experience, particularly with slower internet connections.

# 9. Offline Support

Design the system to support unreliable internet connectivity.

Students should be able to:
- Download and cache public question content.
- Open previously downloaded question banks.
- Select answers locally.
- Preserve an in-progress attempt locally.
- Submit pending attempts after reconnecting.

The backend remains the authoritative source for assessment scoring.

Never cache protected answer keys on student devices.

Handle duplicate submissions safely using idempotency controls.

# 10. Student Progress and Results

Design a consistent data model for:

- Assessment attempts
- Selected answers
- Assessment scores
- Completion status
- Submission timestamps
- Time spent
- Subject performance
- Unit performance
- Historical results

Both platforms must retrieve the same student progress through the API.

Avoid storing unnecessary duplicated statistics. Where useful, calculate analytics through aggregation or maintain carefully updated summaries.

# 11. API Design

Use versioned REST endpoints.

All endpoints should follow:

`/api/v1/...`

Organize endpoints around resources.

Examples:

Authentication:
- POST /api/v1/auth/google
- POST /api/v1/auth/refresh
- POST /api/v1/auth/logout
- GET /api/v1/auth/me

Curriculum:
- GET /api/v1/grades
- GET /api/v1/subjects
- GET /api/v1/units

Questions:
- GET /api/v1/units/:unitId/questions

Assessments:
- POST /api/v1/assessments/submit
- GET /api/v1/assessments/history
- GET /api/v1/assessments/:attemptId

Progress:
- GET /api/v1/progress/overview
- GET /api/v1/progress/subjects
- GET /api/v1/progress/units

These are initial examples. Adjust endpoint design when necessary, but keep the API consistent.

Implement:
- Consistent response formats.
- Appropriate HTTP status codes.
- Centralized error handling.
- Input validation.
- Authentication middleware.
- Role-based authorization.
- Pagination where necessary.
- Rate limiting for sensitive endpoints.
- API documentation using Swagger/OpenAPI.

# 12. Administration and Content Management

Design the backend so that authorized administrators can manage curriculum and question banks.

Question import operations must require administrative authorization.

Never expose administrative functionality to ordinary students.

Do not build a large administration dashboard in the first phase. Establish the required backend permissions and services first.

# 13. Deployment Preparation

The backend must be ready for Render deployment.

Prepare:
- Production build scripts.
- Environment-variable configuration.
- MongoDB Atlas connection.
- Health-check endpoint.
- Structured logging.
- Error handling.
- CORS configuration.
- Graceful shutdown.
- Production security settings.
- Database indexes.
- Deployment documentation.

Never commit `.env` files or secrets.

Provide `.env.example` with variable names and descriptions, but no real credentials.

The application must run locally before deployment.

Document how to deploy the backend to Render and configure MongoDB Atlas.

# 14. Development Phases

Do not attempt to implement everything simultaneously.

Follow these phases.

## Phase 1 — Backend Foundation

- Project setup.
- TypeScript configuration.
- Express server.
- MongoDB Atlas connection.
- Environment configuration.
- Modular architecture.
- Logging and error handling.
- Health endpoint.
- Basic automated tests.

## Phase 2 — Authentication

- Google OAuth verification.
- MongoDB user model.
- Account creation and retrieval.
- JWT access and refresh sessions.
- Authentication middleware.
- Sign-out and session revocation.
- Authentication tests.

## Phase 3 — Curriculum and Question Banks

- Curriculum models.
- Grade, subject, and unit APIs.
- Question bank models.
- Protected answer keys.
- JSON importer.
- Import validation and reporting.
- Test with the supplied Grade 9 Physics Unit 1 and Unit 2 JSON samples.

## Phase 4 — Assessment Engine

- Question delivery.
- Assessment submission.
- Server-side evaluation.
- Result storage.
- Duplicate-submission protection.
- Assessment history.
- Performance tests.

## Phase 5 — Student Progress

- Progress aggregation.
- Subject analytics.
- Unit analytics.
- Historical performance.
- Progress APIs.

## Phase 6 — Deployment

- Production configuration.
- Render deployment.
- MongoDB Atlas production connection.
- API testing using the deployed URL.
- Swagger documentation.
- Final security and reliability checks.

## Phase 7 — Frontend Integration

Only after the backend is stable:

1. Integrate the Flutter mobile application.
2. Build the Next.js web application.
3. Connect both applications to the same API.
4. Implement platform-appropriate Google Sign-In.
5. Verify cross-platform account and progress synchronization.

# 15. Engineering Standards

- Write maintainable TypeScript.
- Avoid unnecessary dependencies.
- Prefer straightforward solutions.
- Keep modules focused.
- Use clear naming.
- Validate external input.
- Never trust client-side authorization.
- Never expose sensitive information.
- Add tests for important business logic.
- Document meaningful architectural decisions.
- Do not generate fake production data.
- Do not silently skip unfinished functionality.
- Do not claim an implementation works without testing it.

# 16. Your Immediate Task

We are beginning with Phase 1: Backend Foundation.

Do not start building the Flutter or Next.js applications yet.

First:

1. Inspect the new project directory.
2. Establish the complete project structure.
3. Initialize the backend application inside `apps/api`.
4. Configure Node.js, Express, and TypeScript.
5. Configure environment variables and `.gitignore`.
6. Establish the MongoDB Atlas connection layer.
7. Implement the health-check endpoint.
8. Implement centralized error handling and logging.
9. Add initial tests.
10. Write the architecture and setup documentation.

Before making architectural decisions that materially conflict with this specification, explain the issue and propose a better solution.

Do not overwhelm me with multiple alternative architectures. Make technically sound decisions and explain them briefly.

At the end, report:
- What you implemented.
- The resulting project structure.
- Dependencies installed.
- Commands to run the backend locally.
- Environment variables I must configure.
- What I need to do manually.
- What remains for Phase 2.

**Important: Build a working foundation, not just documentation or empty placeholder files.**