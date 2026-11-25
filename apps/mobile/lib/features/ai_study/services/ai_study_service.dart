import '../../../core/economy/economy.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/ai_study_models.dart';

/// Repository/Service boundary for AI Cross-Grade Topic Study endpoints (`/api/v1/topics/*`).
abstract class AiStudyRepository {
  Future<AiTopicProgramOverview?> getCachedOverview();
  Future<void> saveCachedOverview(AiTopicProgramOverview overview);
  Future<AiTopicProgramOverview> fetchProgramOverview();
  Future<List<TopicModuleItem>?> getCachedSubjectModules(String subjectCode);
  Future<void> saveCachedSubjectModules(
    String subjectCode,
    List<TopicModuleItem> modules,
  );
  Future<List<TopicModuleItem>> fetchSubjectModules(String subjectCode);
  Future<AiTopicProgramOverview> generateProgram(
    AiCalibrationInput input, {
    String? adSessionId,
  });
  Future<TopicModuleItem> updateModuleProgress({
    required String moduleId,
    TopicModuleItem? existingModule,
    int? stepNumber,
    bool? stepCompleted,
    bool? isCompleted,
  });
  Future<TopicUnitMasteryResult> toggleUnitMastery({
    required String unitCode,
    required bool completed,
    String? moduleId,
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
  Future<void> saveCachedOverview(AiTopicProgramOverview overview) async {
    await _storage.saveAiTopicOverview(overview.toJson());
  }

  @override
  Future<AiTopicProgramOverview> fetchProgramOverview() async {
    final res = await _apiClient.get(
      ApiEndpoints.topicProgram,
      requiresAuth: true,
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final overview = AiTopicProgramOverview.fromJson(data);
    await saveCachedOverview(overview);
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
  Future<void> saveCachedSubjectModules(
    String subjectCode,
    List<TopicModuleItem> modules,
  ) async {
    await _storage.saveSubjectTopicModules(
      subjectCode,
      modules.map((m) => m.toJson()).toList(),
    );
  }

  @override
  Future<List<TopicModuleItem>> fetchSubjectModules(String subjectCode) async {
    final res = await _apiClient.get(
      ApiEndpoints.subjectTopicModules(subjectCode),
      requiresAuth: true,
    );
    final dynamic payload = res.containsKey('data') ? res['data'] : res;

    // Backend returns `data` as a direct JSON array `[ ...modules ]`,
    // while tests or legacy wrappers may wrap `{ modules: [ ... ] }`.
    final List<dynamic> rawList;
    if (payload is List<dynamic>) {
      rawList = payload;
    } else if (payload is Map<String, dynamic>) {
      rawList = (payload['modules'] as List<dynamic>?) ?? const [];
    } else {
      rawList = const [];
    }

    final modules = rawList
        .whereType<Map<String, dynamic>>()
        .map(TopicModuleItem.fromJson)
        .toList()
      ..sort((a, b) => a.moduleNumber.compareTo(b.moduleNumber));

    // Synchronize backend Study-unit completion state into shared AuthStorage notifier
    final completedUnitCodes = <String>[];
    final uncompletedUnitCodes = <String>[];
    for (final mod in modules) {
      for (final r in mod.references) {
        final code = r.unitCode.toUpperCase().trim();
        if (code.isEmpty) continue;
        if (r.isUnitCompleted) {
          completedUnitCodes.add(code);
        } else {
          uncompletedUnitCodes.add(code);
        }
      }
    }
    if (completedUnitCodes.isNotEmpty) {
      await _storage.setUnitCompletions(completedUnitCodes, true);
    }
    if (uncompletedUnitCodes.isNotEmpty) {
      await _storage.setUnitCompletions(uncompletedUnitCodes, false);
    }

    await saveCachedSubjectModules(subjectCode, modules);
    return modules;
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
    await saveCachedOverview(overview);
    return overview;
  }

  @override
  Future<TopicModuleItem> updateModuleProgress({
    required String moduleId,
    TopicModuleItem? existingModule,
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

    final coinsAwarded = (data['coinsAwarded'] as num?)?.toInt();
    final newCoinBalance = (data['newCoinBalance'] as num?)?.toInt();
    if (coinsAwarded != null || newCoinBalance != null) {
      EconomyService.instance.applyServerBalanceUpdate(
        coinsAwarded: coinsAwarded,
        newCoinBalance: newCoinBalance,
      );
    }

    // When backend returns the full module object, parse directly;
    // when it returns the lightweight progress patch ({ completedSteps, isCompleted,
    // progressPercentage }), merge cleanly onto existingModule so metadata isn't wiped.
    if (existingModule != null &&
        (moduleJson['title'] as String? ?? '').isEmpty) {
      final updatedSteps = (moduleJson['completedSteps'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          existingModule.completedSteps;
      final updatedDone =
          moduleJson['isCompleted'] as bool? ?? existingModule.isCompleted;
      final updatedPct =
          (moduleJson['progressPercentage'] as num?)?.toInt() ??
              existingModule.progressPercentage;

      return existingModule.copyWith(
        completedSteps: updatedSteps,
        isCompleted: updatedDone,
        progressPercentage: updatedPct,
      );
    }

    return TopicModuleItem.fromJson(moduleJson);
  }

  @override
  Future<TopicUnitMasteryResult> toggleUnitMastery({
    required String unitCode,
    required bool completed,
    String? moduleId,
  }) async {
    final cleanCode = unitCode.toUpperCase().trim();
    final res = await _apiClient.post(
      ApiEndpoints.topicUnitMastery(cleanCode),
      requiresAuth: true,
      body: {
        'completed': completed,
        if (moduleId != null && moduleId.isNotEmpty) 'moduleId': moduleId,
      },
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final result = TopicUnitMasteryResult.fromJson(data);
    if (result.coinsAwarded != null || result.newCoinBalance != null) {
      EconomyService.instance.applyServerBalanceUpdate(
        coinsAwarded: result.coinsAwarded,
        newCoinBalance: result.newCoinBalance,
      );
    }
    await _storage.setUnitCompletion(
      result.unitCode.isNotEmpty ? result.unitCode : cleanCode,
      result.isStudyCompleted,
    );
    return result;
  }
}
