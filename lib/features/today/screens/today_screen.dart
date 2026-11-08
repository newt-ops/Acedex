import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/widgets/acedex_button.dart';
import '../../../core/widgets/acedex_badge.dart';
import '../../../core/widgets/acedex_header_bar.dart';
import '../../../core/widgets/acedex_toast.dart';
import '../../profile/student_provider.dart';
import '../../developer/screens/developer_showcase_screen.dart';

/// The primary Home / Today study dashboard for Ethiopian secondary students.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({
    super.key,
    this.onNavigateToCurriculum,
  });

  final VoidCallback? onNavigateToCurriculum;

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  int _calculateEueeCountdown() {
    // EUEE typically takes place in early July in Ethiopia
    final now = DateTime.now();
    var targetDate = DateTime(now.year, 7, 5);
    if (now.isAfter(targetDate)) {
      targetDate = DateTime(now.year + 1, 7, 5);
    }
    return targetDate.difference(now).inDays;
  }

  List<List<dynamic>> _getSubjectIcon(String code, String name) {
    final lower = (name + code).toLowerCase();
    if (lower.contains('physic')) return HugeIcons.strokeRoundedAtom02;
    if (lower.contains('chem')) return HugeIcons.strokeRoundedTestTube01;
    if (lower.contains('bio')) return HugeIcons.strokeRoundedDna01;
    if (lower.contains('math')) return HugeIcons.strokeRoundedCalculate;
    if (lower.contains('eng')) return HugeIcons.strokeRoundedBookOpen01;
    if (lower.contains('geo')) return HugeIcons.strokeRoundedGlobe02;
    if (lower.contains('hist')) return HugeIcons.strokeRoundedHourglass;
    if (lower.contains('econ')) return HugeIcons.strokeRoundedCoins01;
    if (lower.contains('it') || lower.contains('comp')) return HugeIcons.strokeRoundedComputer;
    return HugeIcons.strokeRoundedNotebook;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentAsync = ref.watch(studentStateProvider);
    final student = studentAsync.value;
    final db = ref.watch(databaseProvider);

    final grade = student?.grade ?? 11;
    final stream = student?.stream ?? 'natural';
    final studentName = student?.name ?? 'Scholar';
    final dailyGoal = student?.dailyGoalMinutes ?? 120;
    final streak = student?.streakCount ?? 1;
    final freezes = student?.streakFreezes ?? 1;
    final daysToEuee = _calculateEueeCountdown();

    return Scaffold(
      appBar: AcedexFloatingHeaderBar(
        title: 'Acedex',
        subtitle: student != null
            ? 'Grade $grade • ${stream[0].toUpperCase()}${stream.substring(1)} Stream'
            : 'Ethiopian EUEE Preparation',
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              isDark
                  ? 'assets/logo/in_app/acedex_icon_dark_64.png'
                  : 'assets/logo/in_app/acedex_icon_plum_64.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          // Developer Feature Testing Lab Button
          IconButton(
            tooltip: 'Developer Test Lab',
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedCommandLine,
              color: colors.primary,
              size: 20,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DeveloperShowcaseScreen(),
                ),
              );
            },
          ),
          // Theme Toggle
          IconButton(
            tooltip: 'Toggle Theme',
            icon: HugeIcon(
              icon: isDark
                  ? HugeIcons.strokeRoundedSun01
                  : HugeIcons.strokeRoundedMoon02,
              color: colors.primary,
              size: 20,
            ),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .toggleLightDark(MediaQuery.platformBrightnessOf(context));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space16,
          AppTheme.space8,
          AppTheme.space16,
          110.0,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Hero Student Greeting & Motivation Card
          Container(
            padding: const EdgeInsets.all(AppTheme.space20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(
                color: colors.border,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, $studentName',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Consistency beats talent. Ready for your study goal?',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),
                // EUEE Countdown Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space12,
                    vertical: AppTheme.space8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        color: colors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.space8),
                      Text(
                        'EUEE Countdown: $daysToEuee days remaining',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space16),

          // 2. Study Streak & Freeze Retention Card
          Row(
            children: [
              // Streak Tile
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(
                      color: colors.border,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colors.warning.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedFire,
                                color: colors.warning,
                                size: 20,
                              ),
                            ),
                          ),
                          AcedexBadge(
                            label: 'Active',
                            color: colors.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space12),
                      Text(
                        '$streak Days',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Study Streak',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              // Freeze Tile
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(
                      color: colors.border,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedSnowflake,
                                color: Color(0xFF007AFF),
                                size: 20,
                              ),
                            ),
                          ),
                          AcedexBadge(
                            label: 'Protected',
                            color: const Color(0xFF007AFF),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space12),
                      Text(
                        '$freezes Left',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Streak Freezes',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),

          // 3. Today's Study Target Progress Card
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(
                color: colors.border,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedTarget02,
                          color: colors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.space8),
                        Text(
                          'Daily Study Target',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '0 / $dailyGoal min',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space12),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: LinearProgressIndicator(
                    value: 0.05,
                    minHeight: 8.0,
                    backgroundColor: colors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
                Row(
                  children: [
                    Expanded(
                      child: AcedexButton(
                        label: 'Start Focus Timer',
                        variant: AcedexButtonVariant.primary,
                        leading: HugeIcon(
                          icon: HugeIcons.strokeRoundedPlay,
                          color: colors.onPrimary,
                          size: 18,
                        ),
                        onPressed: () {
                          AcedexToast.custom(
                            context,
                            title: 'Focus Session Ready',
                            customIcon: HugeIcons.strokeRoundedClock01,
                            iconColor: colors.primary,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.space8),
                    AcedexButton(
                      label: 'Log Hours',
                      variant: AcedexButtonVariant.secondary,
                      isFullWidth: false,
                      leading: HugeIcon(
                        icon: HugeIcons.strokeRoundedClock01,
                        color: colors.primary,
                        size: 18,
                      ),
                      onPressed: () {
                        AcedexToast.show(
                          context,
                          title: 'Hours Logger',
                          message: 'Manual study logging is ready.',
                          status: AcedexToastStatus.info,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space20),

          // 4. Curriculum Quick Jump
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Curriculum',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              if (widget.onNavigateToCurriculum != null)
                GestureDetector(
                  onTap: widget.onNavigateToCurriculum,
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: colors.primary,
                        size: 14,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),

          // Stream subjects query
          FutureBuilder<List<Subject>>(
            future: (db.select(db.subjects)
                  ..where((tbl) =>
                      tbl.grade.equals(grade) &
                      (tbl.stream.equals(stream) | tbl.stream.equals('common')))
                  ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.space24),
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                );
              }

              final subjects = snapshot.data ?? [];
              if (subjects.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    'No curriculum subjects loaded for Grade $grade yet. Seed database from Developer Test Lab.',
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                children: subjects.take(4).map((subject) {
                  final icon = _getSubjectIcon(subject.code, subject.name);

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppTheme.space8),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: colors.border, width: 1.0),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        onTap: widget.onNavigateToCurriculum,
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.space16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: colors.primarySoft,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Center(
                                  child: HugeIcon(
                                    icon: icon,
                                    color: colors.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTheme.space12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${subject.totalUnits} Units • Grade ${subject.grade}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowRight01,
                                color: colors.textSecondary.withValues(alpha: 0.5),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: AppTheme.space16),

          // 5. Academic Strategy Tip
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.6),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedBulb,
                  color: colors.warning,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EUEE Study Strategy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mastering chapters in 3 stages (Not Started → Completed → Mastered) boosts long-term recall on Ethiopian national exams.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                          height: 1.35,
                        ),
                      ),
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

