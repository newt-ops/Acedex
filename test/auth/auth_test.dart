import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/auth/auth_state.dart';
import 'package:acedex/features/auth/screens/login_screen.dart';
import 'package:acedex/features/auth/screens/signup_screen.dart';

void main() {
  test('AcedexAuthState immutability and status checks', () {
    const initial = AcedexAuthState();
    expect(initial.status, AuthStatus.initial);
    expect(initial.isAuthenticated, isFalse);
    expect(initial.isLoading, isFalse);
    expect(initial.user, isNull);

    final loading = initial.copyWith(status: AuthStatus.loading);
    expect(loading.isLoading, isTrue);

    final error = initial.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Invalid password',
    );
    expect(error.status, AuthStatus.error);
    expect(error.errorMessage, 'Invalid password');
  });

  testWidgets('LoginScreen renders fields and buttons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Acedex'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('SignUpScreen renders fields and title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SignUpScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Join Acedex'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
