import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../network/api_exception.dart';
import '../../theme/app_colors.dart';
import '../../ui/ui.dart';
import '../models/acedex_ad_models.dart';
import '../services/acedex_ads_service.dart';

/// Canonical Common Rewarded Ad Unlock Sheet usable by ANY ACEDEX feature:
/// - `AcedexRewardType.examAccess`
/// - `AcedexRewardType.offlinePack` (requires `targetUnitId`)
/// - `AcedexRewardType.streakRepair`
/// - `AcedexRewardType.aiStudyPlan`
///
/// Orchestrates:
/// 1. `POST /api/v1/ads/session/start` (starts backend clock)
/// 2. Real Unity Rewarded Video Ad on Android/iOS (with sponsored fallback on Web/Desktop/no-fill)
/// 3. Minimum elapsed watch verification (`minimumWatchSeconds`)
/// 4. `POST /api/v1/ads/reward/claim` -> returns [AcedexClaimRewardResult] or `null` if cancelled
class AcedexRewardedAdSheet extends StatefulWidget {
  final AcedexRewardType rewardType;
  final String? targetUnitId;
  final String? title;
  final String? subtitle;
  final AcedexAdsRepository adsRepository;

  const AcedexRewardedAdSheet({
    super.key,
    required this.rewardType,
    this.targetUnitId,
    this.title,
    this.subtitle,
    required this.adsRepository,
  });

  static Future<AcedexClaimRewardResult?> show(
    BuildContext context, {
    required AcedexRewardType rewardType,
    String? targetUnitId,
    String? title,
    String? subtitle,
    AcedexAdsRepository? adsRepository,
  }) {
    return showModalBottomSheet<AcedexClaimRewardResult>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => AcedexRewardedAdSheet(
        rewardType: rewardType,
        targetUnitId: targetUnitId,
        title: title,
        subtitle: subtitle,
        adsRepository: adsRepository ?? AcedexAdsService.instance,
      ),
    );
  }

  @override
  State<AcedexRewardedAdSheet> createState() => _AcedexRewardedAdSheetState();
}

class _AcedexRewardedAdSheetState extends State<AcedexRewardedAdSheet> {
  String _headline = 'Loading Rewarded Ad...';
  String _subtext = 'Connecting to Unity Ads & preparing your reward session.';
  int _secondsRemaining = 0;
  bool _busy = true;
  String? _errorText;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _runAdFlow();
  }

  Future<void> _runAdFlow() async {
    _countdownTimer?.cancel();
    setState(() {
      _busy = true;
      _errorText = null;
      _secondsRemaining = 0;
      _headline = widget.title ?? widget.rewardType.defaultHeadline;
      _subtext =
          widget.subtitle ?? 'Connecting to ACEDEX rewarded ad service...';
    });

    try {
      final session = await widget.adsRepository.startRewardedSession(
        rewardType: widget.rewardType,
        targetUnitId: widget.targetUnitId,
      );
      if (!mounted) return;

      setState(() {
        _headline = widget.title ?? widget.rewardType.defaultHeadline;
        _subtext = 'Launching rewarded video...';
      });

      final playedNativeAd = await widget.adsRepository.showUnityRewardedAd(
        session,
      );
      if (!mounted) return;

      final elapsed = DateTime.now()
          .difference(session.startedAtLocal)
          .inSeconds;
      final remaining = (widget.adsRepository.minimumWatchSeconds - elapsed)
          .clamp(0, 30);

      if (remaining > 0) {
        setState(() {
          _secondsRemaining = remaining;
          _headline = playedNativeAd
              ? 'Verifying Ad Reward...'
              : (widget.title ?? widget.rewardType.defaultHeadline);
          _subtext = playedNativeAd
              ? 'Finalizing reward verification (${remaining}s remaining)...'
              : '${widget.subtitle ?? widget.rewardType.defaultSubtitle} (${remaining}s)';
        });

        final timerDone = Completer<void>();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            if (!timerDone.isCompleted) timerDone.complete();
            return;
          }
          if (_secondsRemaining > 1) {
            setState(() {
              _secondsRemaining--;
              _subtext = playedNativeAd
                  ? 'Finalizing reward verification (${_secondsRemaining}s remaining)...'
                  : '${widget.subtitle ?? widget.rewardType.defaultSubtitle} (${_secondsRemaining}s)';
            });
          } else {
            timer.cancel();
            setState(() => _secondsRemaining = 0);
            if (!timerDone.isCompleted) timerDone.complete();
          }
        });
        await timerDone.future;
      }

      if (!mounted) return;
      setState(() {
        _headline = 'Claiming Reward...';
        _subtext = 'Confirming your reward with ACEDEX.';
      });

      final claimResult = await widget.adsRepository.claimReward(
        adSessionId: session.adSessionId,
        rewardType: widget.rewardType,
      );
      if (!mounted) return;
      Navigator.of(context).pop(claimResult);
    } on RewardedAdSkippedException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _headline = 'Ad Skipped Early';
        _errorText = e.message;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _headline = 'Ad Verification Issue';
        _errorText = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _headline = 'Ad Unavailable';
        _errorText =
            'Could not verify rewarded ad. Please check your connection and retry.';
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark
        ? AppColors.accentSoftDark
        : AppColors.accentSoftLight;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final subtextColor = isDark
        ? AppColors.darkSubtext
        : AppColors.lightSubtext;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedPlay,
                color: accent,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _headline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorText ?? _subtext,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: subtextColor, height: 1.4),
            ),
            const SizedBox(height: 18),
            AcedexDotsLoader(color: accent, dotSize: 7, gap: 6),
            const SizedBox(height: 16),
            if (_errorText != null)
              Row(
                children: [
                  Expanded(
                    child: AcedexButton(
                      label: 'Cancel',
                      variant: AcedexButtonVariant.outline,
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AcedexButton(
                      label: 'Retry Ad',
                      onPressed: _runAdFlow,
                    ),
                  ),
                ],
              )
            else
              AcedexButton(
                label: _secondsRemaining > 0
                    ? 'Verifying Reward...'
                    : 'Please Wait...',
                variant: AcedexButtonVariant.ghost,
                onPressed: _busy ? null : () => Navigator.of(context).pop(null),
              ),
          ],
        ),
      ),
    );
  }
}
