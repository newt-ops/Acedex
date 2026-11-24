import { CollectorNoteItem, CollectorNoteItemSchema, NoteSanitizeResult } from '@acedex/contracts';
import { logger } from '../../../common/utils/logger';

export class NoteSanitizerService {
  /**
   * Resiliently cleans and sanitizes raw text from NotebookLM or LLM into standard Quick Note JSON.
   */
  public static sanitize(rawText: string, expectedUnitCode?: string): NoteSanitizeResult {
    const autoFixedIssues: string[] = [];
    const warnings: string[] = [];
    const errors: string[] = [];

    if (!rawText || !rawText.trim()) {
      return {
        success: false,
        errors: ['Pasted content is empty'],
      };
    }

    let cleaned = rawText.trim();

    // 1. Strip markdown code fences (```json ... ``` or ``` ... ```)
    if (cleaned.includes('```')) {
      const fenceMatch = cleaned.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
      if (fenceMatch && fenceMatch[1]) {
        cleaned = fenceMatch[1].trim();
        autoFixedIssues.push('Stripped markdown code fences (```json)');
      } else {
        cleaned = cleaned.replace(/```(?:json)?/gi, '').replace(/```/g, '').trim();
        autoFixedIssues.push('Removed stray markdown backticks');
      }
    }

    // 2. Remove conversational intro/outro text outside JSON boundary
    const firstBrace = cleaned.indexOf('{');
    const firstBracket = cleaned.indexOf('[');
    let jsonStart = -1;

    if (firstBrace !== -1 && firstBracket !== -1) {
      jsonStart = Math.min(firstBrace, firstBracket);
    } else if (firstBrace !== -1) {
      jsonStart = firstBrace;
    } else if (firstBracket !== -1) {
      jsonStart = firstBracket;
    }

    if (jsonStart > 0) {
      cleaned = cleaned.substring(jsonStart).trim();
      autoFixedIssues.push('Trimmed conversational preamble before JSON');
    }

    const lastBrace = cleaned.lastIndexOf('}');
    const lastBracket = cleaned.lastIndexOf(']');
    const jsonEnd = Math.max(lastBrace, lastBracket);

    if (jsonEnd !== -1 && jsonEnd < cleaned.length - 1) {
      cleaned = cleaned.substring(0, jsonEnd + 1).trim();
      autoFixedIssues.push('Trimmed conversational postscript after JSON');
    }

    // 3. Fix smart quotes and curly quotes
    if (/[\u201C\u201D\u201E\u201F\u2018\u2019]/.test(cleaned)) {
      cleaned = cleaned
        .replace(/[\u201C\u201D\u201E\u201F]/g, '"')
        .replace(/[\u2018\u2019]/g, "'");
      autoFixedIssues.push('Normalized smart/curly quotes to standard quotes');
    }

    // 4. Fix trailing commas before } or ]
    cleaned = cleaned.replace(/,\s*([\]}])/g, '$1');

    // 5. Parse JSON
    let parsed: any;
    try {
      parsed = JSON.parse(cleaned);
    } catch (parseErr: any) {
      logger.warn({ parseErr: parseErr.message }, 'Initial JSON parse failed in NoteSanitizer, attempting recovery');

      // Attempt repair of unescaped control characters
      try {
        const sanitizedNewlines = cleaned.replace(/(?<!\\)\n/g, '\\n');
        parsed = JSON.parse(sanitizedNewlines);
        autoFixedIssues.push('Escaped raw newlines inside JSON strings');
      } catch {
        return {
          success: false,
          errors: [
            `JSON Syntax Error: ${parseErr.message}. Ensure valid JSON syntax or check for unescaped quotes.`,
          ],
        };
      }
    }

    // 6. Handle single unit object vs array of units
    let targetNote: any = null;

    if (Array.isArray(parsed)) {
      if (parsed.length === 0) {
        return { success: false, errors: ['JSON array is empty'] };
      }

      if (expectedUnitCode) {
        targetNote = parsed.find(
          (u: any) =>
            u.unitCode &&
            u.unitCode.toString().toUpperCase().trim() === expectedUnitCode.toUpperCase().trim()
        );
      }

      if (!targetNote) {
        targetNote = parsed[0];
        autoFixedIssues.push(
          `Extracted unit ${targetNote.unitCode || 'U1'} from array of ${parsed.length} units`
        );
      }
    } else if (typeof parsed === 'object' && parsed !== null) {
      targetNote = parsed;
    } else {
      return { success: false, errors: ['Parsed content is neither a JSON object nor an array'] };
    }

    // 7. Auto-fix and normalize fields
    if (expectedUnitCode && (!targetNote.unitCode || targetNote.unitCode.toUpperCase() !== expectedUnitCode.toUpperCase())) {
      targetNote.unitCode = expectedUnitCode.toUpperCase();
      autoFixedIssues.push(`Normalized unitCode to expected: ${expectedUnitCode}`);
    }

    if (typeof targetNote.grade === 'string') {
      const gNum = parseInt(targetNote.grade.replace(/[^0-9]/g, ''), 10);
      if (!isNaN(gNum)) {
        targetNote.grade = gNum;
        autoFixedIssues.push(`Converted grade string to integer (${gNum})`);
      }
    }

    if (typeof targetNote.unitNumber === 'string') {
      const uNum = parseInt(targetNote.unitNumber.replace(/[^0-9]/g, ''), 10);
      if (!isNaN(uNum)) {
        targetNote.unitNumber = uNum;
        autoFixedIssues.push(`Converted unitNumber to integer (${uNum})`);
      }
    }

    // Ensure array fields exist
    if (!Array.isArray(targetNote.summaryPoints)) {
      targetNote.summaryPoints = [];
      warnings.push('summaryPoints was missing; initialized to empty array');
    }

    if (!Array.isArray(targetNote.formulas)) {
      targetNote.formulas = [];
      autoFixedIssues.push('formulas was missing; initialized to empty array');
    }

    if (!Array.isArray(targetNote.keyDefinitions)) {
      targetNote.keyDefinitions = [];
      autoFixedIssues.push('keyDefinitions was missing; initialized to empty array');
    }

    if (!Array.isArray(targetNote.eueeFocusTopics)) {
      targetNote.eueeFocusTopics = [];
      autoFixedIssues.push('eueeFocusTopics was missing; initialized to empty array');
    }

    if (!targetNote.examTip && targetNote.examTips) {
      targetNote.examTip = Array.isArray(targetNote.examTips) ? targetNote.examTips.join(' ') : String(targetNote.examTips);
      autoFixedIssues.push('Normalized plural "examTips" to "examTip"');
    }

    // 8. Validate against Zod schema
    const validation = CollectorNoteItemSchema.safeParse(targetNote);
    if (!validation.success) {
      const fieldErrors = validation.error.errors.map(
        (e) => `${e.path.join('.')}: ${e.message}`
      );
      return {
        success: false,
        errors: fieldErrors,
        autoFixedIssues,
        warnings,
      };
    }

    return {
      success: true,
      note: validation.data as CollectorNoteItem,
      autoFixedIssues,
      warnings,
      fixesApplied: autoFixedIssues,
    };
  }
}
