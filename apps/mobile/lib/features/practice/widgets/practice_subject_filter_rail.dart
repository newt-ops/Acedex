import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/practice_models.dart';

/// Subject Filter Rail for EUEE Practice Hub
class PracticeSubjectFilterRail extends StatelessWidget {
  final List<PracticeSubjectMeta> subjects;
  final String selectedSubjectId;
  final ValueChanged<String> onSelectSubject;

  const PracticeSubjectFilterRail({
    super.key,
    required this.subjects,
    required this.selectedSubjectId,
    required this.onSelectSubject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: subjects.length,
        separatorBuilder: (_, i) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final subj = subjects[index];
          final isSelected = subj.id == selectedSubjectId;

          return AcedexBounceable(
            onTap: () => onSelectSubject(subj.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: isSelected ? accent : surfaceColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? accent : lineColor,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subj.iconData != null) ...[
                    HugeIcon(
                      icon: subj.iconData!,
                      color: isSelected ? Colors.white : textColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    subj.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
