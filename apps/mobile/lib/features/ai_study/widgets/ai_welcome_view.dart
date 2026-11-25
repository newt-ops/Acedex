import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../../splash/painters/acedex_logo_painter.dart';
import '../models/ai_study_models.dart';

/// Phase 0: Welcome Overview explaining ACEDEX's AI Cross-Grade Topic Study Program
/// vs. Grade-by-Grade study in Tab 1, with "Generate Study Program" primary CTA.
class AiWelcomeView extends StatelessWidget {
  final UserProfile? user;
  final bool canGenerateToday;
  final bool requiresAd;
  final VoidCallback onStartCalibration;

  const AiWelcomeView({
    super.key,
    required this.user,
    required this.canGenerateToday,
    required this.requiresAd,
    required this.onStartCalibration,
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

    final streamName = AiStudyPresets.streamDisplayLabel(user?.stream);
    final gradeNum = user?.grade ?? 12;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 132),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero Card with ACEDEX Mark & Gemini AI Pill
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1B1820),
                        const Color(0xFF24192A),
                        const Color(0xFF2F1D39),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFFAF2FC),
                        const Color(0xFFF0DDF6),
                      ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: line),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: isDark ? 0.24 : 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: raised,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: line),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: CustomPaint(
                            painter: AcedexLogoPainter(
                              archSpring: 1.0,
                              waveSpring: 1.0,
                              orbSpring: 1.0,
                              showOrb: true,
                              color: accent,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: raised, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedAiSparkles,
                              color: onAccent,
                              size: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: AcedexBadge(
                              label: 'ACEDEX AI TOPICS',
                              variant: AcedexBadgeVariant.primary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Grade $gradeNum • $streamName',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: subtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Master Ethiopian Subjects by Connected Topics',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.18,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Instead of studying Grade 9, 10, 11, and 12 units separately, ACEDEX AI threads related concepts across all four grades into sequential topic modules — complete with exact textbook page numbers.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.48,
                    color: subtext,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Grade-by-Grade vs Topic-Based Comparison Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: raised,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedBookOpen01,
                              color: subtext,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Study Tab',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: subtext,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Grade by Grade',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Follow units G9 → G12 sequentially',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: subtext,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withValues(alpha: 0.45)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedAiBrain01,
                              color: accent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'AI Study Tab',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'By Topic (G9–12)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Master whole EUEE themes together',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: subtext,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Three Benefit Cards
          _BenefitTile(
            icon: HugeIcons.strokeRoundedBook02,
            title: 'Exact Textbook Pages Cited',
            subtitle:
                'Every module shows the exact Grade, Unit title, and page numbers (e.g. G9 U1 • pp. 1–26) plus direct ACEDEX Quick Notes links.',
            accent: accent,
            accentSoft: accentSoft,
            surface: surface,
            line: line,
            subtext: subtext,
          ),
          const SizedBox(height: 10),
          _BenefitTile(
            icon: HugeIcons.strokeRoundedTarget01,
            title: 'Acedex AI Prioritizes Weak Subjects',
            subtitle:
                'Calibrate your target EUEE score (400–600), weakest subjects, and daily study time in 4 quick steps.',
            accent: accent,
            accentSoft: accentSoft,
            surface: surface,
            line: line,
            subtext: subtext,
          ),
          const SizedBox(height: 10),
          _BenefitTile(
            icon: HugeIcons.strokeRoundedLayers01,
            title: 'Live 0% → 100% Topic Mastery',
            subtitle:
                'Check off each learning step and mastery checkpoint; everything saves straight to your ACEDEX account.',
            accent: accent,
            accentSoft: accentSoft,
            surface: surface,
            line: line,
            subtext: subtext,
          ),

          const SizedBox(height: 22),

          // 4. Primary CTA
          AcedexButton(
            label: 'Generate Study Program',
            size: AcedexButtonSize.lg,
            leadingIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedAiSparkles,
              color: onAccent,
              size: 18,
            ),
            trailingIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: onAccent,
              size: 18,
            ),
            onPressed: onStartCalibration,
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: requiresAd
                    ? HugeIcons.strokeRoundedPlay
                    : HugeIcons.strokeRoundedTick02,
                color: subtext,
                size: 13,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  requiresAd
                      ? 'Generates once per day • Unlocks with 1 rewarded ad'
                      : 'Generates once per day tailored to your progress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: subtext,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color accentSoft;
  final Color surface;
  final Color line;
  final Color subtext;

  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.accentSoft,
    required this.surface,
    required this.line,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: HugeIcon(
              icon: icon,
              color: accent,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: subtext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
