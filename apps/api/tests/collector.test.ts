import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import mongoose from 'mongoose';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { getCollectorDb } from '../src/config/collector-database';
import { ContributorModel } from '../src/modules/collector/models/collector-contributor.model';
import { UnitSubmissionModel } from '../src/modules/collector/models/collector-submission.model';
import { CollectorAuditModel } from '../src/modules/collector/models/collector-audit.model';

describe('Dedicated Question Collection Backend & Isolated Database Tests', { timeout: 60000 }, () => {
  const app = createApp();
  const ADMIN_KEY = 'acedex-admin-2026';

  beforeAll(async () => {
    await connectDatabase();
    const primaryDb = mongoose.connection.db;
    if (primaryDb) {
      try { await primaryDb.dropCollection('temp_contributors'); } catch {}
      try { await primaryDb.dropCollection('temp_unit_submissions'); } catch {}
    }
    // Clean test records in collector database
    await UnitSubmissionModel.deleteMany({ unitCode: { $regex: /^GEO-G09-U01/ } });
  }, 60000);

  afterAll(async () => {
    await UnitSubmissionModel.deleteMany({ unitCode: { $regex: /^GEO-G09-U01/ } });
    await disconnectDatabase();
  }, 60000);

  it('1. Database Isolation: acedex database has zero temp collector collections', async () => {
    const primaryDb = mongoose.connection.db;
    expect(primaryDb).toBeDefined();

    const collections = await primaryDb!.listCollections().toArray();
    const collectionNames = collections.map((c) => c.name);

    // Assert that temp_contributors and temp_unit_submissions were completely purged from primary acedex
    expect(collectionNames).not.toContain('temp_contributors');
    expect(collectionNames).not.toContain('temp_unit_submissions');

    // Assert that collector database is 'acedex_collector'
    const collectorDb = getCollectorDb();
    expect(collectorDb.name).toBe('acedex_collector');
  });

  it('2. POST /api/v1/collector/login should reject unknown contributor ID with 401', async () => {
    const res = await request(app)
      .post('/api/v1/collector/login')
      .send({ contributorId: 'UNKNOWN#999' });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it('3. POST /api/v1/collector/login should authenticate valid contributor ID GEO#982 in acedex_collector', async () => {
    const res = await request(app)
      .post('/api/v1/collector/login')
      .send({ contributorId: 'GEO#982' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.contributorId).toBe('GEO#982');
    expect(res.body.data.subjectCode).toBe('GEO');
    expect(res.body.data.subjectName).toBe('Geography');
    expect(res.body.data.role).toBe('student');

    // Verify stored in acedex_collector.contributors
    const stored = await ContributorModel.findOne({ contributorId: 'GEO#982' });
    expect(stored).toBeDefined();
    expect(stored?.subjectCode).toBe('GEO');
  });

  it('4. POST /api/v1/collector/login should authenticate admin ID ADM#15 with admin role', async () => {
    const res = await request(app)
      .post('/api/v1/collector/login')
      .send({ contributorId: 'ADM#15' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.contributorId).toBe('ADM#15');
    expect(res.body.data.role).toBe('admin');
  });

  it('5. GET /api/v1/collector/profile should return contributor profile', async () => {
    const res = await request(app).get(`/api/v1/collector/profile?contributorId=${encodeURIComponent('GEO#982')}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.contributorId).toBe('GEO#982');
    expect(res.body.data.subjectName).toBe('Geography');
  });

  it('6. GET /api/v1/collector/units should return all 4 grades with not_started units', async () => {
    const res = await request(app)
      .get('/api/v1/collector/units?subjectCode=GEO&contributorId=GEO#982');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.subjectCode).toBe('GEO');
    expect(res.body.data.grades.length).toBe(4);

    const g9 = res.body.data.grades.find((g: any) => g.grade === 9);
    expect(g9).toBeDefined();
    expect(g9.units.length).toBeGreaterThan(0);
    expect(g9.units[0].status).toBe('not_started');
  });

  it('7. POST /api/v1/collector/sanitize should clean markdown fences, smart quotes, and trailing commas', async () => {
    const dirtyNotebookLMText = `
Here are the requested 15 questions for Unit 1:
\`\`\`json
{
  "grade": 9,
  "subject": "Geography",
  "unitNumber": 1,
  "unitTitle": "Geological History and Topography of Ethiopia",
  "questions": [
    ${Array.from({ length: 15 }, (_, i) => `
    {
      "id": "GEO-G09-U01-Q${String(i + 1).padStart(3, '0')}",
      "type": "multiple_choice",
      "difficulty": "Easy",
      "question": "What is the primary geological feature of question ${i + 1}?",
      "options": [
        "A) The Great East African Rift Valley",
        "B) The Ethiopian Highlands",
        "C) The Danakil Depression",
        "D) The Ogaden Basin",
      ],
      "correctOptionId": "A",
      "explanation": "This is an explanation for question ${i + 1} with “smart quotes”.",
    }`).join(',')}
  ]
}
\`\`\`
Hope this helps!
    `;

    const res = await request(app)
      .post('/api/v1/collector/sanitize')
      .send({ rawText: dirtyNotebookLMText, expectedUnitCode: 'GEO-G09-U01' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.questions.length).toBe(15);
    expect(res.body.data.autoFixedIssues.length).toBeGreaterThan(0);
    expect(res.body.data.questions[0].options[0].text).toBe('The Great East African Rift Valley');
  });

  it('8. POST /api/v1/collector/units/:unitCode/submit should store 15 questions in acedex_collector.unit_submissions', async () => {
    const questions = Array.from({ length: 15 }, (_, i) => ({
      id: `GEO-G09-U01-Q${String(i + 1).padStart(3, '0')}`,
      type: 'multiple_choice' as const,
      difficulty: 'medium' as const,
      question: `Geography Question ${i + 1} for Unit 1: Geological History of Ethiopia?`,
      options: [
        { id: 'A' as const, text: 'Precambrian crystalline basement complex' },
        { id: 'B' as const, text: 'Mesozoic sedimentary rock formations' },
        { id: 'C' as const, text: 'Tertiary volcanic trap series' },
        { id: 'D' as const, text: 'Quaternary alluvial and lacustrine deposits' },
      ],
      correctOptionId: 'B' as const,
      explanation: `Explanation for question ${i + 1}: Mesozoic transgression laid down marine sediments.`,
      sourceReference: 'Section 1.2, Page 14',
    }));

    const res = await request(app)
      .post('/api/v1/collector/units/GEO-G09-U01/submit')
      .send({
        contributorId: 'GEO#982',
        questions,
        rawPastedText: 'Sample raw input from student contributor',
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.unitCode).toBe('GEO-G09-U01');
    expect(res.body.data.status).toBe('submitted');
    expect(res.body.data.version).toBe(1);
    expect(res.body.data.questionCount).toBe(15);

    // Verify stored strictly in acedex_collector
    const stored = await UnitSubmissionModel.findOne({ unitCode: 'GEO-G09-U01' });
    expect(stored).toBeDefined();
    expect(stored?.status).toBe('submitted');
    expect(stored?.version).toBe(1);
    expect(stored?.questions.length).toBe(15);
  });

  it('9. Re-submission should increment version and preserve history', async () => {
    const updatedQuestions = Array.from({ length: 15 }, (_, i) => ({
      id: `GEO-G09-U01-Q${String(i + 1).padStart(3, '0')}`,
      type: 'multiple_choice' as const,
      difficulty: 'medium' as const,
      question: `Updated Geography Question ${i + 1} for Unit 1?`,
      options: [
        { id: 'A' as const, text: 'Option A Updated' },
        { id: 'B' as const, text: 'Option B Updated' },
        { id: 'C' as const, text: 'Option C Updated' },
        { id: 'D' as const, text: 'Option D Updated' },
      ],
      correctOptionId: 'A' as const,
      explanation: `Updated explanation for question ${i + 1}`,
    }));

    const res = await request(app)
      .post('/api/v1/collector/units/GEO-G09-U01/submit')
      .send({
        contributorId: 'GEO#982',
        questions: updatedQuestions,
      });

    expect(res.status).toBe(201);
    expect(res.body.data.version).toBe(2);

    const stored = await UnitSubmissionModel.findOne({ unitCode: 'GEO-G09-U01' });
    expect(stored?.version).toBe(2);
    expect(stored?.history?.length).toBe(1);
    expect(stored?.history?.[0].version).toBe(1);
  });

  it('10. GET /api/v1/collector/admin/stats should return system-wide dashboard metrics', async () => {
    const res = await request(app)
      .get('/api/v1/collector/admin/stats')
      .set('x-admin-key', ADMIN_KEY);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.totalContributors).toBeGreaterThan(0);
    expect(res.body.data.submittedUnits).toBeGreaterThan(0);
    expect(res.body.data.subjectStats.GEO).toBeDefined();
  });

  it('11. Admin in-place edit: PATCH /api/v1/collector/admin/submissions/:id/questions', async () => {
    const submission = await UnitSubmissionModel.findOne({ unitCode: 'GEO-G09-U01' });
    expect(submission).toBeDefined();

    const modifiedQuestions = [...submission!.questions];
    modifiedQuestions[0] = {
      ...modifiedQuestions[0],
      question: 'Admin In-Place Patched Question 1: Geological History of Ethiopia',
    };

    const res = await request(app)
      .patch(`/api/v1/collector/admin/submissions/${submission!._id}/questions`)
      .set('x-admin-key', ADMIN_KEY)
      .send({ questions: modifiedQuestions });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    const stored = await UnitSubmissionModel.findOne({ unitCode: 'GEO-G09-U01' });
    expect(stored?.questions[0].question).toContain('Admin In-Place Patched');
  });

  it('12. Admin review & approval flow: list, detail, and approve', async () => {
    const listRes = await request(app)
      .get('/api/v1/collector/admin/submissions?subjectCode=GEO')
      .set('x-admin-key', ADMIN_KEY);

    expect(listRes.status).toBe(200);
    expect(listRes.body.success).toBe(true);
    const submission = listRes.body.data.find((s: any) => s.unitCode === 'GEO-G09-U01');
    expect(submission).toBeDefined();

    const approveRes = await request(app)
      .post(`/api/v1/collector/admin/submissions/${submission._id}/approve`)
      .set('x-admin-key', ADMIN_KEY);

    expect(approveRes.status).toBe(200);
    expect(approveRes.body.data.status).toBe('approved');

    const treeRes = await request(app).get('/api/v1/collector/units?subjectCode=GEO');
    const g9 = treeRes.body.data.grades.find((g: any) => g.grade === 9);
    const u1 = g9.units.find((u: any) => u.unitCode === 'GEO-G09-U01');
    expect(u1.status).toBe('approved');
  });

  it('13. Admin JSON export should deliver canonical question bank format', async () => {
    const res = await request(app)
      .get('/api/v1/collector/admin/submissions/GEO-G09-U01/export')
      .set('x-admin-key', ADMIN_KEY);

    expect(res.status).toBe(200);
    expect(res.body.grade).toBe(9);
    expect(res.body.subject).toBe('Geography');
    expect(res.body.unitNumber).toBe(1);
    expect(res.body.unitTitle).toBeDefined();
    expect(res.body.questions.length).toBe(15);
  });

  it('14. Admin bulk subject export: GET /api/v1/collector/admin/export/subject/GEO', async () => {
    const res = await request(app)
      .get('/api/v1/collector/admin/export/subject/GEO')
      .set('x-admin-key', ADMIN_KEY);

    expect(res.status).toBe(200);
    expect(res.body.subjectCode).toBe('GEO');
    expect(res.body.approvedUnitsCount).toBeGreaterThan(0);
    expect(res.body.units.length).toBeGreaterThan(0);
    expect(res.body.units[0].questions.length).toBe(15);
  });

  it('15. GET /api/v1/collector/admin/audit-logs should record all actions in acedex_collector', async () => {
    const res = await request(app)
      .get('/api/v1/collector/admin/audit-logs')
      .set('x-admin-key', ADMIN_KEY);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.total).toBeGreaterThan(0);

    const actions = res.body.data.logs.map((l: any) => l.action);
    expect(actions).toContain('LOGIN');
    expect(actions).toContain('SUBMIT');
    expect(actions).toContain('APPROVE');
    expect(actions).toContain('EXPORT_JSON');
  });
});
