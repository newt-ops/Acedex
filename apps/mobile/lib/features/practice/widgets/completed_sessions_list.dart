import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/practice_models.dart';

/// List of Recent Completed Exam / Practice Sessions with Review Answers launcher
class CompletedSessionsList extends StatefulWidget {
  final List<CompletedSession> sessions;
  final ValueChanged<CompletedSession> onReviewSession;

  const CompletedSessionsList({
    super.key,
    required this.sessions,
    required this.onReviewSession,
  });

  @override
  State<CompletedSessionsList> createState() => _CompletedSessionsListState();
}

class _CompletedSessionsListState extends State<CompletedSessionsList> {
  String? _loadingSessionId;

  void _handleReviewTap(CompletedSession session) async {
    if (_loadingSessionId != null) return;
    setState(() => _loadingSessionId = session.id);
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() => _loadingSessionId = null);
    widget.onReviewSession(session);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.success;
    final successBg = isDark
        ? AppColors.darkSuccess.withValues(alpha: 0.16)
        : AppColors.successContainer;
    final warningColor = isDark ? AppColors.darkWarning : AppColors.warning;
    final warningBg = isDark
        ? AppColors.darkWarning.withValues(alpha: 0.16)
        : AppColors.warningContainer;

    if (widget.sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: lineColor),
        ),
        child: Center(
          child: Column(
            children: [
              Text(
                'No completed papers for this subject yet',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Complete a past paper above to inspect detailed solutions.',
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
      itemCount: widget.sessions.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = widget.sessions[index];
        final isLoading = _loadingSessionId == item.id;
        final isHigh = item.scorePct >= 75;

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
              // Top Row: Mode badge & date + Title + Score Pct
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: raisedBg,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: lineColor),
                              ),
                              child: Text(
                                item.modeLabel,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.dateLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isHigh ? successBg : warningBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${item.scorePct}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isHigh ? successColor : warningColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Divider(height: 1, color: lineColor),
              const SizedBox(height: 9),

              // Bottom Row: Ratio & elapsed + Review Answers CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.correctCount}/${item.totalCount} Correct • ${item.elapsedStr}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: subtextColor,
                    ),
                  ),
                  AcedexBounceable(
                    onTap: () => _handleReviewTap(item),
                    child: Container(
                      height: 32,
                      constraints: const BoxConstraints(minWidth: 122),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: raisedBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: lineColor),
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
                                    'Review Answers',
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
