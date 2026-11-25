import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../models/ai_study_models.dart';

/// Phase 2: Active Cross-Grade AI Topic Study Workspace.
///
/// Renders:
/// - Gemini Study Program Summary Banner (projected score, pace, coaching note, Recalibrate CTA)
/// - Priority-ordered Subject Rail starting from real 0%..100% database mastery
/// - Cross-grade Topic Modules grouped by Phase with sequential numbering and
///   interactive "Where to Read" textbook page chips
class AiTopicWorkspaceView extends StatelessWidget {
  final AiTopicProgramOverview overview;
  final String selectedSubjectCode;
  final List<TopicModuleItem> modules;
  final bool isLoadingModules;
  final String? modulesError;
  final ValueChanged<String> onSelectSubject;
  final VoidCallback? onRetryLoadModules;
  final ValueChanged<AiDailyTaskItem>? onOpenDailyTask;
  final ValueChanged<TopicModuleItem> onOpenModule;
  final VoidCallback onRecalibrate;

  const AiTopicWorkspaceView({
    super.key,
    required this.overview,
    required this.selectedSubjectCode,
    required this.modules,
    required this.isLoadingModules,
    this.modulesError,
    required this.onSelectSubject,
    this.onRetryLoadModules,
    this.onOpenDailyTask,
    required this.onOpenModule,
    required this.onRecalibrate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final onAccent = isDark ? AppColors.onAccentDark : AppColors.onAccentLight;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final raised = isDark ? AppColors.darkRaised : AppColors.lightRaised;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final program = overview.program;
    final summaries = overview.subjectSummaries;

    // Order modules grouped by phase while preserving sequential moduleNumber order
    final sortedModules = List<TopicModuleItem>.from(modules)
      ..sort((a, b) => a.moduleNumber.compareTo(b.moduleNumber));

    final phasesOrder = <String>[];
    final groupedByPhase = <String, List<TopicModuleItem>>{};
    for (final mod in sortedModules) {
      groupedByPhase.putIfAbsent(mod.phase, () {
        phasesOrder.add(mod.phase);
        return [];
      }).add(mod);
    }

    final selectedSummary = summaries.firstWhere(
      (s) => s.subjectCode.toUpperCase() == selectedSubjectCode.toUpperCase(),
      orElse: () => summaries.isNotEmpty
          ? summaries.first
          : AiTopicSubjectSummary(
              subjectCode: selectedSubjectCode,
              subjectName: selectedSubjectCode,
              totalModules: sortedModules.length,
              completedModules: 0,
              masteryPercentage: 0,
              hasTopicBank: true,
            ),
    );

    final nextSuggestedTask = program != null && program.dailyFocusTasks.isNotEmpty
        ? program.dailyFocusTasks.firstWhere(
            (t) => t.subjectCode.toUpperCase() == selectedSubjectCode.toUpperCase(),
            orElse: () => program.dailyFocusTasks.first,
          )
        : null;

    final recommendedModuleIds = <String>{
      if (program != null)
        ...program.dailyFocusTasks.map((t) => t.moduleId.toUpperCase()),
      if (program != null)
        ...(program.modulePriorityBySubject[selectedSubjectCode.toUpperCase()] ??
                const <String>[])
            .take(1)
            .map((id) => id.toUpperCase()),
    };

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 132),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Gemini AI Program Summary Banner
          if (program != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: accent.withValues(alpha: 0.28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedAiSparkles,
                                color: onAccent,
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'TARGET ${program.calibration.targetScore} • ${program.calibration.dailyMinutes}M ${program.calibration.peakWindow.toUpperCase()}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: onAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AcedexBounceable(
                        onTap: onRecalibrate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: raised,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: line),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: overview.canGenerateToday
                                    ? HugeIcons.strokeRoundedRefresh
                                    : HugeIcons.strokeRoundedClock01,
                                color: accent,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                overview.canGenerateToday ? 'Recalibrate' : '1/Day Used',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    program.diagnosticSummary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.42,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (nextSuggestedTask != null) ...[
                    const SizedBox(height: 10),
                    AcedexBounceable(
                      onTap: onOpenDailyTask != null
                          ? () => onOpenDailyTask!(nextSuggestedTask)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: raised,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: line),
                        ),
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedTarget01,
                              color: accent,
                              size: 14,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                'Today: ${nextSuggestedTask.title} (${nextSuggestedTask.durationMinutes}m)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (onOpenDailyTask != null) ...[
                              const SizedBox(width: 6),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowRight01,
                                color: accent,
                                size: 14,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 2. Priority-Ordered Subject Pill Rail
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: summaries.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final s = summaries[idx];
                final active =
                    s.subjectCode.toUpperCase() == selectedSubjectCode.toUpperCase();

                return AcedexBounceable(
                  onTap: () => onSelectSubject(s.subjectCode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: active ? accent : surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: active ? accent : line),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s.priorityRank != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? onAccent.withValues(alpha: 0.22)
                                  : accentSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '#${s.priorityRank}',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: active ? onAccent : accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        HugeIcon(
                          icon: AiStudyPresets.iconForSubjectCode(s.subjectCode),
                          color: active ? onAccent : theme.colorScheme.onSurface,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          s.subjectName,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: active ? onAccent : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${s.masteryPercentage}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: active ? onAccent.withValues(alpha: 0.9) : accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // 3. Selected Subject Mastery Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${selectedSummary.subjectName} Cross-Grade Map',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${selectedSummary.completedModules}/${selectedSummary.totalModules} modules mastered (${selectedSummary.masteryPercentage}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subtext,
                      ),
                    ),
                  ],
                ),
              ),
              AcedexBadge(
                label: 'G9–12 Sequential',
                variant: AcedexBadgeVariant.neutral,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 4. Module List or Loading State
          if (isLoadingModules && sortedModules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: AcedexSkeletonList(itemCount: 4),
            )
          else if (modulesError != null && sortedModules.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: line),
              ),
              child: Column(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedWifiDisconnected01,
                    color: AppColors.error,
                    size: 28,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    modulesError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (onRetryLoadModules != null) ...[
                    const SizedBox(height: 12),
                    AcedexButton(
                      label: 'Retry Loading Topics',
                      variant: AcedexButtonVariant.soft,
                      size: AcedexButtonSize.sm,
                      leadingIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedRefresh,
                        color: accent,
                        size: 14,
                      ),
                      onPressed: onRetryLoadModules,
                    ),
                  ],
                ],
              ),
            )
          else if (sortedModules.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: line),
              ),
              child: Column(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedBookOpen01,
                    color: subtext,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No topic modules found for ${selectedSummary.subjectName} yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: subtext),
                  ),
                ],
              ),
            )
          else
            ...phasesOrder.map((phase) {
              final phaseModules = groupedByPhase[phase]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 8),
                    child: Text(
                      phase.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: accent,
                      ),
                    ),
                  ),
                  ...phaseModules.map((mod) {
                    return _TopicModuleCard(
                      module: mod,
                      isAiFocus:
                          recommendedModuleIds.contains(mod.moduleId.toUpperCase()),
                      accent: accent,
                      accentSoft: accentSoft,
                      onAccent: onAccent,
                      surface: surface,
                      raised: raised,
                      line: line,
                      subtext: subtext,
                      onTap: () => onOpenModule(mod),
                    );
                  }),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _TopicModuleCard extends StatelessWidget {
  final TopicModuleItem module;
  final bool isAiFocus;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color surface;
  final Color raised;
  final Color line;
  final Color subtext;
  final VoidCallback onTap;

  const _TopicModuleCard({
    required this.module,
    this.isAiFocus = false,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.surface,
    required this.raised,
    required this.line,
    required this.subtext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSteps = module.sequence.length;
    final doneSteps = module.completedSteps.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AcedexBounceable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: module.isCompleted ? AppColors.success.withValues(alpha: 0.45) : line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: module.isCompleted
                          ? AppColors.success.withValues(alpha: 0.16)
                          : accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: module.isCompleted
                        ? HugeIcon(
                            icon: HugeIcons.strokeRoundedTick02,
                            color: AppColors.success,
                            size: 16,
                          )
                        : Text(
                            'M${module.moduleNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$doneSteps/$totalSteps steps • ${module.progressPercentage}% mastered',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: module.isCompleted ? AppColors.success : subtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isAiFocus) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedAiSparkles,
                            color: accent,
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'AI Focus',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    color: subtext,
                    size: 16,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Mastery Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 5,
                  color: raised,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (module.progressPercentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      color: module.isCompleted ? AppColors.success : accent,
                    ),
                  ),
                ),
              ),

              if (module.references.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: module.references.take(4).map((ref) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: raised,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ref.hasQuickNotes) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            ref.shortChipLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
