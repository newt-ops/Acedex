import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/storage/auth_storage.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/auth/screens/auth_screen.dart';
import 'package:acedex/features/auth/screens/login_pin_screen.dart';
import 'package:acedex/features/splash/screens/loading_screen.dart';
import 'package:acedex/features/splash/screens/minimal_loading_screen.dart';
import 'package:acedex/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorage.instance.clear();
  });

  testWidgets('MinimalLoadingScreen renders Apple-style minimal UI elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MinimalLoadingScreen(
          duration: Duration(seconds: 10),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Acedex'), findsOneWidget);
    expect(find.text('EUEE STUDY ENVIRONMENT'), findsOneWidget);
    expect(find.byType(MinimalLoadingScreen), findsOneWidget);
  });

  testWidgets(
      'MinimalLoadingScreen with saved phone auto-redirects to /auth/pin with prefilled phone',
      (WidgetTester tester) async {
    await AuthStorage.instance.saveLastPhone('+251912345678');

    String? receivedPhone;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/loading/minimal',
        routes: {
          '/loading/minimal': (context) => const MinimalLoadingScreen(
                duration: Duration(milliseconds: 100),
                lastPhone: '+251912345678',
              ),
          '/auth/pin': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            receivedPhone = args?['phone'] as String?;
            return Scaffold(
              body: Text('PIN Screen for $receivedPhone'),
            );
          },
        },
      ),
    );

    // Initial minimal loading screen
    expect(find.byType(MinimalLoadingScreen), findsOneWidget);

    // Advance duration past 100ms
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('PIN Screen for +251912345678'), findsOneWidget);
    expect(receivedPhone, equals('+251912345678'));
  });

  testWidgets(
      'MinimalLoadingScreen with no saved phone redirects to /auth',
      (WidgetTester tester) async {
    await AuthStorage.instance.clear();

    bool navigatedToAuth = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/loading/minimal',
        routes: {
          '/loading/minimal': (context) => const MinimalLoadingScreen(
                duration: Duration(milliseconds: 100),
              ),
          '/auth': (context) {
            navigatedToAuth = true;
            return const Scaffold(body: Text('Auth Gateway'));
          },
        },
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(navigatedToAuth, isTrue);
    expect(find.text('Auth Gateway'), findsOneWidget);
  });

  testWidgets(
      'AcedexApp on first launch displays rich LoadingScreen (first-time splash)',
      (WidgetTester tester) async {
    await AuthStorage.instance.clear();

    await tester.pumpWidget(
      const AcedexApp(
        hasSeenSplash: false,
        requirePinOnLaunch: true,
      ),
    );
    await tester.pump();

    // First time opens to LoadingScreen
    expect(find.byType(LoadingScreen), findsOneWidget);
    expect(find.byType(MinimalLoadingScreen), findsNothing);
  });

  testWidgets(
      'AcedexApp returning user with saved phone opens minimal loading then redirects to PIN screen',
      (WidgetTester tester) async {
    await AuthStorage.instance.saveLastPhone('+251913951112');
    await AuthStorage.instance.setSeenSplash(true);

    await tester.pumpWidget(
      const AcedexApp(
        hasSeenSplash: true,
        lastPhone: '+251913951112',
        requirePinOnLaunch: true,
      ),
    );
    await tester.pump();

    // Starts on MinimalLoadingScreen
    expect(find.byType(MinimalLoadingScreen), findsOneWidget);

    // Advance minimal loading duration (~1400ms)
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Seamlessly transitions to LoginPinScreen with prefilled phone
    expect(find.byType(LoginPinScreen), findsOneWidget);
    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.text('+251 91 395 1112'), findsOneWidget);
    expect(find.text('Switch Account'), findsOneWidget);
  });

  testWidgets(
      'LoginPinScreen Switch Account button redirects to /auth',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/auth/pin',
        routes: {
          '/auth/pin': (context) => const LoginPinScreen(
                phone: '+251913951112',
              ),
          '/auth': (context) => const AuthScreen(),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Switch Account'), findsOneWidget);
    await tester.tap(find.text('Switch Account'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
  });
}
