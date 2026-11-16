import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { CurriculumSeederService } from '../src/modules/curriculum/curriculum-seeder.service';
import { UnitModel } from '../src/modules/curriculum/models/unit.model';
import { QuestionModel } from '../src/modules/curriculum/models/question.model';
import { UserModel } from '../src/modules/users/user.model';
import { StudentProgressModel } from '../src/modules/progress/models/student-progress.model';
import { env } from '../src/config/env';

describe('Study Management Engine & Assessment Exam Gating', () => {
  const app = createApp();

  let studentId = '';
  let studentToken = '';
  let sampleUnit: any = null;
  let sampleQuestions: any[] = [];

  beforeAll(async () => {
    await connectDatabase();
    await CurriculumSeederService.seedCurriculum();

    const studentUser = await UserModel.create({
      acedexId: `ACEDEX-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Study Tracker Student',
      grade: 9,
      role: 'student',
      status: 'active',
      authProvider: 'phone',
    });

    studentId = studentUser._id.toString();

    studentToken = jwt.sign(
      {
        sub: studentId,
        id: studentId,
        acedexId: studentUser.acedexId,
        role: studentUser.role,
        grade: studentUser.grade,
        displayName: studentUser.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    sampleUnit = await UnitModel.findOne({
      grade: 9,
      subjectCode: 'PHY',
      unitNumber: 1,
    });
    expect(sampleUnit).toBeDefined();

    sampleQuestions = await QuestionModel.find({
      unitId: sampleUnit._id,
      isPublished: true,
    }).sort({ externalId: 1 });
  }, 60000);

  afterAll(async () => {
    await UserModel.deleteMany({ displayName: /Study Tracker/ });
    await StudentProgressModel.deleteMany({ userId: studentId });
    await disconnectDatabase();
  });

  it('GET /api/v1/curriculum/units should show studyStatus: not_started and isExamUnlocked: false for new student', async () => {
    const res = await request(app)
      .get('/api/v1/curriculum/units?grade=9&subject=PHY')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    const unit = res.body.data.find((u: any) => u.code === sampleUnit.code);
    expect(unit).toBeDefined();
    expect(unit.studyStatus).toBe('not_started');
    expect(unit.isStudyCompleted).toBe(false);
    expect(unit.isExamUnlocked).toBe(false);
  });

  it('POST /api/v1/assessments/submit should reject with 403 EXAM_LOCKED_STUDY_REQUIRED when unit is not finished', async () => {
    const answers = sampleQuestions.map((q) => ({
      questionId: q.externalId,
      selectedOptionId: 'A' as const,
    }));

    const res = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId: sampleUnit._id.toString(),
        answers,
        durationSeconds: 120,
      });

    expect(res.status).toBe(403);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('EXAM_LOCKED_STUDY_REQUIRED');
    expect(res.body.error.message).toContain('Exam assessment is locked for this unit');
  });

  it('POST /api/v1/study/units/:unitId/status should update unit to in_progress (exam remains locked)', async () => {
    const res = await request(app)
      .post(`/api/v1/study/units/${sampleUnit._id}/status`)
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ status: 'in_progress' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.studyStatus).toBe('in_progress');
    expect(res.body.data.isStudyCompleted).toBe(false);
    expect(res.body.data.isExamUnlocked).toBe(false);
  });

  it('POST /api/v1/study/units/:unitId/complete should mark unit finished and immediately unlock exam', async () => {
    const res = await request(app)
      .post(`/api/v1/study/units/${sampleUnit._id}/complete`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.studyStatus).toBe('completed');
    expect(res.body.data.isStudyCompleted).toBe(true);
    expect(res.body.data.isExamUnlocked).toBe(true);
    expect(res.body.data.studyCompletedAt).toBeDefined();
  });

  it('POST /api/v1/assessments/submit should now succeed after unit study is completed', async () => {
    const answers = sampleQuestions.map((q) => ({
      questionId: q.externalId,
      selectedOptionId: 'A' as const,
    }));

    const res = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId: sampleUnit._id.toString(),
        answers,
        durationSeconds: 150,
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.unitCode).toBe(sampleUnit.code);
    expect(res.body.data.totalQuestions).toBe(15);
  });

  it('POST /api/v1/study/units/:unitId/status with not_started should re-lock the exam assessment', async () => {
    const res = await request(app)
      .post(`/api/v1/study/units/${sampleUnit._id}/status`)
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ status: 'not_started' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.studyStatus).toBe('not_started');
    expect(res.body.data.isStudyCompleted).toBe(false);
    expect(res.body.data.isExamUnlocked).toBe(false);

    // Verify submission is locked again
    const submitRes = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId: sampleUnit._id.toString(),
        answers: [{ questionId: sampleQuestions[0].externalId, selectedOptionId: 'A' }],
      });

    expect(submitRes.status).toBe(403);
    expect(submitRes.body.error.code).toBe('EXAM_LOCKED_STUDY_REQUIRED');

    // Re-complete for remaining tests
    await request(app)
      .post(`/api/v1/study/units/${sampleUnit._id}/complete`)
      .set('Authorization', `Bearer ${studentToken}`);
  });

  it('GET /api/v1/study/subjects/:subjectCode should return unit study checklist and mastery metrics', async () => {
    const res = await request(app)
      .get('/api/v1/study/subjects/PHY?grade=9')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.subjectCode).toBe('PHY');
    expect(res.body.data.totalUnits).toBeGreaterThan(0);
    expect(res.body.data.completedUnits).toBeGreaterThanOrEqual(1);
    expect(res.body.data.completionPercentage).toBeGreaterThan(0);
    expect(res.body.data.units).toBeInstanceOf(Array);

    const unit1 = res.body.data.units.find((u: any) => u.unitCode === sampleUnit.code);
    expect(unit1).toBeDefined();
    expect(unit1.isStudyCompleted).toBe(true);
    expect(unit1.isExamUnlocked).toBe(true);
  });

  it('GET /api/v1/study/overview should summarize study completion across all enrolled subjects', async () => {
    const res = await request(app)
      .get('/api/v1/study/overview')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveProperty('totalUnits');
    expect(res.body.data).toHaveProperty('completedUnits');
    expect(res.body.data).toHaveProperty('completionPercentage');
    expect(res.body.data.completedUnits).toBeGreaterThanOrEqual(1);
    expect(res.body.data.subjects).toBeInstanceOf(Array);
  });

  it('GET /api/v1/progress/overview should include populated studyStats', async () => {
    const res = await request(app)
      .get('/api/v1/progress/overview')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveProperty('studyStats');
    expect(res.body.data.studyStats.completedUnits).toBeGreaterThanOrEqual(1);
    expect(res.body.data.studyStats.completionPercentage).toBeGreaterThan(0);
  });
});
