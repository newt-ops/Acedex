import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../ads/ads.dart';
import '../../network/api_exception.dart';
import '../../theme/app_colors.dart';
import '../../ui/ui.dart';
import '../models/economy_models.dart';
import '../services/economy_service.dart';

/// Apple-style Ace Coins Wallet, Rewarded Ad Top-Up, and Perks Store Sheet.
class AcedexWalletSheet extends StatefulWidget {
  final EconomyRepository? economyRepository;
  final AcedexAdsRepository? adsRepository;
  final WalletOverview? initialOverview;

  const AcedexWalletSheet({
    super.key,
    this.economyRepository,
    this.adsRepository,
    this.initialOverview,
  });

  static Future<void> show(
    BuildContext context, {
    EconomyRepository? economyRepository,
    AcedexAdsRepository? adsRepository,
    WalletOverview? initialOverview,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AcedexWalletSheet(
        economyRepository: economyRepository,
        adsRepository: adsRepository,
        initialOverview: initialOverview,
      ),
    );
  }

  @override
  State<AcedexWalletSheet> createState() => _AcedexWalletSheetState();
}

class _AcedexWalletSheetState extends State<AcedexWalletSheet> {
  late final EconomyRepository _economyRepo;
  WalletOverview? _overview;
  bool _loading = true;
  String? _buyingItemKey;
  String? _error;

  @override
  void initState() {
    super.initState();
    _economyRepo = widget.economyRepository ?? EconomyService.instance;
    if (widget.initialOverview != null) {
      _overview = widget.initialOverview;
      _loading = false;
    } else {
      _overview = EconomyService.instance.walletNotifier.value;
      unawaited(_loadWallet());
    }
  }

  Future<void> _loadWallet() async {
    try {
      final live = await _economyRepo.fetchWallet();
      if (!mounted) return;
      setState(() {
        _overview = live;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _overview ??= const WalletOverview();
        _error = e is ApiException ? e.message : null;
      });
    }
  }

  Future<void> _watchAdForCoins() async {
    final result = await AcedexRewardedAdSheet.show(
      context,
      rewardType: AcedexRewardType.bonusCoins,
      adsRepository: widget.adsRepository,
      title: 'Earn +${_overview?.coinsPerAd ?? 40} Ace Coins',
      subtitle: 'Watch 1 short rewarded ad to boost your study wallet.',
    );

    if (!mounted || result == null) return;

    final awarded = result.coinsAwarded ?? 40;
    EconomyService.instance.applyServerBalanceUpdate(
      coinsAwarded: awarded,
      newCoinBalance: result.newCoinBalance,
    );

    AcedexToast.show(
      context,
      message: '+$awarded Ace Coins added to your wallet!',
      type: AcedexToastType.success,
    );
    await _loadWallet();
  }

  Future<void> _buyItem(EconomyStoreItem item) async {
    if (_buyingItemKey != null) return;
    setState(() => _buyingItemKey = item.itemKey);

    try {
      final res = await _economyRepo.spendCoins(itemKey: item.itemKey);
      if (!mounted) return;
      EconomyService.instance.applyServerBalanceUpdate(
        newCoinBalance: res.newBalance,
      );
      AcedexToast.show(
        context,
        message: res.message,
        type: AcedexToastType.success,
      );
      await _loadWallet();
    } on ApiException catch (e) {
      if (!mounted) return;
      AcedexToast.show(
        context,
        message: e.message,
        type: AcedexToastType.error,
      );
    } catch (_) {
      if (!mounted) return;
      AcedexToast.show(
        context,
        message: 'Could not complete purchase right now.',
        type: AcedexToastType.error,
      );
    } finally {
      if (mounted) setState(() => _buyingItemKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoft = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final onAccent = isDark ? AppColors.onAccentDark : AppColors.onAccentLight;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final raised = isDark ? AppColors.darkRaised : AppColors.lightRaised;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    const coinGold = Color(0xFFF59E0B);

    final wallet = _overview ?? const WalletOverview();
    final purchasableItems = wallet.storeCatalog
        .where((i) => i.itemKey != 'offline_pack') // offline_pack needs targetUnitId
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4.5,
                decoration: BoxDecoration(
                  color: line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AcedexBadge(
                          label: 'ACE COINS WALLET',
                          variant: AcedexBadgeVariant.primary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Earn & Spend Coins',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AcedexBounceable(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: line),
                      ),
                      alignment: Alignment.center,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: subtext,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 16, color: line),

            Flexible(
              child: _loading && _overview == null
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: AcedexDotsLoader()),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Balance Hero Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentSoft,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: coinGold.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      alignment: Alignment.center,
                                      child: const HugeIcon(
                                        icon: HugeIcons.strokeRoundedCoins01,
                                        color: coinGold,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${wallet.balance} AC',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.6,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Earned ${wallet.lifetimeEarned} AC • Spent ${wallet.lifetimeSpent} AC',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: subtext,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    AcedexBadge(
                                      label:
                                          'Unit Assessment: ${wallet.assessmentCost} AC',
                                      variant: AcedexBadgeVariant.neutral,
                                    ),
                                    if (wallet.aiPlanPasses > 0)
                                      AcedexBadge(
                                        label:
                                            'AI Passes: ${wallet.aiPlanPasses}',
                                        variant: AcedexBadgeVariant.success,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                AcedexButton(
                                  label: wallet.dailyCoinAdsRemaining > 0
                                      ? 'Watch 1 Ad (+${wallet.coinsPerAd} AC • ${wallet.dailyCoinAdsRemaining}/${wallet.dailyCoinAdsLimit} left)'
                                      : 'Daily Coin Ads Used (${wallet.dailyCoinAdsLimit}/${wallet.dailyCoinAdsLimit})',
                                  size: AcedexButtonSize.md,
                                  leadingIcon: HugeIcon(
                                    icon: HugeIcons.strokeRoundedPlayCircle,
                                    color: onAccent,
                                    size: 18,
                                  ),
                                  onPressed: wallet.dailyCoinAdsRemaining > 0
                                      ? _watchAdForCoins
                                      : null,
                                ),
                              ],
                            ),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _error!,
                              style: TextStyle(fontSize: 11.5, color: subtext),
                            ),
                          ],

                          const SizedBox(height: 18),

                          // 2. How to Earn Study Guide
                          Text(
                            'HOW TO EARN ACE COINS',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: line),
                            ),
                            child: Text(
                              'Complete Units (+15 AC) • Pass Unit Exams (+25 AC, +10 AC 100%) • Master AI Modules (+30 AC) • Daily Streak (+10 AC)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.45,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 3. Store Catalog
                          Text(
                            'SPEND ACE COINS',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...purchasableItems.map((item) {
                            final canAfford = wallet.balance >= item.cost;
                            final isBusy = _buyingItemKey == item.itemKey;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: line),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.description,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: subtext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (item.owned)
                                    const AcedexBadge(
                                      label: 'Owned',
                                      variant: AcedexBadgeVariant.success,
                                    )
                                  else
                                    AcedexBounceable(
                                      onTap: canAfford && !isBusy
                                          ? () => _buyItem(item)
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: canAfford ? accent : raised,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: canAfford ? accent : line,
                                          ),
                                        ),
                                        child: isBusy
                                            ? AcedexDotsLoader(
                                                color: onAccent,
                                                dotSize: 3,
                                                gap: 1.5,
                                              )
                                            : Text(
                                                '${item.cost} AC',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: canAfford
                                                      ? onAccent
                                                      : subtext,
                                                ),
                                              ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),

                          if (wallet.recentTransactions.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'RECENT ACTIVITY',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...wallet.recentTransactions.take(6).map((tx) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: raised,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(color: line),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        tx.reason,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      tx.isEarn
                                          ? '+${tx.amount} AC'
                                          : '${tx.amount} AC',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: tx.isEarn
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
