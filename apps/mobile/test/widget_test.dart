import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/main.dart';
import 'package:acedex/features/onboarding/screens/onboarding_screen.dart';
import 'package:acedex/features/auth/screens/auth_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AcedexApp initial launch displays OnboardingScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AcedexApp(hasSeenOnboarding: false));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Master Every Subject'), findsOneWidget);
    expect(find.text('Grades 9 – 12'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('AcedexApp with onboarding completed displays AuthScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AcedexApp(hasSeenOnboarding: true));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('6-Digit Security PIN'), findsOneWidget);
  });
}
