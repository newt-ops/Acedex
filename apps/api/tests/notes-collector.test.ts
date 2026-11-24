import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import mongoose from 'mongoose';
import { createApp } from '../src/app';
import { connectDatabase, disconnectDatabase } from '../src/config/database';
import { getNotesDb } from '../src/config/notes-database';
import fs from 'fs';
import path from 'path';

describe('Dedicated Quick Notes Collection Backend & Database Tests', { timeout: 60000 }, () => {
  const app = createApp();

  beforeAll(async () => {
    await connectDatabase();
  }, 60000);

  afterAll(async () => {
    // Clean up test file if created
    const testFilePath = path.join(
      process.cwd(),
      '../../content/quick-notes/Grade-09/English/ENG-G09-U01.json'
    );
    if (fs.existsSync(testFilePath)) {
      try {
        fs.unlinkSync(testFilePath);
      } catch {}
    }
    await disconnectDatabase();
  }, 60000);

  it('1. Database Isolation: verify acedex_notes is separate from acedex', async () => {
    const notesDb = getNotesDb();
    expect(notesDb.name).toBe('acedex_notes');
    expect(mongoose.connection.name).not.toBe('acedex_notes');
  });

  it('2. GET /api/v1/notes-collector/units should return curriculum tree for English', async () => {
    const res = await request(app)
      .get('/api/v1/notes-collector/units')
      .query({ subjectCode: 'ENG' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.subjectCode).toBe('ENG');
    expect(res.body.data.grades).toHaveLength(4); // Grades 9, 10, 11, 12
    const grade9 = res.body.data.grades.find((g: any) => g.grade === 9);
    expect(grade9).toBeDefined();
    expect(grade9.units.length).toBeGreaterThan(0);
    expect(grade9.units[0].unitCode).toBe('ENG-G09-U01');
  });

  it('3. POST /api/v1/notes-collector/sanitize should parse and auto-fix markdown fenced JSON', async () => {
    const rawNoteMarkdown = `
\`\`\`json
{
  "grade": 9,
  "subject": "English",
  "subjectCode": "ENG",
  "unitNumber": 1,
  "unitCode": "ENG-G09-U01",
  "unitTitle": "Living in Urban Areas",
  "summaryPoints": [
    "Tag questions invert statement polarity (positive statement takes negative tag).",
    "First person 'I am' takes the tag 'aren\'t I?' in affirmative statements.",
    "Present simple tense denotes general truths and habitual patterns.",
    "Present continuous form is formed with is/am/are + V-ing."
  ],
  "formulas": [
    {
      "label": "General Question Tag",
      "expr": "Statement (+) + , + Auxiliary (-) + Pronoun?"
    }
  ],
  "examTip": "Watch out for 'I am' which requires 'aren\'t I?' instead of 'am not I?'.",
  "keyDefinitions": [
    {
      "term": "Question Tag",
      "definition": "A mini-question placed at the end of a sentence asking for confirmation."
    }
  ],
  "eueeFocusTopics": [
    "Tag Questions",
    "Present Simple vs Continuous"
  ]
}
\`\`\`
`;

    const res = await request(app)
      .post('/api/v1/notes-collector/sanitize')
      .send({ rawText: rawNoteMarkdown, expectedUnitCode: 'ENG-G09-U01' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.note).toBeDefined();
    expect(res.body.data.note.unitCode).toBe('ENG-G09-U01');
    expect(res.body.data.note.summaryPoints).toHaveLength(4);
    expect(res.body.data.fixesApplied).toContain(
      'Stripped markdown code fences (```json)'
    );
  });

  it('4. POST /api/v1/notes-collector/units/:unitCode/submit should store note in acedex_notes', async () => {
    const testNotePayload = {
      grade: 9,
      subject: 'English',
      subjectCode: 'ENG',
      unitNumber: 1,
      unitCode: 'ENG-G09-U01',
      unitTitle: 'Living in Urban Areas',
      examWeight: '10% EUEE',
      summaryPoints: [
        "Tag questions invert statement polarity.",
        "First person singular affirmative takes \"aren't I?\".",
        "Present simple expresses habitual routines.",
        "Present continuous expresses actions occurring right now."
      ],
      formulas: [
        {
          label: 'Question Tag Formula',
          expr: 'Positive + Negative Tag / Negative + Positive Tag'
        }
      ],
      examTip: 'Pay attention to irregular tag questions for "I am".',
      keyDefinitions: [
        {
          term: 'Copula Verb',
          definition: 'A verb linking the subject to a subject complement.'
        }
      ],
      eueeFocusTopics: ['Tag Questions', 'Verb Tenses']
    };

    const res = await request(app)
      .post('/api/v1/notes-collector/units/ENG-G09-U01/submit')
      .send({
        unitCode: 'ENG-G09-U01',
        contributorId: 'ENG#101',
        rawPastedText: JSON.stringify(testNotePayload),
        notes: testNotePayload
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.unitCode).toBe('ENG-G09-U01');
    expect(res.body.data.status).toBe('submitted');
  });

  it('5. GET /api/v1/notes-collector/admin/submissions should list submitted note', async () => {
    const res = await request(app)
      .get('/api/v1/notes-collector/admin/submissions')
      .query({ subjectCode: 'ENG' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    const sub = res.body.data.find((s: any) => s.unitCode === 'ENG-G09-U01');
    expect(sub).toBeDefined();
    expect(sub.status).toBe('submitted');
    expect(sub.summaryPointCount).toBe(4);
  });

  it('6. POST /api/v1/notes-collector/admin/submissions/:id/review (approve) should approve and write to disk', async () => {
    // Fetch submission ID
    const listRes = await request(app)
      .get('/api/v1/notes-collector/admin/submissions')
      .query({ subjectCode: 'ENG' });
    const sub = listRes.body.data.find((s: any) => s.unitCode === 'ENG-G09-U01');
    expect(sub).toBeDefined();

    const reviewRes = await request(app)
      .post(`/api/v1/notes-collector/admin/submissions/${sub._id}/review`)
      .send({ action: 'approve' });

    expect(reviewRes.status).toBe(200);
    expect(reviewRes.body.success).toBe(true);
    expect(reviewRes.body.data.status).toBe('approved');

    // Verify written to disk
    const targetFile = path.resolve(
      process.cwd(),
      '../../content/quick-notes/Grade-09/English/ENG-G09-U01.json'
    );
    expect(fs.existsSync(targetFile)).toBe(true);

    const savedContent = JSON.parse(fs.readFileSync(targetFile, 'utf-8'));
    expect(savedContent.unitCode).toBe('ENG-G09-U01');
    expect(savedContent.summaryPoints).toHaveLength(4);

    // Clean up test file so repository stays clean
    fs.unlinkSync(targetFile);
  });
});
