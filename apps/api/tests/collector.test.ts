import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { ContributorModel } from '../src/modules/collector/models/contributor.model';
import { TempUnitSubmissionModel } from '../src/modules/collector/models/unit-submission.model';
import { JsonSanitizerService } from '../src/modules/collector/services/sanitizer.service';

describe('Subject Contributor Portal & JSON Exporter Engine', { timeout: 60000 }, () => {
  const app = createApp();

  const ADMIN_KEY = 'acedex-admin-2026';

  beforeAll(async () => {
    await connectDatabase();
    // Clean test records
    await TempUnitSubmissionModel.deleteMany({ unitCode: { $regex: /^GEO-G09-U01/ } });
  }, 60000);

  afterAll(async () => {
    await TempUnitSubmissionModel.deleteMany({ unitCode: { $regex: /^GEO-G09-U01/ } });
    await disconnectDatabase();
  }, 60000);

  it('1. POST /api/v1/collector/login should reject unknown contributor ID with 401', async () => {
    const res = await request(app)
      .post('/api/v1/collector/login')
      .send({ contributorId: 'UNKNOWN#999' });

    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it('2. POST /api/v1/collector/login should authenticate valid contributor ID GEO#982', async () => {
    const res = await request(app)
      .post('/api/v1/collector/login')
      .send({ contributorId: 'GEO#982' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.contributorId).toBe('GEO#982');
    expect(res.body.data.subjectCode).toBe('GEO');
    expect(res.body.data.subjectName).toBe('Geography');
    expect(res.body.data.role).toBe('student');
  });

  it('2b. POST /api/v1/collector/login should authenticate admin ID ADM#15 with admin role', async () => {
    const res = await request(app)
      .post('/api/v1/collector/login')
      .send({ contributorId: 'ADM#15' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.contributorId).toBe('ADM#15');
    expect(res.body.data.role).toBe('admin');
  });

  it('3. GET /api/v1/collector/units should return all 4 grades with not_started units', async () => {
    const res = await request(app)
      .get('/api/v1/collector/units?subjectCode=GEO&contributorId=GEO#982');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.subjectCode).toBe('GEO');
    expect(res.body.data.grades.length).toBe(4);

    // Grade 9 should have units with status: not_started
    const g9 = res.body.data.grades.find((g: any) => g.grade === 9);
    expect(g9).toBeDefined();
    expect(g9.units.length).toBeGreaterThan(0);
    expect(g9.units[0].status).toBe('not_started');
  });

  it('4. POST /api/v1/collector/sanitize should clean markdown fences, smart quotes, and trailing commas', async () => {
    // Dirty raw text simulating NotebookLM output
    const dirtyNotebookLMText = `
Here is the requested 15 questions for Unit 1 in JSON format:
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
  ],
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

  it('5. POST /api/v1/collector/units/:unitCode/submit should store 15 questions in temp_unit_submissions', async () => {
    // Generate 15 valid sample questions
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
    expect(res.body.data.questionCount).toBe(15);

    // Verify in temp collection
    const stored = await TempUnitSubmissionModel.findOne({ unitCode: 'GEO-G09-U01' });
    expect(stored).toBeDefined();
    expect(stored?.status).toBe('submitted');
    expect(stored?.questions.length).toBe(15);

    // Verify unit tree reflects submitted status
    const treeRes = await request(app).get('/api/v1/collector/units?subjectCode=GEO&contributorId=GEO#982');
    const g9 = treeRes.body.data.grades.find((g: any) => g.grade === 9);
    const u1 = g9.units.find((u: any) => u.unitCode === 'GEO-G09-U01');
    expect(u1.status).toBe('submitted');
  });

  it('6. Admin review & approval flow: list, detail, and approve', async () => {
    // List submissions
    const listRes = await request(app)
      .get('/api/v1/collector/admin/submissions?subjectCode=GEO')
      .set('x-admin-key', ADMIN_KEY);

    expect(listRes.status).toBe(200);
    expect(listRes.body.success).toBe(true);
    expect(listRes.body.data.length).toBeGreaterThan(0);

    const submission = listRes.body.data.find((s: any) => s.unitCode === 'GEO-G09-U01');
    expect(submission).toBeDefined();

    // Get submission detail
    const detailRes = await request(app)
      .get(`/api/v1/collector/admin/submissions/${submission._id}`)
      .set('x-admin-key', ADMIN_KEY);

    expect(detailRes.status).toBe(200);
    expect(detailRes.body.data.questions.length).toBe(15);

    // Approve submission
    const approveRes = await request(app)
      .post(`/api/v1/collector/admin/submissions/${submission._id}/approve`)
      .set('x-admin-key', ADMIN_KEY);

    expect(approveRes.status).toBe(200);
    expect(approveRes.body.data.status).toBe('approved');

    // Verify unit tree now reflects approved status
    const treeRes = await request(app).get('/api/v1/collector/units?subjectCode=GEO');
    const g9 = treeRes.body.data.grades.find((g: any) => g.grade === 9);
    const u1 = g9.units.find((u: any) => u.unitCode === 'GEO-G09-U01');
    expect(u1.status).toBe('approved');
  });

  it('7. Admin JSON export should deliver canonical question bank format', async () => {
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
});
