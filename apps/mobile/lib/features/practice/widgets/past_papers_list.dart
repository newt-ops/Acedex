import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/practice_models.dart';

/// List of Official EUEE Past Papers with single-tap Practice launcher
class PastPapersList extends StatefulWidget {
  final List<EueePaper> papers;
  final ValueChanged<EueePaper> onStartPaper;

  const PastPapersList({
    super.key,
    required this.papers,
    required this.onStartPaper,
  });

  @override
  State<PastPapersList> createState() => _PastPapersListState();
}

class _PastPapersListState extends State<PastPapersList> {
  String? _loadingPaperId;

  void _handlePracticeTap(EueePaper paper) async {
    if (_loadingPaperId != null) return;
    setState(() => _loadingPaperId = paper.id);
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() => _loadingPaperId = null);
    widget.onStartPaper(paper);
  }

  List<List<dynamic>> _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return HugeIcons.strokeRoundedCalculator01;
      case 'chemistry':
        return HugeIcons.strokeRoundedChemistry01;
      case 'biology':
        return HugeIcons.strokeRoundedDna;
      case 'physics':
      default:
        return HugeIcons.strokeRoundedAtom01;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;
    final accentSoft =
        isDark ? accent.withValues(alpha: 0.18) : AppColors.royalPurpleSoft;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.success;
    final successBg = isDark
        ? AppColors.darkSuccess.withValues(alpha: 0.16)
        : AppColors.successContainer;

    if (widget.papers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: lineColor),
        ),
        child: Center(
          child: Column(
            children: [
              Text(
                'No papers found for this subject filter',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Switch back to "All" to browse all national exam papers.',
                style: TextStyle(
                  fontSize: 11,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.papers.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final paper = widget.papers[index];
        final isLoading = _loadingPaperId == paper.id;
        final hasScore = paper.bestScore != null;

        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: lineColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Title/Topic + Score Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: _getSubjectIcon(paper.subject),
                        color: accent,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paper.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: textColor,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          paper.topics,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: hasScore ? successBg : accentSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      hasScore ? 'Best: ${paper.bestScore}%' : 'New',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: hasScore ? successColor : accent,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(height: 1, color: lineColor),
              const SizedBox(height: 9),

              // Bottom Row: Qs count & mins + Practice CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${paper.questions.length} Qs • ${paper.durationMins} mins',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: subtextColor,
                    ),
                  ),
                  AcedexBounceable(
                    onTap: () => _handlePracticeTap(paper),
                    child: Container(
                      height: 32,
                      constraints: const BoxConstraints(minWidth: 92),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: isLoading
                            ? AcedexDotsLoader(
                                dotSize: 4.5,
                                gap: 3.5,
                                color: accent,
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Practice',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedArrowRight01,
                                    color: accent,
                                    size: 13,
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
        );
      },
    );
  }
}
