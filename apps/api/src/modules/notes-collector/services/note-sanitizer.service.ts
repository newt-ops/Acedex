import { CollectorNoteItem, CollectorNoteItemSchema, NoteSanitizeResult } from '@acedex/contracts';
import { logger } from '../../../common/utils/logger';

export class NoteSanitizerService {
  /**
   * Resiliently cleans and sanitizes raw text from NotebookLM or LLM into standard Quick Note JSON.
   * Supports both a single unit object or a full array of units for a grade.
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

    // 6. Handle array of units vs single unit object
    if (Array.isArray(parsed)) {
      if (parsed.length === 0) {
        return { success: false, errors: ['JSON array is empty'] };
      }

      const validatedUnits: CollectorNoteItem[] = [];
      const arrayErrors: string[] = [];

      for (let i = 0; i < parsed.length; i++) {
        const item = parsed[i];
        const res = this.normalizeAndValidateUnit(item, expectedUnitCode && parsed.length === 1 ? expectedUnitCode : undefined);
        if (res.success && res.note) {
          validatedUnits.push(res.note);
          res.issues.forEach((iss) => {
            if (!autoFixedIssues.includes(iss)) autoFixedIssues.push(iss);
          });
          res.warnings.forEach((warn) => {
            if (!warnings.includes(warn)) warnings.push(warn);
          });
        } else if (res.errors) {
          arrayErrors.push(`Unit #${i + 1} (${item.unitCode || item.unitTitle || 'Unknown'}): ${res.errors.join(', ')}`);
        }
      }

      if (validatedUnits.length === 0) {
        return {
          success: false,
          errors: arrayErrors.length > 0 ? arrayErrors : ['Failed to validate any units in the array'],
          autoFixedIssues,
          warnings,
        };
      }

      // If some units had errors, report as warnings
      if (arrayErrors.length > 0) {
        warnings.push(`${arrayErrors.length} unit(s) had errors and were skipped: ${arrayErrors.join('; ')}`);
      }

      autoFixedIssues.push(`Validated ${validatedUnits.length} unit(s) in curriculum array`);

      // Determine primary target note
      let primaryNote = validatedUnits[0];
      if (expectedUnitCode) {
        const match = validatedUnits.find(
          (u) => u.unitCode.toUpperCase() === expectedUnitCode.toUpperCase()
        );
        if (match) primaryNote = match;
      }

      return {
        success: true,
        note: primaryNote,
        notes: validatedUnits,
        unitCount: validatedUnits.length,
        autoFixedIssues,
        warnings,
        fixesApplied: autoFixedIssues,
      };
    } else if (typeof parsed === 'object' && parsed !== null) {
      const res = this.normalizeAndValidateUnit(parsed, expectedUnitCode);
      if (!res.success || !res.note) {
        return {
          success: false,
          errors: res.errors || ['Validation failed'],
          autoFixedIssues,
          warnings,
        };
      }

      res.issues.forEach((iss) => {
        if (!autoFixedIssues.includes(iss)) autoFixedIssues.push(iss);
      });
      res.warnings.forEach((warn) => {
        if (!warnings.includes(warn)) warnings.push(warn);
      });

      return {
        success: true,
        note: res.note,
        notes: [res.note],
        unitCount: 1,
        autoFixedIssues,
        warnings,
        fixesApplied: autoFixedIssues,
      };
    } else {
      return { success: false, errors: ['Parsed content is neither a JSON object nor an array'] };
    }
  }

  /**
   * Helper to normalize fields of a single note object and validate against Zod schema
   */
  private static normalizeAndValidateUnit(
    raw: any,
    expectedUnitCode?: string
  ): {
    success: boolean;
    note?: CollectorNoteItem;
    errors?: string[];
    issues: string[];
    warnings: string[];
  } {
    const issues: string[] = [];
    const unitWarnings: string[] = [];
    const note = { ...raw };

    if (expectedUnitCode && (!note.unitCode || note.unitCode.toUpperCase() !== expectedUnitCode.toUpperCase())) {
      note.unitCode = expectedUnitCode.toUpperCase();
      issues.push(`Normalized unitCode to expected: ${expectedUnitCode}`);
    }

    if (typeof note.grade === 'string') {
      const gNum = parseInt(note.grade.replace(/[^0-9]/g, ''), 10);
      if (!isNaN(gNum)) {
        note.grade = gNum;
        issues.push(`Converted grade string to integer (${gNum})`);
      }
    }

    if (typeof note.unitNumber === 'string') {
      const uNum = parseInt(note.unitNumber.replace(/[^0-9]/g, ''), 10);
      if (!isNaN(uNum)) {
        note.unitNumber = uNum;
        issues.push(`Converted unitNumber to integer (${uNum})`);
      }
    }

    // Default missing unitCode from grade and unitNumber if available
    if (!note.unitCode && note.subjectCode && note.grade && note.unitNumber) {
      const gStr = note.grade.toString().padStart(2, '0');
      const uStr = note.unitNumber.toString().padStart(2, '0');
      note.unitCode = `${note.subjectCode.toUpperCase()}-G${gStr}-U${uStr}`;
      issues.push(`Auto-generated unitCode: ${note.unitCode}`);
    }

    // Ensure array fields exist
    if (!Array.isArray(note.summaryPoints)) {
      note.summaryPoints = [];
      unitWarnings.push('summaryPoints was missing; initialized to empty array');
    }

    if (!Array.isArray(note.formulas)) {
      note.formulas = [];
      issues.push('formulas was missing; initialized to empty array');
    }

    if (!Array.isArray(note.keyDefinitions)) {
      note.keyDefinitions = [];
      issues.push('keyDefinitions was missing; initialized to empty array');
    }

    if (!Array.isArray(note.eueeFocusTopics)) {
      note.eueeFocusTopics = [];
      issues.push('eueeFocusTopics was missing; initialized to empty array');
    }

    if (!note.examTip && note.examTips) {
      note.examTip = Array.isArray(note.examTips)
        ? note.examTips.join(' ')
        : String(note.examTips);
      issues.push('Normalized plural "examTips" to "examTip"');
    }

    if (!note.examTip || typeof note.examTip !== 'string' || note.examTip.trim() === '') {
      note.examTip = 'Review all core definitions and practice previous EUEE examination questions for this unit.';
      issues.push('Added default exam tip');
    }

    const validation = CollectorNoteItemSchema.safeParse(note);
    if (!validation.success) {
      const fieldErrors = validation.error.errors.map(
        (e) => `${e.path.join('.')}: ${e.message}`
      );
      return {
        success: false,
        errors: fieldErrors,
        issues,
        warnings: unitWarnings,
      };
    }

    return {
      success: true,
      note: validation.data as CollectorNoteItem,
      issues,
      warnings: unitWarnings,
    };
  }
}
