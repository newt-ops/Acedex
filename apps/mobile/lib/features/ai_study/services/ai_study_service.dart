import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/services/unity_ads_service.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/ai_study_models.dart';

@immutable
class RewardedAdStartData {
  final String adSessionId;
  final String gameId;
  final String placementId;
  final DateTime startedAtLocal;

  const RewardedAdStartData({
    required this.adSessionId,
    required this.gameId,
    required this.placementId,
    required this.startedAtLocal,
  });
}

/// Repository/Service boundary for AI Cross-Grade Topic Study & Rewarded Ad Unlock.
abstract class AiStudyRepository {
  int get minimumAdWatchSeconds;
  Future<AiTopicProgramOverview?> getCachedOverview();
  Future<AiTopicProgramOverview> fetchProgramOverview();
  Future<List<TopicModuleItem>?> getCachedSubjectModules(String subjectCode);
  Future<List<TopicModuleItem>> fetchSubjectModules(String subjectCode);
  Future<RewardedAdStartData> startRewardedAdSession();
  Future<bool> playRewardedAd(RewardedAdStartData session);
  Future<void> claimRewardedAd(String adSessionId);
  Future<AiTopicProgramOverview> generateProgram(
    AiCalibrationInput input, {
    String? adSessionId,
  });
  Future<TopicModuleItem> updateModuleProgress({
    required String moduleId,
    int? stepNumber,
    bool? stepCompleted,
    bool? isCompleted,
  });
}

class AiStudyService implements AiStudyRepository {
  static final AiStudyService instance = AiStudyService();

  final ApiClient _apiClient;
  final AuthStorage _storage;
  final UnityAdsService _unityAds;

  AiStudyService({
    ApiClient? apiClient,
    AuthStorage? storage,
    UnityAdsService? unityAds,
  })  : _apiClient = apiClient ?? ApiClient.instance,
        _storage = storage ?? AuthStorage.instance,
        _unityAds = unityAds ?? UnityAdsService.instance;

  /// Production backend enforces >= 15s watch time when S2S hasn't fired; 16s avoids clock boundary 400s.
  @override
  int get minimumAdWatchSeconds => 16;

  @override
  Future<AiTopicProgramOverview?> getCachedOverview() async {
    final json = await _storage.getAiTopicOverview();
    if (json == null) return null;
    try {
      return AiTopicProgramOverview.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AiTopicProgramOverview> fetchProgramOverview() async {
    final res = await _apiClient.get(
      ApiEndpoints.topicProgram,
      requiresAuth: true,
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final overview = AiTopicProgramOverview.fromJson(data);
    await _storage.saveAiTopicOverview(overview.toJson());
    return overview;
  }

  @override
  Future<List<TopicModuleItem>?> getCachedSubjectModules(String subjectCode) async {
    final cached = await _storage.getSubjectTopicModules(subjectCode);
    if (cached == null) return null;
    try {
      return cached.map(TopicModuleItem.fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TopicModuleItem>> fetchSubjectModules(String subjectCode) async {
    final res = await _apiClient.get(
      ApiEndpoints.subjectTopicModules(subjectCode),
      requiresAuth: true,
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final rawModules = (data['modules'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final modules = rawModules.map(TopicModuleItem.fromJson).toList();
    await _storage.saveSubjectTopicModules(
      subjectCode,
      modules.map((m) => m.toJson()).toList(),
    );
    return modules;
  }

  @override
  Future<RewardedAdStartData> startRewardedAdSession() async {
    final platform = (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
        ? 'ios'
        : 'android';

    final startRes = await _apiClient.post(
      ApiEndpoints.adsSessionStart,
      requiresAuth: true,
      body: {
        'rewardType': 'ai_study_plan',
        'platform': platform,
      },
    );
    final startData = (startRes['data'] as Map<String, dynamic>?) ?? startRes;
    return RewardedAdStartData(
      adSessionId: startData['adSessionId'] as String? ?? '',
      gameId: startData['gameId'] as String? ?? '6220248',
      placementId: startData['placementId'] as String? ?? 'Rewarded_Android',
      startedAtLocal: DateTime.now(),
    );
  }

  @override
  Future<bool> playRewardedAd(RewardedAdStartData session) {
    return _unityAds.playRewardedAd(
      gameId: session.gameId,
      placementId: session.placementId,
      adSessionId: session.adSessionId,
    );
  }

  @override
  Future<void> claimRewardedAd(String adSessionId) async {
    await _apiClient.post(
      ApiEndpoints.adsRewardClaim,
      requiresAuth: true,
      body: {
        'adSessionId': adSessionId,
        'rewardType': 'ai_study_plan',
      },
    );
  }

  @override
  Future<AiTopicProgramOverview> generateProgram(
    AiCalibrationInput input, {
    String? adSessionId,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.topicProgram,
      requiresAuth: true,
      timeout: const Duration(seconds: 45),
      body: input.toJson(adSessionId: adSessionId),
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final overview = AiTopicProgramOverview.fromJson(data);
    await _storage.saveAiTopicOverview(overview.toJson());
    return overview;
  }

  @override
  Future<TopicModuleItem> updateModuleProgress({
    required String moduleId,
    int? stepNumber,
    bool? stepCompleted,
    bool? isCompleted,
  }) async {
    final body = <String, dynamic>{
      'stepNumber': ?stepNumber,
      'stepCompleted': ?stepCompleted,
      'isCompleted': ?isCompleted,
    };

    final res = await _apiClient.post(
      ApiEndpoints.topicModuleProgress(moduleId),
      requiresAuth: true,
      body: body,
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final moduleJson = (data['module'] as Map<String, dynamic>?) ?? data;
    return TopicModuleItem.fromJson(moduleJson);
  }
}
