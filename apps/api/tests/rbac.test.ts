import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import express, { Response } from 'express';
import jwt from 'jsonwebtoken';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { UserModel } from '../src/modules/users/user.model';
import { requireAuth, requireRole, AuthenticatedRequest } from '../src/middleware/auth.middleware';
import { errorHandler } from '../src/middleware/error.middleware';
import { env } from '../src/config/env';

describe('RBAC Middleware', () => {
  const app = express();
  app.use(express.json());

  app.get(
    '/test-rbac/admin-only',
    requireAuth,
    requireRole('admin', 'super_admin'),
    (req: AuthenticatedRequest, res: Response) => {
      res.json({ success: true, message: `Welcome ${req.user?.role}` });
    }
  );

  app.use(errorHandler);

  let studentToken = '';
  let adminToken = '';
  let superAdminToken = '';

  beforeAll(async () => {
    await connectDatabase();

    // Create a student user
    const studentUser = await UserModel.create({
      email: `test-rbac-student-${Date.now()}@example.com`,
      displayName: 'Test Student',
      role: 'student',
      status: 'active',
      authProvider: 'phone',
    });

    studentToken = jwt.sign(
      {
        sub: studentUser._id.toString(),
        email: studentUser.email,
        role: studentUser.role,
        displayName: studentUser.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    // Create an admin user
    const adminUser = await UserModel.create({
      email: `test-rbac-admin-${Date.now()}@example.com`,
      displayName: 'Test Admin',
      role: 'admin',
      status: 'active',
      authProvider: 'phone',
    });

    adminToken = jwt.sign(
      {
        sub: adminUser._id.toString(),
        email: adminUser.email,
        role: adminUser.role,
        displayName: adminUser.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    // Create a super_admin user
    const superAdminUser = await UserModel.create({
      email: `test-rbac-superadmin-${Date.now()}@example.com`,
      displayName: 'Test Super Admin',
      role: 'super_admin',
      status: 'active',
      authProvider: 'phone',
    });

    superAdminToken = jwt.sign(
      {
        sub: superAdminUser._id.toString(),
        email: superAdminUser.email,
        role: superAdminUser.role,
        displayName: superAdminUser.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );
  }, 30000);

  afterAll(async () => {
    await UserModel.deleteMany({ email: { $regex: /^test-rbac-/ } });
    await disconnectDatabase();
  }, 30000);

  it('GET /test-rbac/admin-only should reject unauthenticated requests with 401', async () => {
    const res = await request(app).get('/test-rbac/admin-only');

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  it('GET /test-rbac/admin-only should reject student role with 403 Forbidden', async () => {
    const res = await request(app)
      .get('/test-rbac/admin-only')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(403);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('FORBIDDEN');
  });

  it('GET /test-rbac/admin-only should allow admin role with 200 OK', async () => {
    const res = await request(app)
      .get('/test-rbac/admin-only')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.message).toBe('Welcome admin');
  });

  it('GET /test-rbac/admin-only should allow super_admin role with 200 OK', async () => {
    const res = await request(app)
      .get('/test-rbac/admin-only')
      .set('Authorization', `Bearer ${superAdminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.message).toBe('Welcome super_admin');
  });
});
