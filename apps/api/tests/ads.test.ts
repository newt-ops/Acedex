import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { CurriculumSeederService } from '../src/modules/curriculum/curriculum-seeder.service';
import { UserModel } from '../src/modules/users/user.model';
import { UnitModel } from '../src/modules/curriculum/models/unit.model';
import { AdSessionModel } from '../src/modules/ads/models/ad-session.model';
import { AdConfigModel } from '../src/modules/ads/models/ad-config.model';
import { StudentProgressModel } from '../src/modules/progress/models/student-progress.model';
import { env } from '../src/config/env';

describe('Unity Ads Rewarded Engine & Monetization APIs', () => {
  const app = createApp();

  let studentId = '';
  let studentToken = '';
  let otherStudentToken = '';
  let sampleUnit: any = null;
  let otherUnit: any = null;

  beforeAll(async () => {
    await connectDatabase();
    await CurriculumSeederService.seedCurriculum();

    // 1. Create primary student
    const studentUser = await UserModel.create({
      acedexId: `ACEDEX-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Ad Test Student',
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

    // 2. Create another student for isolation testing
    const otherStudent = await UserModel.create({
      acedexId: `ACEDEX-${(Date.now() + 1).toString().slice(-6)}`,
      phone: `+2519${(Date.now() + 2).toString().slice(-8)}`,
      displayName: 'Other Test Student',
      grade: 9,
      role: 'student',
      status: 'active',
      authProvider: 'phone',
    });

    otherStudentToken = jwt.sign(
      {
        sub: otherStudent._id.toString(),
        acedexId: otherStudent.acedexId,
        role: otherStudent.role,
        displayName: otherStudent.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    // 3. Resolve published units for offline pack testing
    sampleUnit = await UnitModel.findOne({ grade: 9, subjectCode: 'PHY', unitNumber: 1 });
    otherUnit = await UnitModel.findOne({ grade: 9, subjectCode: 'CHE', unitNumber: 1 });
  }, 60000);

  afterAll(async () => {
    await AdSessionModel.deleteMany({ userId: studentId });
    await StudentProgressModel.deleteMany({ userId: studentId });
    await UserModel.deleteMany({ displayName: /Ad Test Student|Other Test Student/ });
    await disconnectDatabase();
  });

  it('GET /api/v1/ads/config should return Unity Ads IDs and 24-hour offline policy', async () => {
    const res = await request(app).get('/api/v1/ads/config');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.enabled).toBe(true);

    const unity = res.body.data.unityAds;
    expect(unity.androidGameId).toBe('6220248');
    expect(unity.iosGameId).toBe('6220249');
    expect(unity.androidPlacement).toBe('Rewarded_Android');
    expect(unity.iosPlacement).toBe('Rewarded_iOS');

    const policies = res.body.data.policies;
    expect(policies.streakRepair.enabled).toBe(true);
    expect(policies.examAccess.enabled).toBe(true);
    expect(policies.offlinePack.enabled).toBe(true);
    expect(policies.offlinePack.durationHours).toBe(24); // Strictly 24 hours per user specification
  });

  it('GET /api/v1/ads/status should report initial status (2 free tickets, no broken streak)', async () => {
    const res = await request(app)
      .get('/api/v1/ads/status')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.examAccess.ticketsAvailable).toBe(2);
    expect(res.body.data.examAccess.canTakeExam).toBe(true);
    expect(res.body.data.streak.canRepair).toBe(false);
    expect(res.body.data.offlineAccess.unlockedUnits).toHaveLength(0);
  });

  it('POST /api/v1/ads/session/start should start ad session for exam_access on Android', async () => {
    const res = await request(app)
      .post('/api/v1/ads/session/start')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        rewardType: 'exam_access',
        platform: 'android',
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.adSessionId).toMatch(/^adsess_/);
    expect(res.body.data.rewardType).toBe('exam_access');
    expect(res.body.data.gameId).toBe('6220248');
    expect(res.body.data.placementId).toBe('Rewarded_Android');
    expect(res.body.data.expiresAt).toBeDefined();
  });

  it('POST /api/v1/ads/session/start should start ad session on iOS with Rewarded_iOS placement', async () => {
    const res = await request(app)
      .post('/api/v1/ads/session/start')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        rewardType: 'exam_access',
        platform: 'ios',
      });

    expect(res.status).toBe(201);
    expect(res.body.data.gameId).toBe('6220249');
    expect(res.body.data.placementId).toBe('Rewarded_iOS');
  });

  it('POST /api/v1/ads/session/start should require targetUnitId for offline_pack reward', async () => {
    const res = await request(app)
      .post('/api/v1/ads/session/start')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        rewardType: 'offline_pack',
      });

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  it('GET /api/v1/ads/unity/callback should mark ad session verified via S2S webhook', async () => {
    // 1. Start a session
    const startRes = await request(app)
      .post('/api/v1/ads/session/start')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        rewardType: 'exam_access',
        platform: 'android',
      });

    const sessionId = startRes.body.data.adSessionId;

    // 2. Call S2S callback
    const s2sRes = await request(app).get(
      `/api/v1/ads/unity/callback?sid=${sessionId}&oid=unity_order_test_99`
    );

    expect(s2sRes.status).toBe(200);
    expect(s2sRes.body.data.verified).toBe(true);

    const doc = await AdSessionModel.findOne({ adSessionId: sessionId });
    expect(doc?.status).toBe('verified');
    expect(doc?.unityOrderId).toBe('unity_order_test_99');
  });

  it('POST /api/v1/ads/reward/claim should fulfill exam_access reward and grant ticket', async () => {
    // 1. Start session
    const startRes = await request(app)
      .post('/api/v1/ads/session/start')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        rewardType: 'exam_access',
      });

    const sessionId = startRes.body.data.adSessionId;

    // 2. Claim reward
    const claimRes = await request(app)
      .post('/api/v1/ads/reward/claim')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        adSessionId: sessionId,
        rewardType: 'exam_access',
      });

    expect(claimRes.status).toBe(200);
    expect(claimRes.body.success).toBe(true);
    expect(claimRes.body.data.rewardType).toBe('exam_access');
    expect(claimRes.body.data.examTicketsAvailable).toBe(3); // Initial 2 + 1 granted

    // 3. Double-claim rejection
    const doubleClaimRes = await request(app)
      .post('/api/v1/ads/reward/claim')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        adSessionId: sessionId,
        rewardType: 'exam_access',
      });

    expect(doubleClaimRes.status).toBe(400);
  });

  it('POST /api/v1/ads/reward/claim should reject unauthorized student attempting to claim another student session', async () => {
    const startRes = await request(app)
      .post('/api/v1/ads/session/start')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        rewardType: 'exam_access',
      });

    const sessionId = startRes.body.data.adSessionId;

    const stealRes = await request(app)
      .post('/api/v1/ads/reward/claim')
      .set('Authorization', `Bearer ${otherStudentToken}`)
      .send({
        adSessionId: sessionId,
        rewardType: 'exam_access',
      });

    expect(stealRes.status).toBe(403);
  });

  it('POST /api/v1/ads/reward/claim should unlock 24-hour offline study pass for unit', async () => {
    expect(sampleUnit).toBeDefined();

    // 1. Start session for offline pack
    const startRes = await request(app)
      .post('/api/v1/ads/session/start')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        rewardType: 'offline_pack',
        targetUnitId: sampleUnit._id.toString(),
      });

    expect(startRes.status).toBe(201);
    const sessionId = startRes.body.data.adSessionId;

    // 2. Claim offline pack reward
    const claimRes = await request(app)
      .post('/api/v1/ads/reward/claim')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        adSessionId: sessionId,
        rewardType: 'offline_pack',
      });

    expect(claimRes.status).toBe(200);
    expect(claimRes.body.data.rewardType).toBe('offline_pack');
    expect(claimRes.body.data.unlockedUnitId).toBe(sampleUnit._id.toString());
    expect(claimRes.body.data.unlockedUnitCode).toBe(sampleUnit.code);

    const expiryTime = new Date(claimRes.body.data.offlineAccessExpiresAt).getTime();
    const expectedTime = Date.now() + 24 * 3600 * 1000;
    // Must be valid ~24 hours from now (within 1 minute delta)
    expect(Math.abs(expiryTime - expectedTime)).toBeLessThan(60000);
  });

  it('GET /api/v1/curriculum/units/:unitId/offline-pack should deliver 15 questions with active pass', async () => {
    // 1. Fetch offline pack for unlocked unit
    const packRes = await request(app)
      .get(`/api/v1/curriculum/units/${sampleUnit._id.toString()}/offline-pack`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(packRes.status).toBe(200);
    expect(packRes.body.success).toBe(true);

    const pack = packRes.body.data;
    expect(pack.unitCode).toBe(sampleUnit.code);
    expect(pack.questionCount).toBe(15);
    expect(pack.questions).toHaveLength(15);

    // Verify ZERO answer keys are leaked in offline pack (Zero Client Trust)
    for (const q of pack.questions) {
      expect(q.id).toBeDefined();
      expect(q.question).toBeDefined();
      expect(q.options).toHaveLength(4);
      expect((q as any).correctOptionId).toBeUndefined();
      expect((q as any).explanation).toBeUndefined();
    }
  });

  it('GET /api/v1/curriculum/units/:unitId/offline-pack should return 403 for non-unlocked unit', async () => {
    expect(otherUnit).toBeDefined();

    const packRes = await request(app)
      .get(`/api/v1/curriculum/units/${otherUnit._id.toString()}/offline-pack`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(packRes.status).toBe(403);
    expect(packRes.body.success).toBe(false);
  });

  it('POST /api/v1/ads/reward/claim should repair broken streak and increment by 1', async () => {
    // 1. Simulate broken streak in DB
    await StudentProgressModel.updateOne(
      { userId: studentId },
      {
        $set: {
          'streak.currentStreak': 1,
          'streak.longestStreak': 8,
          'streak.previousBrokenStreak': 6,
        },
      }
    );

    // Verify student status reports repair available
    const statusRes = await request(app)
      .get('/api/v1/ads/status')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(statusRes.body.data.streak.canRepair).toBe(true);
    expect(statusRes.body.data.streak.brokenStreakCount).toBe(6);

    // 2. Start session
    const startRes = await request(app)
      .post('/api/v1/ads/session/start')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        rewardType: 'streak_repair',
      });

    const sessionId = startRes.body.data.adSessionId;

    // 3. Claim streak repair reward
    const claimRes = await request(app)
      .post('/api/v1/ads/reward/claim')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        adSessionId: sessionId,
        rewardType: 'streak_repair',
      });

    expect(claimRes.status).toBe(200);
    expect(claimRes.body.data.rewardType).toBe('streak_repair');
    expect(claimRes.body.data.repairedStreak).toBe(7); // 6 + 1

    // Verify DB state
    const progress = await StudentProgressModel.findOne({ userId: studentId });
    expect(progress?.streak.currentStreak).toBe(7);
    expect(progress?.streak.previousBrokenStreak).toBe(0);
  });
});
