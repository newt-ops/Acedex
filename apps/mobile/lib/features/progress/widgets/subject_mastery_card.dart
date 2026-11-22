import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/progress_models.dart';

/// Card 4: Subject Mastery Section with Gliding Segmented Filter & Interactive Cards
class SubjectMasterySection extends StatefulWidget {
  final List<SubjectMastery> subjects;
  final Map<String, String> deltas;
  final ValueChanged<SubjectMastery> onSelectSubject;

  const SubjectMasterySection({
    super.key,
    required this.subjects,
    required this.deltas,
    required this.onSelectSubject,
  });

  @override
  State<SubjectMasterySection> createState() => _SubjectMasterySectionState();
}

class _SubjectMasterySectionState extends State<SubjectMasterySection> {
  SubjectFilterTab _tab = SubjectFilterTab.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final filtered = widget.subjects.where((s) {
      if (_tab == SubjectFilterTab.focus) return s.mastery < 80;
      if (_tab == SubjectFilterTab.ready) return s.mastery >= 80;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subject Mastery',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Tap card to boost',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Gliding 3-Tab Segmented Filter
        Container(
          height: 34,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: lineColor),
          ),
          child: Row(
            children: [
              for (final tab in SubjectFilterTab.values)
                Expanded(
                  child: AcedexBounceable(
                    onTap: () => setState(() => _tab = tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _tab == tab ? cardBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border: _tab == tab ? Border.all(color: lineColor) : null,
                        boxShadow: _tab == tab
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _tab == tab ? accentColor : subtextColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Subject Cards List
        for (final subj in filtered) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SubjectCard(
              subject: subj,
              delta: widget.deltas[subj.id] ?? '+2.5%',
              accentColor: accentColor,
              accentSoftColor: accentSoftColor,
              lineColor: lineColor,
              surfaceColor: surfaceColor,
              cardBg: cardBg,
              subtextColor: subtextColor,
              isDark: isDark,
              onTap: () => widget.onSelectSubject(subj),
            ),
          ),
        ],
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectMastery subject;
  final String delta;
  final Color accentColor;
  final Color accentSoftColor;
  final Color lineColor;
  final Color surfaceColor;
  final Color cardBg;
  final Color subtextColor;
  final bool isDark;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.delta,
    required this.accentColor,
    required this.accentSoftColor,
    required this.lineColor,
    required this.surfaceColor,
    required this.cardBg,
    required this.subtextColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReady = subject.mastery >= 80;

    return AcedexBounceable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: lineColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentSoftColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: HugeIcon(
                    icon: subject.icon as dynamic,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),

                // Title + Weight + Weakest Topic
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            subject.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: lineColor),
                            ),
                            child: Text(
                              subject.weightLabel,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: subtextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                          children: [
                            const TextSpan(text: 'Weakest: '),
                            TextSpan(
                              text: subject.weakestTopic,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Mastery % + Delta
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${subject.mastery}%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      delta,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkSuccess : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Animated Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: subject.mastery / 100,
                minHeight: 5.5,
                backgroundColor: lineColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isReady
                      ? accentColor
                      : (isDark ? AppColors.darkWarning : AppColors.warning),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
