import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/practice/screens/practice_screen.dart';

void main() {
  const testUser = UserProfile(
    id: 'usr_test_practice',
    acedexId: 'ACX-26-0001',
    displayName: 'Abebe Bikila',
    phone: '+251911223344',
    gender: 'male',
    grade: 12,
    stream: 'natural',
    role: 'student',
    status: 'active',
  );

  testWidgets('PracticeScreen renders clean placeholder state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: PracticeScreen(user: testUser),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready for New Feature'), findsOneWidget);
  });
}
