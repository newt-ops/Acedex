import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../models/progress_models.dart';
import '../widgets/consistency_heatmap_card.dart';
import '../widgets/readiness_hero_card.dart';
import '../widgets/score_simulator_sheet.dart';
import '../widgets/study_analytics_chart_card.dart';
import '../widgets/subject_breakdown_sheet.dart';
import '../widgets/subject_mastery_card.dart';

/// Clean Apple-Style Progress & Performance Analytics Inside Screen (Tab 3: Progress)
///
/// Features:
/// - Zero Top Header Bar & Zero Bottom Navigation Bar (rendered by shell)
/// - 130px bottom scroll padding clearing the concave notch navigation bar
/// - Timeframe Switcher ("7 Days" | "30 Days" | "All Term")
/// - Top sync/refresh button with horizontal 3-dots wave loader
/// - Card 1: EUEE Exam Readiness Hero Card + interactive pillars + What-If Simulator Sheet
/// - Card 2: Interactive Study & Accuracy Chart with horizontal scrubbing
/// - Card 3: 28-Day Study Consistency Heatmap (4×7 grid)
/// - Card 4: Subject Mastery Cards + Subject Breakdown Bottom Sheet + 2-Question Booster Drill
class ProgressScreen extends StatefulWidget {
  final UserProfile? user;

  const ProgressScreen({super.key, this.user});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressTimeframe _activeTimeframe = ProgressTimeframe.sevenDays;
  ReadinessPillarType _activePillar = ReadinessPillarType.coverage;

  bool _isRefreshing = false;

  // Mutable subject mastery state for live boosting
  late List<SubjectMastery> _subjects;

  // Custom simulated overrides from the What-If Simulator
  int? _simulatedTotalScore;
  String? _simulatedPercentile;
  int? _simulatedReadinessPct;

  @override
  void initState() {
    super.initState();
    _subjects = ProgressData.getInitialSubjects();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 680));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _simulatedTotalScore = null;
        _simulatedPercentile = null;
        _simulatedReadinessPct = null;
      });
    }
  }

  void _openScoreSimulator() {
    ScoreSimulatorSheet.show(
      context,
      subjects: _subjects,
      onApplyTarget: (newTotalScore, newPercentile, newPct) {
        setState(() {
          _simulatedTotalScore = newTotalScore;
          _simulatedPercentile = newPercentile;
          _simulatedReadinessPct = newPct;
        });
      },
    );
  }

  void _openSubjectBreakdown(SubjectMastery subject) {
    final baseData = ProgressData.timeframeMap[_activeTimeframe]!;
    final delta = baseData.subjectDeltas[subject.id] ?? '+2.5%';

    SubjectBreakdownSheet.show(
      context,
      subject: subject,
      delta: delta,
      onMasteryBoosted: (subjectId, gain) {
        setState(() {
          // Trigger rebuild to update subject card, filter tabs, and simulator
        });
      },
    );
  }

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

    final baseData = ProgressData.timeframeMap[_activeTimeframe]!;

    // Blend simulated projection if user applied a target in the simulator
    final currentData = TimeframeData(
      readinessPct: _simulatedReadinessPct ?? baseData.readinessPct,
      projectedScore: _simulatedTotalScore ?? baseData.projectedScore,
      percentile: _simulatedPercentile ?? baseData.percentile,
      delta: baseData.delta,
      subcopy: baseData.subcopy,
      coveragePct: baseData.coveragePct,
      accuracyPct: baseData.accuracyPct,
      consistencyPct: baseData.consistencyPct,
      footerHours: baseData.footerHours,
      footerAcc: baseData.footerAcc,
      footerQs: baseData.footerQs,
      points: baseData.points,
      subjectDeltas: baseData.subjectDeltas,
    );

    final isSocial = (widget.user?.stream ?? 'natural').toLowerCase() == 'social';
    final gradeBadgeText = 'G12 • ${isSocial ? 'Social Science' : 'Natural Science'}';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 22, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==================================================================
          // TOP SECTION HEADER & TIMEFRAME SWITCHER
          // ==================================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'PERFORMANCE & ANALYTICS',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentSoftColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          gradeBadgeText,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Inline Sync / Refresh Button with 3-Dots Wave Loader
              AcedexBounceable(
                onTap: _isRefreshing ? null : _handleRefresh,
                child: Container(
                  height: 34,
                  width: 36,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: lineColor),
                  ),
                  alignment: Alignment.center,
                  child: _isRefreshing
                      ? AcedexDotsLoader(
                          color: accentColor,
                          dotSize: 3.5,
                          gap: 2.5,
                        )
                      : HugeIcon(
                          icon: HugeIcons.strokeRoundedRefresh,
                          color: accentColor,
                          size: 16,
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Gliding 3-Tab Segmented Timeframe Switcher
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
                for (final tf in ProgressTimeframe.values)
                  Expanded(
                    child: AcedexBounceable(
                      onTap: () {
                        if (_activeTimeframe != tf) {
                          setState(() {
                            _activeTimeframe = tf;
                            _simulatedTotalScore = null;
                            _simulatedPercentile = null;
                            _simulatedReadinessPct = null;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _activeTimeframe == tf ? cardBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          border: _activeTimeframe == tf ? Border.all(color: lineColor) : null,
                          boxShadow: _activeTimeframe == tf
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
                          tf.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _activeTimeframe == tf ? accentColor : subtextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ==================================================================
          // CARD 1: EUEE EXAM READINESS HERO CARD
          // ==================================================================
          ReadinessHeroCard(
            data: currentData,
            activePillar: _activePillar,
            onPillarSelected: (pillar) => setState(() => _activePillar = pillar),
            onOpenSimulator: _openScoreSimulator,
          ),

          const SizedBox(height: 16),

          // ==================================================================
          // CARD 2: INTERACTIVE STUDY & ACCURACY ANALYTICS CHART
          // ==================================================================
          StudyAnalyticsChartCard(data: currentData),

          const SizedBox(height: 16),

          // ==================================================================
          // CARD 3: 28-DAY STUDY CONSISTENCY HEATMAP
          // ==================================================================
          const ConsistencyHeatmapCard(days: ProgressData.heatmapDays),

          const SizedBox(height: 16),

          // ==================================================================
          // CARD 4: SUBJECT BREAKDOWN & MASTERY CARDS
          // ==================================================================
          SubjectMasterySection(
            subjects: _subjects,
            deltas: currentData.subjectDeltas,
            onSelectSubject: _openSubjectBreakdown,
          ),
        ],
      ),
    );
  }
}
