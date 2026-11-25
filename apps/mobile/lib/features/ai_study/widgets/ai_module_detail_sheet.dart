import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../../study/models/study_models.dart';
import '../../study/widgets/unit_quick_notes_sheet.dart';
import '../models/ai_study_models.dart';

/// Interactive Cross-Grade Module Detail Bottom Sheet.
///
/// Displays:
/// - "Why Study Together" cross-grade rationale
/// - "Where to Read" textbook citations (Grade / Official Unit Title / Page Range)
///   with shared Study-unit mastery checkmarks and direct [UnitQuickNotesSheet] launch
/// - Checkable Learning Sequence steps persisted via callback
/// - Mastery Checkpoint & "Mark Module Mastered" action
class AiModuleDetailSheet extends StatefulWidget {
  final TopicModuleItem module;
  final Future<TopicModuleItem?> Function(int stepNumber, bool completed)
  onToggleStep;
  final Future<TopicModuleItem?> Function(bool completed) onToggleMastered;
  final Future<TopicModuleItem?> Function(
    TopicReadingReference ref,
    bool completed,
  )?
  onToggleUnitMastery;

  const AiModuleDetailSheet({
    super.key,
    required this.module,
    required this.onToggleStep,
    required this.onToggleMastered,
    this.onToggleUnitMastery,
  });

  static Future<void> show(
    BuildContext context, {
    required TopicModuleItem module,
    required Future<TopicModuleItem?> Function(int stepNumber, bool completed)
    onToggleStep,
    required Future<TopicModuleItem?> Function(bool completed) onToggleMastered,
    Future<TopicModuleItem?> Function(
      TopicReadingReference ref,
      bool completed,
    )?
    onToggleUnitMastery,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiModuleDetailSheet(
        module: module,
        onToggleStep: onToggleStep,
        onToggleMastered: onToggleMastered,
        onToggleUnitMastery: onToggleUnitMastery,
      ),
    );
  }

  @override
  State<AiModuleDetailSheet> createState() => _AiModuleDetailSheetState();
}

class _AiModuleDetailSheetState extends State<AiModuleDetailSheet> {
  late TopicModuleItem _module;
  bool _saving = false;
  String? _savingUnitCode;

  @override
  void initState() {
    super.initState();
    _module = widget.module;
  }

  Future<void> _handleStepTap(int stepNumber) async {
    if (_saving) return;
    final currentlyDone = _module.completedSteps.contains(stepNumber);
    setState(() => _saving = true);
    final updated = await widget.onToggleStep(stepNumber, !currentlyDone);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (updated != null) {
        _module = updated;
      }
    });
  }

  Future<void> _handleMasteredTap() async {
    if (_saving) return;
    setState(() => _saving = true);
    final updated = await widget.onToggleMastered(!_module.isCompleted);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (updated != null) {
        _module = updated;
      }
    });
  }

  Future<void> _handleUnitMasteryTap(TopicReadingReference ref) async {
    final handler = widget.onToggleUnitMastery;
    if (handler == null || _saving || _savingUnitCode != null) return;
    final code = ref.unitCode.toUpperCase().trim();
    final isCurrentlyDone = ref.isUnitCompleted ||
        AuthStorage.instance.completedUnitsNotifier.value.contains(code);

    setState(() => _savingUnitCode = code);
    final updated = await handler(ref, !isCurrentlyDone);
    if (!mounted) return;
    setState(() {
      _savingUnitCode = null;
      if (updated != null) {
        _module = updated;
      } else {
        // Fallback local update in case callback didn't return full module
        final nextRefs = _module.references
            .map(
              (r) => r.unitCode.toUpperCase().trim() == code
                  ? r.copyWith(isUnitCompleted: !isCurrentlyDone)
                  : r,
            )
            .toList();
        _module = _module.copyWith(references: nextRefs);
      }
    });
  }

  void _openQuickNotes(TopicReadingReference ref, Color accent) {
    final unit = StudyUnit(
      id: ref.unitCode,
      code: 'U${ref.unitNumber}',
      title: ref.unitTitle,
      examWeight: ref.pages,
      expanded: true,
      topics: const [],
      unitCode: ref.unitCode,
    );
    final subject = SubjectCurriculum(
      id: _module.subjectCode.toLowerCase(),
      name: _module.subjectName,
      mastery: _module.progressPercentage,
      lastTopicId: _module.moduleId,
      iconData: AiStudyPresets.iconForSubjectCode(_module.subjectCode),
      color: accent,
      units: const [],
    );

    UnitQuickNotesSheet.show(
      context,
      unit: unit,
      subject: subject,
      primaryActionLabel: 'Done Reading Notes',
      onCompleteAndUnlockAssessment: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark
        ? AppColors.accentSoftDark
        : AppColors.accentSoftLight;
    final onAccent = isDark ? AppColors.onAccentDark : AppColors.onAccentLight;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final raised = isDark ? AppColors.darkRaised : AppColors.lightRaised;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4.5,
                decoration: BoxDecoration(
                  color: line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AcedexBadge(
                              label: 'MODULE ${_module.moduleNumber}',
                              variant: AcedexBadgeVariant.primary,
                            ),
                            AcedexBadge(
                              label: '${_module.progressPercentage}% Mastered',
                              variant: _module.isCompleted
                                  ? AcedexBadgeVariant.success
                                  : AcedexBadgeVariant.neutral,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _module.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_module.subjectName} • ${_module.phase}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: subtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AcedexBounceable(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: line),
                      ),
                      alignment: Alignment.center,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: subtext,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 16, color: line),

            // Scrollable Body
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Why Study Together
                    if (_module.rationale.isNotEmpty) ...[
                      Text(
                        'WHY STUDY TOGETHER',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: line),
                        ),
                        child: Text(
                          _module.rationale,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 2. Where to Read (Textbooks & Quick Notes)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'WHERE TO READ (TEXTBOOKS)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                              color: accent,
                            ),
                          ),
                        ),
                        if (_module.references.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ValueListenableBuilder<Set<String>>(
                            valueListenable:
                                AuthStorage.instance.completedUnitsNotifier,
                            builder: (_, completedSet, _) {
                              final masteredCount = _module.references.where((r) {
                                final code = r.unitCode.toUpperCase().trim();
                                return r.isUnitCompleted ||
                                    completedSet.contains(code);
                              }).length;
                              return Text(
                                '$masteredCount/${_module.references.length} units mastered',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: masteredCount ==
                                          _module.references.length
                                      ? AppColors.success
                                      : subtext,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_module.references.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: line),
                        ),
                        child: Text(
                          'Cross-grade ${_module.subjectName} textbook units.',
                          style: TextStyle(fontSize: 12, color: subtext),
                        ),
                      )
                    else
                      ValueListenableBuilder<Set<String>>(
                        valueListenable:
                            AuthStorage.instance.completedUnitsNotifier,
                        builder: (context, completedSet, _) {
                          final successColor = isDark
                              ? AppColors.darkSuccess
                              : AppColors.success;

                          return Column(
                            children: _module.references.map((ref) {
                              final normalizedCode =
                                  ref.unitCode.toUpperCase().trim();
                              final isUnitDone = ref.isUnitCompleted ||
                                  completedSet.contains(normalizedCode);
                              final isUnitSaving =
                                  _savingUnitCode == normalizedCode;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isUnitDone
                                        ? successColor.withValues(alpha: 0.45)
                                        : line,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isUnitDone
                                            ? successColor.withValues(alpha: 0.14)
                                            : accentSoft,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'G${ref.grade}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isUnitDone
                                              ? successColor
                                              : accent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Unit ${ref.unitNumber}: ${ref.unitTitle}',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isUnitDone
                                                ? '${ref.unitCode} • ${ref.pages} • Mastered'
                                                : '${ref.unitCode} • ${ref.pages}',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: isUnitDone
                                                  ? successColor
                                                  : subtext,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (ref.hasQuickNotes) ...[
                                      const SizedBox(width: 8),
                                      AcedexBounceable(
                                        onTap: () =>
                                            _openQuickNotes(ref, accent),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accentSoft,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            border: Border.all(
                                              color: accent.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedBookOpen01,
                                                color: accent,
                                                size: 13,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Quick Notes',
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
                                    if (widget.onToggleUnitMastery != null) ...[
                                      const SizedBox(width: 8),
                                      Semantics(
                                        button: true,
                                        label: isUnitDone
                                            ? 'Unmark ${ref.unitCode} mastered'
                                            : 'Mark ${ref.unitCode} mastered',
                                        child: AcedexBounceable(
                                          onTap: () =>
                                              _handleUnitMasteryTap(ref),
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isUnitDone
                                                  ? successColor
                                                  : raised,
                                              border: Border.all(
                                                color: isUnitDone
                                                    ? successColor
                                                    : subtext,
                                                width: 1.8,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: isUnitSaving
                                                ? FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: AcedexDotsLoader(
                                                      color: isUnitDone
                                                          ? onAccent
                                                          : accent,
                                                      dotSize: 3,
                                                      gap: 1.5,
                                                    ),
                                                  )
                                                : (isUnitDone
                                                    ? const Icon(
                                                        Icons.check_rounded,
                                                        size: 16,
                                                        color: Colors.white,
                                                      )
                                                    : null),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // 3. Recommended Learning Sequence Checklist
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LEARNING SEQUENCE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: accent,
                          ),
                        ),
                        Text(
                          '${_module.completedSteps.length}/${_module.sequence.length} done',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: subtext,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._module.sequence.map((step) {
                      final done = _module.completedSteps.contains(
                        step.stepNumber,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AcedexBounceable(
                          onTap: () => _handleStepTap(step.stepNumber),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: done ? accentSoft : raised,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: done ? accent : line),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: BoxDecoration(
                                    color: done ? accent : surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: done ? accent : line,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: done
                                      ? HugeIcon(
                                          icon: HugeIcons.strokeRoundedTick02,
                                          color: onAccent,
                                          size: 12,
                                        )
                                      : Text(
                                          '${step.stepNumber}',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            color: subtext,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.text,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                          decoration: done
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: theme.colorScheme.onSurface
                                              .withValues(
                                                alpha: done ? 0.7 : 1.0,
                                              ),
                                        ),
                                      ),
                                      if (step.grade != null &&
                                          step.unitNumber != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Grade ${step.grade} Unit ${step.unitNumber}${step.pages != null ? ' • ${step.pages}' : ''}',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: accent,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // 4. Mastery Checkpoint
                    if (_module.masteryCheckpoint.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: accentSoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedTarget01,
                                  color: accent,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'MASTERY CHECKPOINT',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _module.masteryCheckpoint,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                height: 1.45,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    AcedexButton(
                      label: _module.isCompleted
                          ? 'Module Mastered • Tap to Reopen'
                          : 'Mark Module Mastered',
                      variant: _module.isCompleted
                          ? AcedexButtonVariant.soft
                          : AcedexButtonVariant.primary,
                      size: AcedexButtonSize.lg,
                      isLoading: _saving,
                      leadingIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedTick02,
                        color: _module.isCompleted ? accent : onAccent,
                        size: 18,
                      ),
                      onPressed: _handleMasteredTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
