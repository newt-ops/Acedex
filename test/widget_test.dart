import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:acedex/main.dart';
import 'package:acedex/core/theme/theme_provider.dart';
import 'package:acedex/core/database/database_provider.dart';
import 'package:acedex/core/database/database.dart';

import 'package:acedex/features/onboarding/screens/intro_flow_screen.dart';
import 'package:acedex/features/onboarding/screens/intro_splash_screen.dart';
import 'package:acedex/features/onboarding/screens/intro_slides_screen.dart';

void main() {
  testWidgets('AcedexApp loads Intro flow on fresh install',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final testDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(testDb),
        ],
        child: const AcedexAppRoot(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Fresh install displays IntroFlowScreen starting with IntroSplashScreen
    expect(find.byType(IntroFlowScreen), findsOneWidget);
    expect(find.byType(IntroSplashScreen), findsOneWidget);

    // Fast forward past splash loading bar duration
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    // Now transitioned to 3D IntroSlidesScreen
    expect(find.byType(IntroSlidesScreen), findsOneWidget);
    expect(find.textContaining('Master', findRichText: true), findsWidgets);
    expect(find.textContaining('Offline', findRichText: true), findsWidgets);
    expect(find.text('Next  ›'), findsOneWidget);

    await testDb.close();
  });

  testWidgets('AcedexApp loads main shell when onboarding is completed',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'acedex_onboarding_completed': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final testDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(testDb),
        ],
        child: const AcedexAppRoot(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Acedex'), findsOneWidget);
    expect(find.text('Daily Study Target'), findsOneWidget);
    expect(find.text('My Curriculum'), findsOneWidget);
    expect(find.text('Study Streak'), findsOneWidget);

    // Verify Developer Test Lab button opens DeveloperShowcaseScreen
    final devButton = find.byTooltip('Developer Test Lab');
    expect(devButton, findsOneWidget);
    await tester.tap(devButton);
    await tester.pumpAndSettle();

    expect(find.text('Developer Test Lab'), findsOneWidget);
    expect(find.text('Curriculum Database'), findsOneWidget);
    expect(find.text('App Security & PIN'), findsOneWidget);

    await testDb.close();
  });
}
