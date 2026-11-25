import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../ads/ads.dart';
import '../../network/api_exception.dart';
import '../../theme/app_colors.dart';
import '../../ui/ui.dart';
import '../models/economy_models.dart';
import '../services/economy_service.dart';

enum _LedgerFilter { all, earn, spend }

/// Bank-statement style Ace Coins Wallet with Rewarded Ad top-ups and live transaction ledger.
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
  String? _error;
  _LedgerFilter _filter = _LedgerFilter.all;

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
    final coinsPerAd = _overview?.coinsPerAd ?? 10;
    final result = await AcedexRewardedAdSheet.show(
      context,
      rewardType: AcedexRewardType.bonusCoins,
      adsRepository: widget.adsRepository,
      title: 'Earn +$coinsPerAd Ace Coins',
      subtitle: 'Watch 1 short rewarded ad to add +$coinsPerAd AC to your wallet.',
    );

    if (!mounted || result == null) return;

    final awarded = result.coinsAwarded ?? coinsPerAd;
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

  String _txCategoryLabel(CoinTransactionItem tx) {
    if (!tx.isEarn) {
      if (tx.itemKey == 'unit_assessment') return 'Debit • Assessment';
      return 'Debit • Purchase';
    }
    switch (tx.type) {
      case 'earn_welcome':
        return 'Credit • Welcome';
      case 'earn_ad':
        return 'Credit • Ad Reward';
      case 'earn_milestone':
      default:
        return 'Credit • Study';
    }
  }

  String _formatTxTimestamp(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return 'Posted';
    final local = parsed.toLocal();
    final now = DateTime.now();
    final isToday =
        local.year == now.year && local.month == now.month && local.day == now.day;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final datePart = isToday ? 'Today' : '${months[local.month - 1]} ${local.day}';
    return '$datePart, $hh:$mm';
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
    final canWatchCoinAd = wallet.dailyCoinAdsRemaining > 0;
    final filteredTransactions = wallet.recentTransactions.where((tx) {
      switch (_filter) {
        case _LedgerFilter.earn:
          return tx.isEarn;
        case _LedgerFilter.spend:
          return !tx.isEarn;
        case _LedgerFilter.all:
          return true;
      }
    }).toList();

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
                          'Wallet Statement',
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
                          // 1. Account Balance Hero Card
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
                                            'AVAILABLE BALANCE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.7,
                                              color: subtext,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${wallet.balance} AC',
                                            style: TextStyle(
                                              fontSize: 27,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.6,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'In +${wallet.lifetimeEarned} AC • Out -${wallet.lifetimeSpent} AC',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                              color: subtext,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (wallet.aiPlanPasses > 0) ...[
                                  const SizedBox(height: 10),
                                  AcedexBadge(
                                    label: 'AI Passes: ${wallet.aiPlanPasses}',
                                    variant: AcedexBadgeVariant.success,
                                  ),
                                ],
                                const SizedBox(height: 14),
                                AcedexButton(
                                  label: 'Watch 1 Ad (+${wallet.coinsPerAd} AC)',
                                  size: AcedexButtonSize.md,
                                  leadingIcon: HugeIcon(
                                    icon: HugeIcons.strokeRoundedPlayCircle,
                                    color: canWatchCoinAd ? onAccent : subtext,
                                    size: 18,
                                  ),
                                  onPressed:
                                      canWatchCoinAd ? _watchAdForCoins : null,
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

                          // 2. Bank-Statement Transaction Logs Header + Filters
                          Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedExchange01,
                                color: accent,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'TRANSACTION LOGS',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                    color: accent,
                                  ),
                                ),
                              ),
                              _FilterChip(
                                label: 'All',
                                selected: _filter == _LedgerFilter.all,
                                accent: accent,
                                onAccent: onAccent,
                                raised: raised,
                                line: line,
                                subtext: subtext,
                                onTap: () =>
                                    setState(() => _filter = _LedgerFilter.all),
                              ),
                              const SizedBox(width: 6),
                              _FilterChip(
                                label: 'Earn',
                                selected: _filter == _LedgerFilter.earn,
                                accent: accent,
                                onAccent: onAccent,
                                raised: raised,
                                line: line,
                                subtext: subtext,
                                onTap: () =>
                                    setState(() => _filter = _LedgerFilter.earn),
                              ),
                              const SizedBox(width: 6),
                              _FilterChip(
                                label: 'Spend',
                                selected: _filter == _LedgerFilter.spend,
                                accent: accent,
                                onAccent: onAccent,
                                raised: raised,
                                line: line,
                                subtext: subtext,
                                onTap: () => setState(
                                    () => _filter = _LedgerFilter.spend),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (filteredTransactions.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 24,
                              ),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: line),
                              ),
                              child: Column(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedExchange01,
                                    color: subtext,
                                    size: 26,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _filter == _LedgerFilter.spend
                                        ? 'No spend transactions yet'
                                        : _filter == _LedgerFilter.earn
                                            ? 'No earn transactions yet'
                                            : 'No transactions yet',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'All Ace Coins earned and spent appear in this statement.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: subtext,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: line),
                              ),
                              child: Column(
                                children: List.generate(
                                  filteredTransactions.length,
                                  (index) {
                                    final tx = filteredTransactions[index];
                                    final isEarn = tx.isEarn;
                                    final statusColor = isEarn
                                        ? AppColors.success
                                        : AppColors.error;
                                    final txIcon = isEarn
                                        ? HugeIcons.strokeRoundedArrowDownLeft01
                                        : HugeIcons.strokeRoundedArrowUpRight01;

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(
                                                    alpha: 0.13,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: HugeIcon(
                                                  icon: txIcon,
                                                  color: statusColor,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tx.reason,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: theme.colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      '${_txCategoryLabel(tx)} • ${_formatTxTimestamp(tx.createdAt)}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: subtext,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    isEarn
                                                        ? '+${tx.amount} AC'
                                                        : '-${tx.amount.abs()} AC',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontFeatures: const [
                                                        FontFeature
                                                            .tabularFigures(),
                                                      ],
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Bal: ${tx.balanceAfter} AC',
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFeatures: const [
                                                        FontFeature
                                                            .tabularFigures(),
                                                      ],
                                                      color: subtext,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (index <
                                            filteredTransactions.length - 1)
                                          Divider(
                                            height: 1,
                                            thickness: 0.7,
                                            indent: 64,
                                            endIndent: 14,
                                            color: line,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final Color onAccent;
  final Color raised;
  final Color line;
  final Color subtext;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onAccent,
    required this.raised,
    required this.line,
    required this.subtext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AcedexBounceable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? accent : raised,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? accent : line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? onAccent : subtext,
          ),
        ),
      ),
    );
  }
}
