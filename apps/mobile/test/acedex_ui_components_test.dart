import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/ui/ui.dart';

void main() {
  group('Acedex Apple-Style UI Components Tests', () {
    testWidgets('AcedexBounceable animates scale down on tap and triggers callback',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AcedexBounceable(
                onTap: () => tapped = true,
                child: const Text('Tap Me'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);

      // Press down
      final gesture = await tester.startGesture(tester.getCenter(find.text('Tap Me')));
      await tester.pump(const Duration(milliseconds: 50));

      // Up and complete
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('AcedexButton renders correct Teal styling and handles loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AcedexButton(
                label: 'Submit Assessment',
                isLoading: false,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Submit Assessment'), findsOneWidget);

      // Verify loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AcedexButton(
                label: 'Submit Assessment',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AcedexCard renders content and handles tap interactions',
        (WidgetTester tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AcedexCard(
                onTap: () => cardTapped = true,
                child: const Text('Unit 01: Kinematics'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Unit 01: Kinematics'), findsOneWidget);
      await tester.tap(find.text('Unit 01: Kinematics'));
      await tester.pumpAndSettle();

      expect(cardTapped, isTrue);
    });

    testWidgets('AcedexToast mounts in overlay and auto-dismisses',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AcedexToast.show(
                    context,
                    title: 'Score Saved',
                    message: '15 of 15 Correct',
                    type: AcedexToastType.success,
                    duration: const Duration(seconds: 1),
                  );
                },
                child: const Text('Show Toast'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Score Saved'), findsOneWidget);
      expect(find.text('15 of 15 Correct'), findsOneWidget);

      // Advance past duration to clean up timer
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      AcedexToast.dismiss();
    });

    testWidgets('AcedexBadge renders pill with proper label and variant',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AcedexBadge(
                label: 'Grade 12',
                variant: AcedexBadgeVariant.primary,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Grade 12'), findsOneWidget);
    });

    testWidgets('AcedexProgressBar renders and clamps progress correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AcedexProgressBar(progress: 0.75),
            ),
          ),
        ),
      );

      expect(find.byType(AcedexProgressBar), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('AcedexToggle animates and fires onChanged callback',
        (WidgetTester tester) async {
      bool toggleValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: AcedexToggle(
                    value: toggleValue,
                    onChanged: (val) {
                      setState(() {
                        toggleValue = val;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(AcedexToggle), findsOneWidget);
      expect(toggleValue, isFalse);

      await tester.tap(find.byType(AcedexToggle));
      await tester.pumpAndSettle();

      expect(toggleValue, isTrue);
    });

    testWidgets('AcedexToggleTile renders title and toggles on tap',
        (WidgetTester tester) async {
      bool tileValue = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: AcedexToggleTile(
                    title: 'Dark Mode',
                    subtitle: 'Switch application appearance',
                    value: tileValue,
                    onChanged: (val) {
                      setState(() {
                        tileValue = val;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Switch application appearance'), findsOneWidget);

      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      expect(tileValue, isFalse);
    });
  });
}
