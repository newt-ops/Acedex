import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = AuthStorage.instance;
  final token = await storage.getToken();
  final profile = await storage.getProfile();
  final hasSeenOnboarding = await storage.hasSeenOnboarding();

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

  const AcedexApp({
    super.key,
    this.initialUser,
    this.hasSeenOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
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
          initialRoute: initialUser != null ? '/home' : '/loading',
          routes: {
            '/loading': (context) => const LoadingScreen(),
            '/auth': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              final prefilledPhone = args?['prefilledPhone'] as String?;
              return AuthScreen(initialPhone: prefilledPhone);
            },
            '/auth/pin': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              final phone = args?['phone'] as String? ?? '';
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
