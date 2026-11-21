import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../../onboarding/models/student_registration_draft.dart';
import '../../onboarding/widgets/student_id_card.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Future<void> _signOut(BuildContext context) async {
    await AuthStorage.instance.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final displayName = widget.user?.displayName.isNotEmpty == true
        ? widget.user!.displayName
        : 'Student';
    final gradeLabel = widget.user?.gradeLabel ?? 'High School';

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ACEDEX',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AcedexBadge(label: gradeLabel, variant: AcedexBadgeVariant.primary),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedLogout01,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              size: 20,
            ),
            onPressed: () => _signOut(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeDashboardView(user: widget.user, displayName: displayName),
          _StudyCurriculumView(gradeLabel: gradeLabel),
          const _PracticeExamView(),
          const _ProgressAnalyticsView(),
          _ProfileView(
            user: widget.user,
            displayName: displayName,
            gradeLabel: gradeLabel,
            onSignOut: () => _signOut(context),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: AcedexBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

/// Tab 0: Home Dashboard
class _HomeDashboardView extends StatelessWidget {
  final UserProfile? user;
  final String displayName;

  const _HomeDashboardView({
    required this.user,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Header
          Text(
            'Hello, $displayName',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ready to master your curriculum questions today?',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 24),

          // Streak & Daily Goals Card
          AcedexCard(
            variant: AcedexCardVariant.raised,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkWarning : AppColors.warning)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedFire,
                      color: isDark ? AppColors.darkWarning : AppColors.warning,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1 Day Streak',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete 10 practice questions to extend your streak',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Exam Preparation Banner
          AcedexCard(
            variant: AcedexCardVariant.raised,
            onTap: () {
              AcedexToast.show(
                context,
                message: 'Opening Practice Exam Engine...',
                type: AcedexToastType.success,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedShieldCheck,
                      size: 20,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'National Exam Practice',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Timed questions, step-by-step explanations, and real Ethiopian national entrance exam coverage.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                AcedexButton(
                  label: 'Start Practice Session',
                  variant: AcedexButtonVariant.primary,
                  size: AcedexButtonSize.md,
                  isFullWidth: true,
                  onPressed: () {
                    AcedexToast.show(
                      context,
                      message: 'Opening Practice Exam Engine...',
                      type: AcedexToastType.success,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Account summary on Home Tab
          AcedexCard(
            variant: AcedexCardVariant.flat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STUDENT PROFILE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileRow(label: 'Name', value: displayName),
                if (user?.phone != null) _ProfileRow(label: 'Phone', value: user!.phone!),
                _ProfileRow(label: 'Curriculum', value: user?.gradeLabel ?? 'High School'),
                if (user?.acedexId != null && user!.acedexId.isNotEmpty)
                  _ProfileRow(label: 'Candidate ID', value: user!.acedexId),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Tab 1: Study & Curriculum Journey
class _StudyCurriculumView extends StatelessWidget {
  final String gradeLabel;

  const _StudyCurriculumView({required this.gradeLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subjects = [
      {'name': 'Biology', 'units': '6 Units • 90 Questions', 'progress': '4/6 Completed'},
      {'name': 'Chemistry', 'units': '6 Units • 90 Questions', 'progress': '5/6 Completed'},
      {'name': 'Mathematics', 'units': '7 Units • 105 Questions', 'progress': '6/7 Completed'},
      {'name': 'Physics', 'units': '6 Units • 90 Questions', 'progress': '6/6 Completed'},
      {'name': 'English', 'units': '10 Units • 150 Questions', 'progress': '8/10 Completed'},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Study Curriculum',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track your unit study notes. Mark units finished to unlock exams.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 20),

          // Search / Filter
          AcedexTextField(
            hint: 'Search subjects, units, or definitions...',
            prefixIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              size: 20,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'ENROLLED SUBJECTS ($gradeLabel)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 12),

          for (final sub in subjects) ...[
            AcedexCard(
              variant: AcedexCardVariant.raised,
              onTap: () {
                AcedexToast.show(
                  context,
                  message: 'Opening ${sub['name']} study units...',
                  type: AcedexToastType.info,
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedBookOpen01,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub['name']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          sub['units']!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AcedexBadge(
                    label: sub['progress']!,
                    variant: AcedexBadgeVariant.neutral,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Tab 2: Practice & Exam Assessments (Elevated Center Action)
class _PracticeExamView extends StatelessWidget {
  const _PracticeExamView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Practice & Assessments',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Test your mastery with 15-question unit exams and national past papers.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 24),

          // Big Exam Start Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryAccent,
                  isDark ? const Color(0xFF6A1B82) : const Color(0xFF782390),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryAccent.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'TIMED ASSESSMENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedShieldCheck,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Full 15-Question Unit Test',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Timed delivery, server-side authoritative grading, and instant step-by-step explanations.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                AcedexButton(
                  label: 'Launch Assessment',
                  variant: AcedexButtonVariant.surface,
                  size: AcedexButtonSize.md,
                  isFullWidth: true,
                  leadingIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    color: primaryAccent,
                    size: 18,
                  ),
                  onPressed: () {
                    AcedexToast.show(
                      context,
                      message: 'Starting 15-question unit test...',
                      type: AcedexToastType.success,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'QUICK EXAM MODES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: AcedexCard(
                  variant: AcedexCardVariant.raised,
                  onTap: () {
                    AcedexToast.show(
                      context,
                      message: 'Opening National Exam Drills...',
                      type: AcedexToastType.info,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedNoteEdit,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'EUEE Drills',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Past national exams',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AcedexCard(
                  variant: AcedexCardVariant.raised,
                  onTap: () {
                    AcedexToast.show(
                      context,
                      message: 'Opening Weakness Review...',
                      type: AcedexToastType.info,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedFire,
                        color: AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Missed Bank',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Retry mistakes',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                        ),
                      ),
                    ],
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

/// Tab 3: Progress & Performance Analytics
class _ProgressAnalyticsView extends StatelessWidget {
  const _ProgressAnalyticsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stats = [
      {'title': 'Curriculum Mastery', 'value': '84%', 'detail': '29 of 35 Units Passed'},
      {'title': 'Average Score', 'value': '82.5%', 'detail': 'Benchmark: >=70%'},
      {'title': 'Questions Solved', 'value': '435', 'detail': 'Across all 5 subjects'},
      {'title': 'Current Streak', 'value': '1 Day', 'detail': 'Best: 14 Days'},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Diagnostic metrics across curriculum subjects and exam readiness.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 24),

          // 2x2 Metric Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: stats.map((s) {
              return AcedexCard(
                variant: AcedexCardVariant.raised,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s['title']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      ),
                    ),
                    Text(
                      s['value']!,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      s['detail']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Subject Mastery Breakdown
          AcedexCard(
            variant: AcedexCardVariant.flat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUBJECT MASTERY BREAKDOWN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                  ),
                ),
                const SizedBox(height: 16),
                _MasteryRow(subject: 'Physics', percent: 1.0, color: AppColors.success),
                _MasteryRow(subject: 'Mathematics', percent: 0.85, color: theme.colorScheme.primary),
                _MasteryRow(subject: 'Chemistry', percent: 0.83, color: theme.colorScheme.primary),
                _MasteryRow(subject: 'English', percent: 0.80, color: theme.colorScheme.primary),
                _MasteryRow(subject: 'Biology', percent: 0.67, color: AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryRow extends StatelessWidget {
  final String subject;
  final double percent;
  final Color color;

  const _MasteryRow({
    required this.subject,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 4: Student Profile & ID Card
class _ProfileView extends StatelessWidget {
  final UserProfile? user;
  final String displayName;
  final String gradeLabel;
  final VoidCallback onSignOut;

  const _ProfileView({
    required this.user,
    required this.displayName,
    required this.gradeLabel,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final draft = StudentRegistrationDraft(
      fullName: displayName,
      phoneNumber: user?.phone ?? '',
      gender: user?.gender ?? 'male',
      grade: user?.grade ?? 12,
      stream: user?.stream ?? 'natural',
      customCandidateId: user?.acedexId,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Candidate Profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your verified digital student credential and account details.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 20),

          // 3D Flippable Student ID Pass with Vector QR Code
          StudentIdCard(draft: draft),
          const SizedBox(height: 24),

          // Theme Selector
          AcedexCard(
            variant: AcedexCardVariant.flat,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Theme Appearance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const AcedexThemeToggle(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Account Details Card
          AcedexCard(
            variant: AcedexCardVariant.flat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCOUNT DETAILS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileRow(label: 'Name', value: displayName),
                if (user?.phone != null) _ProfileRow(label: 'Phone', value: user!.phone!),
                _ProfileRow(label: 'Curriculum', value: gradeLabel),
                if (user?.acedexId != null && user!.acedexId.isNotEmpty)
                  _ProfileRow(label: 'Candidate ID', value: user!.acedexId),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sign Out Button
          AcedexButton(
            label: 'Sign Out',
            variant: AcedexButtonVariant.outline,
            size: AcedexButtonSize.md,
            leadingIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedLogout01,
              color: isDark ? AppColors.darkText : AppColors.lightText,
              size: 18,
            ),
            isFullWidth: true,
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
