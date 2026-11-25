import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { CurriculumSeederService } from '../src/modules/curriculum/curriculum-seeder.service';
import { UnitModel } from '../src/modules/curriculum/models/unit.model';
import { QuestionModel } from '../src/modules/curriculum/models/question.model';
import { AnswerKeyModel } from '../src/modules/curriculum/models/answer-key.model';
import { AssessmentAttemptModel } from '../src/modules/assessments/models/assessment-attempt.model';
import { StudentProgressModel } from '../src/modules/progress/models/student-progress.model';
import { ProgressService } from '../src/modules/progress/progress.service';
import { UserModel } from '../src/modules/users/user.model';
import { env } from '../src/config/env';

describe('Student Progress & Analytics Engine', () => {
  const app = createApp();

  let studentId = '';
  let studentToken = '';
  let sampleUnit: any = null;
  let sampleQuestions: any[] = [];
  let answerKeyMap: Map<string, string> = new Map();

  beforeAll(async () => {
    await connectDatabase();

    // 1. Ensure curriculum is seeded
    await CurriculumSeederService.seedCurriculum();

    // 2. Create dedicated student for progress test
    const studentUser = await UserModel.create({
      acedexId: `ACEDEX-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Progress Test Student',
      grade: 9,
      role: 'student',
      status: 'active',
      authProvider: 'phone',
    });

    studentId = studentUser._id.toString();

    studentToken = jwt.sign(
      {
        sub: studentId,
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

    sampleQuestions = await QuestionModel.find({
      unitId: sampleUnit._id,
      isPublished: true,
    });

    const answerKeys = await AnswerKeyModel.find({
      questionId: { $in: sampleQuestions.map((q) => q._id) },
    });

    for (const ak of answerKeys) {
      answerKeyMap.set(ak.externalId, ak.correctOptionId);
    }
  }, 120000);

  afterAll(async () => {
    if (studentId) {
      await AssessmentAttemptModel.deleteMany({ userId: studentId });
      await StudentProgressModel.deleteMany({ userId: studentId });
    }
    await UserModel.deleteMany({ displayName: 'Progress Test Student' });
    await disconnectDatabase();
  });

  it('GET /api/v1/progress/overview should return zero-state for new student', async () => {
    const res = await request(app)
      .get('/api/v1/progress/overview')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    const data = res.body.data;
    expect(data.overallStats.totalAssessmentsTaken).toBe(0);
    expect(data.overallStats.totalAssessmentsPassed).toBe(0);
    expect(data.overallStats.averageScore).toBe(0);
    expect(data.streak.currentStreak).toBe(0);
    expect(data.recentAttempts).toHaveLength(0);
    expect(data.subjectMastery.length).toBeGreaterThan(0);
  });

  it('GET /api/v1/progress/overview should update after student submits an assessment', async () => {
    // Submit 12/15 correct answers
    const answers = sampleQuestions.map((q, index) => {
      const correctOpt = answerKeyMap.get(q.externalId) || 'A';
      return {
        questionId: q.externalId,
        selectedOptionId: index < 12 ? correctOpt : (correctOpt === 'A' ? 'B' : 'A'),
      };
    });

    // Mark unit completed in study tracker to unlock exam
    await ProgressService.updateUnitStudyStatus(studentId, sampleUnit._id.toString(), 'completed');

    const submitRes = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId: sampleUnit._id.toString(),
        answers,
        durationSeconds: 120,
      });

    expect(submitRes.status).toBe(200);

    // Verify updated progress overview
    const overviewRes = await request(app)
      .get('/api/v1/progress/overview')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(overviewRes.status).toBe(200);
    expect(overviewRes.body.success).toBe(true);

    const data = overviewRes.body.data;
    expect(data.overallStats.totalAssessmentsTaken).toBe(1);
    expect(data.overallStats.totalAssessmentsPassed).toBe(1);
    expect(data.overallStats.averageScore).toBe(80);
    expect(data.overallStats.totalTimeSpentSeconds).toBe(120);
    expect(data.streak.currentStreak).toBe(1);
    expect(data.streak.longestStreak).toBe(1);
    expect(data.recentAttempts).toHaveLength(1);
    expect(data.recentAttempts[0].unitCode).toBe('PHY-G09-U01');
    expect(data.recentAttempts[0].score).toBe(12);
  });

  it('GET /api/v1/progress/subjects/:subjectCode should return unit-level breakdown', async () => {
    const res = await request(app)
      .get('/api/v1/progress/subjects/PHY?grade=9')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    const data = res.body.data;
    expect(data.subjectCode).toBe('PHY');
    expect(data.grade).toBe(9);
    expect(data.units.length).toBeGreaterThan(0);

    const unit1 = data.units.find((u: any) => u.unitNumber === 1);
    expect(unit1).toBeDefined();
    expect(unit1.attemptsCount).toBe(1);
    expect(unit1.bestScore).toBe(12);
    expect(unit1.bestPercentage).toBe(80);
    expect(unit1.passed).toBe(true);
  });

  it('GET /api/v1/progress/analytics should compute live trends, 28-day heatmap, and 6 simulator subjects including English & SAT', async () => {
    const res = await request(app)
      .get('/api/v1/progress/analytics')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    const data = res.body.data;
    expect(data.stream).toBe('natural');
    expect(data.streak.currentStreak).toBeGreaterThanOrEqual(1);
    expect(data.heatmapDays).toHaveLength(28);
    expect(data.heatmapDays[27].date).toContain('Today');
    expect(data.heatmapDays[27].minutes).toBeGreaterThan(0);

    // 7d timeframe reflects real recorded unit & assessment activity
    const tf7d = data.timeframes['7d'];
    expect(tf7d.points).toHaveLength(7);
    expect(tf7d.completedUnits).toBeGreaterThanOrEqual(1);
    expect(tf7d.assessmentsCount).toBe(1);
    expect(tf7d.accuracyPct).toBe(80);
    expect(tf7d.footerQs).toBe(`${sampleQuestions.length} Qs`);

    // 6 simulator subjects including English & SAT
    expect(data.simulatorSubjects).toHaveLength(6);
    const codes = data.simulatorSubjects.map((s: any) => s.code);
    expect(codes).toEqual(['MAT', 'PHY', 'BIO', 'CHE', 'ENG', 'SAT']);
    const phySubj = data.simulatorSubjects.find((s: any) => s.code === 'PHY');
    expect(phySubj.score).toBeGreaterThan(0);
    const satSubj = data.simulatorSubjects.find((s: any) => s.code === 'SAT');
    expect(satSubj.score).toBeGreaterThan(0);
  });
});
