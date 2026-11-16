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
import { UserModel } from '../src/modules/users/user.model';
import { env } from '../src/config/env';

describe('Assessment & Scoring Engine (Zero Client Trust)', () => {
  const app = createApp();

  let studentId = '';
  let studentToken = '';
  let sampleUnit: any = null;
  let sampleQuestions: any[] = [];
  let answerKeyMap: Map<string, string> = new Map(); // questionId -> correctOptionId
  let firstAttemptId = '';

  beforeAll(async () => {
    await connectDatabase();

    // 1. Ensure curriculum is seeded
    await CurriculumSeederService.seedCurriculum();

    // 2. Create test student
    const studentUser = await UserModel.create({
      acedexId: `ACEDEX-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Assessment Test Student',
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

    // 3. Find published Unit 1 of Physics
    sampleUnit = await UnitModel.findOne({
      grade: 9,
      subjectCode: 'PHY',
      unitNumber: 1,
    });
    expect(sampleUnit).toBeDefined();

    // 4. Fetch questions and answer keys directly from DB for test assertions
    sampleQuestions = await QuestionModel.find({
      unitId: sampleUnit._id,
      isPublished: true,
    }).sort({ externalId: 1 });

    expect(sampleQuestions.length).toBe(15);

    const answerKeys = await AnswerKeyModel.find({
      questionId: { $in: sampleQuestions.map((q) => q._id) },
    });

    for (const ak of answerKeys) {
      answerKeyMap.set(ak.externalId, ak.correctOptionId);
      answerKeyMap.set(ak.questionId.toString(), ak.correctOptionId);
    }
  }, 60000);

  afterAll(async () => {
    await AssessmentAttemptModel.deleteMany({ userId: studentId });
    await StudentProgressModel.deleteMany({ userId: studentId });
    await UserModel.deleteMany({ displayName: 'Assessment Test Student' });
    await disconnectDatabase();
  });

  it('POST /api/v1/assessments/submit should reject unauthenticated request with 401 Unauthorized', async () => {
    const res = await request(app)
      .post('/api/v1/assessments/submit')
      .send({
        unitId: sampleUnit._id.toString(),
        answers: [],
      });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it('POST /api/v1/assessments/submit should reject empty answers with 422 Validation Error', async () => {
    const res = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId: sampleUnit._id.toString(),
        answers: [],
      });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  it('POST /api/v1/assessments/submit should score 12/15 (80%), pass, and hydrate explanations', async () => {
    // Build answers: 12 correct and 3 intentionally incorrect
    const answers = sampleQuestions.map((q, index) => {
      const correctOpt = answerKeyMap.get(q.externalId) || 'A';
      if (index < 12) {
        // Correct answer
        return {
          questionId: q.externalId,
          selectedOptionId: correctOpt,
        };
      } else {
        // Incorrect answer
        const wrongOpt = correctOpt === 'A' ? 'B' : 'A';
        return {
          questionId: q.externalId,
          selectedOptionId: wrongOpt,
        };
      }
    });

    const res = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId: sampleUnit._id.toString(),
        answers,
        durationSeconds: 180,
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    const data = res.body.data;
    expect(data.unitCode).toBe('PHY-G09-U01');
    expect(data.totalQuestions).toBe(15);
    expect(data.score).toBe(12);
    expect(data.percentage).toBe(80);
    expect(data.passed).toBe(true);
    expect(data.durationSeconds).toBe(180);
    expect(data.answers).toHaveLength(15);

    // Verify explanation hydration
    for (const ans of data.answers) {
      expect(ans.explanation).toBeDefined();
      expect(ans.explanation.length).toBeGreaterThan(0);
      expect(ans.correctOptionId).toBeDefined();
    }

    firstAttemptId = data.attemptId;
    expect(firstAttemptId).toBeDefined();
  });

  it('GET /api/v1/assessments/history should return the submitted attempt in history', async () => {
    const res = await request(app)
      .get('/api/v1/assessments/history')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.items.length).toBeGreaterThanOrEqual(1);

    const attempt = res.body.data.items[0];
    expect(attempt.attemptId).toBe(firstAttemptId);
    expect(attempt.score).toBe(12);
    expect(attempt.percentage).toBe(80);
    expect(attempt.passed).toBe(true);
  });

  it('GET /api/v1/assessments/:attemptId should return full attempt details and reviews', async () => {
    const res = await request(app)
      .get(`/api/v1/assessments/${firstAttemptId}`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.attemptId).toBe(firstAttemptId);
    expect(res.body.data.score).toBe(12);
    expect(res.body.data.answers).toHaveLength(15);

    const firstAnswer = res.body.data.answers[0];
    expect(firstAnswer.explanation).toBeDefined();
    expect(firstAnswer.correctOptionId).toBeDefined();
  });

  it('GET /api/v1/assessments/unit/:unitId/summary should reflect best score 12 and 1 total attempt', async () => {
    const res = await request(app)
      .get(`/api/v1/assessments/unit/${sampleUnit._id.toString()}/summary`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.hasAttempted).toBe(true);
    expect(res.body.data.bestScore).toBe(12);
    expect(res.body.data.bestPercentage).toBe(80);
    expect(res.body.data.passed).toBe(true);
    expect(res.body.data.totalAttempts).toBe(1);
  });

  it('POST /api/v1/assessments/submit with 15/15 should update best score to 15 and attempts to 2', async () => {
    // All 15 correct
    const allCorrectAnswers = sampleQuestions.map((q) => ({
      questionId: q.externalId,
      selectedOptionId: answerKeyMap.get(q.externalId),
    }));

    const submitRes = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId: sampleUnit.code, // Test unitCode resolution
        answers: allCorrectAnswers,
        durationSeconds: 120,
      });

    expect(submitRes.status).toBe(200);
    expect(submitRes.body.data.score).toBe(15);
    expect(submitRes.body.data.percentage).toBe(100);
    expect(submitRes.body.data.passed).toBe(true);

    // Verify summary
    const summaryRes = await request(app)
      .get(`/api/v1/assessments/unit/${sampleUnit.code}/summary`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(summaryRes.status).toBe(200);
    expect(summaryRes.body.data.bestScore).toBe(15);
    expect(summaryRes.body.data.bestPercentage).toBe(100);
    expect(summaryRes.body.data.totalAttempts).toBe(2);
  });
});
