import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/config/feature_flags.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/dashboard_data.dart';
import '../widgets/curriculum_bento_grid.dart';
import '../widgets/formula_flashcards_carousel.dart';
import '../widgets/hero_countdown_card.dart';
import '../widgets/study_plan_section.dart';

/// Clean Apple-Style Inside Dashboard Screen (Tab 0: Home)
class DashboardScreen extends StatefulWidget {
  final UserProfile? user;
  final VoidCallback? onNavigateToStudy;
  final VoidCallback? onNavigateToAiStudy;
  final List<StudyTaskItem>? initialTasks;
  final int? initialUnitsMastered;
  final int? initialTotalUnits;
  final double? initialAccuracyPct;
  final DateTime? initialExamDate;

  const DashboardScreen({
    super.key,
    this.user,
    this.onNavigateToStudy,
    this.onNavigateToAiStudy,
    this.initialTasks,
    this.initialUnitsMastered,
    this.initialTotalUnits,
    this.initialAccuracyPct,
    this.initialExamDate,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int get _readinessScore {
    final completedCount =
        AuthStorage.instance.completedUnitsNotifier.value.length;
    final effectiveMastered =
        completedCount > _unitsMastered ? completedCount : _unitsMastered;
    final total = _totalUnits > 0 ? _totalUnits : 237;
    if (effectiveMastered == 0) return 0;
    return ((effectiveMastered / total) * 100).round().clamp(0, 100);
  }

  bool _standingIsAllTime = false;

  static int _parseDurationMinutes(String duration) {
    int total = 0;
    final hourMatch =
        RegExp(r'(\d+)\s*h', caseSensitive: false).firstMatch(duration);
    if (hourMatch != null) {
      total += (int.tryParse(hourMatch.group(1)!) ?? 0) * 60;
    }
    final minMatch =
        RegExp(r'(\d+)\s*(?:m|min)', caseSensitive: false).firstMatch(duration);
    if (minMatch != null) {
      total += int.tryParse(minMatch.group(1)!) ?? 0;
    }
    if (total == 0) {
      total =
          int.tryParse(RegExp(r'\d+').firstMatch(duration)?.group(0) ?? '') ??
              0;
    }
    return total;
  }

  int get _calculatedFocusMinutes {
    final planCompletedMins = _tasks
        .where((t) => t.completed)
        .fold<int>(0, (sum, t) => sum + _parseDurationMinutes(t.duration));
    final storedTaskMins =
        AuthStorage.instance.dailyFocusCompletedMinutesNotifier.value;
    return planCompletedMins + storedTaskMins;
  }

  int get _calculatedFocusGoalMinutes {
    final calibratedGoal =
        AuthStorage.instance.dailyFocusGoalMinutesNotifier.value;
    if (calibratedGoal > 0) return calibratedGoal;
    final totalPlanMins = _tasks.fold<int>(
      0,
      (sum, t) => sum + _parseDurationMinutes(t.duration),
    );
    return totalPlanMins;
  }

  // Live Curriculum Pulse Metrics (Database: 237 units across G9-12)
  late int _unitsMastered;
  late int _totalUnits;
  late double _accuracyPct;
  late DateTime _examDate;

  late List<StudyTaskItem> _tasks;
  late final List<FlashcardItem> _flashcards;

  @override
  void initState() {
    super.initState();
    AuthStorage.instance.completedUnitsNotifier
        .addListener(_onExternalMetricsChanged);
    AuthStorage.instance.dailyFocusGoalMinutesNotifier
        .addListener(_onExternalMetricsChanged);
    AuthStorage.instance.dailyFocusCompletedMinutesNotifier
        .addListener(_onExternalMetricsChanged);
    _tasks = widget.initialTasks != null
        ? List.from(widget.initialTasks!)
        : List.from(defaultStudyTasks);
    _flashcards = defaultFlashcardsData;

    _unitsMastered = widget.initialUnitsMastered ?? 0;
    _totalUnits = widget.initialTotalUnits ?? 237;
    _accuracyPct = widget.initialAccuracyPct ?? 0.0;
    final now = DateTime.now();
    final defaultExamDate = now.isBefore(DateTime(now.year, 6, 8, 9, 0))
        ? DateTime(now.year, 6, 8, 9, 0)
        : DateTime(now.year + 1, 6, 8, 9, 0);
    _examDate = widget.initialExamDate ?? defaultExamDate;

    unawaited(_fetchLiveDashboardData());
    unawaited(AuthStorage.instance.getCompletedUnits());
    unawaited(AuthStorage.instance.loadDailyFocus());
  }

  @override
  void dispose() {
    AuthStorage.instance.completedUnitsNotifier
        .removeListener(_onExternalMetricsChanged);
    AuthStorage.instance.dailyFocusGoalMinutesNotifier
        .removeListener(_onExternalMetricsChanged);
    AuthStorage.instance.dailyFocusCompletedMinutesNotifier
        .removeListener(_onExternalMetricsChanged);
    super.dispose();
  }

  void _onExternalMetricsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchLiveDashboardData() async {
    try {
      final pulseRes = await ApiClient.instance.get(
        ApiEndpoints.curriculumPulse,
        requiresAuth: true,
      );
      final data = pulseRes['data'] ?? pulseRes;
      if (mounted) {
        setState(() {
          _totalUnits = (data['totalUnits'] as num?)?.toInt() ?? _totalUnits;
          _unitsMastered =
              (data['unitsMastered'] as num?)?.toInt() ?? _unitsMastered;
          _accuracyPct = (data['accuracy'] as num?)?.toDouble() ?? _accuracyPct;
        });
      }
    } catch (_) {
      // Offline fallback: keep real baseline (237 units from database)
    }

    try {
      final countdownRes = await ApiClient.instance.get(
        ApiEndpoints.examCountdown,
        requiresAuth: false,
      );
      final data = countdownRes['data'] ?? countdownRes;
      final targetStr = data['targetDate'] as String?;
      if (targetStr != null && mounted) {
        final parsed = DateTime.tryParse(targetStr);
        if (parsed != null) {
          setState(() {
            _examDate = parsed;
          });
        }
      }
    } catch (_) {
      // Offline fallback: June 8, 2026
    }
  }

  void _onToggleStanding() {
    setState(() {
      _standingIsAllTime = !_standingIsAllTime;
    });
  }

  void _onToggleTask(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final current = _tasks[index];
        _tasks[index] = current.copyWith(completed: !current.completed);
      }
    });
  }

  void _onAddTask(String title, String subject, String duration) {
    setState(() {
      _tasks.add(
        StudyTaskItem(
          id: 'task-${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          subject: subject,
          duration: duration,
          completed: false,
        ),
      );
    });
  }

  void _onAddStudyPlan(StudyTaskItem item) {
    setState(() {
      _tasks.add(item);
    });
  }

  void _onDeleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.user?.displayName.isNotEmpty == true)
          ExcludeSemantics(
            excluding: true,
            child: SizedBox.shrink(
              child: Text(
                widget.user!.displayName,
                style: const TextStyle(fontSize: 0, height: 0),
              ),
            ),
          ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeroCountdownCard(
                readinessScore: _readinessScore,
                targetDate: _examDate,
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<Set<String>>(
                valueListenable: AuthStorage.instance.completedUnitsNotifier,
                builder: (context, completedUnits, _) {
                  final effectiveUnitsMastered = completedUnits.isNotEmpty
                      ? completedUnits.length
                      : _unitsMastered;

                  return CurriculumBentoGrid(
                    unitsMastered: effectiveUnitsMastered,
                    totalUnits: _totalUnits,
                    accuracyPercentage: _accuracyPct,
                    focusMinutes: _calculatedFocusMinutes,
                    focusGoalMinutes: _calculatedFocusGoalMinutes,
                    standingIsAllTime: _standingIsAllTime,
                    onToggleStanding: _onToggleStanding,
                  );
                },
              ),
              const SizedBox(height: 20),
              StudyPlanSection(
                tasks: _tasks,
                onToggleTask: _onToggleTask,
                onAddTask: _onAddTask,
                onAddStudyPlan: _onAddStudyPlan,
                onDeleteTask: _onDeleteTask,
              ),
              if (FeatureFlags.enableFlashcards) ...[
                const SizedBox(height: 20),
                FormulaFlashcardsCarousel(
                  flashcards: _flashcards,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
