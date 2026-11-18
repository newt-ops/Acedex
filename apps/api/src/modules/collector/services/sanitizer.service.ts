import { RawQuestionItem, RawQuestionItemSchema, QuestionBankFileSchema } from '@acedex/contracts';

export interface SanitizationResult {
  success: boolean;
  questions?: RawQuestionItem[];
  unitMeta?: {
    grade?: number;
    subject?: string;
    unitNumber?: number;
    unitTitle?: string;
  };
  errors?: string[];
  autoFixedIssues?: string[];
}

export class JsonSanitizerService {
  /**
   * Resiliently cleans and sanitizes raw text from NotebookLM or LLM into standard 15 questions.
   */
  public static sanitize(rawText: string, expectedUnitCode?: string): SanitizationResult {
    const autoFixedIssues: string[] = [];

    if (!rawText || !rawText.trim()) {
      return { success: false, errors: ['Input text is empty'] };
    }

    let cleaned = rawText.trim();

    // 1. Remove Markdown code fences
    if (cleaned.includes('```')) {
      cleaned = cleaned.replace(/^```(?:json)?\s*/gi, '').replace(/\s*```$/g, '');
      cleaned = cleaned.replace(/```json/gi, '').replace(/```/g, '');
      autoFixedIssues.push('Stripped Markdown code block fences (```json)');
    }

    // 2. Extract outermost JSON block if surrounded by conversational filler
    const firstBrace = cleaned.indexOf('{');
    const firstBracket = cleaned.indexOf('[');

    if (firstBrace !== -1 && (firstBracket === -1 || firstBrace < firstBracket)) {
      const lastBrace = cleaned.lastIndexOf('}');
      if (lastBrace > firstBrace) {
        if (firstBrace > 0 || lastBrace < cleaned.length - 1) {
          cleaned = cleaned.slice(firstBrace, lastBrace + 1);
          autoFixedIssues.push('Extracted outermost JSON object, removing leading/trailing text');
        }
      }
    } else if (firstBracket !== -1) {
      const lastBracket = cleaned.lastIndexOf(']');
      if (lastBracket > firstBracket) {
        if (firstBracket > 0 || lastBracket < cleaned.length - 1) {
          cleaned = cleaned.slice(firstBracket, lastBracket + 1);
          autoFixedIssues.push('Extracted outermost JSON array, removing leading/trailing text');
        }
      }
    }

    // 3. Normalize smart / curly quotes
    const quoteCount = (cleaned.match(/[“”„‟❝❞‘’‚‛❛❜]/g) || []).length;
    if (quoteCount > 0) {
      // First normalize smart quotes used around JSON keys: “key”: -> "key":
      cleaned = cleaned.replace(/“([^”\n]+)”\s*:/g, '"$1":');
      // Normalize remaining smart quotes inside strings to single quotes so JSON strings are not terminated
      cleaned = cleaned
        .replace(/[“”„‟❝❞]/g, "'")
        .replace(/[‘’‚‛❛❜]/g, "'");
      autoFixedIssues.push(`Normalized ${quoteCount} curly/smart quotes to standard quotes`);
    }

    // 4. Remove trailing commas before } or ] (repeat until no nested trailing commas remain)
    const trailingCommaRegex = /,\s*([}\]])/g;
    let hadTrailingCommas = false;
    while (trailingCommaRegex.test(cleaned)) {
      hadTrailingCommas = true;
      cleaned = cleaned.replace(trailingCommaRegex, '$1');
    }
    if (hadTrailingCommas) {
      autoFixedIssues.push('Removed trailing commas before closing braces/brackets');
    }

    // 5. Parse JSON
    let parsed: any;
    try {
      parsed = JSON.parse(cleaned);
    } catch (parseError: any) {
      return {
        success: false,
        errors: [`JSON syntax error: ${parseError.message}. Please check for missing brackets or quotes.`],
        autoFixedIssues,
      };
    }

    // 6. Extract questions array and optional unit metadata
    let rawQuestions: any[] = [];
    const unitMeta: {
      grade?: number;
      subject?: string;
      unitNumber?: number;
      unitTitle?: string;
    } = {};

    if (Array.isArray(parsed)) {
      rawQuestions = parsed;
    } else if (parsed && typeof parsed === 'object') {
      if (Array.isArray(parsed.questions)) {
        rawQuestions = parsed.questions;
      }
      if (parsed.grade) unitMeta.grade = Number(parsed.grade);
      if (parsed.subject) unitMeta.subject = String(parsed.subject);
      if (parsed.unitNumber) unitMeta.unitNumber = Number(parsed.unitNumber);
      if (parsed.unitTitle) unitMeta.unitTitle = String(parsed.unitTitle);
    }

    if (!Array.isArray(rawQuestions) || rawQuestions.length === 0) {
      return {
        success: false,
        errors: ['No questions array found in the parsed JSON'],
        autoFixedIssues,
      };
    }

    if (rawQuestions.length !== 15) {
      return {
        success: false,
        errors: [`Expected exactly 15 questions, but found ${rawQuestions.length}`],
        autoFixedIssues,
      };
    }

    // 7. Normalize individual questions
    const normalizedQuestions: RawQuestionItem[] = [];
    const validationErrors: string[] = [];

    rawQuestions.forEach((q: any, idx: number) => {
      const qNum = idx + 1;
      const qPrefix = `Question #${qNum}`;

      // Resolve question id
      let qId = q.id;
      if (!qId && expectedUnitCode) {
        qId = `${expectedUnitCode}-Q${String(qNum).padStart(3, '0')}`;
        autoFixedIssues.push(`Auto-generated missing ID for ${qPrefix}: ${qId}`);
      } else if (!qId) {
        qId = `Q${String(qNum).padStart(3, '0')}`;
      }

      // Resolve stem
      const questionText = (q.question || q.question_text || q.stem || '').trim();
      if (!questionText) {
        validationErrors.push(`${qPrefix}: question text is missing or empty`);
      }

      // Resolve difficulty
      let difficulty = String(q.difficulty || 'medium').toLowerCase().trim();
      if (difficulty === 'hard') difficulty = 'challenging';
      if (!['easy', 'medium', 'challenging'].includes(difficulty)) {
        difficulty = 'medium';
      }

      // Resolve options
      let options: { id: 'A' | 'B' | 'C' | 'D'; text: string }[] = [];
      if (Array.isArray(q.options)) {
        if (q.options.length === 4 && typeof q.options[0] === 'object' && q.options[0].id && q.options[0].text) {
          options = q.options.map((opt: any) => ({
            id: String(opt.id).toUpperCase().trim() as 'A' | 'B' | 'C' | 'D',
            text: String(opt.text).trim(),
          }));
        } else if (q.options.length === 4 && typeof q.options[0] === 'string') {
          // Strings like ["A) text", "B) text", ...]
          const labels: ('A' | 'B' | 'C' | 'D')[] = ['A', 'B', 'C', 'D'];
          options = q.options.map((optStr: string, optIdx: number) => {
            const cleanText = optStr.replace(/^[A-D][\)\.\:\-]\s*/i, '').trim();
            return {
              id: labels[optIdx],
              text: cleanText || optStr,
            };
          });
          autoFixedIssues.push(`Normalized string options for ${qPrefix} into standard A-D format`);
        }
      } else if (q.options && typeof q.options === 'object') {
        // Object like { "A": "...", "B": "..." }
        const labels: ('A' | 'B' | 'C' | 'D')[] = ['A', 'B', 'C', 'D'];
        options = labels.map((lbl) => ({
          id: lbl,
          text: String(q.options[lbl] || q.options[lbl.toLowerCase()] || '').trim(),
        }));
        autoFixedIssues.push(`Converted key-value options object for ${qPrefix} into A-D array`);
      }

      if (options.length !== 4) {
        validationErrors.push(`${qPrefix}: exactly 4 options (A, B, C, D) are required (found ${options.length})`);
      } else {
        options.forEach((opt) => {
          if (!opt.text) {
            validationErrors.push(`${qPrefix}: option ${opt.id} has empty text`);
          }
        });
      }

      // Resolve correctOptionId
      let correctId = String(q.correctOptionId || q.correct_answer || q.correctOption || q.answer || '').toUpperCase().trim();
      // If user typed "Option B" or "B) ...", extract the single letter
      const letterMatch = correctId.match(/\b([A-D])\b/);
      if (letterMatch) {
        correctId = letterMatch[1];
      }

      if (!['A', 'B', 'C', 'D'].includes(correctId)) {
        validationErrors.push(`${qPrefix}: correctOptionId must be A, B, C, or D (got '${correctId}')`);
      }

      // Resolve explanation
      const explanation = (q.explanation || q.rationale || '').trim();
      if (!explanation) {
        validationErrors.push(`${qPrefix}: explanation is missing or empty`);
      }

      const item: RawQuestionItem = {
        id: qId,
        type: 'multiple_choice',
        difficulty: difficulty as 'easy' | 'medium' | 'challenging',
        question: questionText,
        options: options as any,
        correctOptionId: correctId as 'A' | 'B' | 'C' | 'D',
        explanation: explanation || 'No explanation provided.',
        sourceReference: q.sourceReference || q.source || undefined,
      };

      normalizedQuestions.push(item);
    });

    if (validationErrors.length > 0) {
      return {
        success: false,
        errors: validationErrors,
        autoFixedIssues,
      };
    }

    return {
      success: true,
      questions: normalizedQuestions,
      unitMeta,
      autoFixedIssues: autoFixedIssues.length > 0 ? autoFixedIssues : undefined,
    };
  }
}
