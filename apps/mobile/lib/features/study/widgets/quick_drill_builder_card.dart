import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/study_models.dart';

/// Component 4: Quick Topic Drill Builder Card
///
/// Features target unit selector, gliding 3 Qs / 5 Qs / 8 Qs count control,
/// gliding Standard / EUEE Hard difficulty toggle, and "Start Topic Drill >"
/// CTA with horizontal 3-dots wave loader.
class QuickTopicDrillBuilderCard extends StatefulWidget {
  final SubjectCurriculum subject;
  final String selectedUnitId;
  final int questionCount;
  final String difficulty;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<String> onDifficultyChanged;
  final Function(String unitId, int count, String difficulty) onStartDrill;

  const QuickTopicDrillBuilderCard({
    super.key,
    required this.subject,
    required this.selectedUnitId,
    required this.questionCount,
    required this.difficulty,
    required this.onUnitChanged,
    required this.onCountChanged,
    required this.onDifficultyChanged,
    required this.onStartDrill,
  });

  @override
  State<QuickTopicDrillBuilderCard> createState() =>
      _QuickTopicDrillBuilderCardState();
}

class _QuickTopicDrillBuilderCardState
    extends State<QuickTopicDrillBuilderCard> {
  bool _isLoading = false;

  void _handleStartDrill() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _isLoading = false);
    widget.onStartDrill(
      widget.selectedUnitId,
      widget.questionCount,
      widget.difficulty,
    );
  }

  void _showUnitPicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF1B1B1F) : const Color(0xFFFFFFFF);
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: lineColor)),
          ),
          padding: const EdgeInsets.only(top: 12, bottom: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Target Unit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    Text(
                      '${widget.subject.units.length} Units',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: lineColor),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildPickerItem(
                      ctx,
                      id: 'all',
                      label:
                          'All ${widget.subject.name} Units (${widget.subject.units.length} Units)',
                      sublabel: 'Comprehensive pool across all syllabus units',
                      isSelected: widget.selectedUnitId == 'all',
                    ),
                    for (final unit in widget.subject.units)
                      _buildPickerItem(
                        ctx,
                        id: unit.id,
                        label: '${unit.code}: ${unit.title}',
                        sublabel:
                            '${unit.examWeight} • ${unit.topics.length} Topics',
                        isSelected: widget.selectedUnitId == unit.id,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerItem(
    BuildContext context, {
    required String id,
    required String label,
    required String sublabel,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;

    return InkWell(
      onTap: () {
        widget.onUnitChanged(id);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? accent.withValues(alpha: 0.12)
                  : AppColors.royalPurpleSoft.withValues(alpha: 0.6))
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkLine : AppColors.lightLine,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? accent
                          : (isDark
                              ? AppColors.darkText
                              : AppColors.lightText),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                color: accent,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  String _getSelectedUnitLabel() {
    if (widget.selectedUnitId == 'all') {
      return 'All ${widget.subject.name} Units (${widget.subject.units.length} Units)';
    }
    final found = widget.subject.units.firstWhere(
      (u) => u.id == widget.selectedUnitId,
      orElse: () => widget.subject.units.first,
    );
    return '${found.code}: ${found.title}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF1B1B1F) : const Color(0xFFFFFFFF);
    final raisedBg = isDark ? const Color(0xFF2B2B31) : const Color(0xFFF4F4F6);
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;
    final accentSoft =
        isDark ? accent.withValues(alpha: 0.18) : AppColors.royalPurpleSoft;

    // Glider alignment math
    final double countAlignX = widget.questionCount == 3
        ? -1.0
        : (widget.questionCount == 5 ? 0.0 : 1.0);
    final double diffAlignX = widget.difficulty == 'Standard' ? -1.0 : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: lineColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedTarget02,
                    color: accent,
                    size: 17,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Topic Drill Builder',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Custom EUEE-Style Practice Session',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 1. Target Unit Selector
          Text(
            'TARGET UNIT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          AcedexBounceable(
            onTap: () => _showUnitPicker(context),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: raisedBg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: lineColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _getSelectedUnitLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowDown01,
                    color: subtextColor,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Question Count ("3 Qs", "5 Qs", "8 Qs")
          Text(
            'QUESTION COUNT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 34,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: raisedBg,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: lineColor),
            ),
            child: Stack(
              children: [
                // Glider
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  alignment: Alignment(countAlignX, 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3,
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(8.5),
                        border: Border.all(color: accent),
                      ),
                    ),
                  ),
                ),
                // Buttons
                Row(
                  children: [
                    _buildSegmentButton(
                      label: '3 Qs',
                      isSelected: widget.questionCount == 3,
                      onTap: () => widget.onCountChanged(3),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                    _buildSegmentButton(
                      label: '5 Qs',
                      isSelected: widget.questionCount == 5,
                      onTap: () => widget.onCountChanged(5),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                    _buildSegmentButton(
                      label: '15 Qs',
                      isSelected: widget.questionCount == 15,
                      onTap: () => widget.onCountChanged(15),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Difficulty Tier ("Standard", "EUEE Hard")
          Text(
            'DIFFICULTY TIER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 34,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: raisedBg,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: lineColor),
            ),
            child: Stack(
              children: [
                // Glider
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  alignment: Alignment(diffAlignX, 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 2,
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(8.5),
                        border: Border.all(color: accent),
                      ),
                    ),
                  ),
                ),
                // Buttons
                Row(
                  children: [
                    _buildSegmentButton(
                      label: 'Standard',
                      isSelected: widget.difficulty == 'Standard',
                      onTap: () => widget.onDifficultyChanged('Standard'),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                    _buildSegmentButton(
                      label: 'EUEE Hard',
                      isSelected: widget.difficulty == 'EUEE Hard',
                      onTap: () => widget.onDifficultyChanged('EUEE Hard'),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Start Topic Drill CTA button
          AcedexBounceable(
            onTap: _handleStartDrill,
            child: Container(
              height: 42,
              width: double.infinity,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: _isLoading
                    ? const AcedexDotsLoader(
                        dotSize: 5.5,
                        gap: 4.5,
                        color: Colors.white,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Start Topic Drill',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 5),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accent,
    required Color subtextColor,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? accent : subtextColor,
            ),
          ),
        ),
      ),
    );
  }
}
