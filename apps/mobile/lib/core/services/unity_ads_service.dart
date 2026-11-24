import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class RewardedAdSkippedException implements Exception {
  final String message;
  const RewardedAdSkippedException([
    this.message =
        'Please watch the full rewarded ad to unlock your AI study plan.',
  ]);
}

/// Real Unity Ads rewarded video integration for Android & iOS.
///
/// Uses backend-provided Game ID (`6220248` Android / `6220249` iOS) and
/// Placement ID (`Rewarded_Android` / `Rewarded_iOS`).
class UnityAdsService {
  static final UnityAdsService instance = UnityAdsService();

  String? _initializedGameId;

  bool get isSupportedNativePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Ensures Unity Ads SDK is initialized for the active platform Game ID.
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

  /// Loads and plays a rewarded video ad through Unity Ads SDK.
  ///
  /// - Returns `true` when the native Unity video completed (`onComplete`).
  /// - Throws [RewardedAdSkippedException] if the student skipped before completion.
  /// - Returns `false` if running on Web/Desktop or if Unity Ads could not fill/load
  ///   so the caller can display a verified fallback countdown instead of failing.
  Future<bool> playRewardedAd({
    required String gameId,
    required String placementId,
    required String adSessionId,
  }) async {
    final initialized = await ensureInitialized(gameId);
    if (!initialized) return false;

    // 1. Load rewarded placement
    final loadCompleter = Completer<bool>();
    try {
      await UnityAds.load(
        placementId: placementId,
        onComplete: (_) {
          if (!loadCompleter.isCompleted) loadCompleter.complete(true);
        },
        onFailed: (id, error, message) {
          debugPrint('[UnityAds load failed] $id ($error): $message');
          if (!loadCompleter.isCompleted) loadCompleter.complete(false);
        },
      );

      final loaded = await loadCompleter.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => false,
      );
      if (!loaded) return false;
    } catch (e) {
      debugPrint('[UnityAds load exception] $e');
      return false;
    }

    // 2. Show full-screen rewarded video with S2S serverId = adSessionId
    final showCompleter = Completer<bool>();
    try {
      await UnityAds.showVideoAd(
        placementId: placementId,
        serverId: adSessionId,
        onComplete: (_) {
          if (!showCompleter.isCompleted) showCompleter.complete(true);
        },
        onSkipped: (_) {
          if (!showCompleter.isCompleted) {
            showCompleter.completeError(const RewardedAdSkippedException());
          }
        },
        onFailed: (id, error, message) {
          debugPrint('[UnityAds show failed] $id ($error): $message');
          if (!showCompleter.isCompleted) showCompleter.complete(false);
        },
      );

      return await showCompleter.future.timeout(
        const Duration(seconds: 75),
        onTimeout: () => false,
      );
    } on RewardedAdSkippedException {
      rethrow;
    } catch (e) {
      debugPrint('[UnityAds show exception] $e');
      return false;
    }
  }
}
