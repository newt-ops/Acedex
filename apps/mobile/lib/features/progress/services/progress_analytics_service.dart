import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/progress_models.dart';

/// Repository/Service boundary for live student progress analytics (`/api/v1/progress/analytics`).
abstract class ProgressAnalyticsRepository {
  Future<ProgressAnalyticsData?> getCachedAnalytics();
  Future<void> saveCachedAnalytics(ProgressAnalyticsData data);
  Future<ProgressAnalyticsData> fetchAnalytics();
}

class ProgressAnalyticsService implements ProgressAnalyticsRepository {
  static final ProgressAnalyticsService instance = ProgressAnalyticsService();

  static const String _cacheKey = 'acedex_progress_analytics';
  final ApiClient _apiClient;

  ProgressAnalyticsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  @override
  Future<ProgressAnalyticsData?> getCachedAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ProgressAnalyticsData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCachedAnalytics(ProgressAnalyticsData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(data.toJson()));
  }

  @override
  Future<ProgressAnalyticsData> fetchAnalytics() async {
    final res = await _apiClient.get(
      ApiEndpoints.progressAnalytics,
      requiresAuth: true,
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final parsed = ProgressAnalyticsData.fromJson(data);
    await saveCachedAnalytics(parsed);
    return parsed;
  }
}
