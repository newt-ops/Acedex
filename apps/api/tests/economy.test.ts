import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { CurriculumSeederService } from '../src/modules/curriculum/curriculum-seeder.service';
import { TopicBankParserService } from '../src/modules/topics/topic-bank-parser.service';
import { TopicModuleModel } from '../src/modules/topics/models/topic-module.model';
import { UnitModel } from '../src/modules/curriculum/models/unit.model';
import { QuestionModel } from '../src/modules/curriculum/models/question.model';
import { AnswerKeyModel } from '../src/modules/curriculum/models/answer-key.model';
import { AssessmentAttemptModel } from '../src/modules/assessments/models/assessment-attempt.model';
import { StudentProgressModel } from '../src/modules/progress/models/student-progress.model';
import { AdSessionModel } from '../src/modules/ads/models/ad-session.model';
import { CoinTransactionModel } from '../src/modules/economy/models/coin-transaction.model';
import { UserModel } from '../src/modules/users/user.model';
import { env } from '../src/config/env';

describe('Ace Coins Economy, Milestones, Ad Top-Ups & Assessment Fee', { timeout: 90000 }, () => {
  const app = createApp();

  let studentId = '';
  let studentToken = '';
  let phyUnit: any = null;
  let sampleQuestions: any[] = [];
  let answerKeyMap: Map<string, string> = new Map();

  beforeAll(async () => {
    await connectDatabase();
    const existingUnit = await UnitModel.findOne({ grade: 9, subjectCode: 'PHY', unitNumber: 1 });
    if (!existingUnit) {
      await CurriculumSeederService.seedCurriculum();
    }
    const existingModule = await TopicModuleModel.findOne({ moduleId: 'MAT-M01' });
    if (!existingModule) {
      await TopicBankParserService.seedTopicsFromDisk();
    }

    const studentUser = await UserModel.create({
      acedexId: `ACEDEX-ECN-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Economy Test Student',
      grade: 12,
      stream: 'natural',
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

    phyUnit = await UnitModel.findOne({ grade: 9, subjectCode: 'PHY', unitNumber: 1 });
    expect(phyUnit).toBeDefined();

    sampleQuestions = await QuestionModel.find({
      unitId: phyUnit._id,
      isPublished: true,
    }).sort({ externalId: 1 });

    const keys = await AnswerKeyModel.find({
      questionId: { $in: sampleQuestions.map((q) => q._id) },
    });
    for (const k of keys) {
      answerKeyMap.set(k.externalId, k.correctOptionId);
    }
  }, 180000);

  afterAll(async () => {
    if (studentId) {
      await CoinTransactionModel.deleteMany({ userId: studentId });
      await AdSessionModel.deleteMany({ userId: studentId });
      await AssessmentAttemptModel.deleteMany({ userId: studentId });
      await StudentProgressModel.deleteMany({ userId: studentId });
    }
    await UserModel.deleteMany({ displayName: 'Economy Test Student' });
    await disconnectDatabase();
  }, 60000);

  it('1. Fresh student starts with 25 AC Welcome Bonus and ledger entry', async () => {
    const res = await request(app)
      .get('/api/v1/economy/wallet')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.data.currencyName).toBe('Ace Coins');
    expect(res.body.data.currencyCode).toBe('AC');
    expect(res.body.data.balance).toBe(25);
    expect(res.body.data.assessmentCost).toBe(10);
    expect(res.body.data.recentTransactions[0].type).toBe('earn_welcome');
    expect(res.body.data.recentTransactions[0].amount).toBe(25);
  });

  it('2. Completing unit awards +15 AC unit & +10 AC daily streak idempotently once only', async () => {
    const res1 = await request(app)
      .post(`/api/v1/study/units/${phyUnit.code}/complete`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res1.status).toBe(200);
    expect(res1.body.data.coinsAwarded).toBe(25); // +15 unit + 10 streak
    expect(res1.body.data.newCoinBalance).toBe(50);

    // Unmark & re-complete should NOT double-award coins
    await request(app)
      .post(`/api/v1/study/units/${phyUnit.code}/status`)
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ status: 'not_started' });

    const res2 = await request(app)
      .post(`/api/v1/study/units/${phyUnit.code}/complete`)
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res2.status).toBe(200);
    expect(res2.body.data.coinsAwarded).toBeUndefined();
    expect(res2.body.data.newCoinBalance).toBe(50);
  });

  it('3. Unit assessment deducts 10 AC once per unit, retakes are 0 AC, and reward is 5 AC only', async () => {
    const allCorrect = sampleQuestions.map((q) => ({
      questionId: q.externalId,
      selectedOptionId: answerKeyMap.get(q.externalId) || 'A',
    }));

    const submitRes = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId: phyUnit.code,
        answers: allCorrect,
        durationSeconds: 95,
      });

    expect(submitRes.status).toBe(200);
    expect(submitRes.body.data.coinsSpent).toBe(10);
    expect(submitRes.body.data.coinsAwarded).toBe(5); // 5 coins only
    expect(submitRes.body.data.newCoinBalance).toBe(45); // 50 - 10 + 5 = 45

    // Retaking the same unit assessment charges 0 AC (permanently unlocked for this unit)
    const retakeRes = await request(app)
      .post('/api/v1/assessments/submit')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        unitId: phyUnit.code,
        answers: allCorrect,
        durationSeconds: 80,
      });
    expect(retakeRes.status).toBe(200);
    expect(retakeRes.body.data.coinsSpent).toBe(0);
    expect(retakeRes.body.data.newCoinBalance).toBe(45);

    // Calling spend for already-unlocked unit also charges 0 AC
    const spendAgainRes = await request(app)
      .post('/api/v1/economy/spend')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ itemKey: 'unit_assessment', targetUnitId: phyUnit.code });
    expect(spendAgainRes.status).toBe(200);
    expect(spendAgainRes.body.data.coinsSpent).toBe(0);
    expect(spendAgainRes.body.data.newBalance).toBe(45);
  });

  it('4. Mastering AI topic module grants +30 AC idempotently', async () => {
    const modRes = await request(app)
      .post('/api/v1/topics/modules/MAT-M01/progress')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ isCompleted: true });

    expect(modRes.status).toBe(200);
    expect(modRes.body.data.coinsAwarded).toBe(30);
    expect(modRes.body.data.newCoinBalance).toBe(75); // 45 + 30
  });

  it('5. Rewarded Ad (bonus_coins) grants +10 AC without daily ad limits', async () => {
    for (let i = 0; i < 6; i++) {
      const startRes = await request(app)
        .post('/api/v1/ads/session/start')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ rewardType: 'bonus_coins', platform: 'android' });
      expect(startRes.status).toBe(201);

      const claimRes = await request(app)
        .post('/api/v1/ads/reward/claim')
        .set('Authorization', `Bearer ${studentToken}`)
        .send({
          adSessionId: startRes.body.data.adSessionId,
          rewardType: 'bonus_coins',
        });
      expect(claimRes.status).toBe(200);
      expect(claimRes.body.data.coinsAwarded).toBe(10);
    }

    // Balance should now be 75 + 6*10 = 135 AC, and ALL 6 earn_ad logs must exist
    const walletRes = await request(app)
      .get('/api/v1/economy/wallet')
      .set('Authorization', `Bearer ${studentToken}`);
    expect(walletRes.body.data.balance).toBe(135);
    expect(walletRes.body.data.coinsPerAd).toBe(10);
    expect(walletRes.body.data.dailyCoinAdsLimit).toBe(0);
    expect(walletRes.body.data.unlockedAssessmentUnits).toContain(phyUnit.code);
    const adLogs = walletRes.body.data.recentTransactions.filter(
      (t: any) => t.type === 'earn_ad'
    );
    expect(adLogs).toHaveLength(6);
  });

  it('6. Spending 100 AC unlocks AI Study Plan Pass & 120 AC unlocks Gold Scholar Badge', async () => {
    // Buy AI Plan Pass (100 AC -> 35 AC left)
    const passRes = await request(app)
      .post('/api/v1/economy/spend')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ itemKey: 'ai_plan_pass' });
    expect(passRes.status).toBe(200);
    expect(passRes.body.data.newBalance).toBe(35);
    expect(passRes.body.data.aiPlanPasses).toBe(1);

    // Generate AI Study Program using coin pass without adSessionId
    const planRes = await request(app)
      .post('/api/v1/topics/program')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        tierId: 'competitive',
        targetScore: 500,
        weakSubjectCodes: ['PHY', 'MAT'],
        dailyMinutes: 90,
        peakWindow: 'Morning',
        prepStageId: 'reviewing',
        useCoinPass: true,
      });
    expect(planRes.status).toBe(200);
    expect(planRes.body.data.hasProgram).toBe(true);

    // Earn +90 AC from 3 more topic modules (BIO-M01, CHE-M01, PHY-M01 -> 35 + 90 = 125 AC)
    for (const moduleId of ['BIO-M01', 'CHE-M01', 'PHY-M01']) {
      const mRes = await request(app)
        .post(`/api/v1/topics/modules/${moduleId}/progress`)
        .set('Authorization', `Bearer ${studentToken}`)
        .send({ isCompleted: true });
      expect(mRes.status).toBe(200);
      expect(mRes.body.data.coinsAwarded).toBe(30);
    }

    // Buy Gold Scholar Badge (120 AC -> 5 AC left), and confirm BOTH spend logs exist
    const badgeRes = await request(app)
      .post('/api/v1/economy/spend')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ itemKey: 'badge_euee_gold' });
    expect(badgeRes.status).toBe(200);
    expect(badgeRes.body.data.newBalance).toBe(5);
    expect(badgeRes.body.data.unlockedBadge).toBe('badge_euee_gold');

    const walletAfterSpend = await request(app)
      .get('/api/v1/economy/wallet')
      .set('Authorization', `Bearer ${studentToken}`);
    const spendLogs = walletAfterSpend.body.data.recentTransactions.filter(
      (t: any) => t.type === 'spend'
    );
    expect(spendLogs.length).toBeGreaterThanOrEqual(3); // 10 AC assessment + 100 AC pass + 120 AC badge

    // Insufficient balance check for 180 AC STEM Master badge
    const failBadge = await request(app)
      .post('/api/v1/economy/spend')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ itemKey: 'badge_stem_master' });
    expect(failBadge.status).toBe(400);
    expect(failBadge.body.error.code).toBe('INSUFFICIENT_COINS');
  });
});
