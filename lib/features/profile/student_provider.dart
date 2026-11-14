import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/theme_provider.dart';
import '../onboarding/models/onboarding_data.dart';

const String _onboardingCompleteKey = 'acedex_onboarding_completed';

final studentStateProvider =
    StateNotifierProvider<StudentNotifier, AsyncValue<Student?>>((ref) {
  final db = ref.watch(databaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return StudentNotifier(db, prefs);
});

final isOnboardingCompletedProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_onboardingCompleteKey) ?? false;
});

class StudentNotifier extends StateNotifier<AsyncValue<Student?>> {
  StudentNotifier(this._db, this._prefs) : super(const AsyncValue.loading()) {
    loadStudent();
  }

  final AppDatabase _db;
  final SharedPreferences _prefs;

  Future<void> loadStudent() async {
    try {
      final students = await _db.select(_db.students).get();
      if (students.isNotEmpty) {
        state = AsyncValue.data(students.first);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveStudentProfile({
    required OnboardingData onboardingData,
    String? userId,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final id = userId ??
          SupabaseService.currentUserId ??
          'local_${now.millisecondsSinceEpoch}';
      final studentEmail = email ??
          SupabaseService.currentUser?.email ??
          'student@acedex.app';

      final effectiveStream =
          (onboardingData.grade == 9 || onboardingData.grade == 10)
              ? 'common'
              : onboardingData.stream;

      final studentCompanion = StudentsCompanion.insert(
        id: id,
        email: studentEmail,
        name: onboardingData.name.trim().isEmpty
            ? 'Acedex Scholar'
            : onboardingData.name.trim(),
        grade: onboardingData.grade,
        gender: onboardingData.gender,
        stream: effectiveStream,
        dailyGoalMinutes: Value(onboardingData.dailyGoalMinutes),
        streakCount: const Value(0),
        streakFreezes: const Value(1), // Welcome gift of 1 streak freeze!
        createdAt: Value(now),
        updatedAt: Value(now),
        isSynced: Value(SupabaseService.isAuthenticated),
      );

      // Save to Drift SQLite
      await _db.into(_db.students).insertOnConflictUpdate(studentCompanion);

      // Mark onboarding as completed
      await _prefs.setBool(_onboardingCompleteKey, true);

      // If user is authenticated in Supabase, sync immediately to Supabase
      final effectiveUserId = userId ?? SupabaseService.currentUserId;
      if (SupabaseService.isAuthenticated && effectiveUserId != null) {
        try {
          final client = SupabaseService.clientOrNull;
          if (client != null) {
            await client.rpc('save_onboarding_profile', params: {
              'p_name': onboardingData.name.trim().isEmpty
                  ? 'Acedex Scholar'
                  : onboardingData.name.trim(),
              'p_gender': onboardingData.gender,
              'p_grade': onboardingData.grade,
              'p_stream': effectiveStream,
              'p_daily_goal_minutes': onboardingData.dailyGoalMinutes,
            });
          }
        } catch (rpcError) {
          debugPrint('RPC save_onboarding_profile fallback to direct upsert: $rpcError');
          try {
            final client = SupabaseService.clientOrNull;
            if (client != null) {
              await client.from('students').upsert({
                'id': effectiveUserId,
                'email': studentEmail,
                'name': onboardingData.name.trim().isEmpty
                    ? 'Acedex Scholar'
                    : onboardingData.name.trim(),
                'grade': onboardingData.grade,
                'gender': onboardingData.gender,
                'stream': effectiveStream,
                'daily_goal_minutes': onboardingData.dailyGoalMinutes,
                'streak_count': 0,
                'streak_freezes': 1,
                'created_at': now.toIso8601String(),
                'updated_at': now.toIso8601String(),
              });
            }
          } catch (e) {
            debugPrint('Cloud sync error during onboarding: $e');
          }
        }
      }

      await loadStudent();
      return true;
    } catch (e, st) {
      debugPrint('Save student profile error: $e');
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> updateStreak(int streakCount) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(
      streakCount: streakCount,
      updatedAt: DateTime.now(),
    );
    await _db.update(_db.students).replace(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> resetForTesting() async {
    await _prefs.remove(_onboardingCompleteKey);
    await _db.delete(_db.students).go();
    state = const AsyncValue.data(null);
  }
}
