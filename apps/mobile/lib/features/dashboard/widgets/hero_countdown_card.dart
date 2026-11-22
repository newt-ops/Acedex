import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';

/// EUEE 2026 Countdown & Readiness Hero Card (Section 1)
///
/// Features:
/// - Top Row: Grade badge + Gliding segmented toggle ("Countdown" / "Readiness")
/// - View A: Live ticking Days / Hours / Mins readout with pulsing indicator dot
/// - View B: Radial Exam Readiness meter (76% score + "+4.2% wk" badge + 545+ target score)
/// - Bottom Row: Linear progress meter + Primary "Continue Unit 4 >" CTA pill
/// - Loading State: Zero circular spinners! Displays horizontal `AcedexDotsLoader`
class HeroCountdownCard extends StatefulWidget {
  final String gradeLabel;
  final int readinessScore;
  final VoidCallback onContinueUnit4;
  final DateTime? targetDate;

  const HeroCountdownCard({
    super.key,
    required this.gradeLabel,
    required this.readinessScore,
    required this.onContinueUnit4,
    this.targetDate,
  });

  @override
  State<HeroCountdownCard> createState() => _HeroCountdownCardState();
}

class _HeroCountdownCardState extends State<HeroCountdownCard> {
  String _heroMode = 'countdown'; // 'countdown' | 'readiness'
  bool _isLoadingUnit4 = false;

  // Study deadline: June 8, 2026 EUEE Examination
  late int _countdownMinutes;
  bool _pulseOn = true;
  Timer? _pulseTimer;
  Timer? _minuteTimer;

  void _recomputeCountdown() {
    final target = widget.targetDate ?? DateTime(2026, 6, 8, 9, 0);
    final diff = target.difference(DateTime.now());
    _countdownMinutes = diff.isNegative ? 0 : diff.inMinutes;
  }

  @override
  void initState() {
    super.initState();
    _recomputeCountdown();
    _pulseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _pulseOn = !_pulseOn);
      }
    });

    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _recomputeCountdown();
        });
      }
    });
  }

  @override
  void didUpdateWidget(HeroCountdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDate != widget.targetDate) {
      setState(() {
        _recomputeCountdown();
      });
    }
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _minuteTimer?.cancel();
    super.dispose();
  }

  void _handleContinueTap() {
    if (_isLoadingUnit4) return;
    setState(() => _isLoadingUnit4 = true);

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() => _isLoadingUnit4 = false);
        widget.onContinueUnit4();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineBorder = isDark ? const Color(0xFF383842) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final days = _countdownMinutes ~/ (24 * 60);
    final hours = (_countdownMinutes % (24 * 60)) ~/ 60;
    final mins = _countdownMinutes % 60;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF1E1523),
                  Color(0xFF26192C),
                  Color(0xFF2C1C34),
                ]
              : const [
                  Color(0xFFFAF5FC),
                  Color(0xFFF3E5F7),
                  Color(0xFFEFE1F2),
                ],
        ),
        border: Border.all(color: lineBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===================================================================
          // TOP ROW: Grade Badge + Gliding "Countdown" / "Readiness" Toggle
          // ===================================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Grade & Stream Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: raisedBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: lineBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.gradeLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Gliding Segmented Pill Switcher
              Container(
                height: 28,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: raisedBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: lineBorder),
                ),
                child: Stack(
                  children: [
                    // Animated Glider
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      alignment: _heroMode == 'countdown'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        width: 74,
                        height: 22,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeButton(
                          label: 'Countdown',
                          isActive: _heroMode == 'countdown',
                          onTap: () => setState(() => _heroMode = 'countdown'),
                        ),
                        _buildModeButton(
                          label: 'Readiness',
                          isActive: _heroMode == 'readiness',
                          onTap: () => setState(() => _heroMode = 'readiness'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===================================================================
          // MIDDLE VIEW: Animated Switcher between Countdown and Readiness
          // ===================================================================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _heroMode == 'countdown'
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildCountdownView(
              days: days,
              hours: hours,
              mins: mins,
              raisedBg: raisedBg,
              lineBorder: lineBorder,
              subtextColor: subtextColor,
              primaryColor: primaryColor,
            ),
            secondChild: _buildReadinessView(
              raisedBg: raisedBg,
              lineBorder: lineBorder,
              subtextColor: subtextColor,
              primaryColor: primaryColor,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 14),

          // ===================================================================
          // BOTTOM ROW: Linear Progress Bar + "Continue Unit 4 >" CTA Pill
          // ===================================================================
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: lineBorder),
              ),
            ),
            child: Row(
              children: [
                // Linear Progress Fill + Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.readinessScore}% Ready',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '+4.2% this week',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkSuccess : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          height: 7,
                          color: raisedBg,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: (widget.readinessScore / 100).clamp(0.0, 1.0),
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

                const SizedBox(width: 14),

                // Primary Pill CTA with 3-Dots Wave Loader
                AcedexBounceable(
                  onTap: _handleContinueTap,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoadingUnit4
                          ? const AcedexDotsLoader(
                              color: Colors.white,
                              dotSize: 4.5,
                              gap: 3.5,
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Continue Unit 4',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                SizedBox(width: 4),
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowRight01,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 74,
        height: 22,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppColors.lightSecondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownView({
    required int days,
    required int hours,
    required int mins,
    required Color raisedBg,
    required Color lineBorder,
    required Color subtextColor,
    required Color primaryColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildCountdownTile(
            value: '$days',
            unit: 'Days',
            raisedBg: raisedBg,
            lineBorder: lineBorder,
            subtextColor: subtextColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCountdownTile(
            value: hours.toString().padLeft(2, '0'),
            unit: 'Hours',
            raisedBg: raisedBg,
            lineBorder: lineBorder,
            subtextColor: subtextColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCountdownTile(
            value: mins.toString().padLeft(2, '0'),
            unit: 'Mins',
            raisedBg: raisedBg,
            lineBorder: lineBorder,
            subtextColor: subtextColor,
            pulseColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownTile({
    required String value,
    required String unit,
    required Color raisedBg,
    required Color lineBorder,
    required Color subtextColor,
    Color? pulseColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
      decoration: BoxDecoration(
        color: raisedBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: lineBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: theme.colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (pulseColor != null) ...[
                const SizedBox(width: 3),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _pulseOn ? 1.0 : 0.2,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: pulseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            unit.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessView({
    required Color raisedBg,
    required Color lineBorder,
    required Color subtextColor,
    required Color primaryColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final score = widget.readinessScore;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: raisedBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineBorder),
      ),
      child: Row(
        children: [
          // Radial Circular Progress
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (score / 100).clamp(0.0, 1.0),
                  strokeWidth: 5.5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: lineBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Readiness Readout & Target Score
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Exam Readiness',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkSuccess : AppColors.success)
                            .withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '+4.2% wk',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkSuccess : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: subtextColor,
                    ),
                    children: [
                      const TextSpan(text: 'On track for '),
                      TextSpan(
                        text: '545+ EUEE',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const TextSpan(text: ' score • 48d 14h remaining'),
                    ],
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
