import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:acedex/main.dart';
import 'package:acedex/core/theme/theme_provider.dart';
import 'package:acedex/core/database/database_provider.dart';
import 'package:acedex/core/database/database.dart';

void main() {
  testWidgets('AcedexApp loads design system showcase cleanly', (WidgetTester tester) async {
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

    expect(find.text('Acedex Today'), findsOneWidget);
    expect(find.text('Curriculum Database'), findsOneWidget);
    expect(find.text('App Security & PIN Lock'), findsOneWidget);
    expect(find.text('Theme Mode'), findsOneWidget);

    await testDb.close();
  });
}
