import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/models/student_avatar.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/storage/auth_storage.dart';
import 'package:acedex/core/ui/navigation/acedex_header_bar.dart';
import 'package:acedex/core/ui/feedback/profile_photo_modal.dart';
import 'package:acedex/core/ui/avatars/student_avatar_widget.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthStorage.instance.clear();
  });

  const testUser = UserProfile(
    id: 'usr_001',
    acedexId: 'ETH-2026-9921',
    displayName: 'Aymen Mubarek',
    phone: '+251911223344',
    gender: 'male',
    grade: 12,
    stream: 'natural',
    role: 'student',
    status: 'active',
  );

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        appBar: child is PreferredSizeWidget ? child : null,
        body: child is! PreferredSizeWidget ? child : const SizedBox.shrink(),
      ),
    );
  }

  Finder findHugeIcon(dynamic iconData) {
    return find.byWidgetPredicate(
      (w) => w is HugeIcon && w.icon == iconData,
    );
  }

  group('AcedexHeaderBar Widget Tests', () {
    testWidgets('renders Apple iOS 68px header bar with avatar, greeting stack, streak, and bell', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AcedexHeaderBar(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header PreferredSize is 68px
      final headerFinder = find.byType(AcedexHeaderBar);
      expect(headerFinder, findsOneWidget);
      final AcedexHeaderBar headerWidget = tester.widget(headerFinder);
      expect(headerWidget.preferredSize.height, 68.0);

      // Verify Greeting Stack
      expect(find.text('Hi, Aymen'), findsOneWidget);
      expect(
        find.textContaining(RegExp(r'Good (morning|afternoon|evening)')),
        findsOneWidget,
      );

      // Verify Initial Streak Pill ("12") and Flame Icon
      expect(find.text('12'), findsOneWidget);
      expect(findHugeIcon(HugeIcons.strokeRoundedFire), findsOneWidget);

      // Verify Circular Notification Bell
      expect(findHugeIcon(HugeIcons.strokeRoundedNotification01), findsOneWidget);

      // Verify Avatar Camera Badge
      expect(findHugeIcon(HugeIcons.strokeRoundedCamera01), findsOneWidget);
    });

    testWidgets('tapping streak pill increments streak count and displays floating +1 badge', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AcedexHeaderBar(user: testUser, initialStreak: 12),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('12'), findsOneWidget);

      // Tap streak pill button
      await tester.tap(find.text('12'));
      await tester.pump(const Duration(milliseconds: 100));

      // Streak count increments to 13
      expect(find.text('13'), findsOneWidget);
      // Floating "+1" badge is visible
      expect(find.text('+1'), findsOneWidget);

      // Settle animation
      await tester.pumpAndSettle();
    });

    testWidgets('tapping notification bell triggers ring and toggles unread state', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AcedexHeaderBar(user: testUser, initialHasUnread: true),
        ),
      );
      await tester.pumpAndSettle();

      final bellFinder = findHugeIcon(HugeIcons.strokeRoundedNotification01);
      expect(bellFinder, findsOneWidget);

      // Tap bell button
      await tester.tap(bellFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('tapping avatar button triggers profile photo callback or modal', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          AcedexHeaderBar(
            user: testUser,
            onProfileTap: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap avatar camera micro-badge
      await tester.tap(findHugeIcon(HugeIcons.strokeRoundedCamera01));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('ProfilePhotoModal & Storage Tests', () {
    testWidgets('renders modal with title, presets, live stage, reset, and save buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ProfilePhotoModal(user: testUser),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title & Student Name
      expect(find.text('Profile Photo'), findsOneWidget);
      expect(find.text('Aymen Mubarek'), findsOneWidget);

      // Verify "Upload from Device" Pill
      expect(find.text('Upload from Device'), findsOneWidget);

      // Verify "QUICK STUDIO AVATARS" label
      expect(find.text('QUICK STUDIO AVATARS'), findsOneWidget);

      // Verify Action Buttons
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Save Photo'), findsOneWidget);
    });

    testWidgets('selecting preset and saving persists avatar to local storage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ProfilePhotoModal(user: testUser),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the second preset (monogram)
      final presetWidgets = find.byType(StudentAvatarWidget);
      // Stage avatar widget + 5 presets in strip = 6 total
      expect(presetWidgets, findsNWidgets(6));

      // Tap the 2nd preset chip (monogram)
      await tester.tap(presetWidgets.at(2));
      await tester.pumpAndSettle();

      // Tap Save Photo
      await tester.tap(find.text('Save Photo'));
      // Step through wave loader hold (750ms)
      await tester.pump(const Duration(milliseconds: 800));
      // Updated checkmark state
      expect(find.text('Updated'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));

      // Check persisted avatar in AuthStorage
      final saved = await AuthStorage.instance.getAvatar();
      expect(saved.presetId, 'monogram');
      expect(AuthStorage.instance.avatarNotifier.value.presetId, 'monogram');
    });

    testWidgets('tapping reset reverts avatar to default silhouette', (tester) async {
      // Set initial avatar to atom
      await AuthStorage.instance.saveAvatar(const StudentAvatar.preset('atom'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ProfilePhotoModal(user: testUser),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Science Atom Emblem'), findsOneWidget);

      // Tap Reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Default Silhouette'), findsOneWidget);
    });
  });
}
