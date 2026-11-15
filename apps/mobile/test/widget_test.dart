import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/main.dart';

void main() {
  testWidgets('AcedexApp smoke test loads BackendHealthCheckScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AcedexApp());

    expect(find.text('ACEDEX'), findsOneWidget);
    expect(find.text('Mobile Client'), findsOneWidget);
    expect(find.text('Target Backend API'), findsOneWidget);
    expect(find.text('System Status'), findsOneWidget);
  });
}
