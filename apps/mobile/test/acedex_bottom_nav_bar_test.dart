import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:acedex/core/ui/ui.dart';

void main() {
  group('AcedexBottomNavBar Widget Tests', () {
    testWidgets('renders all 5 canonical study navigation slots without labels',
        (WidgetTester tester) async {
      int selectedIndex = 2; // Default AI Study

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return AcedexBottomNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify all 5 slots exist by keys
      expect(find.byKey(const Key('nav-slot-0')), findsOneWidget); // Home
      expect(find.byKey(const Key('nav-slot-1')), findsOneWidget); // Study
      expect(find.byKey(const Key('nav-slot-2')), findsOneWidget); // AI Study
      expect(find.byKey(const Key('nav-slot-3')), findsOneWidget); // Progress
      expect(find.byKey(const Key('nav-slot-4')), findsOneWidget); // Profile

      // Verify no floating text readout above the bar
      expect(find.text('AI Study'), findsNothing);

      // Tap 'Home' slot (Slot 0)
      final homeSlotFinder = find.byKey(const Key('nav-slot-0'));
      await tester.tap(homeSlotFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Active index should now be 0
      expect(selectedIndex, 0);
    });

    testWidgets('tapping active circle triggers 3-dot wave loader action',
        (WidgetTester tester) async {
      int selectedIndex = 0;
      bool circleTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AcedexBottomNavBar(
              currentIndex: selectedIndex,
              onTap: (_) {},
              onActiveCircleTap: () {
                circleTapped = true;
              },
            ),
          ),
        ),
      );

      // Find the elevated circle and tap it
      final circleFinder = find.byWidgetPredicate((widget) {
        return widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
            widget.constraints?.maxWidth == 50.0;
      });

      expect(circleFinder, findsOneWidget);
      await tester.tap(circleFinder);
      await tester.pump();

      expect(circleTapped, isTrue);

      // AcedexDotsLoader should now be active inside the elevated circle
      expect(find.byType(AcedexDotsLoader), findsOneWidget);

      // Advance past the 1100ms action duration
      await tester.pump(const Duration(milliseconds: 1200));

      // After 1100ms, dots loader disappears
      expect(find.byType(AcedexDotsLoader), findsNothing);
    });

    testWidgets('supports dragging / scrubbing across navigation slots',
        (WidgetTester tester) async {
      int selectedIndex = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return AcedexBottomNavBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Scrub from center to slot 4 (right side)
      final navBarFinder = find.byType(AcedexBottomNavBar);
      await tester.drag(navBarFinder, const Offset(120, 0));
      await tester.pumpAndSettle();

      // Should have navigated to Profile (Slot 4)
      expect(selectedIndex, 4);
    });

    testWidgets('works with custom navigation items',
        (WidgetTester tester) async {
      int selectedIndex = 0;

      final customItems = [
        const AcedexNavItem(
          label: 'Dashboard',
          icon: HugeIcons.strokeRoundedHome01,
        ),
        const AcedexNavItem(
          label: 'Favorites',
          icon: HugeIcons.strokeRoundedBookmark02,
        ),
        const AcedexNavItem(
          label: 'Account',
          icon: HugeIcons.strokeRoundedUserCircle,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AcedexBottomNavBar(
              currentIndex: selectedIndex,
              items: customItems,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(AcedexBottomNavBar), findsOneWidget);
    });
  });
}
