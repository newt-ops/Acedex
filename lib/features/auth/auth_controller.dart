import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AcedexAuthState>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<AcedexAuthState> {
  AuthController() : super(const AcedexAuthState()) {
    _init();
  }

  StreamSubscription<AuthState>? _sub;

  void _init() {
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: currentUser,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }

      _sub = SupabaseService.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: session.user,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
          );
        }
      });
    } catch (_) {
      // In offline / test mode when Supabase isn't initialized yet
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final res = await SupabaseService.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: res.user,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Unable to connect. Please check your internet connection.',
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final res = await SupabaseService.auth.signUp(
        email: email.trim(),
        password: password,
        data: name != null && name.trim().isNotEmpty
            ? {'full_name': name.trim()}
            : null,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: res.user,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to create account. Please try again.',
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await SupabaseService.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.aymen.acedex://login-callback',
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google Sign-In failed. Please try again.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.auth.signOut();
    } catch (_) {}
    state = const AcedexAuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> resetPassword(String email) async {
    try {
      await SupabaseService.auth.resetPasswordForEmail(email.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
