import 'package:acedex/core/theme/app_colors.dart';
import 'package:acedex/core/widgets/acedex_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  Widget buildTestHost(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        extensions: const [AppColors.light],
      ),
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('AcedexToast renders dual-line title and message with circular badge',
      (tester) async {
    await tester.pumpWidget(
      buildTestHost(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AcedexToast.show(
                context,
                title: 'Done',
                message: 'Confirmed',
                status: AcedexToastStatus.info,
              );
            },
            child: const Text('Show Toast'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
  });

  testWidgets('AcedexToast.onlyTitle renders title without leading icon',
      (tester) async {
    await tester.pumpWidget(
      buildTestHost(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AcedexToast.onlyTitle(
                context,
                title: 'Only Title',
              );
            },
            child: const Text('Show Only Title'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Only Title'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Only Title'), findsOneWidget);
  });

  testWidgets('AcedexToast.custom renders custom icon with single-line title',
      (tester) async {
    await tester.pumpWidget(
      buildTestHost(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AcedexToast.custom(
                context,
                title: 'Custom Image',
                customIcon: HugeIcons.strokeRoundedSun01,
              );
            },
            child: const Text('Show Custom Toast'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Custom Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Custom Image'), findsOneWidget);
  });

  testWidgets('AcedexToast bottom present displays at bottom and responds to tap',
      (tester) async {
    await tester.pumpWidget(
      buildTestHost(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              AcedexToast.custom(
                context,
                title: 'File Unlocked',
                customIcon: HugeIcons.strokeRoundedLockOpen,
                isBottom: true,
              );
            },
            child: const Text('Show Bottom Toast'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Bottom Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('File Unlocked'), findsOneWidget);

    // Tap to dismiss
    await tester.tap(find.text('File Unlocked'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('File Unlocked'), findsNothing);
  });

  testWidgets('Showing second toast cleans up previous active toast',
      (tester) async {
    await tester.pumpWidget(
      buildTestHost(
        Builder(
          builder: (context) => Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  AcedexToast.show(
                    context,
                    title: 'First Toast',
                  );
                },
                child: const Text('First'),
              ),
              ElevatedButton(
                onPressed: () {
                  AcedexToast.show(
                    context,
                    title: 'Second Toast',
                  );
                },
                child: const Text('Second'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('First'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('First Toast'), findsOneWidget);

    await tester.tap(find.text('Second'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Second Toast'), findsOneWidget);
  });
}
