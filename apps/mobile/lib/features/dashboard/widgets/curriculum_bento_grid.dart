import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';

/// 2x2 Live Curriculum Bento Grid (Section 2)
///
/// Features:
/// - Card 1: Units Mastered (18 / 24 with 75% progress bar)
/// - Card 2: EUEE Accuracy (83.4% with +2.8% green badge & "Last 120 questions")
/// - Card 3: Daily Focus (Interactive "+15m" quick-log with bounce & dynamic progress)
/// - Card 4: Stream Standing (Tappable toggle between Weekly "Top 5%" / "2,480 XP"
///   and All-Time "Top 3%" / "18,940 XP")
class CurriculumBentoGrid extends StatefulWidget {
  final int focusMinutes;
  final int focusGoalMinutes;
  final VoidCallback onQuickLogFocus;
  final bool standingIsAllTime;
  final VoidCallback onToggleStanding;

  const CurriculumBentoGrid({
    super.key,
    required this.focusMinutes,
    this.focusGoalMinutes = 60,
    required this.onQuickLogFocus,
    required this.standingIsAllTime,
    required this.onToggleStanding,
  });

  @override
  State<CurriculumBentoGrid> createState() => _CurriculumBentoGridState();
}

class _CurriculumBentoGridState extends State<CurriculumBentoGrid>
    with TickerProviderStateMixin {
  late final AnimationController _focusBounceController;
  late final Animation<double> _focusScaleAnimation;

  late final AnimationController _standingBounceController;
  late final Animation<double> _standingScaleAnimation;

  @override
  void initState() {
    super.initState();
    _focusBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _focusScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.04, end: 0.98), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 0.98, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _focusBounceController,
      curve: Curves.easeInOut,
    ));

    _standingBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _standingScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.04, end: 0.98), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 0.98, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _standingBounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _focusBounceController.dispose();
    _standingBounceController.dispose();
    super.dispose();
  }

  void _triggerFocusBounce() {
    widget.onQuickLogFocus();
    _focusBounceController.forward(from: 0.0);
  }

  void _triggerStandingToggle() {
    widget.onToggleStanding();
    _standingBounceController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final lineBorder = isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Curriculum Pulse',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Live Metrics',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: subtextColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 2x2 Bento Grid
        Row(
          children: [
            // Card 1: Units Mastered
            Expanded(
              child: _buildBentoCard(
                surfaceColor: surfaceColor,
                lineBorder: lineBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Units Mastered',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subtextColor,
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedBookOpen01,
                            color: primaryColor,
                            size: 13.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '18 / 24',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: theme.colorScheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 6,
                        color: lineBorder,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 18 / 24,
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Card 2: EUEE Accuracy
            Expanded(
              child: _buildBentoCard(
                surfaceColor: surfaceColor,
                lineBorder: lineBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EUEE Accuracy',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subtextColor,
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedTarget01,
                            color: primaryColor,
                            size: 13.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '83.4%',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: theme.colorScheme.onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.darkSuccess : AppColors.success)
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '+2.8%',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkSuccess : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last 120 questions',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            // Card 3: Daily Focus (+15m interactive quick-log)
            Expanded(
              child: AnimatedBuilder(
                animation: _focusScaleAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _focusScaleAnimation.value,
                  child: child,
                ),
                child: _buildBentoCard(
                  surfaceColor: surfaceColor,
                  lineBorder: lineBorder,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily Focus',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: subtextColor,
                            ),
                          ),
                          AcedexBounceable(
                            onTap: _triggerFocusBounce,
                            child: Container(
                              height: 22,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '+15m',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${widget.focusMinutes} / ${widget.focusGoalMinutes}m',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: theme.colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          height: 6,
                          color: lineBorder,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: (widget.focusMinutes / widget.focusGoalMinutes)
                                  .clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.focusMinutes >= widget.focusGoalMinutes
                                      ? (isDark ? AppColors.darkSuccess : AppColors.success)
                                      : primaryColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Card 4: Stream Standing (Tappable Weekly / All-Time Toggle)
            Expanded(
              child: AnimatedBuilder(
                animation: _standingScaleAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _standingScaleAnimation.value,
                  child: child,
                ),
                child: AcedexBounceable(
                  onTap: _triggerStandingToggle,
                  child: _buildBentoCard(
                    surfaceColor: surfaceColor,
                    lineBorder: lineBorder,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stream Standing',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: subtextColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                widget.standingIsAllTime ? 'ALL-TIME' : 'WEEKLY',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.standingIsAllTime ? 'Top 3%' : 'Top 5%',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: theme.colorScheme.onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.standingIsAllTime ? '18,940 XP' : '2,480 XP',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard({
    required Color surfaceColor,
    required Color lineBorder,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lineBorder),
      ),
      child: child,
    );
  }
}
