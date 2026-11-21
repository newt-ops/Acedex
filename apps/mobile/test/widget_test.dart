import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/features/auth/screens/auth_screen.dart';
import 'package:acedex/features/home/screens/home_screen.dart';
import 'package:acedex/features/splash/screens/loading_screen.dart';
import 'package:acedex/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AcedexApp initial launch displays LoadingScreen then transitions to AuthScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AcedexApp());
    await tester.pump();

    // Initial route is LoadingScreen
    expect(find.byType(LoadingScreen), findsOneWidget);
    expect(find.text('Acedex'), findsOneWidget);

    // Advance timeline into Stage 3 and tap "I already have an account"
    await tester.pump(const Duration(milliseconds: 6700));

    expect(find.text('Ace every exam'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();

    // After navigating from loading, user is on AuthScreen (Login Gateway)
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Phone Number'), findsOneWidget);
  });

  testWidgets('AcedexApp with authenticated user directly launches HomeScreen',
      (WidgetTester tester) async {
    const user = UserProfile(
      id: 'usr_1',
      acedexId: 'ACX-26-1001',
      displayName: 'Abebe Kebede',
      phone: '+251912345678',
      gender: 'male',
      grade: 12,
      stream: 'natural',
      role: 'student',
      status: 'active',
    );

    await tester.pumpWidget(const AcedexApp(initialUser: user));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Abebe Kebede'), findsOneWidget);
  });
}
