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
          const _SearchQuestionsView(),
          const _AiScanView(),
          const _SavedQuestionsView(),
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
                message: 'Practice engine starting up...',
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
                      message: 'Practice engine starting up...',
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

/// Tab 1: Search Questions & Topics
class _SearchQuestionsView extends StatelessWidget {
  const _SearchQuestionsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Search Curriculum',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Find questions by topic, subject, or national exam year.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 20),

          // Search Input Bar
          AcedexTextField(
            hint: 'Search questions, formulas, or concepts...',
            prefixIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              size: 20,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'POPULAR SUBJECTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Mathematics',
              'Physics',
              'Chemistry',
              'Biology',
              'English',
              'Aptitude',
            ].map((subject) {
              return AcedexBadge(
                label: subject,
                variant: AcedexBadgeVariant.neutral,
                onTap: () {
                  AcedexToast.show(
                    context,
                    message: 'Browsing $subject questions...',
                    type: AcedexToastType.info,
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          AcedexCard(
            variant: AcedexCardVariant.raised,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedBookOpen01,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Exam Papers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse past Ethiopian University Entrance Examinations (EUEE) categorized by subject.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    height: 1.4,
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

/// Tab 2: AI Scan & Problem Solver
class _AiScanView extends StatelessWidget {
  const _AiScanView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'AI Question Scanner',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Point your camera at any question to get step-by-step explanations.',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Camera Viewfinder Simulation
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: primaryAccent.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AcedexAiScanIcon(color: primaryAccent, size: 54),
                      const SizedBox(height: 12),
                      Text(
                        'Align question in viewfinder',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AcedexButton(
            label: 'Scan & Solve with AI',
            variant: AcedexButtonVariant.primary,
            size: AcedexButtonSize.lg,
            isFullWidth: true,
            leadingIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedScan,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              AcedexToast.show(
                context,
                message: 'AI Question Scanner launching...',
                type: AcedexToastType.info,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tab 3: Saved Questions
class _SavedQuestionsView extends StatelessWidget {
  const _SavedQuestionsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Saved Questions',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Review flagged questions and bookmarked explanations.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            ),
          ),
          const SizedBox(height: 24),

          AcedexCard(
            variant: AcedexCardVariant.raised,
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedBookmark02,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bookmarks Collection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Questions you bookmark during practice will appear here.',
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
