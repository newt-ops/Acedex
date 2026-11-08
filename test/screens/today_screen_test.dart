import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:acedex/core/theme/theme_provider.dart';
import 'package:acedex/core/database/database_provider.dart';
import 'package:acedex/core/database/database.dart';
import 'package:acedex/features/today/screens/today_screen.dart';
import 'package:acedex/features/settings/screens/settings_screen.dart';
import 'package:acedex/features/developer/screens/developer_showcase_screen.dart';

void main() {
  late AppDatabase testDb;

  setUp(() {
    testDb = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await testDb.close();
  });

  testWidgets('TodayScreen renders academic dashboard components',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(testDb),
        ],
        child: const MaterialApp(
          home: TodayScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Acedex'), findsOneWidget);
    expect(find.textContaining('Countdown'), findsOneWidget);
    expect(find.text('Daily Study Target'), findsOneWidget);
    expect(find.text('Study Streak'), findsOneWidget);
    expect(find.text('Streak Freezes'), findsOneWidget);
    expect(find.text('Start Focus Timer'), findsOneWidget);
    expect(find.text('Log Hours'), findsOneWidget);
    expect(find.text('My Curriculum'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('EUEE Study Strategy'), findsOneWidget);
  });

  testWidgets('SettingsScreen renders profile, security, and developer lab item',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(testDb),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Settings & Security'), findsOneWidget);
    expect(find.text('Student Account'), findsOneWidget);
    expect(find.text('Security & Biometrics'), findsOneWidget);
    expect(find.text('Developer Test Lab'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
  });

  testWidgets('DeveloperShowcaseScreen renders sandbox controls',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(testDb),
        ],
        child: const MaterialApp(
          home: DeveloperShowcaseScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Developer Test Lab'), findsOneWidget);
    expect(find.text('Curriculum Database'), findsOneWidget);
    expect(find.text('App Security & PIN'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('Buttons (Zero Glow)'), findsOneWidget);
  });
}
