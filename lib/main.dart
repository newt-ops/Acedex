import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hugeicons/hugeicons.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/acedex_nav_bar.dart';
import 'core/widgets/acedex_header_bar.dart';
import 'core/services/supabase_service.dart';
import 'core/database/database.dart';
import 'core/database/database_provider.dart';
import 'core/database/curriculum_seeder.dart';
import 'features/security/pin_provider.dart';
import 'features/auth/app_gate.dart';
import 'features/today/screens/today_screen.dart';
import 'features/curriculum/screens/curriculum_screen.dart';
import 'features/settings/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase initialization: $e');
  }

  final db = AppDatabase();
  try {
    await CurriculumSeeder.seedIfEmpty(db);
  } catch (e) {
    debugPrint('Database seeding error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
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
        children: [
          TodayScreen(
            onNavigateToCurriculum: () => _onTabSelected(1),
          ),
          const CurriculumScreen(),
          const PlaceholderTabScreen(
            title: 'Study Analytics',
            icon: HugeIcons.strokeRoundedAnalytics01,
            description:
                'Weekly study time consistency charts and subject breakdown.',
          ),
          const SettingsScreen(),
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
