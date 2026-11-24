import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_tokens.dart';
import '../models/student_avatar.dart';
import '../models/user_profile.dart';

class AuthStorage {
  static const String _keyToken = 'acedex_access_token';
  static const String _keyRefreshToken = 'acedex_refresh_token';
  static const String _keyProfile = 'acedex_user_profile';
  static const String _keyHasSeenOnboarding = 'acedex_seen_onboarding';
  static const String _keyAvatar = 'acedex_student_avatar';
  static const String _keyLastPhone = 'acedex_last_phone';
  static const String _keyHasSeenSplash = 'acedex_seen_splash';
  static const String _keyAiTopicOverview = 'acedex_ai_topic_overview';
  static const String _keyAiSubjectModulesPrefix = 'acedex_ai_modules_';

  static AuthStorage? _instance;
  static AuthStorage get instance => _instance ??= AuthStorage._();

  AuthStorage._();

  String? _cachedToken;
  UserProfile? _cachedProfile;
  StudentAvatar? _cachedAvatar;
  String? _cachedLastPhone;

  static const String _keyCompletedUnits = 'acedex_completed_units';

  final ValueNotifier<StudentAvatar> avatarNotifier =
      ValueNotifier<StudentAvatar>(StudentAvatar.defaultSilhouette);

  final ValueNotifier<Set<String>> completedUnitsNotifier =
      ValueNotifier<Set<String>>({});

  Future<Set<String>> getCompletedUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCompletedUnits) ?? [];
    completedUnitsNotifier.value = list.toSet();
    return completedUnitsNotifier.value;
  }

  Future<void> setUnitCompletion(String unitId, bool completed) async {
    final current = Set<String>.from(completedUnitsNotifier.value);
    if (completed) {
      current.add(unitId);
    } else {
      current.remove(unitId);
    }
    completedUnitsNotifier.value = current;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompletedUnits, current.toList());
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    _cachedToken = tokens.accessToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, tokens.accessToken);
    if (tokens.refreshToken != null) {
      await prefs.setString(_keyRefreshToken, tokens.refreshToken!);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    _cachedProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
    if (profile.phone != null && profile.phone!.isNotEmpty) {
      await saveLastPhone(profile.phone!);
    }
  }

  Future<void> saveLastPhone(String phone) async {
    _cachedLastPhone = phone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastPhone, phone);
  }

  Future<String?> getLastPhone() async {
    if (_cachedLastPhone != null) return _cachedLastPhone;
    final prefs = await SharedPreferences.getInstance();
    _cachedLastPhone = prefs.getString(_keyLastPhone);
    if (_cachedLastPhone == null && _cachedProfile?.phone != null) {
      _cachedLastPhone = _cachedProfile!.phone;
    }
    return _cachedLastPhone;
  }

  Future<bool> hasSeenSplash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenSplash) ?? false;
  }

  Future<void> setSeenSplash(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenSplash, seen);
  }

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_keyToken);
    return _cachedToken;
  }

  Future<UserProfile?> getProfile() async {
    if (_cachedProfile != null) return _cachedProfile;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProfile);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _cachedProfile = UserProfile.fromJson(map);
      return _cachedProfile;
    } catch (_) {
      return null;
    }
  }

  Future<StudentAvatar> getAvatar() async {
    if (_cachedAvatar != null) return _cachedAvatar!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAvatar);
    if (raw == null) {
      _cachedAvatar = StudentAvatar.defaultSilhouette;
      avatarNotifier.value = _cachedAvatar!;
      return _cachedAvatar!;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _cachedAvatar = StudentAvatar.fromJson(map);
      avatarNotifier.value = _cachedAvatar!;
      return _cachedAvatar!;
    } catch (_) {
      _cachedAvatar = StudentAvatar.defaultSilhouette;
      avatarNotifier.value = _cachedAvatar!;
      return _cachedAvatar!;
    }
  }

  Future<void> saveAvatar(StudentAvatar avatar) async {
    _cachedAvatar = avatar;
    avatarNotifier.value = avatar;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatar, jsonEncode(avatar.toJson()));
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  Future<void> setSeenOnboarding(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, seen);
  }

  Future<void> saveAiTopicOverview(Map<String, dynamic> overviewJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAiTopicOverview, jsonEncode(overviewJson));
  }

  Future<Map<String, dynamic>?> getAiTopicOverview() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAiTopicOverview);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSubjectTopicModules(
    String subjectCode,
    List<Map<String, dynamic>> modulesJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_keyAiSubjectModulesPrefix${subjectCode.toUpperCase()}',
      jsonEncode(modulesJson),
    );
  }

  Future<List<Map<String, dynamic>>?> getSubjectTopicModules(String subjectCode) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyAiSubjectModulesPrefix${subjectCode.toUpperCase()}');
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    _cachedToken = null;
    _cachedProfile = null;
    _cachedAvatar = StudentAvatar.defaultSilhouette;
    _cachedLastPhone = null;
    avatarNotifier.value = StudentAvatar.defaultSilhouette;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyProfile);
    await prefs.remove(_keyAvatar);
    await prefs.remove(_keyAiTopicOverview);
    for (final key in prefs.getKeys().where((k) => k.startsWith(_keyAiSubjectModulesPrefix)).toList()) {
      await prefs.remove(key);
    }
  }
}
