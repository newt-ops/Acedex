import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { CurriculumSeederService } from '../src/modules/curriculum/curriculum-seeder.service';
import { UserModel } from '../src/modules/users/user.model';
import { UnitModel } from '../src/modules/curriculum/models/unit.model';
import { env } from '../src/config/env';

describe('Admin Management Engine (RBAC Protected)', () => {
  const app = createApp();

  let studentToken = '';
  let adminToken = '';
  let studentUser: any = null;
  let sampleUnit: any = null;

  beforeAll(async () => {
    await connectDatabase();

    // 1. Ensure curriculum is seeded
    await CurriculumSeederService.seedCurriculum();

    // 2. Create student user
    studentUser = await UserModel.create({
      acedexId: `ACEDEX-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Admin Test Student',
      grade: 10,
      role: 'student',
      status: 'active',
      authProvider: 'phone',
    });

    studentToken = jwt.sign(
      {
        sub: studentUser._id.toString(),
        acedexId: studentUser.acedexId,
        role: studentUser.role,
        displayName: studentUser.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    // 3. Create admin user
    const adminUser = await UserModel.create({
      acedexId: `ACEDEX-${(Date.now() + 1).toString().slice(-6)}`,
      email: `admin-${Date.now()}@example.com`,
      displayName: 'Admin Staff',
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

    // 4. Sample unit
    sampleUnit = await UnitModel.findOne({ grade: 9, subjectCode: 'PHY', unitNumber: 1 });
    expect(sampleUnit).toBeDefined();
  }, 60000);

  afterAll(async () => {
    await UserModel.deleteMany({ displayName: { $in: ['Admin Test Student', 'Admin Staff'] } });
    await disconnectDatabase();
  });

  it('GET /api/v1/admin/dashboard should reject unauthenticated requests with 401 Unauthorized', async () => {
    const res = await request(app).get('/api/v1/admin/dashboard');
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it('GET /api/v1/admin/dashboard should reject student token with 403 Forbidden', async () => {
    const res = await request(app)
      .get('/api/v1/admin/dashboard')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(403);
    expect(res.body.success).toBe(false);
  });

  it('GET /api/v1/admin/dashboard should return platform metrics for admin', async () => {
    const res = await request(app)
      .get('/api/v1/admin/dashboard')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    const stats = res.body.data;
    expect(stats.students).toBeDefined();
    expect(stats.students.total).toBeGreaterThan(0);
    expect(stats.curriculum).toBeDefined();
    expect(stats.curriculum.totalUnits).toBeGreaterThan(0);
    expect(stats.assessments).toBeDefined();
  });

  it('POST /api/v1/admin/question-bank/preview should validate question bank file without saving', async () => {
    const invalidPayload = {
      grade: 9,
      subject: 'Physics',
      unitNumber: 1,
      unitTitle: 'Test',
      questions: [], // Invalid: needs 15 questions
    };

    const invalidRes = await request(app)
      .post('/api/v1/admin/question-bank/preview')
      .set('Authorization', `Bearer ${adminToken}`)
      .send(invalidPayload);

    expect(invalidRes.status).toBe(200);
    expect(invalidRes.body.data.valid).toBe(false);
    expect(invalidRes.body.data.errors).toBeDefined();
  });

  it('PATCH /api/v1/admin/units/:unitId/status should toggle unit publication status', async () => {
    // Toggle to draft
    const draftRes = await request(app)
      .patch(`/api/v1/admin/units/${sampleUnit._id.toString()}/status`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'draft' });

    expect(draftRes.status).toBe(200);
    expect(draftRes.body.data.status).toBe('draft');
    expect(draftRes.body.data.isPublished).toBe(false);

    // Toggle back to published (has 15 questions)
    const pubRes = await request(app)
      .patch(`/api/v1/admin/units/${sampleUnit._id.toString()}/status`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'published' });

    expect(pubRes.status).toBe(200);
    expect(pubRes.body.data.status).toBe('published');
    expect(pubRes.body.data.isPublished).toBe(true);
  });

  it('GET /api/v1/admin/students should return paginated students with search filter', async () => {
    const res = await request(app)
      .get(`/api/v1/admin/students?search=${studentUser.acedexId}`)
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.items.length).toBeGreaterThanOrEqual(1);
    expect(res.body.data.items[0].acedexId).toBe(studentUser.acedexId);
  });

  it('PATCH /api/v1/admin/students/:studentId/status should suspend and reactivate student', async () => {
    // Suspend
    const suspendRes = await request(app)
      .patch(`/api/v1/admin/students/${studentUser._id.toString()}/status`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'suspended' });

    expect(suspendRes.status).toBe(200);
    expect(suspendRes.body.data.status).toBe('suspended');

    // Reactivate
    const activateRes = await request(app)
      .patch(`/api/v1/admin/students/${studentUser._id.toString()}/status`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'active' });

    expect(activateRes.status).toBe(200);
    expect(activateRes.body.data.status).toBe('active');
  });

  it('GET /api/v1/admin/audit-logs should return system audit log history', async () => {
    const res = await request(app)
      .get('/api/v1/admin/audit-logs?limit=5')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.items.length).toBeGreaterThan(0);
    expect(res.body.data.items[0].action).toBeDefined();
    expect(res.body.data.items[0].timestamp).toBeDefined();
  });
});
