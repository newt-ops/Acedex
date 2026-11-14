import { describe, it, expect } from 'vitest';
import path from 'path';
import fs from 'fs';
import { QuestionBankFileSchema } from '@acedex/contracts';

describe('Shared Contracts & Question Bank Validation', () => {
  const physicsG09Dir = path.resolve(__dirname, '../../../content/question-bank/Grade-09/Physics');

  it('PHY-G09-U01.json should be fully valid against QuestionBankFileSchema', () => {
    const filePath = path.join(physicsG09Dir, 'PHY-G09-U01.json');
    expect(fs.existsSync(filePath)).toBe(true);

    const rawData = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
    const parsed = QuestionBankFileSchema.safeParse(rawData);

    expect(parsed.success).toBe(true);
    if (parsed.success) {
      expect(parsed.data.grade).toBe(9);
      expect(parsed.data.subject).toBe('Physics');
      expect(parsed.data.unitNumber).toBe(1);
      expect(parsed.data.questions).toHaveLength(30);

      // Verify question IDs are unique
      const ids = parsed.data.questions.map((q) => q.id);
      const uniqueIds = new Set(ids);
      expect(uniqueIds.size).toBe(30);
    }
  });

  it('PHY-G09-U02.json should be fully valid against QuestionBankFileSchema', () => {
    const filePath = path.join(physicsG09Dir, 'PHY-G09-U02.json');
    expect(fs.existsSync(filePath)).toBe(true);

    const rawData = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
    const parsed = QuestionBankFileSchema.safeParse(rawData);

    expect(parsed.success).toBe(true);
    if (parsed.success) {
      expect(parsed.data.grade).toBe(9);
      expect(parsed.data.subject).toBe('Physics');
      expect(parsed.data.unitNumber).toBe(2);
      expect(parsed.data.questions).toHaveLength(30);

      const ids = parsed.data.questions.map((q) => q.id);
      const uniqueIds = new Set(ids);
      expect(uniqueIds.size).toBe(30);
    }
  });
});
