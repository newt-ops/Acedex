import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/models/user_profile.dart';
import 'core/storage/auth_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/ui.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/login_pin_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/splash/screens/loading_screen.dart';
import 'features/splash/screens/minimal_loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Full-screen edge-to-edge system chrome configuration
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  final storage = AuthStorage.instance;
  final token = await storage.getToken();
  final profile = await storage.getProfile();
  final hasSeenOnboarding = await storage.hasSeenOnboarding();
  final hasSeenSplash = await storage.hasSeenSplash();
  final lastPhone = await storage.getLastPhone() ?? profile?.phone;

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('acedex_theme_mode');
  if (savedTheme == 'light') {
    AcedexApp.themeModeNotifier.value = ThemeMode.light;
  } else if (savedTheme == 'dark') {
    AcedexApp.themeModeNotifier.value = ThemeMode.dark;
  } else {
    AcedexApp.themeModeNotifier.value = ThemeMode.system;
  }

  runApp(AcedexApp(
    initialUser: token != null ? profile : null,
    hasSeenOnboarding: hasSeenOnboarding,
    hasSeenSplash: hasSeenSplash,
    lastPhone: lastPhone,
    requirePinOnLaunch: true,
  ));
}

class AcedexApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString('acedex_theme_mode', str);
    } catch (_) {}
  }

  static void toggleTheme(BuildContext context) {
    final current = themeModeNotifier.value;
    switch (current) {
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
    }
  }

  final UserProfile? initialUser;
  final bool hasSeenOnboarding;
  final bool hasSeenSplash;
  final String? lastPhone;
  final bool requirePinOnLaunch;

  const AcedexApp({
    super.key,
    this.initialUser,
    this.hasSeenOnboarding = false,
    this.hasSeenSplash = false,
    this.lastPhone,
    this.requirePinOnLaunch = false,
  });

  @override
  Widget build(BuildContext context) {
    final String initialRouteName = (initialUser != null && !requirePinOnLaunch)
        ? '/home'
        : (hasSeenSplash ? '/loading/minimal' : '/loading');

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Acedex',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AcedexScrollBehavior(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: initialRouteName,
          routes: {
            '/loading': (context) => const LoadingScreen(),
            '/loading/minimal': (context) =>
                MinimalLoadingScreen(lastPhone: lastPhone),
            '/auth': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              final prefilledPhone = args?['prefilledPhone'] as String?;
              return AuthScreen(initialPhone: prefilledPhone);
            },
            '/auth/pin': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              final phone = args?['phone'] as String? ?? lastPhone ?? '';
              return LoginPinScreen(phone: phone);
            },
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) {
              final user = ModalRoute.of(context)?.settings.arguments
                      as UserProfile? ??
                  initialUser;
              return HomeScreen(user: user);
            },
          },
        );
      },
    );
  }
}
