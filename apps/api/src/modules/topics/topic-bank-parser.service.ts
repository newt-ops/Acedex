import fs from 'fs';
import path from 'path';
import mongoose from 'mongoose';
import {
  SubjectStreamCategory,
  SubjectTopicBankJson,
  SubjectTopicBankJsonSchema,
  TopicLearningStep,
  TopicReadingReference,
} from '@acedex/contracts';
import { EUEE_SUBJECTS } from '../curriculum/curriculum-seeder.service';
import { UnitModel } from '../curriculum/models/unit.model';
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

export interface TopicCompileReport {
  markdownFilesScanned: number;
  jsonFilesWritten: string[];
  existingJsonPreserved: string[];
  totalModulesCompiled: number;
  unitTitlesHydratedFromDb: number;
}

export interface TopicSeederReport {
  filesScanned: number;
  subjectsSeeded: string[];
  modulesUpserted: number;
  sourceMode: 'json-first';
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
   * Resolves compiled canonical JSON directory (content/topic-bank/json)
   */
  public static resolveCompiledJsonDir(): string {
    return path.join(this.resolveTopicBankDir(), 'json');
  }

  /**
   * Converts raw Markdown emphasis, bracket citations, and LaTeX math into clean Unicode text
   * suitable for mobile Text widgets while preserving exact formulas and numbers.
   */
  public static cleanMarkdownText(raw: string): string {
    let text = raw
      // Remove NotebookLM citation numbers (and preceding spaces before punctuation)
      .replace(/\s*\[\d+(?:[–\-,\s]+\d+)*\]/g, '')
      // Convert escaped LaTeX parens/brackets
      .replace(/\\\\?\(/g, '')
      .replace(/\\\\?\)/g, '')
      .replace(/\\\\?\[/g, '')
      .replace(/\\\\?\]/g, '')
      // Strip inline/block dollar math wrappers while preserving contents
      .replace(/\$\$([^$]+)\$\$/g, '$1')
      .replace(/\$([^$]+)\$/g, '$1')
      // Strip bold markdown while protecting math multiplication if any
      .replace(/\*\*([^*]+)\*\*/g, '$1')
      // Strip italic underscores around words without touching variable subscripts (e.g. P_x, Q_d)
      .replace(/(^|[\s(>"])_([^_\n]+?)_(?=[\s.,;:?!<)")']|$)/g, '$1$2');

    // Unwrap \text{...}, \mathrm{...}, \mathbf{...}
    for (let i = 0; i < 3; i++) {
      text = text.replace(/\\(?:text|mathrm|mathbf|mathit)\{([^{}]+)\}/g, '$1');
    }

    // Simplify \frac{num}{den} up to 2 passes
    for (let i = 0; i < 2; i++) {
      text = text.replace(/\\frac\{([^{}]+)\}\{([^{}]+)\}/g, '($1)/($2)');
    }

    // Map common LaTeX symbols to readable Unicode
    const replacements: Array<[RegExp, string]> = [
      [/\\left\|/g, '|'],
      [/\\right\|/g, '|'],
      [/\\left/g, ''],
      [/\\right/g, ''],
      [/\\implies|\\Rightarrow/g, '→'],
      [/\\iff|\\Leftrightarrow/g, '⇔'],
      [/\\to|\\rightarrow/g, '→'],
      [/\\leftarrow/g, '←'],
      [/\\uparrow/g, '↑'],
      [/\\downarrow/g, '↓'],
      [/\^\{?\\circ\}?/g, '°'],
      [/\\circ/g, '∘'],
      [/\\Delta/g, 'Δ'],
      [/\\Sigma|\\sum/g, 'Σ'],
      [/\\alpha/g, 'α'],
      [/\\beta/g, 'β'],
      [/\\gamma/g, 'γ'],
      [/\\theta/g, 'θ'],
      [/\\lambda/g, 'λ'],
      [/\\mu/g, 'μ'],
      [/\\pi/g, 'π'],
      [/\\sigma/g, 'σ'],
      [/\\Omega/g, 'Ω'],
      [/\\infty/g, '∞'],
      [/\\geq|\\ge/g, '≥'],
      [/\\leq|\\le/g, '≤'],
      [/\\neq|\\ne/g, '≠'],
      [/\\approx/g, '≈'],
      [/\\equiv/g, '≡'],
      [/\\times/g, '×'],
      [/\\cdot/g, '·'],
      [/\\div/g, '÷'],
      [/\\pm/g, '±'],
      [/\\land/g, '∧'],
      [/\\lor/g, '∨'],
      [/\\lfloor/g, '⌊'],
      [/\\rfloor/g, '⌋'],
      [/\\lceil/g, '⌈'],
      [/\\rceil/g, '⌉'],
      [/\\dots|\\ldots/g, '...'],
      [/\^\{([^{}]+)\}/g, '^($1)'],
      [/_\{([^{}]+)\}/g, '_$1'],
      [/\\([a-zA-Z]+)/g, '$1'],
      [/\s+([.,;:?!])/g, '$1'],
      [/\s+/g, ' '],
    ];

    for (const [pattern, replacement] of replacements) {
      text = text.replace(pattern, replacement);
    }

    return text.trim();
  }

  private static buildUnitCode(subjectCode: string, grade: number, unitNumber: number): string {
    return `${subjectCode.toUpperCase()}-G${String(grade).padStart(2, '0')}-U${String(unitNumber).padStart(2, '0')}`;
  }

  /**
   * Loads official unit titles from MongoDB acedex.units when connected so reading chips show
   * canonical textbook titles instead of generic "Unit 1" fallbacks.
   */
  public static async loadDbUnitTitleMap(): Promise<Map<string, string>> {
    const map = new Map<string, string>();
    if (mongoose.connection.readyState !== 1) {
      return map;
    }

    const docs = await UnitModel.find({}, 'code title').lean();
    for (const doc of docs) {
      if (doc.code && doc.title) {
        map.set(doc.code.toUpperCase(), doc.title.trim());
      }
    }
    return map;
  }

  /**
   * Hydrates a parsed module's reading references (and steps) using official DB unit titles
   */
  public static hydrateModuleWithDbTitles(
    mod: ParsedTopicModuleInput,
    dbUnitTitles: Map<string, string>
  ): { module: ParsedTopicModuleInput; hydratedCount: number } {
    if (dbUnitTitles.size === 0) {
      return { module: mod, hydratedCount: 0 };
    }

    let hydratedCount = 0;
    const updatedRefs = mod.references.map((ref) => {
      const officialTitle = dbUnitTitles.get(ref.unitCode.toUpperCase());
      if (officialTitle && officialTitle !== ref.unitTitle) {
        hydratedCount++;
        return {
          ...ref,
          unitTitle: officialTitle,
        };
      }
      return ref;
    });

    return {
      module: {
        ...mod,
        references: updatedRefs,
      },
      hydratedCount,
    };
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
   * Parses single or combined textbook unit references such as:
   * - "Grade 9 Unit 1 (pp. 1–10); Grade 10 Unit 1 (pp. 5–26)"
   * - "Grade 9, Unit 1: Further on Sets (pp. 1–26)."
   * - "Grade 9 Unit 4 & Unit 5 (pp. 81–126)"
   * - "Grade 9 Unit 7 & 8 (pp. 133–187)"
   * - "Grade 10 Unit 6, 7, 8, 9 (pp. 144–230)"
   */
  private static parseReferencesFromText(
    text: string,
    subjectCode: string,
    unitLookup: Map<string, UnitLookupMeta>
  ): TopicReadingReference[] {
    const refs: TopicReadingReference[] = [];
    const seen = new Set<string>();

    // Normalize "Unit 4 & Unit 5" into "Units 4, 5" for unified multi-unit parsing
    const normalized = text.replace(
      /Grade\s+(\d{1,2})\s*,?\s*Unit\s+(\d{1,2})\s*&\s*Unit\s+(\d{1,2})/gi,
      'Grade $1 Units $2, $3'
    );

    const refRegex =
      /Grade\s+(\d{1,2})\s*,?\s*Units?\s+(\d{1,2}(?:\s*(?:,|&)\s*\d{1,2})*)(?:\s*:\s*([^(\n;]+))?(?:\s*\(([^)]+)\))?/gi;

    let match: RegExpExecArray | null;
    while ((match = refRegex.exec(normalized)) !== null) {
      const grade = Number(match[1]);
      const unitNumbers = (match[2].match(/\d+/g) ?? []).map((n) => Number(n));
      const inlineTitle = match[3]?.trim().replace(/\.$/, '') || '';
      const parenDetail = match[4]?.trim() || '';

      // Split comma-separated page ranges when multiple units share one paren block (e.g. "pp. 64–82, 188–208")
      const cleanPagesToken = parenDetail.replace(/^pp?\.?\s*/i, '').trim();
      const splitPageSegments = cleanPagesToken
        .split(',')
        .map((s) => s.trim())
        .filter((s) => /\d/.test(s));

      unitNumbers.forEach((unitNumber, idx) => {
        const unitCode = this.buildUnitCode(subjectCode, grade, unitNumber);
        const lookup = unitLookup.get(`G${grade}-U${unitNumber}`);

        let pages = '';
        if (
          unitNumbers.length > 1 &&
          splitPageSegments.length === unitNumbers.length &&
          /pp?\.?\s*\d+/i.test(parenDetail)
        ) {
          pages = `pp. ${splitPageSegments[idx]}`;
        } else if (/pp?\.?\s*\d+/i.test(parenDetail)) {
          pages = parenDetail.match(/pp?\.?\s*[\d–\-,\s]+/i)?.[0]?.trim() || parenDetail;
        } else if (lookup?.pages) {
          pages = lookup.pages;
        }

        const unitTitle =
          (unitNumbers.length === 1 ? inlineTitle : '') ||
          lookup?.unitTitle ||
          `Unit ${unitNumber}`;

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
      });
    }

    return refs;
  }

  /**
   * Splits prerequisite clauses on ';' or ', ' followed by a capitalized clause or 'Module',
   * ignoring commas nested inside parentheses such as "(B.C., A.D., B.P., ...)".
   */
  private static splitPrerequisites(raw: string): string[] {
    const items: string[] = [];
    let current = '';
    let depth = 0;

    for (let i = 0; i < raw.length; i++) {
      const ch = raw[i];
      if (ch === '(') depth++;
      else if (ch === ')' && depth > 0) depth--;

      if (depth === 0) {
        if (ch === ';') {
          items.push(current);
          current = '';
          continue;
        }
        if (ch === ',' && /^\s+(?:[A-Z]|Module)/.test(raw.slice(i + 1))) {
          items.push(current);
          current = '';
          continue;
        }
      }
      current += ch;
    }
    if (current) items.push(current);

    return items
      .map((p) => this.cleanMarkdownText(p.replace(/\.$/, '')))
      .filter(Boolean);
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

        if (
          /^-\s+\*\*(?:Curriculum References|Textbook Units to Study|Textbook References)\*\*\s*:/i.test(
            trimmed
          )
        ) {
          section = 'refs';
          referencesRaw +=
            ' ' +
            trimmed.replace(
              /^-\s+\*\*(?:Curriculum References|Textbook Units to Study|Textbook References)\*\*\s*:\s*/i,
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

      const prerequisites = this.splitPrerequisites(prereqRaw);

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
   * Compiles all non-empty content/topic-bank/*.md files into validated, clean JSON files
   * under content/topic-bank/json/<subject>.json enriched with official acedex.units titles.
   */
  public static async compileTopicBankToJson(): Promise<TopicCompileReport> {
    const dir = this.resolveTopicBankDir();
    const jsonDir = this.resolveCompiledJsonDir();
    fs.mkdirSync(jsonDir, { recursive: true });

    const dbUnitTitles = await this.loadDbUnitTitleMap();
    const mdFiles = fs
      .readdirSync(dir)
      .filter((f) => f.toLowerCase().endsWith('.md'))
      .sort();

    const jsonFilesWritten: string[] = [];
    const existingJsonPreserved: string[] = [];
    let totalModulesCompiled = 0;
    let unitTitlesHydratedFromDb = 0;

    for (const fileName of mdFiles) {
      const slug = path.basename(fileName, '.md').toLowerCase().trim();
      const jsonFileName = `${slug}.json`;
      const jsonPath = path.join(jsonDir, jsonFileName);
      const raw = fs.readFileSync(path.join(dir, fileName), 'utf-8');

      if (!raw.trim()) {
        // Keep manually curated/synthesized JSON (e.g. english.json) if the corresponding .md is empty
        if (fs.existsSync(jsonPath)) {
          const parsedJson = SubjectTopicBankJsonSchema.parse(
            JSON.parse(fs.readFileSync(jsonPath, 'utf-8'))
          );
          existingJsonPreserved.push(jsonFileName);
          totalModulesCompiled += parsedJson.modules.length;
        }
        continue;
      }

      const rawModules = this.parseSubjectMarkdown(raw, fileName);
      if (rawModules.length === 0) continue;

      const hydratedModules = rawModules.map((mod) => {
        const res = this.hydrateModuleWithDbTitles(mod, dbUnitTitles);
        unitTitlesHydratedFromDb += res.hydratedCount;
        return res.module;
      });

      const payload: SubjectTopicBankJson = SubjectTopicBankJsonSchema.parse({
        schemaVersion: 1,
        subjectCode: hydratedModules[0].subjectCode,
        subjectName: hydratedModules[0].subjectName,
        streamCategory: hydratedModules[0].streamCategory,
        compiledAt: new Date().toISOString(),
        sourceFile: fileName,
        modules: hydratedModules,
      });

      fs.writeFileSync(jsonPath, JSON.stringify(payload, null, 2) + '\n', 'utf-8');
      jsonFilesWritten.push(jsonFileName);
      totalModulesCompiled += payload.modules.length;
    }

    // Also count any standalone JSON files that have no .md counterpart
    const extraJsonFiles = fs
      .readdirSync(jsonDir)
      .filter((f) => f.toLowerCase().endsWith('.json'))
      .filter((f) => !jsonFilesWritten.includes(f) && !existingJsonPreserved.includes(f))
      .sort();

    for (const extra of extraJsonFiles) {
      const parsedJson = SubjectTopicBankJsonSchema.parse(
        JSON.parse(fs.readFileSync(path.join(jsonDir, extra), 'utf-8'))
      );
      existingJsonPreserved.push(extra);
      totalModulesCompiled += parsedJson.modules.length;
    }

    logger.info(
      {
        markdownFilesScanned: mdFiles.length,
        jsonFilesWritten,
        existingJsonPreserved,
        totalModulesCompiled,
        unitTitlesHydratedFromDb,
      },
      'Compiled topic-bank data into validated canonical JSON files'
    );

    return {
      markdownFilesScanned: mdFiles.length,
      jsonFilesWritten,
      existingJsonPreserved,
      totalModulesCompiled,
      unitTitlesHydratedFromDb,
    };
  }

  /**
   * Feeds acedex.topic_modules from validated canonical JSON files in content/topic-bank/json/*.json,
   * falling back to Markdown parsing only if a subject's JSON has not yet been compiled.
   */
  public static async seedTopicsFromDisk(): Promise<TopicSeederReport> {
    const dir = this.resolveTopicBankDir();
    const jsonDir = this.resolveCompiledJsonDir();
    if (!fs.existsSync(dir)) {
      logger.warn({ dir }, 'Topic bank directory not found; skipping topic seeding');
      return { filesScanned: 0, subjectsSeeded: [], modulesUpserted: 0, sourceMode: 'json-first' };
    }

    const dbUnitTitles = await this.loadDbUnitTitleMap();
    const modulesBySubject = new Map<string, ParsedTopicModuleInput[]>();
    let filesScanned = 0;

    // 1. Prefer compiled/curated JSON files in content/topic-bank/json/*.json
    if (fs.existsSync(jsonDir)) {
      const jsonFiles = fs
        .readdirSync(jsonDir)
        .filter((f) => f.toLowerCase().endsWith('.json'))
        .sort();

      for (const jsonFile of jsonFiles) {
        filesScanned++;
        const rawJson = fs.readFileSync(path.join(jsonDir, jsonFile), 'utf-8');
        if (!rawJson.trim()) continue;
        const parsed = SubjectTopicBankJsonSchema.parse(JSON.parse(rawJson));
        const hydrated = parsed.modules.map(
          (m) => this.hydrateModuleWithDbTitles(m, dbUnitTitles).module
        );
        modulesBySubject.set(parsed.subjectCode, hydrated);
      }
    }

    // 2. Fall back to *.md only for subjects not already loaded from JSON
    const mdFiles = fs
      .readdirSync(dir)
      .filter((f) => f.toLowerCase().endsWith('.md'))
      .sort();

    for (const fileName of mdFiles) {
      const slug = path.basename(fileName, '.md').toLowerCase().trim();
      const subjectMeta = EUEE_SUBJECTS.find((s) => s.slug === slug);
      if (subjectMeta && modulesBySubject.has(subjectMeta.code)) {
        continue;
      }

      filesScanned++;
      const raw = fs.readFileSync(path.join(dir, fileName), 'utf-8');
      if (!raw.trim()) continue;

      const parsedModules = this.parseSubjectMarkdown(raw, fileName).map(
        (m) => this.hydrateModuleWithDbTitles(m, dbUnitTitles).module
      );
      if (parsedModules.length > 0) {
        modulesBySubject.set(parsedModules[0].subjectCode, parsedModules);
      }
    }

    let modulesUpserted = 0;
    const subjectsSeeded: string[] = [];
    const bulkOps: Array<{
      updateOne: {
        filter: { moduleId: string };
        update: { $set: ParsedTopicModuleInput };
        upsert: true;
      };
    }> = [];

    for (const [subjectCode, modules] of Array.from(modulesBySubject.entries()).sort((a, b) =>
      a[0].localeCompare(b[0])
    )) {
      subjectsSeeded.push(subjectCode);
      for (const mod of modules) {
        bulkOps.push({
          updateOne: {
            filter: { moduleId: mod.moduleId },
            update: { $set: mod },
            upsert: true,
          },
        });
      }
    }

    if (bulkOps.length > 0) {
      await TopicModuleModel.bulkWrite(bulkOps, { ordered: false });
      modulesUpserted = bulkOps.length;
    }

    logger.info(
      { filesScanned, subjectsSeeded, modulesUpserted, sourceMode: 'json-first' },
      'Cross-grade topic modules seeded into acedex.topic_modules'
    );

    return {
      filesScanned,
      subjectsSeeded,
      modulesUpserted,
      sourceMode: 'json-first',
    };
  }
}
