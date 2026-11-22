import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/profile/screens/profile_screen.dart';

void main() {
  const dummyUser = UserProfile(
    id: 'usr_test_1',
    acedexId: 'ACX-26-1194',
    displayName: 'Aymen Mubarek',
    phone: '+251 913 951 112',
    grade: 12,
    stream: 'natural',
    gender: 'male',
    role: 'student',
    status: 'active',
  );

  Future<void> pumpProfileScreen(
    WidgetTester tester, {
    VoidCallback? onSignOut,
  }) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ProfileScreen(
            user: dummyUser,
            onSignOut: onSignOut ?? () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all core inside components of ProfileScreen', (tester) async {
    await pumpProfileScreen(tester);

    // 1. Top Title Block
    expect(find.text('STUDENT CREDENTIALS'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);

    // 2. Candidate Pass Card Front Face
    expect(find.text('ACEDEX NATIONAL EDUCATION'), findsOneWidget);
    expect(find.text('OFFICIAL CANDIDATE PASS'), findsOneWidget);
    expect(find.text('Aymen Mubarek'), findsWidgets);
    expect(find.text('+251 913 951 112'), findsWidgets);
    expect(find.text('Male'), findsWidgets);
    expect(find.text('Grade 12'), findsWidgets);
    expect(find.text('Natural Science'), findsWidgets);
    expect(find.text('ACX-26-1194'), findsWidgets);
    expect(find.text('Flip Pass'), findsWidgets);

    // 3. Credential Export & Share QR Buttons
    expect(find.text('Export Credential'), findsOneWidget);
    expect(find.text('Share QR'), findsOneWidget);

    // 4. Exam Registration Card
    expect(find.text('EXAM REGISTRATION'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('ET-AA-26-084912'), findsOneWidget);
    expect(find.text('Bole Preparatory Center (Hall B-04)'), findsOneWidget);
    expect(find.textContaining('Hamle 14 – 18'), findsOneWidget);
    expect(find.text('View 6 Registered EUEE Subjects'), findsOneWidget);
    expect(find.text('Edit Registration Details'), findsOneWidget);

    // 5. Storage & Security Card
    expect(find.text('STORAGE & SECURITY'), findsOneWidget);
    expect(find.text('Offline Study Pack'), findsOneWidget);
    expect(find.text('6-Digit PIN & App Lock'), findsOneWidget);
    expect(find.text('Change 6-Digit PIN'), findsOneWidget);
    expect(find.text('Daily Study Reminders'), findsOneWidget);

    // 6. Theme & Sign Out
    expect(find.text('Theme Appearance'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('flipping candidate pass toggles between front and back faces', (tester) async {
    await pumpProfileScreen(tester);

    // Initially Front Face is visible
    expect(find.text('OFFICIAL CANDIDATE PASS'), findsOneWidget);
    expect(find.text('OFFICIAL DIGITAL SEAL'), findsNothing);

    // Tap Flip Pass
    await tester.tap(find.text('Flip Pass').first);
    await tester.pumpAndSettle();

    // Back Face is visible
    expect(find.text('OFFICIAL DIGITAL SEAL'), findsOneWidget);
    expect(find.text('EUEE Candidate Verification'), findsOneWidget);
    expect(find.text('DIGITAL SIGNATURE AUTHENTICATED'), findsOneWidget);
    expect(find.text('Bole Preparatory Center • Hall B-04'), findsOneWidget);
    expect(find.text('S-114'), findsOneWidget);

    // Tap Flip Pass on Back Face returns to Front Face
    await tester.tap(find.text('Flip Pass').first);
    await tester.pumpAndSettle();

    expect(find.text('OFFICIAL CANDIDATE PASS'), findsOneWidget);
  });

  testWidgets('tapping barcode triggers laser scan animation and toast', (tester) async {
    await pumpProfileScreen(tester);

    expect(find.text('Tap barcode to test scan'), findsOneWidget);

    // Tap the barcode area via its explicit key
    await tester.tap(find.byKey(const Key('candidate_barcode_tap')));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Toast is displayed
    expect(find.text('Barcode verified: ACX-26-1194'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
  });

  testWidgets('export credential button opens export sheet with formats and download action', (tester) async {
    await pumpProfileScreen(tester);

    await tester.tap(find.text('Export Credential'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Export Credential'), findsWidgets);
    expect(find.text('Official PDF'), findsOneWidget);
    expect(find.text('High-Res PNG'), findsOneWidget);
    expect(find.text('Wallet Pass'), findsOneWidget);
    expect(find.text('Download & Save'), findsOneWidget);

    // Tap High-Res PNG format pill
    await tester.tap(find.text('High-Res PNG'));
    await tester.pumpAndSettle();

    expect(find.textContaining('HIGH-RES PASS PNG'), findsOneWidget);

    // Tap Download & Save
    await tester.tap(find.text('Download & Save'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Sheet dismissed and toast shown
    expect(find.textContaining('exported & saved'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
  });

  testWidgets('share QR button opens share QR sheet with copyable verification link', (tester) async {
    await pumpProfileScreen(tester);

    await tester.tap(find.text('Share QR'));
    await tester.pumpAndSettle();

    expect(find.text('Share Candidate QR'), findsOneWidget);
    expect(find.text('acedex.edu.et/verify/ACX-26-1194'), findsOneWidget);
    expect(find.text('Copy Link'), findsOneWidget);

    // Tap Copy Link
    await tester.tap(find.text('Copy Link'));
    await tester.pumpAndSettle();

    expect(find.text('Copied ✓'), findsOneWidget);
    expect(find.text('Verification link copied'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
  });

  testWidgets('accordion expands to display 6 registered EUEE subjects', (tester) async {
    await pumpProfileScreen(tester);

    // Initially subjects are hidden
    expect(find.text('PHYS-12 • Hamle 14 • 08:30'), findsNothing);

    // Tap accordion header
    await tester.tap(find.text('View 6 Registered EUEE Subjects'));
    await tester.pumpAndSettle();

    expect(find.text('PHYS-12 • Hamle 14 • 08:30'), findsOneWidget);
    expect(find.text('MATH-12 • Hamle 15 • 08:30'), findsOneWidget);
    expect(find.text('CHEM-12 • Hamle 16 • 08:30'), findsOneWidget);
    expect(find.text('BIOL-12 • Hamle 17 • 08:30'), findsOneWidget);
    expect(find.text('ENGL-12 • Hamle 18 • 08:30'), findsOneWidget);
    expect(find.text('SAPT-12 • Hamle 18 • 14:00'), findsOneWidget);
  });

  testWidgets('edit registration details sheet saves updated student information', (tester) async {
    await pumpProfileScreen(tester);

    await tester.tap(find.text('Edit Registration Details'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Registration Details'), findsWidgets);
    expect(find.text('Save Changes'), findsOneWidget);

    // Enter new name
    await tester.enterText(find.widgetWithText(TextField, 'Aymen Mubarek'), 'Dawit Kebede');
    // Select Social Science
    await tester.tap(find.text('Social Science'));
    await tester.pumpAndSettle();

    // Tap Save Changes
    await tester.tap(find.text('Save Changes'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Sheet dismissed, updated name and stream displayed on pass
    expect(find.text('Dawit Kebede'), findsWidgets);
    expect(find.text('Social Science'), findsWidgets);
    expect(find.text('Registration details updated'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
  });

  testWidgets('offline sync button simulates sync and updates status label', (tester) async {
    await pumpProfileScreen(tester);

    expect(find.text('Sync'), findsOneWidget);
    expect(find.text('142 MB cached • Works offline'), findsOneWidget);

    await tester.tap(find.text('Sync'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Synced ✓'), findsOneWidget);
    expect(find.text('142 MB cached • Synced just now'), findsOneWidget);
    expect(find.text('Offline study pack synced'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
  });

  testWidgets('change 6-digit PIN keypad sheet inputs digits and encrypts', (tester) async {
    await pumpProfileScreen(tester);

    await tester.tap(find.text('Change 6-Digit PIN'));
    await tester.pumpAndSettle();

    expect(find.text('Set New 6-Digit PIN'), findsOneWidget);

    // Tap digits 1, 2, 3, 4, 5, 6
    for (int i = 1; i <= 6; i++) {
      await tester.tap(find.text('$i'));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Sheet dismissed and PIN updated toast shown
    expect(find.text('Set New 6-Digit PIN'), findsNothing);
    expect(find.text('6-Digit PIN updated'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
  });

  testWidgets('sign out button triggers onSignOut callback', (tester) async {
    bool didSignOut = false;
    await pumpProfileScreen(tester, onSignOut: () => didSignOut = true);

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(didSignOut, isTrue);
  });
}
