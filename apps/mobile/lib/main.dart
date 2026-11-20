import 'package:flutter/material.dart';
import 'core/models/user_profile.dart';
import 'core/storage/auth_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/ui.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = AuthStorage.instance;
  final token = await storage.getToken();
  final profile = await storage.getProfile();
  final hasSeenOnboarding = await storage.hasSeenOnboarding();

  runApp(AcedexApp(
    initialUser: token != null ? profile : null,
    hasSeenOnboarding: hasSeenOnboarding,
  ));
}

class AcedexApp extends StatelessWidget {
  final UserProfile? initialUser;
  final bool hasSeenOnboarding;

  const AcedexApp({
    super.key,
    this.initialUser,
    this.hasSeenOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acedex',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AcedexScrollBehavior(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialUser != null
          ? '/home'
          : (hasSeenOnboarding ? '/auth' : '/onboarding'),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final initialTab = (args?['initialTab'] as int?) ?? 0;
          return AuthScreen(initialTab: initialTab);
        },
        '/home': (context) {
          final user = ModalRoute.of(context)?.settings.arguments
                  as UserProfile? ??
              initialUser;
          return HomeScreen(user: user);
        },
      },
    );
  }
}
