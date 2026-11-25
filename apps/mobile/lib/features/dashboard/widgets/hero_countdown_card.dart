import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// EUEE 2026 Remaining Study Time Countdown Hero Card (Section 1)
///
/// Features:
/// - Top Row: "STUDY TIME REMAINING" status header with pulsing indicator dot
/// - Middle Row: Live ticking Days / Hours / Mins readout
/// - Bottom Row: Full-width linear progress meter
class HeroCountdownCard extends StatefulWidget {
  final int readinessScore;
  final DateTime? targetDate;

  const HeroCountdownCard({
    super.key,
    required this.readinessScore,
    this.targetDate,
  });

  @override
  State<HeroCountdownCard> createState() => _HeroCountdownCardState();
}

class _HeroCountdownCardState extends State<HeroCountdownCard> {
  // Study deadline: June 8, 2026 EUEE Examination
  late int _countdownMinutes;
  bool _pulseOn = true;
  Timer? _pulseTimer;
  Timer? _minuteTimer;

  void _recomputeCountdown() {
    DateTime target = widget.targetDate ?? DateTime(2026, 6, 8, 9, 0);
    final now = DateTime.now();
    if (target.isBefore(now)) {
      target = DateTime(now.year + 1, 6, 8, 9, 0);
    }
    final diff = target.difference(now);
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
          // TOP ROW: Study Time Remaining Label
          // ===================================================================
          Row(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _pulseOn ? 1.0 : 0.35,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'STUDY TIME REMAINING',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: primaryColor,
                  ),
                ),
              ),
              Text(
                'Until EUEE Exam',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===================================================================
          // MIDDLE VIEW: Live Remaining Study Time Countdown
          // ===================================================================
          _buildCountdownView(
            days: days,
            hours: hours,
            mins: mins,
            raisedBg: raisedBg,
            lineBorder: lineBorder,
            subtextColor: subtextColor,
            primaryColor: primaryColor,
          ),

          const SizedBox(height: 14),

          // ===================================================================
          // BOTTOM ROW: Full-Width Linear Progress Bar
          // ===================================================================
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: lineBorder),
              ),
            ),
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
        ],
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
}
