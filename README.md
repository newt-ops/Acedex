# ACEDEX — Cross-Platform Study Management & Assessment Platform

Acedex is a cross-platform study management and assessment platform designed for Ethiopian students preparing systematically for the **Ethiopian University Entrance Examination (EUEE)** across Grades 9–12.

Both the **Android application (Flutter)** and **Web application (Next.js)** share a single unified backend API and MongoDB Atlas database.

---

## 🛠 Technology Stack

- **Backend:** Node.js (v20+), Express.js, TypeScript
- **Database:** MongoDB Atlas, Mongoose ODM
- **Validation & Contracts:** Zod, `@acedex/contracts`
- **Security & Logging:** Helmet, CORS, Pino, Pino-HTTP
- **Testing:** Vitest, Supertest
- **Future Clients:**
  - Android: Flutter / Dart
  - Web: Next.js (App Router, TypeScript)
- **Deployment:** Render (Backend API), MongoDB Atlas (Database), Vercel (Web)

---

## 📁 Repository Structure

```text
Acedex/
├── apps/
│   ├── api/                     # Express.js + TypeScript backend application
│   ├── web/                     # Next.js web application (future phase)
│   └── mobile/                  # Flutter Android application (future phase)
│
├── packages/
│   └── contracts/               # Shared TypeScript schemas, DTOs & Zod validators
│
├── content/
│   └── question-bank/           # Questions strictly partitioned by Grade -> Subject -> Unit
│       ├── Grade-09/            # Biology, Chemistry, Economics, English, Geography, History, Math, Physics
│       ├── Grade-10/
│       ├── Grade-11/
│       ├── Grade-12/
│       └── README.md
│
├── docs/                        # Project documentation
│   ├── plan.md                  # Master rebuild plan
│   ├── architecture.md          # Architecture & topology
│   ├── database.md              # MongoDB collections, schemas & indexes
│   ├── authentication.md        # Google OAuth & session management
│   ├── api.md                   # REST API contracts & error codes
│   └── development-roadmap.md   # Project phases & progress tracking
│
├── .gitignore
├── package.json                 # Monorepo workspace configuration
└── README.md
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Node.js** (v20.x or v22.x or v24.x)
- **npm** (v10.x or v11.x)
- **MongoDB Atlas** account (or local MongoDB for development)

### 2. Installation
Install all root and workspace dependencies:

```bash
npm install
```

Build the shared contracts package:

```bash
npm run build --workspace=@acedex/contracts
```

### 3. Environment Configuration
Copy the sample environment file for the backend:

```bash
cp apps/api/.env.example apps/api/.env
```

Edit `apps/api/.env` and configure your credentials:
```env
PORT=5000
NODE_ENV=development
API_PREFIX=/api/v1
MONGODB_URI=mongodb+srv://<username>:<password>@cluster.mongodb.net/acedex?retryWrites=true&w=majority
CORS_ORIGIN=http://localhost:3000,http://localhost:5173
```

> **Note:** For local development and testing, if `MONGODB_URI` is not configured, the API will start in **degraded mode** allowing you to test endpoints without crashing. In production (`NODE_ENV=production`), `MONGODB_URI` is strictly enforced.

### 4. Running the Backend Locally

**Development Mode (Hot Reload):**
```bash
npm run dev
# or from apps/api:
cd apps/api && npm run dev
```

**Production Build & Run:**
```bash
npm run build
npm start --workspace=@acedex/api
```

### 5. Running Automated Tests

```bash
npm test
```

Runs all Vitest unit and integration test suites (health probes, error handling, question bank schemas).

---

## 🌐 Live Deployments

- **Backend API (Render):** [https://acedex-api.onrender.com](https://acedex-api.onrender.com)
  - Health check: [https://acedex-api.onrender.com/health](https://acedex-api.onrender.com/health)
  - API v1 Root: [https://acedex-api.onrender.com/api/v1](https://acedex-api.onrender.com/api/v1)
- **Admin Web Portal (Vercel):** [https://acedex.vercel.app](https://acedex.vercel.app)

---

## 🔍 API Verification

Once the server is running on port 5000:

- **Root API Metadata:**
  `curl http://localhost:5000/`
- **Platform Health Check:**
  `curl http://localhost:5000/health`
- **Readiness Probe:**
  `curl http://localhost:5000/ready`
- **Versioned API Health Check:**
  `curl http://localhost:5000/api/v1/health`

---

## 📚 Documentation Links

- [Master System Rebuild Plan](file:///c:/Projects/Mobile%20App/Acedex/docs/plan.md)
- [System Architecture](file:///c:/Projects/Mobile%20App/Acedex/docs/architecture.md)
- [Database Design & Models](file:///c:/Projects/Mobile%20App/Acedex/docs/database.md)
- [Authentication & Sessions](file:///c:/Projects/Mobile%20App/Acedex/docs/authentication.md)
- [REST API Specification](file:///c:/Projects/Mobile%20App/Acedex/docs/api.md)
- [Development Roadmap](file:///c:/Projects/Mobile%20App/Acedex/docs/development-roadmap.md)
