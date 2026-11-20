import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_tokens.dart';
import '../models/user_profile.dart';

class AuthStorage {
  static const String _keyToken = 'acedex_access_token';
  static const String _keyRefreshToken = 'acedex_refresh_token';
  static const String _keyProfile = 'acedex_user_profile';
  static const String _keyHasSeenOnboarding = 'acedex_seen_onboarding';

  static AuthStorage? _instance;
  static AuthStorage get instance => _instance ??= AuthStorage._();

  AuthStorage._();

  String? _cachedToken;
  UserProfile? _cachedProfile;

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

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  Future<void> setSeenOnboarding(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, seen);
  }

  Future<void> clear() async {
    _cachedToken = null;
    _cachedProfile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyProfile);
  }
}
