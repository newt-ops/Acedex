import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://kqrkkmyvpziapxpwiqoe.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_mvkPMEyuPOrriQKJzecIIA_S9O-TfcY';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxcmtrbXl2cHppYXB4cHdpcW9lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM5NzUzMTEsImV4cCI6MjEwOTU1MTMxMX0.NAKpI1pkUSlCiluQOrOuNdjBpQdxyHmilWKWxBpclfY';

  static bool get isInitialized {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static SupabaseClient? get clientOrNull {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static GoTrueClient get auth => Supabase.instance.client.auth;

  static GoTrueClient? get authOrNull {
    try {
      return Supabase.instance.client.auth;
    } catch (_) {
      return null;
    }
  }

  static User? get currentUser => authOrNull?.currentUser;
  static String? get currentUserId => authOrNull?.currentUser?.id;
  static bool get isAuthenticated => currentUser != null;
}

/// Riverpod provider for SupabaseClient instance
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  return SupabaseService.clientOrNull;
});

/// Riverpod stream provider for real-time authentication state
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final auth = SupabaseService.authOrNull;
  if (auth != null) {
    return auth.onAuthStateChange;
  }
  return const Stream.empty();
});

/// Riverpod provider for currently authenticated user
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateChangesProvider);
  return SupabaseService.currentUser;
});
