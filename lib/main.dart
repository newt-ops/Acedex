import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hugeicons/hugeicons.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/database/database_provider.dart';
import 'core/database/curriculum_seeder.dart';
import 'core/widgets/acedex_button.dart';
import 'core/widgets/acedex_toast.dart';
import 'core/widgets/acedex_dialog.dart';
import 'core/widgets/acedex_badge.dart';
import 'core/widgets/acedex_input.dart';
import 'core/widgets/acedex_skeleton.dart';
import 'core/widgets/acedex_nav_bar.dart';
import 'core/widgets/acedex_header_bar.dart';
import 'core/services/supabase_service.dart';
import 'features/security/pin_provider.dart';
import 'features/security/screens/pin_setup_screen.dart';
import 'features/auth/app_gate.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/profile/student_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase initialization: $e');
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const AcedexAppRoot(),
    ),
  );
}

class AcedexAppRoot extends ConsumerStatefulWidget {
  const AcedexAppRoot({super.key});

  @override
  ConsumerState<AcedexAppRoot> createState() => _AcedexAppRootState();
}

class _AcedexAppRootState extends ConsumerState<AcedexAppRoot>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(pinProvider.notifier).onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(pinProvider.notifier).onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Acedex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
      ),
      home: const AppGate(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      const AcedexNavItem(
        icon: HugeIcons.strokeRoundedHome01,
        tooltip: 'Today',
      ),
      const AcedexNavItem(
        icon: HugeIcons.strokeRoundedBookOpen01,
        tooltip: 'Curriculum',
      ),
      const AcedexNavItem(
        icon: HugeIcons.strokeRoundedAnalytics01,
        tooltip: 'Analytics',
      ),
      const AcedexNavItem(
        icon: HugeIcons.strokeRoundedSettings02,
        tooltip: 'Settings',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          DesignSystemShowcaseScreen(),
          PlaceholderTabScreen(
            title: 'Curriculum & Units',
            icon: HugeIcons.strokeRoundedBookOpen01,
            description:
                'Ethiopian Grade 9–12 syllabus tracking with 3-stage mastery.',
          ),
          PlaceholderTabScreen(
            title: 'Study Analytics',
            icon: HugeIcons.strokeRoundedAnalytics01,
            description:
                'Weekly study time consistency charts and subject breakdown.',
          ),
          PlaceholderTabScreen(
            title: 'Settings & Profile',
            icon: HugeIcons.strokeRoundedSettings02,
            description:
                'App preferences, PIN security, and developer appreciation.',
          ),
        ],
      ),
      bottomNavigationBar: AcedexFloatingNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: navItems,
      ),
    );
  }
}

class PlaceholderTabScreen extends StatelessWidget {
  const PlaceholderTabScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final List<List<dynamic>> icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AcedexFloatingHeaderBar(title: title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(icon: icon, color: colors.primary, size: 32),
                ),
              ),
              const SizedBox(height: AppTheme.space16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DesignSystemShowcaseScreen extends ConsumerStatefulWidget {
  const DesignSystemShowcaseScreen({super.key});

  @override
  ConsumerState<DesignSystemShowcaseScreen> createState() =>
      _DesignSystemShowcaseScreenState();
}

class _DesignSystemShowcaseScreenState
    extends ConsumerState<DesignSystemShowcaseScreen> {
  bool _isSeeded = false;
  int _subjectCount = 0;
  int _chapterCount = 0;

  @override
  void initState() {
    super.initState();
    _checkAndSeedDatabase();
  }

  Future<void> _checkAndSeedDatabase() async {
    final db = ref.read(databaseProvider);
    await CurriculumSeeder.seedIfEmpty(db);
    final subjects = (await db.select(db.subjects).get()).length;
    final chapters = (await db.select(db.chapters).get()).length;
    if (mounted) {
      setState(() {
        _isSeeded = true;
        _subjectCount = subjects;
        _chapterCount = chapters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final currentThemeMode = ref.watch(themeModeProvider);
    final pinState = ref.watch(pinProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AcedexFloatingHeaderBar(
        title: 'Acedex Today',
        subtitle: 'Ethiopian EUEE Preparation',
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedGraduationScroll,
              color: colors.primary,
              size: 18,
            ),
          ),
        ),
        actions: [
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Curriculum Database',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      AcedexBadge(
                        label: _isSeeded ? 'Seeded & Ready' : 'Seeding...',
                        color: _isSeeded ? colors.success : colors.warning,
                        leading: HugeIcon(
                          icon: _isSeeded
                              ? HugeIcons.strokeRoundedCheckmarkCircle02
                              : HugeIcons.strokeRoundedClock01,
                          color: _isSeeded ? colors.success : colors.warning,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space12),
                  Text(
                    'Local Drift SQLite initialized with $_subjectCount subjects and $_chapterCount curriculum units.',
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedLockPassword,
                              color: colors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.space8),
                            Flexible(
                              child: Text(
                                'App Security & PIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.space8),
                      AcedexBadge(
                        label: pinState.isPinEnabled ? 'Active' : 'Disabled',
                        color: pinState.isPinEnabled
                            ? colors.success
                            : colors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space12),
                  Text(
                    'Lock Acedex with a custom on-screen numeric keypad whenever the app is reopened.',
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppTheme.space16),
                  Row(
                    children: [
                      Expanded(
                        child: AcedexButton(
                          label: pinState.isPinEnabled
                              ? 'Disable PIN'
                              : 'Set PIN Lock',
                          variant: pinState.isPinEnabled
                              ? AcedexButtonVariant.danger
                              : AcedexButtonVariant.primary,
                          onPressed: () async {
                            if (pinState.isPinEnabled) {
                              await ref.read(pinProvider.notifier).disablePin();
                              if (context.mounted) {
                                AcedexToast.show(
                                  context,
                                  title: 'PIN Removed',
                                  message: 'PIN lock has been turned off.',
                                  status: AcedexToastStatus.info,
                                );
                              }
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PinSetupScreen(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      if (pinState.isPinEnabled) ...[
                        const SizedBox(width: AppTheme.space8),
                        AcedexButton(
                          label: 'Lock Now',
                          variant: AcedexButtonVariant.secondary,
                          isFullWidth: false,
                          onPressed: () {
                            ref.read(pinProvider.notifier).onAppResumed();
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          Consumer(
            builder: (context, ref, _) {
              final studentAsync = ref.watch(studentStateProvider);
              final student = studentAsync.value;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedUser,
                                  color: colors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.space8),
                                Flexible(
                                  child: Text(
                                    'Student Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.space8),
                          AcedexBadge(
                            label: student != null
                                ? 'Grade ${student.grade}'
                                : 'Guest',
                            color: student != null
                                ? colors.success
                                : colors.warning,
                            leading: HugeIcon(
                              icon: student != null
                                  ? HugeIcons.strokeRoundedCheckmarkCircle02
                                  : HugeIcons.strokeRoundedClock01,
                              color: student != null
                                  ? colors.success
                                  : colors.warning,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space12),
                      if (student != null) ...[
                        Text(
                          '${student.name} (${student.email})',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Daily Target: ${student.dailyGoalMinutes} min/day  |  Streak Freezes: ${student.streakFreezes}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'No student profile active yet. Launch onboarding or sign in to configure your grade and academic stream.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTheme.space16),
                      Row(
                        children: [
                          Expanded(
                            child: AcedexButton(
                              label: 'Onboarding',
                              variant: AcedexButtonVariant.primary,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OnboardingScreen(
                                      onCompleted: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppTheme.space8),
                          Expanded(
                            child: AcedexButton(
                              label: 'Sign In',
                              variant: AcedexButtonVariant.secondary,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(
                                      onLoginSuccess: () =>
                                          Navigator.of(context).pop(),
                                      onSkip: () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space8),
                      Row(
                        children: [
                          Expanded(
                            child: AcedexButton(
                              label: 'Sign Up',
                              variant: AcedexButtonVariant.secondary,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SignUpScreen(
                                      onSignUpSuccess: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppTheme.space8),
                          Expanded(
                            child: AcedexButton(
                              label: 'Reset Profile',
                              variant: AcedexButtonVariant.secondary,
                              onPressed: () async {
                                await ref
                                    .read(studentStateProvider.notifier)
                                    .resetForTesting();
                                if (context.mounted) {
                                  AcedexToast.show(
                                    context,
                                    title: 'Profile Reset',
                                    message: 'You can test onboarding again.',
                                    status: AcedexToastStatus.info,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.space16),
          Text(
            'Theme Mode',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Row(
            children: [
              Expanded(
                child: AcedexButton(
                  label: 'System',
                  variant: currentThemeMode == ThemeMode.system
                      ? AcedexButtonVariant.primary
                      : AcedexButtonVariant.secondary,
                  onPressed: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.system),
                ),
              ),
              const SizedBox(width: AppTheme.space8),
              Expanded(
                child: AcedexButton(
                  label: 'Light',
                  variant: currentThemeMode == ThemeMode.light
                      ? AcedexButtonVariant.primary
                      : AcedexButtonVariant.secondary,
                  onPressed: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: AppTheme.space8),
              Expanded(
                child: AcedexButton(
                  label: 'Dark',
                  variant: currentThemeMode == ThemeMode.dark
                      ? AcedexButtonVariant.primary
                      : AcedexButtonVariant.secondary,
                  onPressed: () => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space20),
          Text(
            'Buttons',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          AcedexButton(
            label: 'Primary Button',
            variant: AcedexButtonVariant.primary,
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedBookOpen01,
              color: colors.onPrimary,
              size: 20,
            ),
            onPressed: () {
              AcedexToast.show(
                context,
                title: 'Done',
                message: 'Confirmed',
                status: AcedexToastStatus.success,
              );
            },
          ),
          const SizedBox(height: AppTheme.space8),
          AcedexButton(
            label: 'Secondary Button',
            variant: AcedexButtonVariant.secondary,
            onPressed: () {
              AcedexToast.show(
                context,
                title: 'Study Goal Saved',
                status: AcedexToastStatus.info,
              );
            },
          ),
          const SizedBox(height: AppTheme.space8),
          AcedexButton(
            label: 'Danger Button',
            variant: AcedexButtonVariant.danger,
            onPressed: () async {
              final confirmed = await AcedexDialog.showConfirmation(
                context,
                title: 'Reset Study Streak?',
                message: 'This will reset your consecutive study days.',
                confirmLabel: 'Reset',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                AcedexToast.show(
                  context,
                  title: 'Streak Reset',
                  message: 'Action completed.',
                  status: AcedexToastStatus.danger,
                );
              }
            },
          ),
          const SizedBox(height: AppTheme.space20),
          Text(
            'Inputs',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          AcedexInput(
            label: 'Student Name',
            hintText: 'e.g. Aymen Newton',
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: colors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(height: AppTheme.space20),
          Text(
            'Badges',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Wrap(
            spacing: AppTheme.space8,
            runSpacing: AppTheme.space8,
            children: [
              AcedexBadge(
                label: 'Mastered',
                color: colors.secondary,
                leading: HugeIcon(
                  icon: HugeIcons.strokeRoundedAward01,
                  color: colors.secondary,
                  size: 14,
                ),
              ),
              AcedexBadge(
                label: 'Completed',
                color: colors.primary,
                leading: HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: colors.primary,
                  size: 14,
                ),
              ),
              AcedexBadge(
                label: 'Streak: 14 Days',
                color: colors.warning,
                leading: HugeIcon(
                  icon: HugeIcons.strokeRoundedFire,
                  color: colors.warning,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space20),
          Text(
            'Apple Capsule Toasts',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Wrap(
            spacing: AppTheme.space8,
            runSpacing: AppTheme.space8,
            children: [
              AcedexButton(
                label: 'Done / Confirmed',
                variant: AcedexButtonVariant.secondary,
                onPressed: () {
                  AcedexToast.show(
                    context,
                    title: 'Done',
                    message: 'Confirmed',
                    status: AcedexToastStatus.info,
                    badgeColor: const Color(0xFF007AFF),
                  );
                },
              ),
              AcedexButton(
                label: 'Custom Image',
                variant: AcedexButtonVariant.secondary,
                onPressed: () {
                  AcedexToast.custom(
                    context,
                    title: 'Custom Image',
                    customIcon: HugeIcons.strokeRoundedSun01,
                    iconColor: const Color(0xFFF5A623),
                  );
                },
              ),
              AcedexButton(
                label: 'Only Title',
                variant: AcedexButtonVariant.secondary,
                onPressed: () {
                  AcedexToast.onlyTitle(context, title: 'Only Title');
                },
              ),
              AcedexButton(
                label: 'Bottom Present',
                variant: AcedexButtonVariant.secondary,
                onPressed: () {
                  AcedexToast.custom(
                    context,
                    title: 'File Unlocked',
                    customIcon: HugeIcons.strokeRoundedLockOpen,
                    iconColor: const Color(0xFF34C759),
                    isBottom: true,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space20),
          Text(
            'Skeleton Shimmer',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          const AcedexSkeleton(height: 56, width: double.infinity),
        ],
      ),
    );
  }
}
