import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../ads/ads.dart';
import '../../network/api_exception.dart';
import '../../theme/app_colors.dart';
import '../../ui/ui.dart';
import '../services/economy_service.dart';

/// Shared dual-option unlock prompt: spend earned Ace Coins OR watch 1 Rewarded Ad (+10 AC).
class AcedexUnlockChoiceSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String itemKey;
  final int coinCost;
  final String? targetUnitId;
  final AcedexRewardType adRewardType;
  final EconomyRepository? economyRepository;
  final AcedexAdsRepository? adsRepository;

  const AcedexUnlockChoiceSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.itemKey,
    required this.coinCost,
    this.targetUnitId,
    this.adRewardType = AcedexRewardType.bonusCoins,
    this.economyRepository,
    this.adsRepository,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String itemKey,
    required int coinCost,
    String? targetUnitId,
    AcedexRewardType adRewardType = AcedexRewardType.bonusCoins,
    EconomyRepository? economyRepository,
    AcedexAdsRepository? adsRepository,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AcedexUnlockChoiceSheet(
        title: title,
        subtitle: subtitle,
        itemKey: itemKey,
        coinCost: coinCost,
        targetUnitId: targetUnitId,
        adRewardType: adRewardType,
        economyRepository: economyRepository,
        adsRepository: adsRepository,
      ),
    );
    return result == true;
  }

  @override
  State<AcedexUnlockChoiceSheet> createState() =>
      _AcedexUnlockChoiceSheetState();
}

class _AcedexUnlockChoiceSheetState extends State<AcedexUnlockChoiceSheet> {
  late final EconomyRepository _economyRepo;
  bool _spending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _economyRepo = widget.economyRepository ?? EconomyService.instance;
  }

  Future<void> _handleSpendCoins({int? earnedFromAd}) async {
    if (_spending) return;
    setState(() {
      _spending = true;
      _error = null;
    });

    try {
      final res = await _economyRepo.spendCoins(
        itemKey: widget.itemKey,
        targetUnitId: widget.targetUnitId,
      );
      if (!mounted) return;
      EconomyService.instance.applyServerBalanceUpdate(
        newCoinBalance: res.newBalance,
      );
      if (widget.itemKey == 'unit_assessment') {
        final code = res.unlockedUnitCode ?? widget.targetUnitId;
        if (code != null && code.isNotEmpty) {
          EconomyService.instance.markAssessmentUnlocked(code);
        }
      }
      final spendAmount = res.coinsSpent;
      final toastMsg = earnedFromAd != null && earnedFromAd > 0
          ? (spendAmount > 0
              ? '+$earnedFromAd AC earned • -$spendAmount AC spent to unlock!'
              : '+$earnedFromAd AC earned • ${res.message}')
          : (spendAmount > 0
              ? '-$spendAmount AC • ${res.message}'
              : res.message);
      AcedexToast.show(
        context,
        message: toastMsg,
        type: earnedFromAd != null && earnedFromAd > 0
            ? AcedexToastType.success
            : AcedexToastType.info,
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _spending = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _spending = false;
        _error = 'Unable to spend Ace Coins right now. Please try again.';
      });
    }
  }

  Future<void> _handleWatchAd() async {
    final claim = await AcedexRewardedAdSheet.show(
      context,
      rewardType: widget.adRewardType,
      targetUnitId: widget.targetUnitId,
      adsRepository: widget.adsRepository,
    );

    if (!mounted || claim == null) return;

    if (widget.adRewardType == AcedexRewardType.bonusCoins) {
      final awarded = claim.coinsAwarded ?? 10;
      EconomyService.instance.applyServerBalanceUpdate(
        coinsAwarded: awarded,
        newCoinBalance: claim.newCoinBalance,
      );
      // Automatically spend the coin cost now that the user earned +10 AC from the ad!
      await _handleSpendCoins(earnedFromAd: awarded);
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft =
        isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final onAccent = isDark ? AppColors.onAccentDark : AppColors.onAccentLight;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: line)),
      ),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<int>(
          valueListenable: EconomyService.instance.coinBalanceNotifier,
          builder: (context, balance, _) {
            final canAfford = balance >= widget.coinCost;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCoins01,
                        color: Color(0xFFF59E0B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Your Balance: $balance AC',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: subtext,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                AcedexButton(
                  label: canAfford
                      ? 'Unlock with ${widget.coinCost} AC'
                      : 'Need ${widget.coinCost} AC (Balance: $balance AC)',
                  size: AcedexButtonSize.lg,
                  isLoading: _spending,
                  leadingIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCoins01,
                    color: onAccent,
                    size: 18,
                  ),
                  onPressed: canAfford && !_spending ? _handleSpendCoins : null,
                ),
                const SizedBox(height: 10),
                AcedexButton(
                  label: widget.adRewardType == AcedexRewardType.bonusCoins
                      ? 'Watch 1 Ad (+10 AC & Unlock)'
                      : 'Or Watch 1 Rewarded Ad',
                  variant: AcedexButtonVariant.soft,
                  size: AcedexButtonSize.lg,
                  leadingIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedPlayCircle,
                    color: accent,
                    size: 18,
                  ),
                  onPressed: _spending ? null : _handleWatchAd,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
