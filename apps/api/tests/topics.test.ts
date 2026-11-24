import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import fs from 'fs';
import path from 'path';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { TopicBankParserService } from '../src/modules/topics/topic-bank-parser.service';
import { TopicModuleModel } from '../src/modules/topics/models/topic-module.model';
import { GeminiPlannerService } from '../src/modules/topics/gemini-planner.service';
import { UserModel } from '../src/modules/users/user.model';
import { StudentProgressModel } from '../src/modules/progress/models/student-progress.model';
import { AdSessionModel } from '../src/modules/ads/models/ad-session.model';
import { env } from '../src/config/env';

describe('AI Cross-Grade Topic Study & Gemini Planner Backend Tests', { timeout: 60000 }, () => {
  const app = createApp();

  let studentId = '';
  let studentToken = '';

  beforeAll(async () => {
    await connectDatabase();
    await TopicBankParserService.seedTopicsFromDisk();

    const studentUser = await UserModel.create({
      acedexId: `ACEDEX-TOP-${Date.now().toString().slice(-6)}`,
      phone: `+2519${Date.now().toString().slice(-8)}`,
      displayName: 'Topic Study Test Student',
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
  }, 60000);

  afterAll(async () => {
    if (studentId) {
      await AdSessionModel.deleteMany({ userId: studentId });
      await StudentProgressModel.deleteMany({ userId: studentId });
    }
    await UserModel.deleteMany({ displayName: 'Topic Study Test Student' });
    await disconnectDatabase();
  }, 60000);

  it('1. TopicBankParserService parses all 7 markdown files cleanly (including History) and seeds all 8 JSON subjects (80 modules)', async () => {
    const dir = TopicBankParserService.resolveTopicBankDir();
    const expectedFiles = [
      { file: 'mathematics.md', code: 'MAT' },
      { file: 'physics.md', code: 'PHY' },
      { file: 'biology.md', code: 'BIO' },
      { file: 'chemistry.md', code: 'CHE' },
      { file: 'economics.md', code: 'ECO' },
      { file: 'geography.md', code: 'GEO' },
      { file: 'history.md', code: 'HIS' },
    ];

    for (const item of expectedFiles) {
      const raw = fs.readFileSync(path.join(dir, item.file), 'utf-8');
      const parsed = TopicBankParserService.parseSubjectMarkdown(raw, item.file);
      expect(parsed).toHaveLength(10);
      expect(parsed[0].moduleId).toBe(`${item.code}-M01`);
      expect(parsed[0].references.length).toBeGreaterThanOrEqual(1);
      expect(parsed[0].references[0].pages).toMatch(/pp\./i);
      expect(parsed[0].sequence.length).toBeGreaterThanOrEqual(2);
      expect(parsed[0].masteryCheckpoint.length).toBeGreaterThan(10);
      // Confirm clean plain/Unicode formatting (no raw citation brackets or dollar LaTeX markers)
      expect(parsed[0].masteryCheckpoint).not.toMatch(/\[\d+/);
      expect(parsed[0].masteryCheckpoint).not.toContain('$');
    }

    // Verify History multi-unit & Textbook References parsing (HIS-M08 previously had 0 refs)
    const hisRaw = fs.readFileSync(path.join(dir, 'history.md'), 'utf-8');
    const hisParsed = TopicBankParserService.parseSubjectMarkdown(hisRaw, 'history.md');
    expect(hisParsed[7].moduleId).toBe('HIS-M08');
    expect(hisParsed[7].references.length).toBe(2);
    expect(hisParsed[9].moduleId).toBe('HIS-M10');
    expect(hisParsed[9].references.length).toBe(8);

    // Verify seeded MongoDB modules include all 8 subjects (including ENG curated JSON)
    const seededCount = await TopicModuleModel.countDocuments();
    expect(seededCount).toBe(80);
    const hisM08Db = await TopicModuleModel.findOne({ moduleId: 'HIS-M08' }).lean();
    expect(hisM08Db?.references[0]?.unitTitle).not.toMatch(/^Unit\s+\d+$/i);
    const engM01Db = await TopicModuleModel.findOne({ moduleId: 'ENG-M01' }).lean();
    expect(engM01Db?.references.length).toBe(4);
  });

  it('2. GET /api/v1/topics/program returns hasProgram: false and 0% baseline mastery for fresh student', async () => {
    const res = await request(app)
      .get('/api/v1/topics/program')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.hasProgram).toBe(false);
    expect(res.body.data.canGenerateToday).toBe(true);
    expect(res.body.data.program).toBeNull();

    const summaries = res.body.data.subjectSummaries;
    expect(Array.isArray(summaries)).toBe(true);
    expect(summaries.length).toBeGreaterThanOrEqual(4);
    for (const s of summaries) {
      expect(s.masteryPercentage).toBe(0);
      expect(s.completedModules).toBe(0);
    }
  });

  it('3. POST /api/v1/topics/program requires 1 rewarded ad, enforces 1-per-day limit, and persists AI program', async () => {
    const calibrationPayload = {
      tierId: 'competitive',
      targetScore: 495,
      weakSubjectCodes: ['PHY', 'MAT'],
      dailyMinutes: 90,
      peakWindow: 'Morning',
      prepStageId: 'reviewing',
    };

    // 3a. Direct generation without watching rewarded ad must fail with 403 AD_REQUIRED_FOR_AI_PLAN
    const noAdRes = await request(app)
      .post('/api/v1/topics/program')
      .set('Authorization', `Bearer ${studentToken}`)
      .send(calibrationPayload);

    expect(noAdRes.status).toBe(403);
    expect(noAdRes.body.error.code).toBe('AD_REQUIRED_FOR_AI_PLAN');

    // 3b. Watch & claim 1 rewarded ad for ai_study_plan
    const startAdRes = await request(app)
      .post('/api/v1/ads/session/start')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ rewardType: 'ai_study_plan', platform: 'android' });

    expect(startAdRes.status).toBe(201);
    const adSessionId = startAdRes.body.data.adSessionId;

    const claimAdRes = await request(app)
      .post('/api/v1/ads/reward/claim')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ adSessionId, rewardType: 'ai_study_plan' });

    expect(claimAdRes.status).toBe(200);
    expect(claimAdRes.body.data.aiStudyPlanUnlocked).toBe(true);

    // 3c. Now POST /api/v1/topics/program succeeds using the verified adSessionId
    const res = await request(app)
      .post('/api/v1/topics/program')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ ...calibrationPayload, adSessionId });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.hasProgram).toBe(true);

    const program = res.body.data.program;
    expect(program.stream).toBe('natural');
    expect(program.projectedScore).toBe(505);
    expect(program.diagnosticSummary).toContain('Physics');
    expect(program.subjectAllocations[0].subjectCode).toBe('PHY');
    expect(program.subjectAllocations[0].priorityRank).toBe(1);
    expect(program.dailyFocusTasks.length).toBe(4);
    expect(program.dailyFocusTasks[0].whereToRead).toContain('pp.');

    // Verify program persists on subsequent GET and daily limit updates
    const getRes = await request(app)
      .get('/api/v1/topics/program')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(getRes.status).toBe(200);
    expect(getRes.body.data.hasProgram).toBe(true);
    expect(getRes.body.data.canGenerateToday).toBe(false);
    expect(getRes.body.data.nextGenerationAt).toBeTruthy();
    expect(getRes.body.data.program.calibration.targetScore).toBe(495);

    // Verify second generation attempt on the same day is blocked (429) without calling Gemini
    const repeatRes = await request(app)
      .post('/api/v1/topics/program')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({
        tierId: 'merit',
        targetScore: 550,
        weakSubjectCodes: ['MAT'],
        dailyMinutes: 120,
        peakWindow: 'Night',
        prepStageId: 'sprint',
      });

    expect(repeatRes.status).toBe(429);
    expect(repeatRes.body.success).toBe(false);
    expect(repeatRes.body.error.code).toBe('DAILY_PLAN_LIMIT_REACHED');
  });

  it('4. GeminiPlannerService collaborates with mocked Gemini API and hydrates exact MongoDB page references', async () => {
    const matModules = await TopicModuleModel.find({ subjectCode: 'MAT' })
      .sort({ moduleNumber: 1 })
      .lean();
    expect(matModules.length).toBe(10);

    const prevKey = env.GEMINI_API_KEY;
    env.GEMINI_API_KEY = 'test-mock-gemini-key';
    const fetchSpy = vi.spyOn(globalThis, 'fetch').mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        candidates: [
          {
            content: {
              parts: [
                {
                  text: JSON.stringify({
                    diagnosticSummary:
                      'Gemini prioritized MAT-M04 and MAT-M08 for your 540+ Natural Science target.',
                    recommendedModules: [
                      {
                        moduleId: 'MAT-M04',
                        coachingNote: 'Master function behavior before Grade 12 calculus.',
                      },
                      {
                        moduleId: 'MAT-M08',
                        coachingNote: 'Build directly on derivatives and definite integrals.',
                      },
                    ],
                  }),
                },
              ],
            },
          },
        ],
      }),
    } as any);

    try {
      const program = await GeminiPlannerService.generateStudyProgram({
        stream: 'natural',
        grade: 12,
        calibration: {
          tierId: 'merit',
          targetScore: 545,
          weakSubjectCodes: ['MAT'],
          dailyMinutes: 150,
          peakWindow: 'Morning',
          prepStageId: 'sprint',
        },
        modules: matModules as any,
        completedUnitCodes: [],
        completedModuleIds: [],
      });

      expect(program.generatedBy).toBe('gemini');
      expect(program.diagnosticSummary).toContain('Gemini prioritized MAT-M04');
      expect(program.dailyFocusTasks[0].moduleId).toBe('MAT-M04');
      expect(program.dailyFocusTasks[0].whereToRead).toContain('G10 U1');
      expect(program.dailyFocusTasks[0].whereToRead).toContain('pp.');
      expect(fetchSpy).toHaveBeenCalledTimes(1);
    } finally {
      fetchSpy.mockRestore();
      env.GEMINI_API_KEY = prevKey;
    }
  });

  it('5. GET /api/v1/topics/subjects/MAT/modules returns 10 sequential cross-grade modules with reading refs', async () => {
    const res = await request(app)
      .get('/api/v1/topics/subjects/MAT/modules')
      .set('Authorization', `Bearer ${studentToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveLength(10);

    const mod1 = res.body.data[0];
    expect(mod1.moduleId).toBe('MAT-M01');
    expect(mod1.progressPercentage).toBe(0);
    expect(mod1.isCompleted).toBe(false);
    expect(mod1.references[0].unitCode).toBe('MAT-G09-U01');
    expect(mod1.references[0].pages).toContain('1–26');
  });

  it('6. POST /api/v1/topics/modules/:moduleId/progress persists step & module completion from 0% to 100%', async () => {
    // 1. Toggle step 1 complete
    const stepRes = await request(app)
      .post('/api/v1/topics/modules/MAT-M01/progress')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ stepNumber: 1, stepCompleted: true });

    expect(stepRes.status).toBe(200);
    expect(stepRes.body.data.completedSteps).toContain(1);
    expect(stepRes.body.data.progressPercentage).toBeGreaterThan(0);
    expect(stepRes.body.data.isCompleted).toBe(false);

    // 2. Mark entire module mastered
    const completeRes = await request(app)
      .post('/api/v1/topics/modules/MAT-M01/progress')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ isCompleted: true });

    expect(completeRes.status).toBe(200);
    expect(completeRes.body.data.isCompleted).toBe(true);
    expect(completeRes.body.data.progressPercentage).toBe(100);
    expect(completeRes.body.data.subjectMasteryPercentage).toBe(10); // 1 of 10 MAT modules = 10%

    // 3. Confirm persistence in GET /api/v1/topics/program
    const overviewRes = await request(app)
      .get('/api/v1/topics/program')
      .set('Authorization', `Bearer ${studentToken}`);

    const matSummary = overviewRes.body.data.subjectSummaries.find(
      (s: any) => s.subjectCode === 'MAT'
    );
    expect(matSummary.completedModules).toBe(1);
    expect(matSummary.masteryPercentage).toBe(10);

    // 4. Unmark module resets back to 0%
    const unmarkRes = await request(app)
      .post('/api/v1/topics/modules/MAT-M01/progress')
      .set('Authorization', `Bearer ${studentToken}`)
      .send({ isCompleted: false });

    expect(unmarkRes.status).toBe(200);
    expect(unmarkRes.body.data.isCompleted).toBe(false);
    expect(unmarkRes.body.data.progressPercentage).toBe(0);
    expect(unmarkRes.body.data.subjectMasteryPercentage).toBe(0);
  });
});
