import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:acedex/main.dart';
import 'package:acedex/core/theme/theme_provider.dart';
import 'package:acedex/core/database/database_provider.dart';
import 'package:acedex/core/database/database.dart';

void main() {
  testWidgets('AcedexApp loads Onboarding flow on fresh install',
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

    expect(find.text('Master Ethiopian Curriculum'), findsOneWidget);
    expect(find.text('100% Offline First'), findsOneWidget);
    expect(find.text('Consistency Streaks'), findsOneWidget);

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
