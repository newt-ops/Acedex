import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/onboarding/models/student_registration_draft.dart';
import 'package:acedex/features/onboarding/widgets/student_id_card.dart';

void main() {
  const testDraft = StudentRegistrationDraft(
    fullName: 'Abebe Bikila',
    phoneNumber: '+251911234567',
    gender: 'male',
    grade: 12,
    stream: 'natural',
  );

  testWidgets('StudentIdCard renders Front face initially with candidate details',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: StudentIdCard(draft: testDraft),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Front face elements
    expect(find.text('ACEDEX NATIONAL EDUCATION'), findsOneWidget);
    expect(find.text('OFFICIAL CANDIDATE PASS'), findsOneWidget);
    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.text('Abebe Bikila'), findsOneWidget);
    expect(find.text('+251911234567'), findsOneWidget);
    expect(find.text('CANDIDATE ID'), findsOneWidget);
    expect(find.text(testDraft.candidateId), findsOneWidget);
  });

  testWidgets('StudentIdCard flips 180 degrees to Back face on tap, displaying QR code and curriculum',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: StudentIdCard(draft: testDraft),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap to flip card
    await tester.tap(find.byType(StudentIdCard));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 700));

    // Back face elements
    expect(find.text('DIGITAL CREDENTIAL BACK'), findsOneWidget);
    expect(find.text('ENROLLED CURRICULUM & QR'), findsOneWidget);
    expect(find.text('ENROLLED SUBJECTS'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Technical Math'), findsOneWidget);
    expect(find.text('ESSLCE 2026 • Addis Ababa, ET'), findsOneWidget);
    expect(find.text('PIN Encrypted'), findsOneWidget);

    // Official QR Code image is present
    expect(find.byType(QrImageView), findsOneWidget);

    // Tap again to flip back to Front
    await tester.tap(find.byType(StudentIdCard));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 700));

    expect(find.text('OFFICIAL CANDIDATE PASS'), findsOneWidget);
  });
}
