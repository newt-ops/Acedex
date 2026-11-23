import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/feedback/acedex_skeleton.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/study_models.dart';

/// Interactive Syllabus Unit Viewer with Expandable Accordions & Sub-Topic Tree (Component 3)
class SyllabusUnitAccordion extends StatefulWidget {
  final SubjectCurriculum subject;
  final String searchQuery;
  final String activeFilter; // 'all' | 'progress' | 'bookmarked'
  final ValueChanged<String> onToggleUnitExpand;
  final ValueChanged<String>? onToggleUnitComplete;
  final ValueChanged<String> onToggleTopicComplete;
  final ValueChanged<String> onOpenNotes;
  final ValueChanged<StudyUnit>? onTakeUnitAssessment;
  final VoidCallback onResetFilters;
  final bool showNotesButton;
  final bool isLoading;

  const SyllabusUnitAccordion({
    super.key,
    required this.subject,
    required this.searchQuery,
    required this.activeFilter,
    required this.onToggleUnitExpand,
    this.onToggleUnitComplete,
    required this.onToggleTopicComplete,
    required this.onOpenNotes,
    this.onTakeUnitAssessment,
    required this.onResetFilters,
    this.showNotesButton = true,
    this.isLoading = false,
  });

  @override
  State<SyllabusUnitAccordion> createState() => _SyllabusUnitAccordionState();
}

class _SyllabusUnitAccordionState extends State<SyllabusUnitAccordion> {
  String? _loadingNotesTopicId;
  String? _loadingUnitAssessmentId;

  bool _topicMatchesSearch(StudyUnit unit, StudyTopic topic, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    final notes = topic.notes;
    final haystack = [
      unit.code,
      unit.title,
      topic.code,
      topic.title,
      if (notes != null) ...notes.summary,
      if (notes != null) ...notes.formulas.map((f) => '${f.name} ${f.expr}'),
    ].join(' ').toLowerCase();
    return haystack.contains(q);
  }

  void _handleNotesTap(String topicId) {
    if (_loadingNotesTopicId != null || _loadingUnitAssessmentId != null) return;
    setState(() => _loadingNotesTopicId = topicId);

    Future.delayed(const Duration(milliseconds: 540), () {
      if (mounted) {
        setState(() => _loadingNotesTopicId = null);
        widget.onOpenNotes(topicId);
      }
    });
  }

  void _handleUnitAssessmentTap(StudyUnit unit) {
    if (_loadingNotesTopicId != null || _loadingUnitAssessmentId != null) return;
    setState(() => _loadingUnitAssessmentId = unit.id);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _loadingUnitAssessmentId = null);
        widget.onTakeUnitAssessment?.call(unit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineBorder = isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    // Filter units & topics
    final visibleUnits = <Map<String, dynamic>>[];

    for (final unit in widget.subject.units) {
      final unitDoneCount = unit.topics.where((t) => t.completed).length;
      final unitTotalCount = unit.topics.length;
      final isUnitComplete = unit.isCompleted || (unitDoneCount == unitTotalCount && unitTotalCount > 0);

      // Filter out completed units if 'progress' filter is active
      if (widget.activeFilter == 'progress' && isUnitComplete) continue;

      final unitMatchesSearch = widget.searchQuery.isEmpty ||
          unit.code.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
          unit.title.toLowerCase().contains(widget.searchQuery.toLowerCase());

      if (unit.topics.isEmpty) {
        if (unitMatchesSearch && widget.activeFilter != 'bookmarked') {
          visibleUnits.add({
            'unit': unit,
            'matchingTopics': <StudyTopic>[],
            'isUnitComplete': isUnitComplete,
            'unitDoneCount': isUnitComplete ? 1 : 0,
            'unitTotalCount': 1,
          });
        }
        continue;
      }

      final matchingTopics = unit.topics.where((t) {
        if (!_topicMatchesSearch(unit, t, widget.searchQuery)) return false;
        if (widget.activeFilter == 'bookmarked' && !t.bookmarked) return false;
        return true;
      }).toList();

      if (matchingTopics.isNotEmpty || unitMatchesSearch) {
        visibleUnits.add({
          'unit': unit,
          'matchingTopics': matchingTopics,
          'isUnitComplete': isUnitComplete,
          'unitDoneCount': unitDoneCount,
          'unitTotalCount': unitTotalCount,
        });
      }
    }

    final hasZeroMatches = visibleUnits.isEmpty;
    final unitCountLabel = widget.isLoading
        ? 'Loading units...'
        : '${visibleUnits.length} ${visibleUnits.length == 1 ? "Unit" : "Units"} • Tap to expand';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Syllabus Units',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              unitCountLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: subtextColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (widget.isLoading)
          const AcedexSkeletonList(
            itemCount: 4,
            spacing: 10,
          )
        else if (hasZeroMatches)
          // Empty State Container
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lineBorder),
            ),
            child: Column(
              children: [
                Text(
                  'No matching units or topics',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Try clearing your search or switching to All Units.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: subtextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                AcedexBounceable(
                  onTap: widget.onResetFilters,
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Reset Filters',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          // List of Unit Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleUnits.length,
            separatorBuilder: (_, i) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = visibleUnits[index];
              final unit = item['unit'] as StudyUnit;
              final matchingTopics = item['matchingTopics'] as List<StudyTopic>;
              final isUnitComplete = item['isUnitComplete'] as bool;
              final unitDoneCount = item['unitDoneCount'] as int;
              final unitTotalCount = item['unitTotalCount'] as int;

              // Force expand if searching or bookmarked filter
              final isExpanded = widget.searchQuery.isNotEmpty || widget.activeFilter == 'bookmarked'
                  ? true
                  : unit.expanded;

              return Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isExpanded ? primaryColor : lineBorder,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    // Unit Header Trigger
                    AcedexBounceable(
                      onTap: () => widget.onToggleUnitExpand(unit.id),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Unit Code Badge (Green if complete, Purple otherwise)
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isUnitComplete
                                    ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                        .withValues(alpha: 0.16)
                                    : primaryColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                unit.code,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isUnitComplete
                                      ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                      : primaryColor,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Unit Title, Weight & Progress Count
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    unit.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: raisedBg,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: lineBorder),
                                          ),
                                          child: Text(
                                            unit.examWeight,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (unit.topics.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '$unitDoneCount/$unitTotalCount Topics',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: isUnitComplete
                                                ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                                : subtextColor,
                                            fontFeatures: const [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ] else if (isUnitComplete) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          'Completed',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.darkSuccess : AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Unit Completion Check Circle
                            AcedexBounceable(
                              onTap: () => widget.onToggleUnitComplete?.call(unit.id),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isUnitComplete
                                      ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                      : surfaceColor,
                                  border: Border.all(
                                    color: isUnitComplete
                                        ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                        : subtextColor,
                                    width: 1.8,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: isUnitComplete
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Rotating Chevron Icon
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expandable Sub-Topic Rows Accordion
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: isExpanded
                          ? Container(
                              decoration: BoxDecoration(
                                color: raisedBg,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(19)),
                              ),
                              child: Column(
                                children: [
                                  // Unit Assessment Card when completed
                                  if (isUnitComplete) ...[
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF23232C) : const Color(0xFFF3F0FA),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: primaryColor.withValues(alpha: 0.35),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: const HugeIcon(
                                              icon: HugeIcons.strokeRoundedAward01,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Unit Assessment',
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w800,
                                                        letterSpacing: -0.1,
                                                        color: theme.colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    if (unit.assessmentScore != null) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                        decoration: BoxDecoration(
                                                          color: (isDark ? AppColors.darkSuccess : AppColors.success)
                                                              .withValues(alpha: 0.18),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          '${unit.assessmentScore}/15',
                                                          style: TextStyle(
                                                            fontSize: 9.5,
                                                            fontWeight: FontWeight.w800,
                                                            color: isDark ? AppColors.darkSuccess : AppColors.success,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '15 Questions • Ethiopian Curriculum Bank',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: subtextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          AcedexBounceable(
                                            onTap: () => _handleUnitAssessmentTap(unit),
                                            child: Container(
                                              height: 30,
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              alignment: Alignment.center,
                                              child: _loadingUnitAssessmentId == unit.id
                                                  ? const AcedexDotsLoader(
                                                      color: Colors.white,
                                                      dotSize: 3.5,
                                                      gap: 2.5,
                                                    )
                                                  : Text(
                                                      unit.assessmentScore != null ? 'Retake' : 'Take Assessment',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: surfaceColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: lineBorder),
                                      ),
                                      child: Row(
                                        children: [
                                          HugeIcon(
                                            icon: HugeIcons.strokeRoundedLockKey,
                                            color: subtextColor,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Check mark this unit or finish all topics to unlock the 15-question assessment.',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: subtextColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          AcedexBounceable(
                                            onTap: () => widget.onToggleUnitComplete?.call(unit.id),
                                            child: Text(
                                              'Complete Unit',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  ...matchingTopics.map((topic) {
                                  final isLoadingNotes = _loadingNotesTopicId == topic.id;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border(top: BorderSide(color: lineBorder)),
                                    ),
                                    child: Row(
                                      children: [
                                        // Spring Completion Check Circle
                                        AcedexBounceable(
                                          onTap: () => widget.onToggleTopicComplete(topic.id),
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: topic.completed
                                                  ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                                  : surfaceColor,
                                              border: Border.all(
                                                color: topic.completed
                                                    ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                                    : subtextColor,
                                                width: 1.8,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: topic.completed
                                                ? const Icon(
                                                    Icons.check_rounded,
                                                    size: 14,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        // Topic Code, Title & Bookmark
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${topic.code} ${topic.title}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: -0.1,
                                                        color: theme.colorScheme.onSurface,
                                                      ),
                                                    ),
                                                  ),
                                                  if (topic.bookmarked) ...[
                                                    const SizedBox(width: 4),
                                                    HugeIcon(
                                                      icon: HugeIcons.strokeRoundedBookmark01,
                                                      color: primaryColor,
                                                      size: 12,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${topic.duration} • ${topic.questionCount} Qs',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w500,
                                                  color: subtextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        if (widget.showNotesButton) ...[
                                          const SizedBox(width: 8),

                                          // "Notes" Action Button
                                          AcedexBounceable(
                                            onTap: () => _handleNotesTap(topic.id),
                                            child: Container(
                                              height: 27,
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(
                                                color: surfaceColor,
                                                borderRadius: BorderRadius.circular(999),
                                                border: Border.all(color: lineBorder),
                                              ),
                                              alignment: Alignment.center,
                                              child: isLoadingNotes
                                                  ? AcedexDotsLoader(
                                                      color: theme.colorScheme.onSurface,
                                                      dotSize: 3.5,
                                                      gap: 2.5,
                                                    )
                                                  : Text(
                                                      'Notes',
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: theme.colorScheme.onSurface,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            )
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
