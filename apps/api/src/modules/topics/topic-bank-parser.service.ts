import fs from 'fs';
import path from 'path';
import {
  SubjectStreamCategory,
  TopicLearningStep,
  TopicReadingReference,
} from '@acedex/contracts';
import { EUEE_SUBJECTS } from '../curriculum/curriculum-seeder.service';
import { TopicModuleModel } from './models/topic-module.model';
import { logger } from '../../common/utils/logger';

export interface ParsedTopicModuleInput {
  moduleId: string;
  subjectCode: string;
  subjectName: string;
  streamCategory: SubjectStreamCategory;
  moduleNumber: number;
  phase: string;
  title: string;
  rationale: string;
  references: TopicReadingReference[];
  sequence: TopicLearningStep[];
  prerequisites: string[];
  masteryCheckpoint: string;
  sourceFile: string;
}

export interface TopicSeederReport {
  filesScanned: number;
  subjectsSeeded: string[];
  modulesUpserted: number;
}

interface UnitLookupMeta {
  unitTitle: string;
  pages: string;
}

export class TopicBankParserService {
  /**
   * Resolves content/topic-bank directory across workspace & compiled dist execution
   */
  public static resolveTopicBankDir(): string {
    const candidates = [
      path.resolve(process.cwd(), 'content/topic-bank'),
      path.resolve(process.cwd(), '../../content/topic-bank'),
      path.resolve(__dirname, '../../../../../content/topic-bank'),
    ];
    for (const dir of candidates) {
      if (fs.existsSync(dir)) return dir;
    }
    return candidates[0];
  }

  /**
   * Strips inline markdown formatting and citation noise while preserving math & readable text
   */
  private static cleanMarkdownText(raw: string): string {
    return raw
      .replace(/\\\\\(/g, '(')
      .replace(/\\\\\)/g, ')')
      .replace(/\[\d+(?:[–\-,\s]+\d+)*\]/g, '')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private static buildUnitCode(subjectCode: string, grade: number, unitNumber: number): string {
    return `${subjectCode.toUpperCase()}-G${String(grade).padStart(2, '0')}-U${String(unitNumber).padStart(2, '0')}`;
  }

  /**
   * Parses Section 1 inventory tables to recover unit titles and page ranges for cross-referencing
   */
  private static parseUnitInventoryLookup(markdown: string): Map<string, UnitLookupMeta> {
    const map = new Map<string, UnitLookupMeta>();
    const rowRegex =
      /^\|\s*\*{0,2}Grade\s+(\d{1,2})\*{0,2}\s*\|\s*\*{0,2}Unit\s+(\d{1,2})\s*(?:\([^)]*\))?:\s*([^|*]+?)\*{0,2}\s*\|[^|]*\|\s*([^|]+?)\s*\|/gim;

    let match: RegExpExecArray | null;
    while ((match = rowRegex.exec(markdown)) !== null) {
      const grade = Number(match[1]);
      const unitNumber = Number(match[2]);
      const rawTitle = match[3].replace(/\(Sections?[^)]+\)/i, '').trim();
      const rawPages = match[4].trim();
      const key = `G${grade}-U${unitNumber}`;
      if (!map.has(key)) {
        map.set(key, {
          unitTitle: rawTitle,
          pages: rawPages,
        });
      }
    }
    return map;
  }

  /**
   * Parses reference strings such as:
   * - "Grade 9 Unit 1 (pp. 1–10); Grade 10 Unit 1 (pp. 5–26)"
   * - "Grade 9, Unit 1: Further on Sets (pp. 1–26)."
   * - "Grade 9 Unit 4 & Unit 5 (pp. 81–126)"
   */
  private static parseReferencesFromText(
    text: string,
    subjectCode: string,
    unitLookup: Map<string, UnitLookupMeta>
  ): TopicReadingReference[] {
    const refs: TopicReadingReference[] = [];
    const seen = new Set<string>();

    // Normalize "Grade 9 Unit 4 & Unit 5" into separate segments before matching
    const normalized = text.replace(
      /Grade\s+(\d{1,2})\s*,?\s*Unit\s+(\d{1,2})\s*&\s*Unit\s+(\d{1,2})/gi,
      'Grade $1 Unit $2; Grade $1 Unit $3'
    );

    const refRegex =
      /Grade\s+(\d{1,2})\s*,?\s*Unit\s+(\d{1,2})(?:\s*:\s*([^(\n;]+))?(?:\s*\(([^)]+)\))?/gi;

    let match: RegExpExecArray | null;
    while ((match = refRegex.exec(normalized)) !== null) {
      const grade = Number(match[1]);
      const unitNumber = Number(match[2]);
      const inlineTitle = match[3]?.trim().replace(/\.$/, '') || '';
      const parenDetail = match[4]?.trim() || '';

      const unitCode = this.buildUnitCode(subjectCode, grade, unitNumber);
      const lookup = unitLookup.get(`G${grade}-U${unitNumber}`);

      let pages = '';
      if (/pp?\.?\s*\d+/i.test(parenDetail)) {
        pages = parenDetail.match(/pp?\.?\s*[\d–\-,\s]+/i)?.[0]?.trim() || parenDetail;
      } else if (lookup?.pages) {
        pages = lookup.pages;
      }

      const unitTitle = inlineTitle || lookup?.unitTitle || `Unit ${unitNumber}`;
      const dedupeKey = `${unitCode}:${pages}`;
      if (!seen.has(dedupeKey)) {
        seen.add(dedupeKey);
        refs.push({
          grade,
          unitNumber,
          unitCode,
          unitTitle,
          pages: pages || 'Full Unit',
        });
      }
    }

    return refs;
  }

  private static deriveDefaultPhase(moduleNumber: number): string {
    if (moduleNumber <= 3) return 'Phase I: Foundational Core';
    if (moduleNumber <= 7) return 'Phase II: Core Systems';
    return 'Phase III: Advanced Synthesis';
  }

  /**
   * Parses a single subject markdown file into structured cross-grade modules
   */
  public static parseSubjectMarkdown(
    markdown: string,
    fileName: string
  ): ParsedTopicModuleInput[] {
    const slug = path.basename(fileName, '.md').toLowerCase().trim();
    const subjectMeta = EUEE_SUBJECTS.find((s) => s.slug === slug);
    if (!subjectMeta || !markdown.trim()) {
      return [];
    }

    const unitLookup = this.parseUnitInventoryLookup(markdown);
    const lines = markdown.split(/\r?\n/);

    // Locate Section 4 start to avoid parsing diagram blocks earlier in the file
    let startLine = lines.findIndex((l) => /^##\s+4\./i.test(l.trim()));
    if (startLine === -1) startLine = 0;

    let currentPhase = '';
    const rawModules: Array<{
      moduleNumber: number;
      title: string;
      phase: string;
      lines: string[];
    }> = [];
    let activeModule: {
      moduleNumber: number;
      title: string;
      phase: string;
      lines: string[];
    } | null = null;

    for (let i = startLine; i < lines.length; i++) {
      const line = lines[i];
      const trimmed = line.trim();

      // Stop if we hit Section 5 verification notes or summary checklist
      if (/^##\s+5\./i.test(trimmed) || /^###\s+Summary Checklist/i.test(trimmed)) {
        break;
      }

      // Track Phase heading (e.g., "### Phase I: Foundational Core (Modules 1 & 2)")
      const phaseMatch = trimmed.match(/^###\s+(Phase\s+[IVX]+:\s*[^(]+)/i);
      if (phaseMatch) {
        currentPhase = phaseMatch[1].trim();
        continue;
      }

      // Match Module heading: "### Module 1: Title" or "#### Module 1: Title"
      const moduleMatch = trimmed.match(/^#{3,4}\s+Module\s+(\d+)\s*:\s*(.+)$/i);
      if (moduleMatch) {
        if (activeModule) rawModules.push(activeModule);
        const modNum = Number(moduleMatch[1]);
        activeModule = {
          moduleNumber: modNum,
          title: moduleMatch[2].trim(),
          phase: currentPhase || this.deriveDefaultPhase(modNum),
          lines: [],
        };
        continue;
      }

      if (activeModule) {
        activeModule.lines.push(line);
      }
    }
    if (activeModule) rawModules.push(activeModule);

    return rawModules.map((mod) => {
      let referencesRaw = '';
      let rationaleRaw = '';
      let prereqRaw = '';
      let checkpointRaw = '';
      const sequenceLines: string[] = [];
      const fallbackNumberedRationale: string[] = [];

      let section: 'none' | 'refs' | 'rationale' | 'sequence' | 'prereq' | 'checkpoint' = 'none';

      for (const line of mod.lines) {
        const trimmed = line.trim();
        if (!trimmed || trimmed === '---') continue;

        if (/^-\s+\*\*(?:Curriculum References|Textbook Units to Study)\*\*\s*:/i.test(trimmed)) {
          section = 'refs';
          referencesRaw +=
            ' ' +
            trimmed.replace(
              /^-\s+\*\*(?:Curriculum References|Textbook Units to Study)\*\*\s*:\s*/i,
              ''
            );
          continue;
        }
        if (/^-\s+\*\*(?:Why Study Together|Why Study Here|Rationale)\*\*\s*:/i.test(trimmed)) {
          section = 'rationale';
          rationaleRaw +=
            ' ' +
            trimmed.replace(
              /^-\s+\*\*(?:Why Study Together|Why Study Here|Rationale)\*\*\s*:\s*/i,
              ''
            );
          continue;
        }
        if (
          /^-\s+\*\*(?:Recommended Learning Sequence|Internal Learning Sequence)\*\*\s*:/i.test(
            trimmed
          )
        ) {
          section = 'sequence';
          const tail = trimmed.replace(
            /^-\s+\*\*(?:Recommended Learning Sequence|Internal Learning Sequence)\*\*\s*:\s*/i,
            ''
          );
          if (tail) sequenceLines.push(tail);
          continue;
        }
        if (/^-\s+\*\*(?:Required Prerequisites|Prerequisites Required)\*\*\s*:/i.test(trimmed)) {
          section = 'prereq';
          prereqRaw +=
            ' ' +
            trimmed.replace(
              /^-\s+\*\*(?:Required Prerequisites|Prerequisites Required)\*\*\s*:\s*/i,
              ''
            );
          continue;
        }
        if (/^-\s+\*\*Mastery Checkpoint\*\*\s*:/i.test(trimmed)) {
          section = 'checkpoint';
          checkpointRaw +=
            ' ' + trimmed.replace(/^-\s+\*\*Mastery Checkpoint\*\*\s*:\s*/i, '');
          continue;
        }

        // Handle indented sub-lines inside the current bullet section
        if (section === 'refs') {
          referencesRaw += '; ' + trimmed.replace(/^-\s+/, '');
        } else if (section === 'rationale') {
          if (/^\d+\.\s+/.test(trimmed)) {
            fallbackNumberedRationale.push(trimmed.replace(/^\d+\.\s+/, ''));
          } else {
            rationaleRaw += ' ' + trimmed;
          }
        } else if (section === 'sequence') {
          if (/^\d+\.\s+/.test(trimmed)) {
            sequenceLines.push(trimmed.replace(/^\d+\.\s+/, ''));
          } else if (sequenceLines.length > 0) {
            // Append continuation sub-bullets onto the active numbered step
            sequenceLines[sequenceLines.length - 1] +=
              ' ' + trimmed.replace(/^-\s+/, '• ');
          }
        } else if (section === 'prereq') {
          prereqRaw += ' ' + trimmed;
        } else if (section === 'checkpoint') {
          checkpointRaw += ' ' + trimmed;
        }
      }

      const references = this.parseReferencesFromText(
        referencesRaw,
        subjectMeta.code,
        unitLookup
      );

      // Build structured learning steps from explicit sequence or unit references
      const rawSteps =
        sequenceLines.length > 0
          ? sequenceLines
          : fallbackNumberedRationale.length > 0
            ? fallbackNumberedRationale
            : references.map(
                (r) =>
                  `Study Grade ${r.grade} Unit ${r.unitNumber}: ${r.unitTitle} (${r.pages})`
              );

      const sequence: TopicLearningStep[] = rawSteps.map((stepText, idx) => {
        const inlineRefMatch = stepText.match(
          /Grade\s+(\d{1,2})\s*,?\s*Unit\s+(\d{1,2})(?:,\s*(pp?\.?\s*[\d–\-,\s]+))?/i
        );
        const stepGrade = inlineRefMatch ? Number(inlineRefMatch[1]) : undefined;
        const stepUnit = inlineRefMatch ? Number(inlineRefMatch[2]) : undefined;
        const stepPages = inlineRefMatch?.[3]?.trim();

        return {
          stepNumber: idx + 1,
          text: this.cleanMarkdownText(stepText),
          ...(stepGrade && stepUnit
            ? {
                grade: stepGrade,
                unitNumber: stepUnit,
                unitCode: this.buildUnitCode(subjectMeta.code, stepGrade, stepUnit),
                ...(stepPages ? { pages: stepPages } : {}),
              }
            : {}),
        };
      });

      const prerequisites = prereqRaw
        .split(/;|,\s*(?=[A-Z]|Module)/)
        .map((p) => this.cleanMarkdownText(p.replace(/\.$/, '')))
        .filter(Boolean);

      return {
        moduleId: `${subjectMeta.code}-M${String(mod.moduleNumber).padStart(2, '0')}`,
        subjectCode: subjectMeta.code,
        subjectName: subjectMeta.name,
        streamCategory: subjectMeta.streamCategory,
        moduleNumber: mod.moduleNumber,
        phase: mod.phase,
        title: this.cleanMarkdownText(mod.title),
        rationale: this.cleanMarkdownText(rationaleRaw),
        references,
        sequence,
        prerequisites,
        masteryCheckpoint: this.cleanMarkdownText(checkpointRaw),
        sourceFile: fileName,
      };
    });
  }

  /**
   * Scans content/topic-bank/*.md and upserts all parsed modules into acedex.topic_modules
   */
  public static async seedTopicsFromDisk(): Promise<TopicSeederReport> {
    const dir = this.resolveTopicBankDir();
    if (!fs.existsSync(dir)) {
      logger.warn({ dir }, 'Topic bank directory not found; skipping topic seeding');
      return { filesScanned: 0, subjectsSeeded: [], modulesUpserted: 0 };
    }

    const mdFiles = fs
      .readdirSync(dir)
      .filter((f) => f.toLowerCase().endsWith('.md'))
      .sort();

    let modulesUpserted = 0;
    const subjectsSeeded: string[] = [];

    for (const fileName of mdFiles) {
      const fullPath = path.join(dir, fileName);
      const raw = fs.readFileSync(fullPath, 'utf-8');
      if (!raw.trim()) continue;

      const parsedModules = this.parseSubjectMarkdown(raw, fileName);
      if (parsedModules.length === 0) continue;

      subjectsSeeded.push(parsedModules[0].subjectCode);

      for (const mod of parsedModules) {
        await TopicModuleModel.findOneAndUpdate(
          { moduleId: mod.moduleId },
          { $set: mod },
          { upsert: true, new: true }
        );
        modulesUpserted++;
      }
    }

    logger.info(
      { filesScanned: mdFiles.length, subjectsSeeded, modulesUpserted },
      'Cross-grade topic modules seeded into acedex.topic_modules'
    );

    return {
      filesScanned: mdFiles.length,
      subjectsSeeded,
      modulesUpserted,
    };
  }
}
