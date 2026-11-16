import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { CurriculumSeederService } from '../src/modules/curriculum/curriculum-seeder.service';
import { UnitModel } from '../src/modules/curriculum/models/unit.model';
import { SubjectModel } from '../src/modules/curriculum/models/subject.model';
import { UserModel } from '../src/modules/users/user.model';
import { env } from '../src/config/env';

describe('Curriculum & Question Bank Engine', () => {
  const app = createApp();

  let naturalStudentToken = '';
  let socialStudentToken = '';
  let samplePublishedUnitId = '';

  beforeAll(async () => {
    await connectDatabase();

    // 1. Ensure subjects and sample units are seeded
    await CurriculumSeederService.seedCurriculum();

    // 2. Create test students for stream verification
    const naturalUser = await UserModel.create({
      acedexId: `ACEDEX-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Natural Student',
      grade: 11,
      stream: 'natural',
      gender: 'female',
      role: 'student',
      status: 'active',
      authProvider: 'phone',
    });

    const socialUser = await UserModel.create({
      acedexId: `ACEDEX-${(Date.now() + 1).toString().slice(-6)}`,
      phone: `+2517${Date.now().toString().slice(-8)}`,
      displayName: 'Social Student',
      grade: 12,
      stream: 'social',
      gender: 'male',
      role: 'student',
      status: 'active',
      authProvider: 'phone',
    });

    naturalStudentToken = jwt.sign(
      {
        sub: naturalUser._id.toString(),
        acedexId: naturalUser.acedexId,
        role: naturalUser.role,
        grade: naturalUser.grade,
        stream: naturalUser.stream,
        displayName: naturalUser.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    socialStudentToken = jwt.sign(
      {
        sub: socialUser._id.toString(),
        acedexId: socialUser.acedexId,
        role: socialUser.role,
        grade: socialUser.grade,
        stream: socialUser.stream,
        displayName: socialUser.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    // 3. Find a published unit (e.g. PHY-G09-U01)
    const publishedUnit = await UnitModel.findOne({
      grade: 9,
      subjectCode: 'PHY',
      unitNumber: 1,
    });
    if (publishedUnit) {
      samplePublishedUnitId = publishedUnit._id.toString();
    }
  }, 60000);

  afterAll(async () => {
    await UserModel.deleteMany({ displayName: /Student$/ });
    await disconnectDatabase();
  });

  it('GET /api/v1/curriculum/grades should return [9, 10, 11, 12]', async () => {
    const res = await request(app).get('/api/v1/curriculum/grades');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toEqual([9, 10, 11, 12]);
  });

  it('GET /api/v1/curriculum/subjects?grade=9 should return all 8 common subjects', async () => {
    const res = await request(app).get('/api/v1/curriculum/subjects?grade=9');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveLength(8);

    const codes = res.body.data.map((s: any) => s.code);
    expect(codes).toContain('PHY');
    expect(codes).toContain('BIO');
    expect(codes).toContain('CHE');
    expect(codes).toContain('MAT');
    expect(codes).toContain('ENG');
    expect(codes).toContain('ECO');
    expect(codes).toContain('GEO');
    expect(codes).toContain('HIS');
  });

  it('GET /api/v1/curriculum/subjects?grade=11&stream=natural should return only Natural Science and Common subjects', async () => {
    const res = await request(app).get('/api/v1/curriculum/subjects?grade=11&stream=natural');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveLength(5);

    const codes = res.body.data.map((s: any) => s.code);
    expect(codes).toEqual(expect.arrayContaining(['PHY', 'CHE', 'BIO', 'MAT', 'ENG']));
    expect(codes).not.toContain('ECO');
    expect(codes).not.toContain('GEO');
    expect(codes).not.toContain('HIS');
  });

  it('GET /api/v1/curriculum/subjects?grade=12&stream=social should return only Social Science and Common subjects', async () => {
    const res = await request(app).get('/api/v1/curriculum/subjects?grade=12&stream=social');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveLength(5);

    const codes = res.body.data.map((s: any) => s.code);
    expect(codes).toEqual(expect.arrayContaining(['ECO', 'GEO', 'HIS', 'MAT', 'ENG']));
    expect(codes).not.toContain('PHY');
    expect(codes).not.toContain('CHE');
    expect(codes).not.toContain('BIO');
  });

  it('GET /api/v1/curriculum/subjects with Bearer token should auto-filter by authenticated student grade & stream', async () => {
    const res = await request(app)
      .get('/api/v1/curriculum/subjects')
      .set('Authorization', `Bearer ${naturalStudentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveLength(5);

    const codes = res.body.data.map((s: any) => s.code);
    expect(codes).toEqual(expect.arrayContaining(['PHY', 'CHE', 'BIO', 'MAT', 'ENG']));
    expect(codes).not.toContain('ECO');
  });

  it('GET /api/v1/curriculum/units should reject missing parameters with 400 Bad Request', async () => {
    const res = await request(app).get('/api/v1/curriculum/units');

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('BAD_REQUEST');
  });

  it('GET /api/v1/curriculum/units?grade=9&subject=PHY should list published units for student', async () => {
    const res = await request(app).get('/api/v1/curriculum/units?grade=9&subject=PHY');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThanOrEqual(1);

    const unit = res.body.data[0];
    expect(unit.grade).toBe(9);
    expect(unit.subjectCode).toBe('PHY');
    expect(unit.isPublished).toBe(true);
    expect(unit.questionCount).toBe(15);
  });

  it('GET /api/v1/curriculum/units/:unitId should return unit details', async () => {
    const res = await request(app).get(`/api/v1/curriculum/units/${samplePublishedUnitId}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.code).toBe('PHY-G09-U01');
    expect(res.body.data.title).toBe('Physics and Human Society');
  });

  it('GET /api/v1/curriculum/units/:unitId/questions should deliver 15 questions with ZERO answer key leakage', async () => {
    const res = await request(app).get(
      `/api/v1/curriculum/units/${samplePublishedUnitId}/questions`
    );

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveLength(15);
    expect(res.body.meta.total).toBe(15);

    for (const q of res.body.data) {
      expect(q.id).toMatch(/^PHY-G09-U01-Q\d{3}$/);
      expect(q.type).toBe('multiple_choice');
      expect(['easy', 'medium', 'challenging']).toContain(q.difficulty);
      expect(typeof q.question).toBe('string');
      expect(q.question.length).toBeGreaterThan(0);
      expect(q.options).toHaveLength(4);

      // CRITICAL SECURITY ASSERTION:
      // Answer keys and explanations must NEVER be returned to students!
      expect(q.correctOptionId).toBeUndefined();
      expect(q.explanation).toBeUndefined();

      // Inspect serialized JSON string to ensure no hidden properties
      const serialized = JSON.stringify(q);
      expect(serialized).not.toContain('correctOptionId');
      expect(serialized).not.toContain('explanation');
    }
  });
});
