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

export class GeminiPlannerService {
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
      calibration,
      allocations,
      modulesBySubject,
      completedModuleIds,
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

      // Validate per-subject module ordering against existing moduleIds
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

  private static readonly ACEDEX_SYSTEM_INSTRUCTION = `
You are ACEDEX AI — the official Ethiopian Ministry of Education (MoE) Grades 9–12 & EUEE Cross-Grade Study Advisor.

CORE MISSION:
Help Ethiopian high school students master subjects by thematic TOPIC MODULES spanning Grades 9–12 instead of fragmented grade-by-grade studying.

CURRICULUM & EXAM DOMAIN KNOWLEDGE:
- EUEE (Ethiopian University Entrance Examination) is scored out of 600 points (6 subjects x 100 pts):
  - Natural Science: Physics (PHY), Chemistry (CHE), Biology (BIO), Mathematics (MAT), English (ENG), Aptitude (APT).
  - Social Science: Economics (ECO), Geography (GEO), History (HIS), Mathematics (MAT), English (ENG), Aptitude (APT).
- Score Tiers: 420+ Solid Pass | 480+ Competitive Track (Engineering/Pharmacy) | 540+ Top 2% Merit (Medicine/AAU Honors).
- Preparation Stages:
  - "starting": Student is building fundamentals. Start from early Module 1–3 prerequisites and emphasize textbook concept reading.
  - "reviewing": Student knows basics and needs cross-grade consolidation. Bridge G9/G10 basics directly into G11/G12 modules (M03–M07).
  - "sprint": High-yield EUEE exam sprint. Prioritize Grade 11–12 synthesis modules, problem-solving, and Mastery Checkpoints.

HOW TO COLLABORATE WITH THE TOPIC BANK & STUDENT PROGRESS:
1. Check the student's "weakSubjectCodes" (#1, #2, #3). Your 4 "recommendedModules" MUST prioritize those weak subjects first, while including 1 foundational/rotation module if helpful.
2. Check "completedUnitCodes" (units already finished in Tab 1) and "completedModuleIds". Skip completed modules; if a student already finished an early unit inside a module (e.g., MAT-G09-U01), mention it in coachingNote and point them to the next unread Grade/Unit/Pages in that module!
3. Check "weakAssessmentUnits" (units where student scored < 65%). If a unit appears there, prioritize the topic module containing that unit so they fix the underlying concept gap.
4. Check "hasQuickNotes" on references. When a referenced unit has ACEDEX Quick Notes available, tell the student they can read the Quick Notes right inside ACEDEX alongside the MoE textbook pages.
5. Respect "registeredGrade": For Grade 9–11 students, keep focus anchored to modules up to their grade before pushing Grade 12 modules unless prerequisites are satisfied. For Grade 12, span the full G9–G12 EUEE pipeline.
6. STRICT GROUNDING: ONLY select moduleIds verbatim from "topicCatalog". Never invent module IDs, unit codes, or page numbers.

OUTPUT STYLE & FEW-SHOT EXAMPLES:
- diagnosticSummary (exactly 2 crisp, encouraging sentences):
  Example: "Built for your Grade 12 Natural Science 480+ goal, putting priority hours on Physics and Chemistry while reinforcing Calculus prerequisites. Your 90 min Morning blocks pair concept notes with targeted cross-grade drills so every session closes real EUEE gaps."
- coachingNote (1 actionable sentence per recommended module referencing where to start reading):
  Example: "Bridge Grade 9 vectors into 3D dot/cross products using G11 U2 (pp. 17–46), fixing foundation gaps before Kinematics."
  Example: "You finished G9 Unit 1 sets—continue straight to G9 U2 (pp. 27–104) to lock in exponent laws and radicals."
`.trim();

  private static async callGeminiWithTopicCatalog(params: {
    stream: StudentStream;
    grade: number;
    calibration: AiCalibrationInput;
    modules: ITopicModuleDocument[];
    completedUnitCodes: string[];
    weakAssessmentUnits: Array<{ unitCode: string; bestPercentage: number }>;
    quickNotesUnitCodes: string[];
    completedModuleIds: string[];
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
    } = params;

    const quickNotesSet = new Set(quickNotesUnitCodes);

    const compactCatalog = modules.map((m) => ({
      moduleId: m.moduleId,
      subjectCode: m.subjectCode,
      moduleNumber: m.moduleNumber,
      phase: m.phase,
      title: m.title,
      rationale: m.rationale.slice(0, 160),
      prerequisites: m.prerequisites.slice(0, 3),
      references: (m.references || []).map((r) => ({
        grade: r.grade,
        unitCode: r.unitCode,
        pages: r.pages,
        hasQuickNotes: quickNotesSet.has(r.unitCode),
      })),
    }));

    const prompt = [
      'Generate the personalized ACEDEX AI Study Blueprint JSON for this student using the grounded topicCatalog below.',
      '',
      `Student Profile & Live Progress: ${JSON.stringify({
        registeredGrade: grade,
        stream,
        targetScore: calibration.targetScore,
        tierId: calibration.tierId,
        weakSubjectCodes: calibration.weakSubjectCodes,
        dailyMinutes: calibration.dailyMinutes,
        peakWindow: calibration.peakWindow,
        prepStageId: calibration.prepStageId,
        completedUnitCodes: completedUnitCodes.slice(0, 25),
        weakAssessmentUnits,
        completedModuleIds,
      })}`,
      '',
      `topicCatalog: ${JSON.stringify(compactCatalog)}`,
    ].join('\n');

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 18000);

    try {
      const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(env.GEMINI_MODEL)}:generateContent?key=${encodeURIComponent(env.GEMINI_API_KEY!)}`;
      const requestBody = JSON.stringify({
        systemInstruction: {
          parts: [{ text: this.ACEDEX_SYSTEM_INSTRUCTION }],
        },
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.35,
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
              subjectModuleOrdering: {
                type: 'ARRAY',
                items: {
                  type: 'OBJECT',
                  properties: {
                    subjectCode: { type: 'STRING' },
                    orderedModuleIds: {
                      type: 'ARRAY',
                      items: { type: 'STRING' },
                    },
                  },
                  required: ['subjectCode', 'orderedModuleIds'],
                },
              },
            },
            required: ['diagnosticSummary', 'recommendedModules'],
          },
        },
      });

      let response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        signal: controller.signal,
        body: requestBody,
      });

      // Retry once briefly on transient 503/429 load spikes
      if (response.status === 503 || response.status === 429) {
        await new Promise((resolve) => setTimeout(resolve, 900));
        response = await fetch(endpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          signal: controller.signal,
          body: requestBody,
        });
      }

      if (!response.ok) {
        const errBody = await response.text();
        logger.warn(
          { status: response.status, errBody: errBody.slice(0, 300) },
          'Gemini API returned non-OK status'
        );
        return null;
      }

      const json = (await response.json()) as any;
      const text = json?.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!text) return null;

      return JSON.parse(text) as GeminiRawResponse;
    } finally {
      clearTimeout(timeoutId);
    }
  }

  private static buildDeterministicOutput(params: {
    stream: StudentStream;
    calibration: AiCalibrationInput;
    allocations: AiSubjectAllocation[];
    modulesBySubject: Map<string, ITopicModuleDocument[]>;
    completedModuleIds: string[];
    projectedScore: number;
  }): AiStudyProgram {
    const {
      stream,
      calibration,
      allocations,
      modulesBySubject,
      completedModuleIds,
      projectedScore,
    } = params;

    const completedSet = new Set(completedModuleIds);
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
      `Tailored for your Grade 12 ${streamLabel} track with priority cross-grade blocks on ${weakText}. ` +
      `Your ${calibration.dailyMinutes} min ${calibration.peakWindow.toLowerCase()} routine follows a ${prepLabel} sequence from Grades 9–12.`;

    const modulePriorityBySubject: Record<string, string[]> = {};
    for (const [code, mods] of modulesBySubject.entries()) {
      modulePriorityBySubject[code] = mods.map((m) => m.moduleId);
    }

    const dailyFocusTasks: AiDailyTaskItem[] = [];
    const blockMinutes = Math.max(20, Math.round(calibration.dailyMinutes / 4));

    // Pick next incomplete module from each priority subject first, then remaining subjects
    for (const alloc of allocations) {
      if (dailyFocusTasks.length >= 4) break;
      const subjectMods = modulesBySubject.get(alloc.subjectCode) || [];
      if (subjectMods.length === 0) continue;

      const nextMod =
        subjectMods.find((m) => !completedSet.has(m.moduleId)) || subjectMods[0];

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
