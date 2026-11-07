import 'package:flutter/material.dart';
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

    expect(find.text('Acedex Today'), findsOneWidget);
    expect(find.text('Curriculum Database'), findsOneWidget);
    expect(find.text('App Security & PIN'), findsOneWidget);
    expect(find.text('Student Profile'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Theme Mode'), findsOneWidget);

    await testDb.close();
  });
}
