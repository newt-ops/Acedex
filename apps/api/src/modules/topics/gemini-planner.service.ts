import crypto from 'crypto';
import {
  AiCalibrationInput,
  AiDailyTaskItem,
  AiStudyProgram,
  AiSubjectAllocation,
  StudentStream,
} from '@acedex/contracts';
import { EUEE_SUBJECTS } from '../curriculum/curriculum-seeder.service';
import { ITopicModuleDocument } from './models/topic-module.model';
import { env } from '../../config/env';
import { logger } from '../../common/utils/logger';
import { ContentCacheService } from '../../common/services/cache.service';

interface GeminiRawResponse {
  diagnosticSummary?: string;
  recommendedModules?: Array<{
    moduleId: string;
    coachingNote?: string;
  }>;
  subjectModuleOrdering?: Array<{
    subjectCode: string;
    orderedModuleIds: string[];
  }>;
}

const AI_PLAN_CACHE_PREFIX = 'ai_plan_blueprint:';
const AI_PLAN_CACHE_TTL_SECONDS = 12 * 60 * 60; // 12 hours
const DAILY_QUOTA_COOLDOWN_MS = 6 * 60 * 60 * 1000; // 6 hours
const BURST_LIMIT_COOLDOWN_MS = 2 * 60 * 1000; // 2 minutes
const UNSUPPORTED_MODEL_COOLDOWN_MS = 60 * 60 * 1000; // 1 hour

export class GeminiPlannerService {
  /** Tracks per-model cooldown timestamps after 429 / unsupported responses to avoid wasted requests. */
  private static modelCooldownUntil = new Map<string, number>();

  /** Deduplicates concurrent identical Gemini calls so parallel bursts only consume 1 quota request. */
  private static inFlightCalls = new Map<string, Promise<GeminiRawResponse | null>>();

  /**
   * Clears in-memory model cooldowns and cached AI blueprints (primarily for tests).
   */
  public static resetRuntimeState(): void {
    this.modelCooldownUntil.clear();
    this.inFlightCalls.clear();
    ContentCacheService.delPrefix(AI_PLAN_CACHE_PREFIX);
  }

  /**
   * Resolves ordered, deduplicated Gemini models starting with `env.GEMINI_MODEL`
   * followed by `env.GEMINI_FALLBACK_MODELS`.
   */
  public static getCandidateModels(): string[] {
    const raw = [
      env.GEMINI_MODEL,
      ...(env.GEMINI_FALLBACK_MODELS || '').split(','),
    ];
    const seen = new Set<string>();
    const models: string[] = [];
    for (const item of raw) {
      const clean = item.trim();
      if (!clean || seen.has(clean)) continue;
      seen.add(clean);
      models.push(clean);
    }
    return models;
  }
  /**
   * Formats exact reading locations (Grade, Unit & Textbook Pages) for a module
   */
  public static formatWhereToRead(mod: ITopicModuleDocument): string {
    if (!mod.references || mod.references.length === 0) {
      return `${mod.subjectName} Module ${mod.moduleNumber}`;
    }
    return mod.references
      .slice(0, 3)
      .map((r) => `G${r.grade} U${r.unitNumber} (${r.pages})`)
      .join(' • ');
  }

  /**
   * Computes balanced weekly minute allocations across all subjects in the student's stream
   */
  private static computeSubjectAllocations(
    stream: StudentStream,
    calibration: AiCalibrationInput
  ): AiSubjectAllocation[] {
    const streamSubjects = EUEE_SUBJECTS.filter(
      (s) => s.streamCategory === 'common' || s.streamCategory === stream
    );
    const weakUpper = calibration.weakSubjectCodes.map((c) => c.toUpperCase().trim());
    const weeklyMinutesTotal = calibration.dailyMinutes * 7;

    const weighted = streamSubjects.map((s) => {
      const rankIdx = weakUpper.indexOf(s.code);
      const priorityRank = rankIdx !== -1 ? rankIdx + 1 : null;
      const weight =
        priorityRank === 1
          ? 2.35
          : priorityRank === 2
            ? 1.95
            : priorityRank === 3
              ? 1.65
              : 1.0;
      return { subject: s, priorityRank, weight };
    });

    const totalWeight = weighted.reduce((acc, w) => acc + w.weight, 0) || 1;

    return weighted
      .map((w) => ({
        subjectCode: w.subject.code,
        subjectName: w.subject.name,
        priorityRank: w.priorityRank,
        weeklyMinutes: Math.round((w.weight / totalWeight) * weeklyMinutesTotal),
        sharePercentage: Math.round((w.weight / totalWeight) * 100),
      }))
      .sort((a, b) => {
        if (a.priorityRank && b.priorityRank) return a.priorityRank - b.priorityRank;
        if (a.priorityRank) return -1;
        if (b.priorityRank) return 1;
        return b.weeklyMinutes - a.weeklyMinutes;
      });
  }

  /**
   * Generates a personalized AI study program collaborating with the curated Topic Bank.
   * Uses Gemini REST API when GEMINI_API_KEY is configured, hydrating verified textbook references
   * from MongoDB and falling back gracefully if unavailable.
   */
  public static async generateStudyProgram(params: {
    stream: StudentStream;
    grade: number;
    calibration: AiCalibrationInput;
    modules: ITopicModuleDocument[];
    completedUnitCodes: string[];
    weakAssessmentUnits?: Array<{ unitCode: string; bestPercentage: number }>;
    quickNotesUnitCodes?: string[];
    completedModuleIds: string[];
  }): Promise<AiStudyProgram> {
    const {
      stream,
      grade,
      calibration,
      modules,
      completedUnitCodes,
      weakAssessmentUnits = [],
      quickNotesUnitCodes = [],
      completedModuleIds,
    } = params;

    const moduleMap = new Map<string, ITopicModuleDocument>();
    const modulesBySubject = new Map<string, ITopicModuleDocument[]>();

    for (const mod of modules) {
      moduleMap.set(mod.moduleId, mod);
      const list = modulesBySubject.get(mod.subjectCode) || [];
      list.push(mod);
      modulesBySubject.set(mod.subjectCode, list);
    }

    for (const list of modulesBySubject.values()) {
      list.sort((a, b) => a.moduleNumber - b.moduleNumber);
    }

    const allocations = this.computeSubjectAllocations(stream, calibration);
    const projectedScore = Math.min(595, calibration.targetScore + 10);

    // Build deterministic baseline first (also serves as safe fallback & structural validation)
    const deterministic = this.buildDeterministicOutput({
      stream,
      grade,
      calibration,
      allocations,
      modulesBySubject,
      completedModuleIds,
      weakAssessmentUnits,
      projectedScore,
    });

    if (!env.GEMINI_API_KEY || modules.length === 0) {
      return deterministic;
    }

    try {
      const geminiResult = await this.callGeminiWithTopicCatalog({
        stream,
        grade,
        calibration,
        modules,
        completedUnitCodes,
        weakAssessmentUnits,
        quickNotesUnitCodes,
        completedModuleIds,
        allocations,
      });

      if (!geminiResult) {
        return deterministic;
      }

      // Hydrate Gemini-selected moduleIds strictly from verified MongoDB TopicModule documents
      const focusTasks: AiDailyTaskItem[] = [];
      const seenModIds = new Set<string>();
      const blockMinutes = Math.max(20, Math.round(calibration.dailyMinutes / 4));

      for (const rec of geminiResult.recommendedModules || []) {
        const mod = moduleMap.get(rec.moduleId);
        if (!mod || seenModIds.has(mod.moduleId)) continue;
        seenModIds.add(mod.moduleId);

        const rankIdx = calibration.weakSubjectCodes
          .map((c) => c.toUpperCase())
          .indexOf(mod.subjectCode);
        const isPriority = rankIdx !== -1;

        focusTasks.push({
          id: `ai-task-${mod.moduleId}`,
          moduleId: mod.moduleId,
          subjectCode: mod.subjectCode,
          subjectName: mod.subjectName,
          title: `Module ${mod.moduleNumber}: ${mod.title}`,
          durationMinutes: isPriority ? blockMinutes + 5 : Math.max(15, blockMinutes - 5),
          priorityTag: isPriority ? `Priority #${rankIdx + 1}` : 'Core Foundation',
          whereToRead: this.formatWhereToRead(mod),
          coachingNote: rec.coachingNote || mod.rationale.slice(0, 140),
        });

        if (focusTasks.length >= 4) break;
      }

      // Top up to 4 tasks from deterministic plan if Gemini returned fewer valid IDs
      for (const fallbackTask of deterministic.dailyFocusTasks) {
        if (focusTasks.length >= 4) break;
        if (!seenModIds.has(fallbackTask.moduleId)) {
          focusTasks.push(fallbackTask);
          seenModIds.add(fallbackTask.moduleId);
        }
      }

      // Prioritize recommended modules at the front of each subject's deterministic ordering
      const priorityBySubject: Record<string, string[]> = {
        ...deterministic.modulePriorityBySubject,
      };
      for (const ord of geminiResult.subjectModuleOrdering || []) {
        const code = ord.subjectCode.toUpperCase().trim();
        const subjectMods = modulesBySubject.get(code);
        if (!subjectMods) continue;

        const validSet = new Set(subjectMods.map((m) => m.moduleId));
        const ordered = (ord.orderedModuleIds || []).filter((id) => validSet.has(id));
        for (const m of subjectMods) {
          if (!ordered.includes(m.moduleId)) ordered.push(m.moduleId);
        }
        priorityBySubject[code] = ordered;
      }
      for (const task of [...focusTasks].reverse()) {
        const list = priorityBySubject[task.subjectCode];
        if (!list) continue;
        priorityBySubject[task.subjectCode] = [
          task.moduleId,
          ...list.filter((id) => id !== task.moduleId),
        ];
      }

      return {
        calibration,
        stream,
        projectedScore,
        diagnosticSummary:
          geminiResult.diagnosticSummary?.trim() || deterministic.diagnosticSummary,
        subjectAllocations: allocations,
        dailyFocusTasks: focusTasks,
        modulePriorityBySubject: priorityBySubject,
        generatedBy: 'gemini',
        generatedAt: new Date().toISOString(),
      };
    } catch (err: any) {
      logger.warn(
        { err: err.message },
        'Gemini planner call failed; using grounded deterministic fallback'
      );
      return deterministic;
    }
  }

  /**
   * Compact system instruction (<220 tokens) to minimize TPM usage on every request.
   */
  private static buildCompactSystemInstruction(stream: StudentStream): string {
    const streamInfo =
      stream === 'social'
        ? 'Social Science EUEE/600: ECO,GEO,HIS,MAT,ENG,APT'
        : 'Natural Science EUEE/600: PHY,CHE,BIO,MAT,ENG,APT';

    return [
      `You are ACEDEX AI, Ethiopian MoE G9-12 & ${streamInfo} Study Advisor.`,
      'Pick 4 recommendedModules STRICTLY from the provided catalog (moduleId verbatim):',
      '1. Prioritize weakSubjects first (at most 1 non-weak rotation module).',
      '2. Prioritize modules matching weakAssessmentUnits (<65%) and skip completed modules.',
      '3. Stage: starting=early M01-M03 foundations; reviewing=G9/10->G11/12 bridge; sprint=G11/12 mastery.',
      '4. For G9-11 students avoid G12-only modules unless prerequisites done.',
      'Output JSON:',
      '- diagnosticSummary: 2 crisp encouraging sentences citing stream, goal, weak subjects & routine.',
      '- recommendedModules: 4 items {moduleId, coachingNote (1 actionable sentence citing unit/pages; mention Quick Notes if ref has *)}.',
    ].join('\n');
  }

  /**
   * Selects a focused shortlist of up to 22 unfinished/relevant candidate modules
   * instead of sending all 50-60 stream modules, cutting input prompt tokens by ~75%.
   */
  private static selectCandidateModulesForPrompt(params: {
    modules: ITopicModuleDocument[];
    allocations: AiSubjectAllocation[];
    completedModuleIds: string[];
    weakAssessmentUnits: Array<{ unitCode: string; bestPercentage: number }>;
  }): ITopicModuleDocument[] {
    const { modules, allocations, completedModuleIds, weakAssessmentUnits } = params;
    const completedSet = new Set(completedModuleIds);
    const weakUnitSet = new Set(
      weakAssessmentUnits.map((w) => w.unitCode.toUpperCase().trim())
    );

    const bySubject = new Map<string, ITopicModuleDocument[]>();
    for (const mod of modules) {
      const list = bySubject.get(mod.subjectCode) || [];
      list.push(mod);
      bySubject.set(mod.subjectCode, list);
    }

    const picked: ITopicModuleDocument[] = [];
    const seen = new Set<string>();

    for (const alloc of allocations) {
      const subjectMods = (bySubject.get(alloc.subjectCode) || [])
        .slice()
        .sort((a, b) => a.moduleNumber - b.moduleNumber);
      if (subjectMods.length === 0) continue;

      const limit = alloc.priorityRank !== null ? 4 : 2;
      const incomplete = subjectMods.filter((m) => !completedSet.has(m.moduleId));
      const pool = incomplete.length > 0 ? incomplete : subjectMods.slice(-1);

      // Float modules containing weak assessment units to the top of this subject's pool
      const ordered = pool.slice().sort((a, b) => {
        const aWeak = (a.references || []).some((r) =>
          weakUnitSet.has((r.unitCode || '').toUpperCase().trim())
        );
        const bWeak = (b.references || []).some((r) =>
          weakUnitSet.has((r.unitCode || '').toUpperCase().trim())
        );
        if (aWeak !== bWeak) return aWeak ? -1 : 1;
        return a.moduleNumber - b.moduleNumber;
      });

      for (const mod of ordered.slice(0, limit)) {
        if (seen.has(mod.moduleId)) continue;
        seen.add(mod.moduleId);
        picked.push(mod);
        if (picked.length >= 22) return picked;
      }
    }

    return picked;
  }

  /**
   * Builds a deterministic fingerprint for the blueprint cache so equivalent profiles
   * reuse existing Gemini plans without consuming extra RPD/TPM quota.
   */
  private static buildPlanCacheKey(params: {
    stream: StudentStream;
    grade: number;
    calibration: AiCalibrationInput;
    candidateModules: ITopicModuleDocument[];
    completedUnitCodes: string[];
    weakAssessmentUnits: Array<{ unitCode: string; bestPercentage: number }>;
    quickNotesUnitCodes: string[];
  }): string {
    const gradeBucket = params.grade <= 10 ? 'g9_10' : params.grade === 11 ? 'g11' : 'g12';
    const completedUnitSet = new Set(
      params.completedUnitCodes.map((c) => c.toUpperCase().trim())
    );
    const quickNotesSet = new Set(
      params.quickNotesUnitCodes.map((c) => c.toUpperCase().trim())
    );

    const payload = {
      stream: params.stream,
      gradeBucket,
      tierId: params.calibration.tierId,
      weakSubjectCodes: params.calibration.weakSubjectCodes.map((c) =>
        c.toUpperCase().trim()
      ),
      dailyMinutes: params.calibration.dailyMinutes,
      peakWindow: params.calibration.peakWindow,
      prepStageId: params.calibration.prepStageId,
      weakUnits: params.weakAssessmentUnits
        .map((w) => w.unitCode.toUpperCase().trim())
        .sort(),
      candidates: params.candidateModules.map((m) => ({
        id: m.moduleId,
        refs: (m.references || []).map((r) => {
          const code = (r.unitCode || '').toUpperCase().trim();
          return `${code}:${completedUnitSet.has(code) ? 1 : 0}:${quickNotesSet.has(code) ? 1 : 0}`;
        }),
      })),
    };

    const hash = crypto
      .createHash('sha256')
      .update(JSON.stringify(payload))
      .digest('hex')
      .slice(0, 24);
    return `${AI_PLAN_CACHE_PREFIX}${hash}`;
  }

  private static cloneGeminiResponse(res: GeminiRawResponse): GeminiRawResponse {
    return {
      diagnosticSummary: res.diagnosticSummary,
      recommendedModules: (res.recommendedModules || []).map((item) => ({ ...item })),
      subjectModuleOrdering: res.subjectModuleOrdering
        ? res.subjectModuleOrdering.map((item) => ({
            subjectCode: item.subjectCode,
            orderedModuleIds: [...item.orderedModuleIds],
          }))
        : undefined,
    };
  }

  private static async callGeminiWithTopicCatalog(params: {
    stream: StudentStream;
    grade: number;
    calibration: AiCalibrationInput;
    modules: ITopicModuleDocument[];
    completedUnitCodes: string[];
    weakAssessmentUnits: Array<{ unitCode: string; bestPercentage: number }>;
    quickNotesUnitCodes: string[];
    completedModuleIds: string[];
    allocations: AiSubjectAllocation[];
  }): Promise<GeminiRawResponse | null> {
    const {
      stream,
      grade,
      calibration,
      modules,
      completedUnitCodes,
      weakAssessmentUnits,
      quickNotesUnitCodes,
      completedModuleIds,
      allocations,
    } = params;

    const candidateModules = this.selectCandidateModulesForPrompt({
      modules,
      allocations,
      completedModuleIds,
      weakAssessmentUnits,
    });
    if (candidateModules.length === 0) return null;

    const cacheKey = this.buildPlanCacheKey({
      stream,
      grade,
      calibration,
      candidateModules,
      completedUnitCodes,
      weakAssessmentUnits,
      quickNotesUnitCodes,
    });

    const cached = ContentCacheService.get<GeminiRawResponse>(cacheKey);
    if (cached) {
      logger.info({ cacheKey }, 'AI blueprint cache hit — 0 Gemini quota consumed');
      return this.cloneGeminiResponse(cached);
    }

    const existingFlight = this.inFlightCalls.get(cacheKey);
    if (existingFlight) {
      const shared = await existingFlight;
      return shared ? this.cloneGeminiResponse(shared) : null;
    }

    const requestPromise = this.executeGeminiWithFallback({
      stream,
      grade,
      calibration,
      candidateModules,
      completedUnitCodes,
      weakAssessmentUnits,
      quickNotesUnitCodes,
      cacheKey,
    }).finally(() => {
      this.inFlightCalls.delete(cacheKey);
    });

    this.inFlightCalls.set(cacheKey, requestPromise);
    const result = await requestPromise;
    return result ? this.cloneGeminiResponse(result) : null;
  }

  private static async executeGeminiWithFallback(params: {
    stream: StudentStream;
    grade: number;
    calibration: AiCalibrationInput;
    candidateModules: ITopicModuleDocument[];
    completedUnitCodes: string[];
    weakAssessmentUnits: Array<{ unitCode: string; bestPercentage: number }>;
    quickNotesUnitCodes: string[];
    cacheKey: string;
  }): Promise<GeminiRawResponse | null> {
    const {
      stream,
      grade,
      calibration,
      candidateModules,
      completedUnitCodes,
      weakAssessmentUnits,
      quickNotesUnitCodes,
      cacheKey,
    } = params;

    const quickNotesSet = new Set(
      quickNotesUnitCodes.map((c) => c.toUpperCase().trim())
    );
    const completedUnitSet = new Set(
      completedUnitCodes.map((c) => c.toUpperCase().trim())
    );

    // Super-compact pipe-delimited catalog (omits repetitive JSON keys & rationales)
    const catalogLines = candidateModules.map((m) => {
      const refs = (m.references || [])
        .slice(0, 3)
        .map((r) => {
          const code = (r.unitCode || '').toUpperCase().trim();
          const doneTag = completedUnitSet.has(code) ? '!' : '';
          const notesTag = quickNotesSet.has(code) ? '*' : '';
          return `G${r.grade}U${r.unitNumber}${doneTag}${notesTag}`;
        })
        .join(',');
      return `${m.moduleId}|${m.phase}|${m.title}|${refs}`;
    });

    const weakUnitsCompact = weakAssessmentUnits
      .slice(0, 6)
      .map((w) => `${w.unitCode}:${w.bestPercentage}%`)
      .join(',');

    const prompt = [
      `Student: G${grade} ${stream}, tier=${calibration.tierId}, target=${calibration.targetScore}, weak=${calibration.weakSubjectCodes.join(',')}, ${calibration.dailyMinutes}m ${calibration.peakWindow}, stage=${calibration.prepStageId}${weakUnitsCompact ? `, lowScores=[${weakUnitsCompact}]` : ''}`,
      'Catalog (id|phase|title|refs; !=done *=QuickNotes):',
      ...catalogLines,
    ].join('\n');

    const systemInstruction = this.buildCompactSystemInstruction(stream);
    const models = this.getCandidateModels();
    const now = Date.now();

    for (const model of models) {
      const cooldownUntil = this.modelCooldownUntil.get(model) ?? 0;
      if (now < cooldownUntil) {
        logger.debug(
          { model, remainingSec: Math.ceil((cooldownUntil - now) / 1000) },
          'Skipping Gemini model in rate-limit cooldown'
        );
        continue;
      }

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 16000);

      try {
        const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(env.GEMINI_API_KEY!)}`;

        const generationConfig: Record<string, unknown> = {
          temperature: 0.3,
          maxOutputTokens: 380,
          responseMimeType: 'application/json',
          responseSchema: {
            type: 'OBJECT',
            properties: {
              diagnosticSummary: { type: 'STRING' },
              recommendedModules: {
                type: 'ARRAY',
                items: {
                  type: 'OBJECT',
                  properties: {
                    moduleId: { type: 'STRING' },
                    coachingNote: { type: 'STRING' },
                  },
                  required: ['moduleId', 'coachingNote'],
                },
              },
            },
            required: ['diagnosticSummary', 'recommendedModules'],
          },
        };

        // Disable thinking tokens on Gemini 2.5 Flash/Lite models to avoid wasting TPM quota
        if (model.toLowerCase().startsWith('gemini-2.5')) {
          generationConfig.thinkingConfig = {
            thinkingBudget: env.GEMINI_THINKING_BUDGET,
          };
        }

        const response = await fetch(endpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          signal: controller.signal,
          body: JSON.stringify({
            systemInstruction: {
              parts: [{ text: systemInstruction }],
            },
            contents: [{ role: 'user', parts: [{ text: prompt }] }],
            generationConfig,
          }),
        });

        if (!response.ok) {
          const errBody = await response.text();
          if (response.status === 429) {
            const isDailyQuota = /per\s*day|PerDay|daily|RPD/i.test(errBody);
            const cooldownMs = isDailyQuota
              ? DAILY_QUOTA_COOLDOWN_MS
              : BURST_LIMIT_COOLDOWN_MS;
            this.modelCooldownUntil.set(model, Date.now() + cooldownMs);
            logger.warn(
              { model, status: 429, isDailyQuota, cooldownMs },
              'Gemini model rate-limited; switching to fallback model'
            );
            continue;
          }

          if (response.status === 404 || response.status === 400) {
            this.modelCooldownUntil.set(model, Date.now() + UNSUPPORTED_MODEL_COOLDOWN_MS);
          }

          logger.warn(
            { model, status: response.status, errBody: errBody.slice(0, 250) },
            'Gemini model failed; trying next fallback'
          );
          continue;
        }

        const json = (await response.json()) as any;
        const text = json?.candidates?.[0]?.content?.parts?.[0]?.text;
        if (!text) {
          logger.warn({ model }, 'Gemini returned empty candidate text; trying next fallback');
          continue;
        }

        const parsed = JSON.parse(text) as GeminiRawResponse;
        ContentCacheService.set(cacheKey, parsed, AI_PLAN_CACHE_TTL_SECONDS);
        return parsed;
      } catch (err: any) {
        logger.warn(
          { model, err: err?.message },
          'Gemini request error; trying next fallback model'
        );
      } finally {
        clearTimeout(timeoutId);
      }
    }

    return null;
  }

  private static buildDeterministicOutput(params: {
    stream: StudentStream;
    grade?: number;
    calibration: AiCalibrationInput;
    allocations: AiSubjectAllocation[];
    modulesBySubject: Map<string, ITopicModuleDocument[]>;
    completedModuleIds: string[];
    weakAssessmentUnits?: Array<{ unitCode: string; bestPercentage: number }>;
    projectedScore: number;
  }): AiStudyProgram {
    const {
      stream,
      grade = 12,
      calibration,
      allocations,
      modulesBySubject,
      completedModuleIds,
      weakAssessmentUnits = [],
      projectedScore,
    } = params;

    const completedSet = new Set(completedModuleIds);
    const weakUnitSet = new Set(
      weakAssessmentUnits.map((w) => w.unitCode.toUpperCase().trim())
    );
    const streamLabel = stream === 'social' ? 'Social Science' : 'Natural Science';
    const weakNames = allocations
      .filter((a) => a.priorityRank !== null)
      .map((a) => a.subjectName);

    const weakText =
      weakNames.length === 1
        ? weakNames[0]
        : weakNames.length === 2
          ? `${weakNames[0]} and ${weakNames[1]}`
          : weakNames.length >= 3
            ? `${weakNames[0]}, ${weakNames[1]}, and ${weakNames[2]}`
            : 'priority subjects';

    const prepLabel =
      calibration.prepStageId === 'starting'
        ? 'concept-first foundation'
        : calibration.prepStageId === 'sprint'
          ? 'high-yield checkpoint sprint'
          : 'balanced cross-grade review';

    const diagnosticSummary =
      `Tailored for your Grade ${grade} ${streamLabel} track with priority cross-grade blocks on ${weakText}. ` +
      `Your ${calibration.dailyMinutes} min ${calibration.peakWindow.toLowerCase()} routine follows a ${prepLabel} sequence from Grades 9–12.`;

    const modulePriorityBySubject: Record<string, string[]> = {};
    for (const [code, mods] of modulesBySubject.entries()) {
      // Deterministically order: weak-assessment incomplete -> other incomplete -> completed
      const prioritized = mods.slice().sort((a, b) => {
        const aDone = completedSet.has(a.moduleId);
        const bDone = completedSet.has(b.moduleId);
        if (aDone !== bDone) return aDone ? 1 : -1;

        const aWeak = (a.references || []).some((r) =>
          weakUnitSet.has((r.unitCode || '').toUpperCase().trim())
        );
        const bWeak = (b.references || []).some((r) =>
          weakUnitSet.has((r.unitCode || '').toUpperCase().trim())
        );
        if (aWeak !== bWeak) return aWeak ? -1 : 1;

        return a.moduleNumber - b.moduleNumber;
      });
      modulePriorityBySubject[code] = prioritized.map((m) => m.moduleId);
    }

    const dailyFocusTasks: AiDailyTaskItem[] = [];
    const blockMinutes = Math.max(20, Math.round(calibration.dailyMinutes / 4));

    // Pick top prioritized incomplete module from each priority subject first, then remaining subjects
    for (const alloc of allocations) {
      if (dailyFocusTasks.length >= 4) break;
      const subjectMods = modulesBySubject.get(alloc.subjectCode) || [];
      if (subjectMods.length === 0) continue;

      const prioritizedIds = modulePriorityBySubject[alloc.subjectCode] || [];
      const topId = prioritizedIds[0];
      const nextMod =
        subjectMods.find((m) => m.moduleId === topId) ||
        subjectMods.find((m) => !completedSet.has(m.moduleId)) ||
        subjectMods[0];

      dailyFocusTasks.push({
        id: `ai-task-${nextMod.moduleId}`,
        moduleId: nextMod.moduleId,
        subjectCode: nextMod.subjectCode,
        subjectName: nextMod.subjectName,
        title: `Module ${nextMod.moduleNumber}: ${nextMod.title}`,
        durationMinutes: alloc.priorityRank
          ? blockMinutes + 5
          : Math.max(15, blockMinutes - 5),
        priorityTag: alloc.priorityRank
          ? `Priority #${alloc.priorityRank}`
          : 'Core Rotation',
        whereToRead: this.formatWhereToRead(nextMod),
        coachingNote: nextMod.rationale
          ? nextMod.rationale.slice(0, 140)
          : `Unifies key ${nextMod.subjectName} concepts across grades.`,
      });
    }

    return {
      calibration,
      stream,
      projectedScore,
      diagnosticSummary,
      subjectAllocations: allocations,
      dailyFocusTasks,
      modulePriorityBySubject,
      generatedBy: 'deterministic',
      generatedAt: new Date().toISOString(),
    };
  }
}
