import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import 'pin_keypad_sheet.dart';

/// Offline Storage & Account Security Card (Apple iOS Grouped Settings)
class StorageSecurityCard extends StatefulWidget {
  final ValueChanged<String> onShowToast;

  const StorageSecurityCard({
    super.key,
    required this.onShowToast,
  });

  @override
  State<StorageSecurityCard> createState() => _StorageSecurityCardState();
}

class _StorageSecurityCardState extends State<StorageSecurityCard> {
  bool _isSyncing = false;
  bool _isSynced = false;
  bool _isPinLockEnabled = true;
  bool _isRemindersEnabled = true;
  Timer? _syncTimer;

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;
    _syncTimer?.cancel();
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 850));
    if (mounted) {
      setState(() {
        _isSyncing = false;
        _isSynced = true;
      });
      widget.onShowToast('Offline study pack synced');

      _syncTimer = Timer(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _isSynced = false);
      });
    }
  }

  void _openPinSheet() {
    PinKeypadSheet.show(
      context,
      onShowToast: widget.onShowToast,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: lineColor),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'STORAGE & SECURITY',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 10),

          // Grouped Settings Container
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lineColor),
            ),
            child: Column(
              children: [
                // Row 1: Offline Study Pack
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accentSoftColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedDownload04,
                          color: accentColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offline Study Pack',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _isSynced
                                  ? '142 MB cached • Synced just now'
                                  : '142 MB cached • Works offline',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AcedexBounceable(
                        onTap: _isSyncing ? null : _handleSync,
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _isSynced
                                ? (isDark
                                    ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
                                    : const Color(0xFFDCFCE7))
                                : accentSoftColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          alignment: Alignment.center,
                          child: _isSyncing
                              ? AcedexDotsLoader(
                                  color: accentColor,
                                  dotSize: 3.5,
                                  gap: 2.5,
                                )
                              : Text(
                                  _isSynced ? 'Synced ✓' : 'Sync',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: _isSynced
                                        ? (isDark
                                            ? const Color(0xFF4ADE80)
                                            : const Color(0xFF16A34A))
                                        : accentColor,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: lineColor),

                // Row 2: 6-Digit PIN & App Lock Toggle
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accentSoftColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedLockPassword,
                          color: accentColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '6-Digit PIN & App Lock',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _isPinLockEnabled
                                  ? 'Enabled • Protects candidate pass'
                                  : 'Disabled • Tap to enable PIN lock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AcedexToggle(
                        value: _isPinLockEnabled,
                        onChanged: (val) {
                          setState(() => _isPinLockEnabled = val);
                          widget.onShowToast(
                            val ? 'App PIN Lock enabled' : 'App PIN Lock disabled',
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: lineColor),

                // Row 3: Change 6-Digit PIN
                AcedexBounceable(
                  onTap: _openPinSheet,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedSecurity,
                            color: subtextColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Change 6-Digit PIN',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          color: subtextColor,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),

                Divider(height: 1, color: lineColor),

                // Row 4: Daily Study Reminders Toggle
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accentSoftColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedNotification01,
                          color: accentColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Study Reminders',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _isRemindersEnabled
                                  ? '07:30 PM • Evening EUEE Review'
                                  : 'Off • Study notifications paused',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AcedexToggle(
                        value: _isRemindersEnabled,
                        onChanged: (val) {
                          setState(() => _isRemindersEnabled = val);
                          widget.onShowToast(
                            val ? 'Daily study reminders on' : 'Daily study reminders off',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
