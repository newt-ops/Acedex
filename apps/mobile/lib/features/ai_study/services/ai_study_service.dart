import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/ai_study_models.dart';

/// Repository/Service boundary for AI Cross-Grade Topic Study & Rewarded Ad Unlock.
abstract class AiStudyRepository {
  Future<AiTopicProgramOverview?> getCachedOverview();
  Future<AiTopicProgramOverview> fetchProgramOverview();
  Future<List<TopicModuleItem>?> getCachedSubjectModules(String subjectCode);
  Future<List<TopicModuleItem>> fetchSubjectModules(String subjectCode);
  Future<String> startAndClaimRewardedAd();
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

  AiStudyService({
    ApiClient? apiClient,
    AuthStorage? storage,
  })  : _apiClient = apiClient ?? ApiClient.instance,
        _storage = storage ?? AuthStorage.instance;

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
  Future<String> startAndClaimRewardedAd() async {
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
    final adSessionId = startData['adSessionId'] as String? ?? '';

    await _apiClient.post(
      ApiEndpoints.adsRewardClaim,
      requiresAuth: true,
      body: {
        'adSessionId': adSessionId,
        'rewardType': 'ai_study_plan',
      },
    );

    return adSessionId;
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
