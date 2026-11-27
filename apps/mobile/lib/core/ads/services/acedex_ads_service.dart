import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import '../models/acedex_ad_models.dart';

class RewardedAdSkippedException implements Exception {
  final String message;
  const RewardedAdSkippedException([
    this.message = 'Please finish watching the rewarded ad to claim your reward.',
  ]);
}

class RewardedAdUnavailableException implements Exception {
  final String message;
  const RewardedAdUnavailableException([
    this.message = 'Rewarded ad could not be loaded right now. Please check your connection and try again.',
  ]);
}

/// Observes Flutter app lifecycle transitions while a fullscreen Unity Ad Activity is active
/// so rewards are never processed until the student has closed the ad and returned to the app.
class _AdForegroundResumeObserver with WidgetsBindingObserver {
  bool leftForeground = false;
  Completer<void>? _resumeCompleter;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      leftForeground = true;
    } else if (_resumeCompleter != null && !_resumeCompleter!.isCompleted) {
      _resumeCompleter!.complete();
    }
  }

  Future<void> waitUntilAppResumed() async {
    final currentState = WidgetsBinding.instance.lifecycleState;
    if (leftForeground &&
        currentState != null &&
        currentState != AppLifecycleState.resumed) {
      _resumeCompleter ??= Completer<void>();
      await _resumeCompleter!.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }
}

/// Shared repository interface for all rewarded ad features across ACEDEX
/// (`exam_access`, `offline_pack`, `streak_repair`, `ai_study_plan`).
abstract class AcedexAdsRepository {
  int get minimumWatchSeconds;
  Future<AcedexAdConfig> fetchConfig();
  Future<AcedexStudentAdStatus> fetchStudentStatus();
  Future<AcedexAdSession> startRewardedSession({
    required AcedexRewardType rewardType,
    String? targetUnitId,
  });
  Future<bool> showUnityRewardedAd(AcedexAdSession session);
  Future<AcedexClaimRewardResult> claimReward({
    required String adSessionId,
    required AcedexRewardType rewardType,
  });
}

/// Common Unity Ads + Backend Monetization Service shared across all ACEDEX features.
class AcedexAdsService implements AcedexAdsRepository {
  static final AcedexAdsService instance = AcedexAdsService();

  final ApiClient _apiClient;
  String? _initializedGameId;

  AcedexAdsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  /// Production backend enforces >= 15s elapsed watch time when S2S hasn't verified.
  @override
  int get minimumWatchSeconds => 16;

  bool get isSupportedNativePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get _currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    }
    return 'android';
  }

  @override
  Future<AcedexAdConfig> fetchConfig() async {
    final res = await _apiClient.get(
      ApiEndpoints.adsConfig,
      requiresAuth: false,
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    return AcedexAdConfig.fromJson(data);
  }

  @override
  Future<AcedexStudentAdStatus> fetchStudentStatus() async {
    final res = await _apiClient.get(
      ApiEndpoints.adsStatus,
      requiresAuth: true,
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    return AcedexStudentAdStatus.fromJson(data);
  }

  @override
  Future<AcedexAdSession> startRewardedSession({
    required AcedexRewardType rewardType,
    String? targetUnitId,
  }) async {
    final body = <String, dynamic>{
      'rewardType': rewardType.apiValue,
      'platform': _currentPlatform,
      'targetUnitId': ?targetUnitId,
    };

    final res = await _apiClient.post(
      ApiEndpoints.adsSessionStart,
      requiresAuth: true,
      body: body,
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    return AcedexAdSession.fromJson(data);
  }

  /// Ensures Unity Ads SDK is initialized for the active Game ID.
  Future<bool> ensureInitialized(String gameId) async {
    if (!isSupportedNativePlatform) return false;

    try {
      final alreadyInit = await UnityAds.isInitialized();
      if (alreadyInit && _initializedGameId == gameId) {
        return true;
      }
    } catch (_) {
      return false;
    }

    final completer = Completer<bool>();
    try {
      await UnityAds.init(
        gameId: gameId,
        testMode: kDebugMode,
        onComplete: () {
          _initializedGameId = gameId;
          if (!completer.isCompleted) completer.complete(true);
        },
        onFailed: (error, message) {
          debugPrint('[UnityAds init failed] $error: $message');
          if (!completer.isCompleted) completer.complete(false);
        },
      );
      return await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () => false,
      );
    } catch (e) {
      debugPrint('[UnityAds init exception] $e');
      return false;
    }
  }

  @override
  Future<bool> showUnityRewardedAd(AcedexAdSession session) async {
    final initialized = await ensureInitialized(session.gameId);
    if (!initialized) return false;

    // 1. Load rewarded placement
    final loadCompleter = Completer<bool>();
    try {
      await UnityAds.load(
        placementId: session.placementId,
        onComplete: (_) {
          if (!loadCompleter.isCompleted) loadCompleter.complete(true);
        },
        onFailed: (id, error, message) {
          debugPrint('[UnityAds load failed] $id ($error): $message');
          if (!loadCompleter.isCompleted) loadCompleter.complete(false);
        },
      );

      final loaded = await loadCompleter.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => false,
      );
      if (!loaded) return false;
    } catch (e) {
      debugPrint('[UnityAds load exception] $e');
      return false;
    }

    // 2. Play fullscreen rewarded video passing serverId = adSessionId for Unity S2S
    final showCompleter = Completer<bool>();
    final lifecycleObserver = _AdForegroundResumeObserver();
    WidgetsBinding.instance.addObserver(lifecycleObserver);

    try {
      await UnityAds.showVideoAd(
        placementId: session.placementId,
        serverId: session.adSessionId,
        onComplete: (_) async {
          await lifecycleObserver.waitUntilAppResumed();
          if (!showCompleter.isCompleted) showCompleter.complete(true);
        },
        onSkipped: (_) async {
          await lifecycleObserver.waitUntilAppResumed();
          if (!showCompleter.isCompleted) {
            showCompleter.completeError(const RewardedAdSkippedException());
          }
        },
        onFailed: (id, error, message) async {
          debugPrint('[UnityAds show failed] $id ($error): $message');
          await lifecycleObserver.waitUntilAppResumed();
          if (!showCompleter.isCompleted) showCompleter.complete(false);
        },
      );

      return await showCompleter.future.timeout(
        const Duration(seconds: 120),
        onTimeout: () => false,
      );
    } on RewardedAdSkippedException {
      rethrow;
    } catch (e) {
      debugPrint('[UnityAds show exception] $e');
      return false;
    } finally {
      WidgetsBinding.instance.removeObserver(lifecycleObserver);
    }
  }

  @override
  Future<AcedexClaimRewardResult> claimReward({
    required String adSessionId,
    required AcedexRewardType rewardType,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.adsRewardClaim,
      requiresAuth: true,
      body: {
        'adSessionId': adSessionId,
        'rewardType': rewardType.apiValue,
      },
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    return AcedexClaimRewardResult.fromJson(data, adSessionId: adSessionId);
  }
}
