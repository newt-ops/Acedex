import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AcedexAuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AcedexAuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;

  AcedexAuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AcedexAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
