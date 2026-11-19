import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import mongoose from 'mongoose';
import { createApp } from '../src/app';
import { env } from '../src/config/env';
import { UserModel } from '../src/modules/users/user.model';
import { QuestionModel } from '../src/modules/curriculum/models/question.model';
import { BookmarkModel } from '../src/modules/curriculum/models/bookmark.model';

describe('Mobile Readiness Backend Enhancements', { timeout: 30000 }, () => {
  const app = createApp();
  let studentToken: string;
  let studentId: string;
  let testPhone: string;
  let sampleQuestion: any;

  beforeAll(async () => {
    if (mongoose.connection.readyState !== 1) {
      await mongoose.connect(env.MONGODB_URI);
    }

    testPhone = `+2519${Math.floor(10000000 + Math.random() * 90000000)}`;

    // Register a test student
    const regRes = await request(app)
      .post('/api/v1/auth/register-phone')
      .send({
        phone: testPhone,
        pin: '123456',
        fullName: 'Test Mobile Student',
        gender: 'female',
        grade: 10,
      });

    expect(regRes.status).toBe(201);
    studentToken = regRes.body.data.tokens.accessToken;
    studentId = regRes.body.data.user.id;

    // Retrieve an existing published question from Economics or History
    sampleQuestion = await QuestionModel.findOne({ isPublished: true });
  }, 35000);

  afterAll(async () => {
    if (studentId) {
      await UserModel.findByIdAndDelete(studentId);
      await BookmarkModel.deleteMany({ userId: new mongoose.Types.ObjectId(studentId) });
    }
  });

  describe('Feature 1: Student Profile Updates (PATCH /auth/profile)', () => {
    it('should update display name and gender', async () => {
      const res = await request(app)
        .patch('/api/v1/auth/profile')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({
          displayName: 'Updated Student Name',
          gender: 'male',
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.displayName).toBe('Updated Student Name');
      expect(res.body.data.gender).toBe('male');
    });

    it('should promote student to Grade 11 with natural stream', async () => {
      const res = await request(app)
        .patch('/api/v1/auth/profile')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({
          grade: 11,
          stream: 'natural',
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.grade).toBe(11);
      expect(res.body.data.stream).toBe('natural');
    });

    it('should reject Grade 11 when stream is null or missing', async () => {
      const res = await request(app)
        .patch('/api/v1/auth/profile')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({
          grade: 12,
          stream: null,
        });

      expect(res.status).toBe(422);
      expect(res.body.success).toBe(false);
    });

    it('GET /api/v1/auth/me should reflect updated profile', async () => {
      const res = await request(app)
        .get('/api/v1/auth/me')
        .set('Authorization', `Bearer ${studentToken}`);

      expect(res.status).toBe(200);
      expect(res.body.data.displayName).toBe('Updated Student Name');
      expect(res.body.data.grade).toBe(11);
      expect(res.body.data.stream).toBe('natural');
    });
  });

  describe('Feature 2: Daily Free Exam Tickets Auto-Replenishment', () => {
    it('should auto-replenish to at least 2 daily free tickets on status check', async () => {
      const res = await request(app)
        .get('/api/v1/ads/status')
        .set('Authorization', `Bearer ${studentToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.examAccess.ticketsAvailable).toBeGreaterThanOrEqual(2);
      expect(res.body.data.examAccess.canTakeExam).toBe(true);
    });
  });

  describe('Feature 3: Question Bookmarks / Saved Questions System', () => {
    it('should bookmark a question with optional notes', async () => {
      if (!sampleQuestion) return;

      const res = await request(app)
        .post(`/api/v1/curriculum/questions/${sampleQuestion.externalId}/bookmark`)
        .set('Authorization', `Bearer ${studentToken}`)
        .send({
          notes: 'Review before national exam',
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.externalId).toBe(sampleQuestion.externalId);
      expect(res.body.data.notes).toBe('Review before national exam');
      expect(res.body.data).toHaveProperty('explanation');
    });

    it('should list bookmarked questions for student', async () => {
      if (!sampleQuestion) return;

      const res = await request(app)
        .get('/api/v1/curriculum/bookmarks')
        .set('Authorization', `Bearer ${studentToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.total).toBeGreaterThanOrEqual(1);
      const found = res.body.data.bookmarks.find(
        (b: any) => b.externalId === sampleQuestion.externalId
      );
      expect(found).toBeDefined();
    });

    it('should remove a bookmark', async () => {
      if (!sampleQuestion) return;

      const res = await request(app)
        .delete(`/api/v1/curriculum/questions/${sampleQuestion.externalId}/bookmark`)
        .set('Authorization', `Bearer ${studentToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.removed).toBe(true);

      const listRes = await request(app)
        .get('/api/v1/curriculum/bookmarks')
        .set('Authorization', `Bearer ${studentToken}`);

      const found = listRes.body.data.bookmarks.find(
        (b: any) => b.externalId === sampleQuestion.externalId
      );
      expect(found).toBeUndefined();
    });
  });

  describe('Feature 4: EUEE Subject Model Exam Generator', () => {
    it('should generate a 50-question model exam session for Economics', async () => {
      const res = await request(app)
        .get('/api/v1/curriculum/subjects/ECO/model-exam?grade=12&count=50');

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.subjectCode).toBe('ECO');
      expect(res.body.data.totalQuestions).toBe(50);
      expect(res.body.data.timeLimitMinutes).toBe(75);
      expect(res.body.data.questions).toHaveLength(50);
      expect(res.body.data.questions[0]).toHaveProperty('id');
      expect(res.body.data.questions[0]).toHaveProperty('question');
      expect(res.body.data.questions[0]).toHaveProperty('options');
      expect(res.body.data.questions[0]).toHaveProperty('unitCode');
    });
  });
});
