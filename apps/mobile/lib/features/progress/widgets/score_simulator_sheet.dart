import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/progress_models.dart';

/// Cupertino Bottom Sheet: What-If EUEE Score Simulator (All 6 Exam Subjects including English & SAT)
class ScoreSimulatorSheet extends StatefulWidget {
  final List<SimulatorSubjectScore> subjects;
  final void Function(int newTotalScore, String newPercentile, int newPct) onApplyTarget;

  const ScoreSimulatorSheet({
    super.key,
    required this.subjects,
    required this.onApplyTarget,
  });

  static Future<void> show(
    BuildContext context, {
    required List<SimulatorSubjectScore> subjects,
    required void Function(int newTotalScore, String newPercentile, int newPct) onApplyTarget,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => ScoreSimulatorSheet(
        subjects: subjects,
        onApplyTarget: onApplyTarget,
      ),
    );
  }

  @override
  State<ScoreSimulatorSheet> createState() => _ScoreSimulatorSheetState();
}

class _ScoreSimulatorSheetState extends State<ScoreSimulatorSheet> {
  late Map<String, int> _scores;

  @override
  void initState() {
    super.initState();
    _resetToCurrent();
  }

  void _resetToCurrent() {
    _scores = {
      for (final s in widget.subjects) s.id: s.score.clamp(0, 100),
    };
  }

  int get _totalScore => _scores.values.fold(0, (sum, val) => sum + val);
  int get _maxTotalScore => widget.subjects.isEmpty ? 600 : widget.subjects.length * 100;
  double get _avgPct => _maxTotalScore > 0 ? (_totalScore / _maxTotalScore) * 100 : 0;

  String get _percentileLabel {
    if (_totalScore <= 0) return 'Baseline';
    if (_totalScore >= 510) return 'Top 1%';
    if (_totalScore >= 460) return 'Top 5%';
    if (_totalScore >= 400) return 'Top 12%';
    if (_totalScore >= 300) return 'Top 25%';
    return 'Building';
  }

  String get _eligibilityNote {
    if (_totalScore >= 510) return 'Competitive for AAU Medicine & Honors Engineering';
    if (_totalScore >= 460) return 'Qualifies for Top-Tier Public University Placement';
    if (_totalScore >= 400) return 'Strong Standing • Push weaker subjects to reach Top 5%';
    if (_totalScore > 0) return 'Keep building mastery across all 6 EUEE subjects';
    return 'Slide subject targets to preview your EUEE projection';
  }

  Color _eligibilityColor(bool isDark) {
    if (_totalScore >= 460) {
      return isDark ? AppColors.darkSuccess : AppColors.success;
    }
    if (_totalScore >= 400) {
      return isDark ? AppColors.darkWarning : AppColors.warning;
    }
    return isDark ? AppColors.accentDark : AppColors.accentLight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final sheetBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final heroGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1E1523), Color(0xFF26192D), Color(0xFF2D1D36)],
          )
        : const LinearGradient(
            colors: [Color(0xFFFAF5FC), Color(0xFFF3E4F8), Color(0xFFECE0F3)],
          );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: lineColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle & Header
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 8),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EUEE 2026 PROJECTION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: accentColor,
                            ),
                          ),
                          Text(
                            'What-If Score Simulator',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      AcedexBounceable(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: lineColor),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: theme.colorScheme.onSurface,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Projected Score Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: heroGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: lineColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PROJECTED TOTAL SCORE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: subtextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$_totalScore',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '/ $_maxTotalScore',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _eligibilityNote,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _eligibilityColor(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _percentileLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_avgPct.toStringAsFixed(1)}% Avg',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 6 Sliders for all EUEE Exam Subjects (including English & SAT)
                    for (final subj in widget.subjects) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: lineColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  subj.name,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '${_scores[subj.id] ?? subj.score} / 100',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6,
                                activeTrackColor: accentColor,
                                inactiveTrackColor: lineColor,
                                thumbColor: accentColor,
                                overlayColor: accentColor.withValues(alpha: 0.16),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 9,
                                  elevation: 2,
                                ),
                              ),
                              child: Slider(
                                min: 0,
                                max: 100,
                                value: (_scores[subj.id] ?? subj.score).toDouble().clamp(0, 100),
                                onChanged: (val) {
                                  setState(() {
                                    _scores[subj.id] = val.round();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Action Buttons (Reset Current | Apply Target)
                    Row(
                      children: [
                        Expanded(
                          child: AcedexBounceable(
                            onTap: () {
                              setState(() {
                                _resetToCurrent();
                              });
                            },
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: lineColor),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Reset Current',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AcedexBounceable(
                            onTap: () {
                              final total = _totalScore;
                              final perc = _percentileLabel;
                              final avg = _avgPct.round();
                              Navigator.of(context).pop();
                              widget.onApplyTarget(total, perc, avg);
                            },
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8A2BA3).withValues(alpha: 0.38),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Apply Target',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
