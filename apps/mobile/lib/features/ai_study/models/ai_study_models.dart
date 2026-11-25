import 'package:flutter/foundation.dart';
import 'package:hugeicons/hugeicons.dart';

/// Textbook reading reference linking a cross-grade module to a Grade/Unit & page range.
@immutable
class TopicReadingReference {
  final int grade;
  final int unitNumber;
  final String unitCode;
  final String unitTitle;
  final String pages;
  final bool hasQuickNotes;

  const TopicReadingReference({
    required this.grade,
    required this.unitNumber,
    required this.unitCode,
    required this.unitTitle,
    required this.pages,
    this.hasQuickNotes = false,
  });

  factory TopicReadingReference.fromJson(Map<String, dynamic> json) {
    return TopicReadingReference(
      grade: (json['grade'] as num?)?.toInt() ?? 9,
      unitNumber: (json['unitNumber'] as num?)?.toInt() ?? 1,
      unitCode: json['unitCode'] as String? ?? '',
      unitTitle: json['unitTitle'] as String? ?? 'Unit',
      pages: json['pages'] as String? ?? 'Full Unit',
      hasQuickNotes: json['hasQuickNotes'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'grade': grade,
        'unitNumber': unitNumber,
        'unitCode': unitCode,
        'unitTitle': unitTitle,
        'pages': pages,
        'hasQuickNotes': hasQuickNotes,
      };

  String get shortChipLabel => 'G$grade U$unitNumber • $pages';
}

/// Interactive step inside a cross-grade topic module sequence.
@immutable
class TopicLearningStep {
  final int stepNumber;
  final String text;
  final int? grade;
  final int? unitNumber;
  final String? unitCode;
  final String? pages;

  const TopicLearningStep({
    required this.stepNumber,
    required this.text,
    this.grade,
    this.unitNumber,
    this.unitCode,
    this.pages,
  });

  factory TopicLearningStep.fromJson(Map<String, dynamic> json) {
    return TopicLearningStep(
      stepNumber: (json['stepNumber'] as num?)?.toInt() ?? 1,
      text: json['text'] as String? ?? '',
      grade: (json['grade'] as num?)?.toInt(),
      unitNumber: (json['unitNumber'] as num?)?.toInt(),
      unitCode: json['unitCode'] as String?,
      pages: json['pages'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'text': text,
        if (grade != null) 'grade': grade,
        if (unitNumber != null) 'unitNumber': unitNumber,
        if (unitCode != null) 'unitCode': unitCode,
        if (pages != null) 'pages': pages,
      };
}

/// Full Cross-Grade Topic Module item with 0%..100% real user mastery.
@immutable
class TopicModuleItem {
  final String moduleId;
  final String subjectCode;
  final String subjectName;
  final String streamCategory;
  final int moduleNumber;
  final String phase;
  final String title;
  final String rationale;
  final List<TopicReadingReference> references;
  final List<TopicLearningStep> sequence;
  final List<String> prerequisites;
  final String masteryCheckpoint;
  final List<int> completedSteps;
  final bool isCompleted;
  final int progressPercentage;

  const TopicModuleItem({
    required this.moduleId,
    required this.subjectCode,
    required this.subjectName,
    required this.streamCategory,
    required this.moduleNumber,
    required this.phase,
    required this.title,
    required this.rationale,
    required this.references,
    required this.sequence,
    required this.prerequisites,
    required this.masteryCheckpoint,
    required this.completedSteps,
    required this.isCompleted,
    required this.progressPercentage,
  });

  factory TopicModuleItem.fromJson(Map<String, dynamic> json) {
    return TopicModuleItem(
      moduleId: json['moduleId'] as String? ?? '',
      subjectCode: json['subjectCode'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      streamCategory: json['streamCategory'] as String? ?? 'common',
      moduleNumber: (json['moduleNumber'] as num?)?.toInt() ?? 1,
      phase: json['phase'] as String? ?? 'Core Mastery',
      title: json['title'] as String? ?? '',
      rationale: json['rationale'] as String? ?? '',
      references: (json['references'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TopicReadingReference.fromJson)
          .toList(),
      sequence: (json['sequence'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TopicLearningStep.fromJson)
          .toList(),
      prerequisites: (json['prerequisites'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      masteryCheckpoint: json['masteryCheckpoint'] as String? ?? '',
      completedSteps: (json['completedSteps'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'moduleId': moduleId,
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'streamCategory': streamCategory,
        'moduleNumber': moduleNumber,
        'phase': phase,
        'title': title,
        'rationale': rationale,
        'references': references.map((r) => r.toJson()).toList(),
        'sequence': sequence.map((s) => s.toJson()).toList(),
        'prerequisites': prerequisites,
        'masteryCheckpoint': masteryCheckpoint,
        'completedSteps': completedSteps,
        'isCompleted': isCompleted,
        'progressPercentage': progressPercentage,
      };

  TopicModuleItem copyWith({
    List<int>? completedSteps,
    bool? isCompleted,
    int? progressPercentage,
  }) {
    return TopicModuleItem(
      moduleId: moduleId,
      subjectCode: subjectCode,
      subjectName: subjectName,
      streamCategory: streamCategory,
      moduleNumber: moduleNumber,
      phase: phase,
      title: title,
      rationale: rationale,
      references: references,
      sequence: sequence,
      prerequisites: prerequisites,
      masteryCheckpoint: masteryCheckpoint,
      completedSteps: completedSteps ?? this.completedSteps,
      isCompleted: isCompleted ?? this.isCompleted,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}

@immutable
class AiCalibrationInput {
  final String tierId; // 'solid' | 'competitive' | 'merit'
  final int targetScore; // 400..600
  final List<String> weakSubjectCodes; // 1..3 ordered codes
  final int dailyMinutes;
  final String peakWindow; // 'Morning' | 'Afternoon' | 'Night'
  final String prepStageId; // 'starting' | 'reviewing' | 'sprint'

  const AiCalibrationInput({
    required this.tierId,
    required this.targetScore,
    required this.weakSubjectCodes,
    required this.dailyMinutes,
    required this.peakWindow,
    required this.prepStageId,
  });

  factory AiCalibrationInput.fromJson(Map<String, dynamic> json) {
    return AiCalibrationInput(
      tierId: json['tierId'] as String? ?? 'competitive',
      targetScore: (json['targetScore'] as num?)?.toInt() ?? 485,
      weakSubjectCodes: (json['weakSubjectCodes'] as List<dynamic>? ?? [])
          .map((e) => e.toString().toUpperCase())
          .toList(),
      dailyMinutes: (json['dailyMinutes'] as num?)?.toInt() ?? 90,
      peakWindow: json['peakWindow'] as String? ?? 'Morning',
      prepStageId: json['prepStageId'] as String? ?? 'reviewing',
    );
  }

  Map<String, dynamic> toJson({String? adSessionId}) => {
        'tierId': tierId,
        'targetScore': targetScore,
        'weakSubjectCodes': weakSubjectCodes,
        'dailyMinutes': dailyMinutes,
        'peakWindow': peakWindow,
        'prepStageId': prepStageId,
        if (adSessionId != null && adSessionId.isNotEmpty) 'adSessionId': adSessionId,
      };
}

@immutable
class AiSubjectAllocation {
  final String subjectCode;
  final String subjectName;
  final int? priorityRank;
  final int weeklyMinutes;
  final int sharePercentage;

  const AiSubjectAllocation({
    required this.subjectCode,
    required this.subjectName,
    this.priorityRank,
    required this.weeklyMinutes,
    required this.sharePercentage,
  });

  factory AiSubjectAllocation.fromJson(Map<String, dynamic> json) {
    return AiSubjectAllocation(
      subjectCode: json['subjectCode'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      priorityRank: (json['priorityRank'] as num?)?.toInt(),
      weeklyMinutes: (json['weeklyMinutes'] as num?)?.toInt() ?? 60,
      sharePercentage: (json['sharePercentage'] as num?)?.toInt() ?? 20,
    );
  }

  Map<String, dynamic> toJson() => {
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'priorityRank': priorityRank,
        'weeklyMinutes': weeklyMinutes,
        'sharePercentage': sharePercentage,
      };

  String get formattedWeeklyHours {
    if (weeklyMinutes >= 60) {
      return '${(weeklyMinutes / 60).toStringAsFixed(1)}h';
    }
    return '${weeklyMinutes}m';
  }
}

@immutable
class AiDailyTaskItem {
  final String id;
  final String moduleId;
  final String subjectCode;
  final String subjectName;
  final String title;
  final int durationMinutes;
  final String priorityTag;
  final String whereToRead;
  final String? coachingNote;

  const AiDailyTaskItem({
    required this.id,
    required this.moduleId,
    required this.subjectCode,
    required this.subjectName,
    required this.title,
    required this.durationMinutes,
    required this.priorityTag,
    required this.whereToRead,
    this.coachingNote,
  });

  factory AiDailyTaskItem.fromJson(Map<String, dynamic> json) {
    return AiDailyTaskItem(
      id: json['id'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? '',
      subjectCode: json['subjectCode'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 25,
      priorityTag: json['priorityTag'] as String? ?? 'Core Focus',
      whereToRead: json['whereToRead'] as String? ?? '',
      coachingNote: json['coachingNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'title': title,
        'durationMinutes': durationMinutes,
        'priorityTag': priorityTag,
        'whereToRead': whereToRead,
        if (coachingNote != null) 'coachingNote': coachingNote,
      };
}

@immutable
class AiTopicSubjectSummary {
  final String subjectCode;
  final String subjectName;
  final int totalModules;
  final int completedModules;
  final int masteryPercentage;
  final int? priorityRank;
  final bool hasTopicBank;

  const AiTopicSubjectSummary({
    required this.subjectCode,
    required this.subjectName,
    required this.totalModules,
    required this.completedModules,
    required this.masteryPercentage,
    this.priorityRank,
    required this.hasTopicBank,
  });

  factory AiTopicSubjectSummary.fromJson(Map<String, dynamic> json) {
    return AiTopicSubjectSummary(
      subjectCode: json['subjectCode'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      totalModules: (json['totalModules'] as num?)?.toInt() ?? 0,
      completedModules: (json['completedModules'] as num?)?.toInt() ?? 0,
      masteryPercentage: (json['masteryPercentage'] as num?)?.toInt() ?? 0,
      priorityRank: (json['priorityRank'] as num?)?.toInt(),
      hasTopicBank: json['hasTopicBank'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'totalModules': totalModules,
        'completedModules': completedModules,
        'masteryPercentage': masteryPercentage,
        'priorityRank': priorityRank,
        'hasTopicBank': hasTopicBank,
      };
}

@immutable
class AiStudyProgram {
  final AiCalibrationInput calibration;
  final String stream;
  final int projectedScore;
  final String diagnosticSummary;
  final List<AiSubjectAllocation> subjectAllocations;
  final List<AiDailyTaskItem> dailyFocusTasks;
  final Map<String, List<String>> modulePriorityBySubject;
  final String generatedBy; // 'gemini' | 'deterministic'
  final String? generatedDate;
  final String generatedAt;

  const AiStudyProgram({
    required this.calibration,
    required this.stream,
    required this.projectedScore,
    required this.diagnosticSummary,
    required this.subjectAllocations,
    required this.dailyFocusTasks,
    required this.modulePriorityBySubject,
    required this.generatedBy,
    this.generatedDate,
    required this.generatedAt,
  });

  factory AiStudyProgram.fromJson(Map<String, dynamic> json) {
    final rawPriority = json['modulePriorityBySubject'] as Map<String, dynamic>? ?? {};
    final parsedPriority = <String, List<String>>{};
    rawPriority.forEach((key, value) {
      if (value is List) {
        parsedPriority[key] = value.map((e) => e.toString()).toList();
      }
    });

    return AiStudyProgram(
      calibration: AiCalibrationInput.fromJson(
        json['calibration'] as Map<String, dynamic>? ?? {},
      ),
      stream: json['stream'] as String? ?? 'natural',
      projectedScore: (json['projectedScore'] as num?)?.toInt() ?? 495,
      diagnosticSummary: json['diagnosticSummary'] as String? ?? '',
      subjectAllocations: (json['subjectAllocations'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AiSubjectAllocation.fromJson)
          .toList(),
      dailyFocusTasks: (json['dailyFocusTasks'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AiDailyTaskItem.fromJson)
          .toList(),
      modulePriorityBySubject: parsedPriority,
      generatedBy: json['generatedBy'] as String? ?? 'gemini',
      generatedDate: json['generatedDate'] as String?,
      generatedAt: json['generatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'calibration': calibration.toJson(),
        'stream': stream,
        'projectedScore': projectedScore,
        'diagnosticSummary': diagnosticSummary,
        'subjectAllocations': subjectAllocations.map((a) => a.toJson()).toList(),
        'dailyFocusTasks': dailyFocusTasks.map((t) => t.toJson()).toList(),
        'modulePriorityBySubject': modulePriorityBySubject,
        'generatedBy': generatedBy,
        if (generatedDate != null) 'generatedDate': generatedDate,
        'generatedAt': generatedAt,
      };
}

@immutable
class AiTopicProgramOverview {
  final bool hasProgram;
  final bool canGenerateToday;
  final String? nextAllowedAt;
  final bool requiresAd;
  final AiStudyProgram? program;
  final List<AiTopicSubjectSummary> subjectSummaries;

  const AiTopicProgramOverview({
    required this.hasProgram,
    required this.canGenerateToday,
    this.nextAllowedAt,
    required this.requiresAd,
    this.program,
    required this.subjectSummaries,
  });

  factory AiTopicProgramOverview.fromJson(Map<String, dynamic> json) {
    return AiTopicProgramOverview(
      hasProgram: json['hasProgram'] as bool? ?? false,
      canGenerateToday: json['canGenerateToday'] as bool? ?? true,
      nextAllowedAt:
          json['nextGenerationAt'] as String? ?? json['nextAllowedAt'] as String?,
      requiresAd: json['requiresAd'] as bool? ?? true,
      program: json['program'] is Map<String, dynamic>
          ? AiStudyProgram.fromJson(json['program'] as Map<String, dynamic>)
          : null,
      subjectSummaries: (json['subjectSummaries'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AiTopicSubjectSummary.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'hasProgram': hasProgram,
        'canGenerateToday': canGenerateToday,
        if (nextAllowedAt != null) 'nextAllowedAt': nextAllowedAt,
        'requiresAd': requiresAd,
        'program': program?.toJson(),
        'subjectSummaries': subjectSummaries.map((s) => s.toJson()).toList(),
      };
}

// =============================================================================
// UI Configuration Presets (Adapted from HTML Inspiration for ACEDEX Stream)
// =============================================================================

@immutable
class AiScoreTier {
  final String id;
  final String title;
  final String subtitle;
  final int defaultScore;
  final int minScore;
  final int maxScore;
  final bool recommended;

  const AiScoreTier({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.defaultScore,
    required this.minScore,
    required this.maxScore,
    this.recommended = false,
  });
}

@immutable
class AiStreamSubjectOption {
  final String code;
  final String name;
  final String subtitle;
  final List<List<dynamic>> icon;

  const AiStreamSubjectOption({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}

@immutable
class AiDailyBudgetOption {
  final String id;
  final String label;
  final String tag;
  final int dailyMinutes;
  final String weeklyLabel;

  const AiDailyBudgetOption({
    required this.id,
    required this.label,
    required this.tag,
    required this.dailyMinutes,
    required this.weeklyLabel,
  });
}

@immutable
class AiPeakWindowOption {
  final String id;
  final String label;
  final String hint;
  final List<List<dynamic>> icon;

  const AiPeakWindowOption({
    required this.id,
    required this.label,
    required this.hint,
    required this.icon,
  });
}

@immutable
class AiPrepStageOption {
  final String id;
  final String title;
  final String ratioText;
  final int notesPct;
  final int drillsPct;

  const AiPrepStageOption({
    required this.id,
    required this.title,
    required this.ratioText,
    required this.notesPct,
    required this.drillsPct,
  });
}

abstract class AiStudyPresets {
  static const List<AiScoreTier> scoreTiers = [
    AiScoreTier(
      id: 'solid',
      title: '420+ • Solid Pass',
      subtitle: 'Core cross-grade syllabus mastery & steady confidence',
      defaultScore: 425,
      minScore: 400,
      maxScore: 459,
    ),
    AiScoreTier(
      id: 'competitive',
      title: '480+ • Competitive Track',
      subtitle: 'Engineering, Pharmacy & top public programs',
      defaultScore: 485,
      minScore: 460,
      maxScore: 529,
      recommended: true,
    ),
    AiScoreTier(
      id: 'merit',
      title: '540+ • Top 2% Merit',
      subtitle: 'Medicine, AAU Honors & elite national merit tiers',
      defaultScore: 545,
      minScore: 530,
      maxScore: 600,
    ),
  ];

  static const List<AiDailyBudgetOption> dailyBudgets = [
    AiDailyBudgetOption(
      id: '45m',
      label: '45 min',
      tag: 'Light Review',
      dailyMinutes: 45,
      weeklyLabel: '5.3 hrs / wk',
    ),
    AiDailyBudgetOption(
      id: '1.5h',
      label: '1.5 hrs',
      tag: 'Balanced Growth',
      dailyMinutes: 90,
      weeklyLabel: '10.5 hrs / wk',
    ),
    AiDailyBudgetOption(
      id: '2.5h',
      label: '2.5 hrs',
      tag: 'Intensive Prep',
      dailyMinutes: 150,
      weeklyLabel: '17.5 hrs / wk',
    ),
    AiDailyBudgetOption(
      id: '4h',
      label: '4+ hrs',
      tag: 'Exam Sprint',
      dailyMinutes: 240,
      weeklyLabel: '28.0 hrs / wk',
    ),
  ];

  static const List<AiPeakWindowOption> peakWindows = [
    AiPeakWindowOption(
      id: 'Morning',
      label: 'Morning',
      hint: '06:00 – 09:30 AM • Peak analytical retention',
      icon: HugeIcons.strokeRoundedSun02,
    ),
    AiPeakWindowOption(
      id: 'Afternoon',
      label: 'Afternoon',
      hint: '02:00 – 05:30 PM • Post-school consolidation',
      icon: HugeIcons.strokeRoundedSunrise,
    ),
    AiPeakWindowOption(
      id: 'Night',
      label: 'Night',
      hint: '07:30 – 10:30 PM • Quiet deep-focus block',
      icon: HugeIcons.strokeRoundedMoon02,
    ),
  ];

  static const List<AiPrepStageOption> prepStages = [
    AiPrepStageOption(
      id: 'starting',
      title: 'Just Starting',
      ratioText: '70% Concept Notes • 30% Checkpoints',
      notesPct: 70,
      drillsPct: 30,
    ),
    AiPrepStageOption(
      id: 'reviewing',
      title: 'Reviewing Units',
      ratioText: '45% Concept Notes • 55% Checkpoints',
      notesPct: 45,
      drillsPct: 55,
    ),
    AiPrepStageOption(
      id: 'sprint',
      title: 'Exam Sprint',
      ratioText: '20% Formula Recap • 80% EUEE Topics',
      notesPct: 20,
      drillsPct: 80,
    ),
  ];

  static String normalizeStream(String? rawStream) {
    final normalized = (rawStream ?? 'natural').trim().toLowerCase();
    return normalized == 'social' ? 'social' : 'natural';
  }

  static String streamDisplayLabel(String? rawStream) {
    return normalizeStream(rawStream) == 'social' ? 'Social Science' : 'Natural Science';
  }

  static List<AiStreamSubjectOption> subjectsForStream(String? rawStream) {
    if (normalizeStream(rawStream) == 'social') {
      return const [
        AiStreamSubjectOption(
          code: 'HIS',
          name: 'History',
          subtitle: '10 Topic Modules • G9–12',
          icon: HugeIcons.strokeRoundedIdea01,
        ),
        AiStreamSubjectOption(
          code: 'GEO',
          name: 'Geography',
          subtitle: '10 Topic Modules • G9–12',
          icon: HugeIcons.strokeRoundedGlobe02,
        ),
        AiStreamSubjectOption(
          code: 'ECO',
          name: 'Economics',
          subtitle: '10 Topic Modules • G9–12',
          icon: HugeIcons.strokeRoundedChartHistogram,
        ),
        AiStreamSubjectOption(
          code: 'MAT',
          name: 'Mathematics',
          subtitle: '10 Topic Modules • G9–12',
          icon: HugeIcons.strokeRoundedCalculate,
        ),
        AiStreamSubjectOption(
          code: 'ENG',
          name: 'English',
          subtitle: '10 Topic Modules • G9–12',
          icon: HugeIcons.strokeRoundedBook02,
        ),
      ];
    }

    return const [
      AiStreamSubjectOption(
        code: 'PHY',
        name: 'Physics',
        subtitle: '10 Topic Modules • G9–12',
        icon: HugeIcons.strokeRoundedAtom01,
      ),
      AiStreamSubjectOption(
        code: 'MAT',
        name: 'Mathematics',
        subtitle: '10 Topic Modules • G9–12',
        icon: HugeIcons.strokeRoundedCalculate,
      ),
      AiStreamSubjectOption(
        code: 'CHE',
        name: 'Chemistry',
        subtitle: '10 Topic Modules • G9–12',
        icon: HugeIcons.strokeRoundedChemistry01,
      ),
      AiStreamSubjectOption(
        code: 'BIO',
        name: 'Biology',
        subtitle: '10 Topic Modules • G9–12',
        icon: HugeIcons.strokeRoundedDna,
      ),
      AiStreamSubjectOption(
        code: 'ENG',
        name: 'English',
        subtitle: '10 Topic Modules • G9–12',
        icon: HugeIcons.strokeRoundedBook02,
      ),
    ];
  }

  static List<List<dynamic>> iconForSubjectCode(String subjectCode) {
    switch (subjectCode.toUpperCase()) {
      case 'PHY':
        return HugeIcons.strokeRoundedAtom01;
      case 'MAT':
        return HugeIcons.strokeRoundedCalculate;
      case 'CHE':
        return HugeIcons.strokeRoundedChemistry01;
      case 'BIO':
        return HugeIcons.strokeRoundedDna;
      case 'ENG':
        return HugeIcons.strokeRoundedBook02;
      case 'GEO':
        return HugeIcons.strokeRoundedGlobe02;
      case 'ECO':
        return HugeIcons.strokeRoundedChartHistogram;
      case 'HIS':
        return HugeIcons.strokeRoundedIdea01;
      default:
        return HugeIcons.strokeRoundedBookOpen01;
    }
  }
}
