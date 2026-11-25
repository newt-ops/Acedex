import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../models/progress_models.dart';
import '../services/progress_analytics_service.dart';
import '../widgets/consistency_heatmap_card.dart';
import '../widgets/readiness_hero_card.dart';
import '../widgets/score_simulator_sheet.dart';
import '../widgets/study_analytics_chart_card.dart';

/// Clean Apple-Style Progress & Performance Analytics Inside Screen (Tab 3: Progress)
///
/// Features:
/// - Zero Top Header Bar & Zero Bottom Navigation Bar (rendered by shell)
/// - 130px bottom scroll padding clearing the concave notch navigation bar
/// - Timeframe Switcher ("7 Days" | "30 Days" | "All Term")
/// - Card 1: Live EUEE Exam Readiness Hero Card + interactive pillars + What-If Simulator Sheet (with English & SAT)
/// - Card 2: Interactive Live Study & Accuracy Chart with horizontal scrubbing
/// - Card 3: Live 28-Day Study Consistency Heatmap (4×7 grid)
class ProgressScreen extends StatefulWidget {
  final UserProfile? user;
  final ProgressAnalyticsRepository? analyticsRepository;

  const ProgressScreen({
    super.key,
    this.user,
    this.analyticsRepository,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressTimeframe _activeTimeframe = ProgressTimeframe.sevenDays;
  ReadinessPillarType _activePillar = ReadinessPillarType.coverage;

  late ProgressAnalyticsData _analytics;
  bool _hasServerData = false;

  // Custom simulated overrides from the What-If Simulator
  int? _simulatedTotalScore;
  String? _simulatedPercentile;
  int? _simulatedReadinessPct;

  ProgressAnalyticsRepository get _repository =>
      widget.analyticsRepository ?? ProgressAnalyticsService.instance;

  @override
  void initState() {
    super.initState();
    _analytics = _buildLocalBaseline();
    AuthStorage.instance.completedUnitsNotifier.addListener(_onLocalActivityChanged);
    AuthStorage.instance.dailyFocusCompletedMinutesNotifier.addListener(_onLocalActivityChanged);
    AuthStorage.instance.dailyFocusGoalMinutesNotifier.addListener(_onLocalActivityChanged);
    unawaited(_loadAnalytics());
  }

  @override
  void dispose() {
    AuthStorage.instance.completedUnitsNotifier.removeListener(_onLocalActivityChanged);
    AuthStorage.instance.dailyFocusCompletedMinutesNotifier.removeListener(_onLocalActivityChanged);
    AuthStorage.instance.dailyFocusGoalMinutesNotifier.removeListener(_onLocalActivityChanged);
    super.dispose();
  }

  ProgressAnalyticsData _buildLocalBaseline() {
    return ProgressAnalyticsData.emptyBaseline(
      stream: widget.user?.stream ?? 'natural',
      dailyGoalMinutes: AuthStorage.instance.dailyFocusGoalMinutesNotifier.value,
      completedUnitsCount: AuthStorage.instance.completedUnitsNotifier.value.length,
      todayCompletedMinutes: AuthStorage.instance.dailyFocusCompletedMinutesNotifier.value,
    );
  }

  void _onLocalActivityChanged() {
    if (!mounted) return;
    if (!_hasServerData) {
      setState(() {
        _analytics = _buildLocalBaseline();
      });
    } else {
      unawaited(_fetchRemoteAnalytics());
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final cached = await _repository.getCachedAnalytics();
      if (mounted && cached != null) {
        setState(() {
          _analytics = cached;
          _hasServerData = true;
        });
      }
    } catch (_) {
      // Ignore cache read failures
    }

    await _fetchRemoteAnalytics();
  }

  Future<void> _fetchRemoteAnalytics() async {
    try {
      final live = await _repository.fetchAnalytics();
      if (mounted) {
        setState(() {
          _analytics = live;
          _hasServerData = true;
        });
      }
    } catch (_) {
      // Offline / unauthenticated fallback keeps real 0-baseline or cached server analytics
    }
  }

  void _openScoreSimulator() {
    final subjects = _analytics.simulatorSubjects.isNotEmpty
        ? _analytics.simulatorSubjects
        : ProgressAnalyticsData.defaultSimulatorSubjects(widget.user?.stream ?? 'natural');

    ScoreSimulatorSheet.show(
      context,
      subjects: subjects,
      onApplyTarget: (newTotalScore, newPercentile, newPct) {
        setState(() {
          _simulatedTotalScore = newTotalScore;
          _simulatedPercentile = newPercentile;
          _simulatedReadinessPct = newPct;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final baseData = _analytics.timeframes[_activeTimeframe] ??
        _buildLocalBaseline().timeframes[_activeTimeframe]!;

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
      completedUnits: baseData.completedUnits,
      totalUnits: baseData.totalUnits,
      assessmentsCount: baseData.assessmentsCount,
      dailyGoalMinutes: baseData.dailyGoalMinutes,
      activeDays: baseData.activeDays,
      windowDays: baseData.windowDays,
      footerHours: baseData.footerHours,
      footerAcc: baseData.footerAcc,
      footerQs: baseData.footerQs,
      points: baseData.points,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 22, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==================================================================
          // TOP SECTION HEADER & TIMEFRAME SWITCHER
          // ==================================================================
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
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: theme.colorScheme.onSurface,
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
          ConsistencyHeatmapCard(
            days: _analytics.heatmapDays,
            currentStreak: _analytics.currentStreak,
            longestStreak: _analytics.longestStreak,
          ),
        ],
      ),
    );
  }
}
