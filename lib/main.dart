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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const AcedexApp(),
    ),
  );
}

class AcedexApp extends ConsumerWidget {
  const AcedexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      home: const DesignSystemShowcaseScreen(),
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
  int _navIndex = 0;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      appBar: AppBar(
        title: const Text('Acedex Design System'),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: HugeIcon(
              icon: isDark
                  ? HugeIcons.strokeRoundedSun01
                  : HugeIcons.strokeRoundedMoon02,
              color: colors.primary,
              size: 22,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleLightDark(
                    MediaQuery.platformBrightnessOf(context),
                  );
            },
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: AcedexFloatingNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
        items: navItems,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space16,
          AppTheme.space8,
          AppTheme.space16,
          100.0,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
                title: 'Primary Action Triggered',
                message: 'Apple HIG Plum palette button tapped.',
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
                title: 'Secondary Action',
                message: '14% primarySoft background button tapped.',
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
                label: 'Danger Notice',
                color: colors.danger,
                leading: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancelCircle,
                  color: colors.danger,
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
