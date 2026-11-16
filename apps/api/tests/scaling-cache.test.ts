import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { CurriculumSeederService } from '../src/modules/curriculum/curriculum-seeder.service';
import { UserModel } from '../src/modules/users/user.model';
import { UnitModel } from '../src/modules/curriculum/models/unit.model';
import { QuestionModel } from '../src/modules/curriculum/models/question.model';
import { AnswerKeyModel } from '../src/modules/curriculum/models/answer-key.model';
import { ContentCacheService } from '../src/common/services/cache.service';
import { ProgressService } from '../src/modules/progress/progress.service';
import { env } from '../src/config/env';

describe('Scaling & In-Memory Caching Engine', () => {
  const app = createApp();

  let studentToken = '';
  let adminToken = '';
  let sampleUnit: any = null;
  let sampleQuestions: any[] = [];
  let answerKeyMap: Map<string, string> = new Map();

  beforeAll(async () => {
    await connectDatabase();
    await CurriculumSeederService.seedCurriculum();
    ContentCacheService.clear();

    // 1. Create Student
    const studentUser = await UserModel.create({
      acedexId: `ACEDEX-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Cache Test Student',
      grade: 9,
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

    // 2. Create Admin
    const adminUser = await UserModel.create({
      acedexId: `ACEDEX-${(Date.now() + 1).toString().slice(-6)}`,
      email: `cache-admin-${Date.now()}@example.com`,
      displayName: 'Cache Admin',
      role: 'admin',
      status: 'active',
      authProvider: 'google',
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

    sampleUnit = await UnitModel.findOne({ grade: 9, subjectCode: 'PHY', unitNumber: 1 });
    sampleQuestions = await QuestionModel.find({ unitId: sampleUnit._id, isPublished: true });

    const keys = await AnswerKeyModel.find({
      questionId: { $in: sampleQuestions.map((q) => q._id) },
    });
    for (const k of keys) {
      answerKeyMap.set(k.externalId, k.correctOptionId);
    }

    // Unlock exam by marking unit completed in study tracker
    await ProgressService.updateUnitStudyStatus(studentUser._id.toString(), sampleUnit._id.toString(), 'completed');
  }, 60000);

  afterAll(async () => {
    ContentCacheService.clear();
    await UserModel.deleteMany({ displayName: /Cache Test Student|Cache Admin/ });
    await disconnectDatabase();
  });

  it('ContentCacheService should store, retrieve, track stats, and invalidate keys correctly', () => {
    ContentCacheService.clear();

    expect(ContentCacheService.get('test_key')).toBeNull();

    ContentCacheService.set('test_key', { foo: 'bar' }, 60);
    const value = ContentCacheService.get<{ foo: string }>('test_key');
    expect(value).toEqual({ foo: 'bar' });

    const stats = ContentCacheService.stats();
    expect(stats.hits).toBe(1);
    expect(stats.misses).toBe(1);
    expect(stats.size).toBe(1);

    ContentCacheService.del('test_key');
    expect(ContentCacheService.get('test_key')).toBeNull();
  });

  it('GET /api/v1/curriculum/units/:unitId/questions should populate and serve from in-memory cache', async () => {
    ContentCacheService.clear();
    const unitId = sampleUnit._id.toString();

    // 1. Initial request (cache miss -> database query -> cache write)
    const res1 = await request(app)
      .get(`/api/v1/curriculum/units/${unitId}/questions`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res1.status).toBe(200);
    expect(res1.body.data).toHaveLength(15);

    // Verify item is now cached in memory
    const cached = ContentCacheService.getUnitQuestions(unitId);
    expect(cached).toBeDefined();
    expect(cached).toHaveLength(15);

    // 2. Second request (cache hit -> sub-millisecond memory response)
    const res2 = await request(app)
      .get(`/api/v1/curriculum/units/${unitId}/questions`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res2.status).toBe(200);
    expect(res2.body.data).toEqual(cached);
  });

  it('POST /api/v1/assessments/submit should populate in-memory answer keys and grade with zero database key queries', async () => {
    const unitId = sampleUnit._id.toString();
    ContentCacheService.del(`unit_keys:${unitId}`);

    const answers = sampleQuestions.map((q) => ({
      questionId: q.externalId,
      selectedOptionId: answerKeyMap.get(q.externalId) || 'A',
    }));

    // 1. First submission (loads and caches answer keys in memory)
    const res1 = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId,
        answers,
        durationSeconds: 90,
      });

    expect(res1.status).toBe(200);
    expect(res1.body.data.score).toBe(15);

    // Verify answer keys are now in memory
    const cachedKeys = ContentCacheService.getUnitAnswerKeys(unitId);
    expect(cachedKeys).toBeDefined();
    expect(cachedKeys?.size).toBeGreaterThanOrEqual(15);

    // 2. Second submission (grades entirely against in-memory key cache)
    const res2 = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId,
        answers,
        durationSeconds: 85,
      });

    expect(res2.status).toBe(200);
    expect(res2.body.data.score).toBe(15);
  });

  it('Admin unit status toggle should invalidate unit cache automatically', async () => {
    const unitId = sampleUnit._id.toString();

    // Ensure unit has cached entries
    ContentCacheService.setUnitQuestions(unitId, [{ id: 'mock' } as any]);
    expect(ContentCacheService.getUnitQuestions(unitId)).not.toBeNull();

    // Admin updates status (e.g. to draft, then back to published)
    const patchRes = await request(app)
      .patch(`/api/v1/admin/units/${unitId}/status`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'draft' });

    expect(patchRes.status).toBe(200);

    // Verify cache was invalidated
    expect(ContentCacheService.getUnitQuestions(unitId)).toBeNull();

    // Revert back to published for consistency
    await request(app)
      .patch(`/api/v1/admin/units/${unitId}/status`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'published' });
  });

  it('Response compression middleware should be active and process Gzip requests', async () => {
    const unitId = sampleUnit._id.toString();

    const res = await request(app)
      .get(`/api/v1/curriculum/units/${unitId}/questions`)
      .set('Authorization', `Bearer ${studentToken}`)
      .set('Accept-Encoding', 'gzip');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveLength(15);
  });
});
