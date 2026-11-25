import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/feedback/acedex_skeleton.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/study_models.dart';
import 'unit_quick_notes_sheet.dart';

/// Interactive Syllabus Unit Viewer with Soft-Surface Cupertino Accordions (Component 3)
class SyllabusUnitAccordion extends StatefulWidget {
  final SubjectCurriculum subject;
  final String searchQuery;
  final String activeFilter; // 'all' | 'progress' | 'bookmarked'
  final ValueChanged<String> onToggleUnitExpand;
  final ValueChanged<String>? onToggleUnitComplete;
  final ValueChanged<String> onToggleTopicComplete;
  final ValueChanged<String> onOpenNotes;
  final ValueChanged<StudyUnit>? onOpenUnitQuickNotes;
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
    this.onOpenUnitQuickNotes,
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

    Future.delayed(const Duration(milliseconds: 500), () {
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

  void _openQuickNotesForUnit(StudyUnit unit) {
    if (widget.onOpenUnitQuickNotes != null) {
      widget.onOpenUnitQuickNotes!(unit);
    } else {
      UnitQuickNotesSheet.show(
        context,
        unit: unit,
        subject: widget.subject,
        onCompleteAndUnlockAssessment: () {
          widget.onToggleUnitComplete?.call(unit.id);
          widget.onTakeUnitAssessment?.call(unit);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF25252B) : Colors.white;
    final lineBorder = isDark ? const Color(0xFF33333E) : const Color(0xFFE4E4E8);
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
        if (widget.activeFilter == 'bookmarked' && !t.bookmarked) return false;
        if (widget.activeFilter == 'progress' && t.completed) return false;
        return _topicMatchesSearch(unit, t, widget.searchQuery);
      }).toList();

      if (matchingTopics.isNotEmpty || (unitMatchesSearch && widget.activeFilter != 'bookmarked')) {
        visibleUnits.add({
          'unit': unit,
          'matchingTopics': matchingTopics,
          'isUnitComplete': isUnitComplete,
          'unitDoneCount': unitDoneCount,
          'unitTotalCount': unitTotalCount,
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // =====================================================================
        // Section Header Row: "Syllabus Units" + Count / Hint
        // =====================================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Syllabus Units',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.35,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                visibleUnits.isNotEmpty
                    ? '${visibleUnits.length} of ${widget.subject.units.length} Units • Tap to expand'
                    : '0 Units Found',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (widget.isLoading)
          Column(
            children: List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: AcedexSkeleton(
                  child: AcedexSkeletonBox(
                    height: 64,
                    borderRadius: 20,
                  ),
                ),
              ),
            ),
          )
        else if (visibleUnits.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: lineBorder),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No units match your filter',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.searchQuery.isNotEmpty
                      ? 'No syllabus units matched "${widget.searchQuery}".'
                      : 'No units in this filter view.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: subtextColor),
                ),
                const SizedBox(height: 12),
                AcedexBounceable(
                  onTap: widget.onResetFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Clear Filter',
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
          // List of Soft-Surface Unit Cards
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

              final isExpanded = widget.searchQuery.isNotEmpty || widget.activeFilter == 'bookmarked'
                  ? true
                  : unit.expanded;

              return Container(
                decoration: BoxDecoration(
                  color: isExpanded
                      ? (isDark ? const Color(0xFF231927) : const Color(0xFFF7EFF9))
                      : surfaceColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isExpanded
                        ? primaryColor.withValues(alpha: 0.28)
                        : lineBorder,
                    width: isExpanded ? 1.2 : 0.8,
                  ),
                  boxShadow: isExpanded
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
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
                            // 42x42 Rounded-Square Unit Code Badge
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isUnitComplete
                                    ? (isDark
                                        ? const Color(0xFF16291C)
                                        : const Color(0xFFEAF8EF))
                                    : primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                unit.code,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: isUnitComplete
                                      ? (isDark
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFF16A34A))
                                      : primaryColor,
                                ),
                              ),
                            ),

                            const SizedBox(width: 11),

                            // Unit Title, Weight & Progress Chips
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    unit.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      height: 1.25,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 5,
                                    runSpacing: 3,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: raisedBg,
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: lineBorder),
                                        ),
                                        child: Text(
                                          unit.examWeight,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      if (unit.topics.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: raisedBg,
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: lineBorder),
                                          ),
                                          child: Text(
                                            '$unitDoneCount/$unitTotalCount Topics',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: isUnitComplete
                                                  ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                                  : subtextColor,
                                              fontFeatures: const [FontFeature.tabularFigures()],
                                            ),
                                          ),
                                        ),
                                      if (isUnitComplete)
                                        Text(
                                          '• Completed',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Right Controls: Quick Notes Action Icon
                            AcedexBounceable(
                              onTap: () => _openQuickNotesForUnit(unit),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: lineBorder),
                                ),
                                alignment: Alignment.center,
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedBookOpen01,
                                  color: subtextColor,
                                  size: 13,
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Unit Completion Spring Check Circle
                            AcedexBounceable(
                              onTap: () => widget.onToggleUnitComplete?.call(unit.id),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isUnitComplete
                                      ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                                      : raisedBg,
                                  border: Border.all(
                                    color: isUnitComplete
                                        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                                        : subtextColor,
                                    width: 1.8,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: isUnitComplete
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
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
                                size: 19,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expandable Accordion Content
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: isExpanded
                          ? Container(
                              decoration: BoxDecoration(
                                color: raisedBg,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(21)),
                              ),
                              child: Column(
                                children: [
                                  // 1. UNLOCKED ASSESSMENT CARD WHEN COMPLETED
                                  if (isUnitComplete) ...[
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: surfaceColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: primaryColor.withValues(alpha: 0.28),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.center,
                                            child: const HugeIcon(
                                              icon: HugeIcons.strokeRoundedAward01,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        'Unit Assessment',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12.5,
                                                          fontWeight: FontWeight.w800,
                                                          letterSpacing: -0.1,
                                                          color: theme.colorScheme.onSurface,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Text(
                                                        '10 AC',
                                                        style: TextStyle(
                                                          fontSize: 9.5,
                                                          fontWeight: FontWeight.w800,
                                                          color: Color(0xFFD97706),
                                                        ),
                                                      ),
                                                    ),
                                                    if (unit.assessmentScore != null) ...[
                                                      const SizedBox(width: 5),
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
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: subtextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),

                                          // Quick Notes button inside assessment card
                                          AcedexBounceable(
                                            onTap: () => _openQuickNotesForUnit(unit),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: surfaceColor,
                                                borderRadius: BorderRadius.circular(999),
                                                border: Border.all(color: lineBorder),
                                              ),
                                              alignment: Alignment.center,
                                              child: HugeIcon(
                                                icon: HugeIcons.strokeRoundedNote01,
                                                color: subtextColor,
                                                size: 13,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 6),

                                          AcedexBounceable(
                                            onTap: () => _handleUnitAssessmentTap(unit),
                                            child: Container(
                                              height: 32,
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                    // 2. UNLOCK PROMPT WHEN INCOMPLETE
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: surfaceColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: lineBorder),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons.strokeRoundedLockKey,
                                                color: primaryColor,
                                                size: 15,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Check mark this unit as complete to unlock your 15-question EUEE Unit Assessment.',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    height: 1.35,
                                                    fontWeight: FontWeight.w500,
                                                    color: subtextColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: AcedexBounceable(
                                                  onTap: () => _openQuickNotesForUnit(unit),
                                                  child: Container(
                                                    height: 34,
                                                    decoration: BoxDecoration(
                                                      color: raisedBg,
                                                      borderRadius: BorderRadius.circular(999),
                                                      border: Border.all(color: lineBorder),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        HugeIcon(
                                                          icon: HugeIcons.strokeRoundedBookOpen01,
                                                          color: primaryColor,
                                                          size: 13,
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Flexible(
                                                          child: Text(
                                                            'Quick Notes',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 11.5,
                                                              fontWeight: FontWeight.w700,
                                                              color: theme.colorScheme.onSurface,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: AcedexBounceable(
                                                  onTap: () => widget.onToggleUnitComplete?.call(unit.id),
                                                  child: Container(
                                                    height: 34,
                                                    decoration: BoxDecoration(
                                                      color: primaryColor.withValues(alpha: 0.14),
                                                      borderRadius: BorderRadius.circular(999),
                                                      border: Border.all(
                                                        color: primaryColor.withValues(alpha: 0.25),
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.check_rounded,
                                                          color: primaryColor,
                                                          size: 15,
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Flexible(
                                                          child: Text(
                                                            'Complete Unit',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 11.5,
                                                              fontWeight: FontWeight.w700,
                                                              color: primaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Sub-Topic items if present
                                  ...matchingTopics.map((topic) {
                                    final isLoadingNotes = _loadingNotesTopicId == topic.id;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        border: Border(top: BorderSide(color: lineBorder)),
                                      ),
                                      child: Row(
                                        children: [
                                          AcedexBounceable(
                                            onTap: () => widget.onToggleTopicComplete(topic.id),
                                            child: Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: topic.completed
                                                    ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                                    : raisedBg,
                                                border: Border.all(
                                                  color: topic.completed
                                                      ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                                      : subtextColor,
                                                  width: 1.5,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: topic.completed
                                                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${topic.code} • ${topic.title}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: topic.completed
                                                        ? subtextColor
                                                        : theme.colorScheme.onSurface,
                                                    decoration: topic.completed
                                                        ? TextDecoration.lineThrough
                                                        : null,
                                                  ),
                                                ),
                                                Text(
                                                  '${topic.duration} • ${topic.questionCount} Questions',
                                                  style: TextStyle(fontSize: 10, color: subtextColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (widget.showNotesButton)
                                            AcedexBounceable(
                                              onTap: () => _handleNotesTap(topic.id),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: surfaceColor,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: lineBorder),
                                                ),
                                                child: isLoadingNotes
                                                    ? AcedexDotsLoader(
                                                        color: primaryColor,
                                                        dotSize: 3,
                                                        gap: 2,
                                                      )
                                                    : Text(
                                                        'Notes',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w700,
                                                          color: primaryColor,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
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
